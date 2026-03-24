import sqlite3
from datetime import datetime

db_path = 'arm_db/arm.db'
conn = sqlite3.connect(db_path)
c = conn.cursor()

# Query the last 20 jobs
c.execute("""
    SELECT job_id, title, start_time, stop_time, job_length, status, disctype
    FROM job
    ORDER BY start_time DESC
    LIMIT 20
""")

jobs = c.fetchall()

print(f"{'ID':<5} {'Title':<30} {'Start':<20} {'Length':<10} {'Status':<10} {'Type'}")
print("-" * 90)
for job in jobs:
    jid, title, start, stop, length, status, dtype = job
    print(f"{jid:<5} {str(title)[:30]:<30} {start:<20} {str(length):<10} {status:<10} {dtype}")

conn.close()
