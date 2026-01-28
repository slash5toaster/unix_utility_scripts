#!/usr/bin/env python3
# this will create entries in /etc/subuid and /etc/subgid for users to allow rootless for nerdctl

import pwd
import sys
import os

def calculate_subid_range(username,
                          range_size=65536, 
                          base_offset=100000):
    try:
        # Get user info
        user_info = pwd.getpwnam(username)
        uid = user_info.pw_uid
        uid_base = 1000
        
        # Standard calculation logic
        # Usually, we start mapping for UIDs uid_base and above
        if uid < uid_base:
            return False
            print(f"# Skip system user: {username} (UID {uid})",file=sys.stderr)

        start_range = base_offset + ((uid - uid_base) * range_size)
        subuid_string = str(uid) + ":" + str(start_range) + ":" +  str(range_size)

        return f"{subuid_string}"
    
    except KeyError:
        return False
        print("# Error: User '{username}' not found.",file=sys.stderr)

# ====================================================
import os

def append_to_control_file(file_path,
                           approval_string):
    """
    Appends new approval string to file
    """
    found = False
    
    # Check if file exists before trying to read it
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as file:
            for line in file:
                # .rstrip('\n') ensures we compare the content, not the formatting
                if line.rstrip('\n') == approval_string:
                    found = True
                    break
    
    if found:
        print(f"Skipped: Exact match for '{approval_string}' already exists.",file=sys.stderr)
        return False
    else:
        # Open in append mode ('a'). This creates the file if it doesn't exist.
        with open(file_path, 'a', encoding='utf-8') as file:
            # Add a newline to the text to ensure the next entry is on a new line
            file.write(approval_string + '\n')
            print(f"Success: '{approval_string}' added to the {file_path}.",file=sys.stderr)
            return True

# ====================================================
if __name__ == "__main__":
    subgid_file = "/tmp/subgid"
    subuid_file = "/tmp/subuid"

    if len(sys.argv) < 2:
        print("Usage: python3 generate_subids.py <username1> <username2> ...")
        sys.exit(1)

    for user in sys.argv[1:]:
        if calculate_subid_range(user):
            append_to_control_file(subuid_file,calculate_subid_range(user))
            append_to_control_file(subgid_file,calculate_subid_range(user))