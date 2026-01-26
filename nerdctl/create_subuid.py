#!/usr/bin/env python3
# this will create entries in /etc/subuid and /etc/subgid for users to allow rootless for nerdctl

import pwd
import sys

def calculate_subid_range(username,
                          range_size=65536, base_offset=100000):
    try:
        # Get user info
        user_info = pwd.getpwnam(username)
        uid = user_info.pw_uid
        uid_base = 1000
        
        # Standard calculation logic
        # Usually, we start mapping for UIDs uid_base and above
        if uid < uid_base:
            return f"# Skip system user: {username} (UID {uid})"

        start_range = base_offset + ((uid - uid_base) * range_size)
        
        return f"{username}:{start_range}:{range_size}"
    
    except KeyError:
        return f"# Error: User '{username}' not found."

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 generate_subids.py <username1> <username2> ...")
        sys.exit(1)

    for user in sys.argv[1:]:
        print(calculate_subid_range(user))
