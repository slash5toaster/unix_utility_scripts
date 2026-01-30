#!/usr/bin/env python3
# this will create entries in /etc/subuid and /etc/subgid for users to allow rootless for nerdctl

import pwd
import sys
import os

def calculate_subid_range(subuid_file,
                          username,
                          range_size=65536, 
                          base_offset=100000):
    """
    calculate_subid_range: calculate the sub{u,g}id range value
       for entry into the file
    :param subuid_file: Path to subuid file
    :param username: username to calculate
    :param range_size: range size for calculation
    :param base_offset: minimum value for subuid range start
    """
    try:
        # Get user info
        user_info = pwd.getpwnam(username)
        uid = user_info.pw_uid
        uid_base = 1000

        # Standard calculation logic
        # Usually, we start mapping for UIDs uid_base and above
        # to keep in the max subuid range, use the line nubmer to calculate the range
        # going from uid overruns the the usable range of 2^32-1 (4,294,967,295)

        if uid < uid_base:
            return False
            print(f"# Skip system user: {username} (UID {uid})",file=sys.stderr)

        # get the number of lines from /etc/subuid
        if os.path.exists(subuid_file):
            with open(subuid_file,'r',encoding="utf-8") as file:
                subuid_lines = len(file.readlines()) + 1 

        start_range = base_offset + (subuid_lines * range_size)
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
    real_uid =  approval_string.split(':')[0]
    # Check if file exists before trying to read it, 
    # if the user already exists, then skip
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as file:
            for line in file:
                if line.split(':')[0] == real_uid:
                    found = True
                    break
    
    if found:
        # print(f"Skipped: Exact match for '{real_uid}' already exists.",file=sys.stderr)
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
        print("Usage: python3 create_subuid.py <username1> <username2> ...")
        sys.exit(1)

    for user in sys.argv[1:]:
        range_value = calculate_subid_range(subuid_file,username=user)
        print(f"For {user}, range is {range_value}",file=sys.stderr)
        
        if range_value != False:
            append_to_control_file(subuid_file,
                                   str(range_value))
            append_to_control_file(subgid_file,
                                   str(range_value))
        else:
            print(f"Not adding {user} to {subgid_file} and {subuid_file}",file=sys.stderr)