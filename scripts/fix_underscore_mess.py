import os
import sys

def fix_underscore_mess(name):
    # Check if the name matches the pattern _C_h_a_r_
    # It should start with _, end with _, and have _ at every even index
    if len(name) < 3:
        return name
    
    if name.startswith('_') and name.endswith('_'):
        # Check if every second character is an underscore
        is_mess = True
        for i in range(0, len(name), 2):
            if name[i] != '_':
                is_mess = False
                break
        
        if is_mess:
            # Reconstruct the name by taking every character at odd indices
            reconstructed = ""
            for i in range(1, len(name), 2):
                reconstructed += name[i]
            return reconstructed
            
    return name

def rename_recursive(root_path):
    for root, dirs, files in os.walk(root_path, topdown=False):
        for name in files:
            fixed = fix_underscore_mess(name)
            if fixed != name:
                old_path = os.path.join(root, name)
                new_path = os.path.join(root, fixed)
                if not os.path.exists(new_path):
                    try:
                        os.rename(old_path, new_path)
                        print(f"Fixed file: {name} -> {fixed}")
                    except Exception as e:
                        print(f"Error fixing file {old_path}: {e}")

        for name in dirs:
            fixed = fix_underscore_mess(name)
            if fixed != name:
                old_path = os.path.join(root, name)
                new_path = os.path.join(root, fixed)
                if not os.path.exists(new_path):
                    try:
                        os.rename(old_path, new_path)
                        print(f"Fixed dir: {name} -> {fixed}")
                    except Exception as e:
                        print(f"Error fixing dir {old_path}: {e}")

if __name__ == "__main__":
    target_dir = "/mnt/storage/music/ingest"
    if len(sys.argv) > 1:
        target_dir = sys.argv[1]
    
    print(f"Fixing underscore mess in {target_dir}...")
    rename_recursive(target_dir)
    print("Fix complete.")
