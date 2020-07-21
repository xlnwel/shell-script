#!/usr/bin/env python3

# Transfer dirs/files from the remote
# To make it work, add the following command to iTerm2's Profile/Advanced/Triggers
# "rtransfer (.*) (.*)" "Run command..." "location/to/t2 \1 \2" 
# This will invoke t2 from the local machine
# Do not select "Use interpolated strings for parameters"
import argparse
import fileinput
import os
import time
import socket
import sys
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument('files', nargs='*')
args = parser.parse_args()

if args.files:
    files = args.files
else:
    files = []
    for line in fileinput.input():
        files.append(line.strip())

tmp_dir = tempfile.mkdtemp()
for f in files:
    if not os.path.exists(f):
        print(f"Error: path '{f}' does not exist", file=sys.stderr)
        exit(1)
    f = os.path.realpath(f)
    if os.path.isabs(f):
        target = os.path.join(tmp_dir, os.path.basename(f))
    else:
        target = os.path.join(tmp_dir, f)
        os.makedirs(os.path.dirname(target), exist_ok=True)
    os.symlink(os.path.abspath(f), target)
    print(f'A symlink of "{target}" to "{os.path.abspath(f)}" is created')

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # doesn't even have to be reachable
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

com = 'r' 'transfer'
print(f"{com} {get_ip()} {tmp_dir}")

time.sleep(1)
# clear window to avoid repetitively triggering
os.system('clear')
