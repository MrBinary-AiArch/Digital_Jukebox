#!/usr/bin/env python3
# ARM Timeout Monitor Script
# Kills active rip jobs that exceed a specified duration.
# This script runs on the HOST and interacts with the 'arm' Docker container.

import subprocess
import json
import datetime
import sys
import os

# Configuration
CONTAINER_NAME = "arm"
DEFAULT_TIMEOUT_MINUTES = 30  # Default to 30 minutes
DB_PATH_INSIDE = "/home/arm/db/arm.db"

def log(message):
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}")

def run_docker_python(py_code):
    """Executes python code inside the ARM container and returns output."""
    cmd = ["docker", "exec", CONTAINER_NAME, "python3", "-c", py_code]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        return None, result.stderr
    return result.stdout.strip(), None

def get_active_jobs():
    """Queries the ARM database for active jobs."""
    py_code = f"""
import sqlite3, json
try:
    conn = sqlite3.connect('{DB_PATH_INSIDE}')
    cursor = conn.cursor()
    cursor.execute("SELECT job_id, start_time, pid, title FROM job WHERE status='active'")
    jobs = [dict(zip(['job_id', 'start_time', 'pid', 'title'], row)) for row in cursor.fetchall()]
    print(json.dumps(jobs))
    conn.close()
except Exception as e:
    print(f"ERROR: {{e}}")
"""
    output, error = run_docker_python(py_code)
    if error or not output or output.startswith("ERROR"):
        log(f"Failed to query database: {error or output}")
        return []
    try:
        return json.loads(output)
    except json.JSONDecodeError:
        log(f"Failed to parse JSON output: {output}")
        return []

def kill_job(job_id, pid):
    """Kills the job process inside the container and updates the database."""
    # 1. Kill the process
    if pid:
        log(f"Killing process {pid} for Job {job_id}...")
        subprocess.run(["docker", "exec", CONTAINER_NAME, "kill", "-9", str(pid)])
    
    # 2. Update DB status
    py_code = f"""
import sqlite3
conn = sqlite3.connect('{DB_PATH_INSIDE}')
cursor = conn.cursor()
cursor.execute("UPDATE job SET status='fail', errors='Job timed out automatically' WHERE job_id={job_id}")
conn.commit()
conn.close()
"""
    run_docker_python(py_code)
    log(f"Job {job_id} marked as failed in database.")

def eject_drive():
    """Ejects the drive from the host."""
    log("Ejecting /dev/sr0...")
    subprocess.run(["eject", "/dev/sr0"])

def main():
    timeout_minutes = int(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_TIMEOUT_MINUTES
    log(f"Checking for jobs active for more than {timeout_minutes} minutes...")
    
    jobs = get_active_jobs()
    if not jobs:
        log("No active jobs found.")
        return

    current_time = datetime.datetime.utcnow()
    found_timeout = False

    for job in jobs:
        try:
            # Parse ARM start time (UTC)
            start_time = datetime.datetime.strptime(job['start_time'], "%Y-%m-%d %H:%M:%S.%f")
        except ValueError:
            try:
                start_time = datetime.datetime.strptime(job['start_time'], "%Y-%m-%d %H:%M:%S")
            except ValueError:
                log(f"Could not parse start_time for Job {job['job_id']}: {job['start_time']}")
                continue

        elapsed = (current_time - start_time).total_seconds() / 60
        
        if elapsed > timeout_minutes:
            log(f"TIMEOUT: Job {job['job_id']} ('{job['title']}') has been running for {elapsed:.1f} minutes.")
            kill_job(job['job_id'], job['pid'])
            found_timeout = True
        else:
            log(f"Job {job['job_id']} ('{job['title']}') is within limits ({elapsed:.1f} min).")

    if found_timeout:
        eject_drive()

if __name__ == "__main__":
    main()
