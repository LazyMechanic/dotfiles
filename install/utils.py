import subprocess
import fileinput
import argparse
import shutil
import sys
import os
import re

###################### Helpers ######################

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def error(msg):
    print(f"{bcolors.FAIL}[ERRO]{bcolors.ENDC}: {msg}")

def warning(msg):
    print(f"{bcolors.WARNING}[WARN]{bcolors.ENDC}: {msg}")

def info(msg):
    print(f"{bcolors.OKBLUE}[INFO]{bcolors.ENDC}: {msg}")

def ok(msg):
    print(f"{bcolors.OKGREEN}[ OK ]{bcolors.ENDC}: {msg}")

def str_to_bool(v):
    if isinstance(v, bool):
       return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

def has_tool(name):
    """Check whether `name` is on PATH and marked as executable."""

    # from whichcraft import which
    from shutil import which
    return which(name) is not None

def query_yes_no(question, default="yes"):
    """Ask a yes/no question via raw_input() and return their answer.

    "question" is a string that is presented to the user.
    "default" is the presumed answer if the user just hits <Enter>.
        It must be "yes" (the default), "no" or None (meaning
        an answer is required of the user).

    The "answer" return value is True for "yes" or False for "no".
    """
    valid = {"yes": True, "y": True, "ye": True,
             "no": False, "n": False}
    if default is None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)

    while True:
        sys.stdout.write(question + prompt)
        choice = input().lower()
        if default is not None and choice == '':
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' "
                             "(or 'y' or 'n').\n")

def exec_and_print(cmd):
    return subprocess.run(cmd, 
            shell=True, 
            stdout=sys.stdout,
            stderr=sys.stderr,
            encoding="utf-8").returncode

def exec(cmd):
    process = subprocess.run(cmd, 
            shell=True, 
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            encoding="utf-8")

    return process.stdout, process.stderr, process.returncode

def copy_mkdir(src_file, dst_file):
    dst_dir = os.path.dirname(dst_file)
    os.makedirs(dst_dir, exist_ok=True)
    shutil.copy(src_file, dst_file)

def sed(src_re, dst_re, file):
    for line in fileinput.input(file, inplace=True):
        warn("before: %s" % line)
        line = re.sub(
            src_re,
            dst_re,
            line
        )
        warn("after: %s" % line)

def copy_file_if_exists(src_file, dst_file):
    if os.path.isfile(src_file):
        info(f"Copy '{src_file}' -> '{dst_file}'")
        shutil.copy(src_file, dst_file)
