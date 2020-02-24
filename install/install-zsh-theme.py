#!/usr/bin/python

import argparse
import subprocess
import shutil
import enum
import sys
import os

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
    print(f"{bcolors.FAIL}[ ERROR ]{bcolors.ENDC}: {msg}")

def warning(msg):
    print(f"{bcolors.WARNING}[WARNING]{bcolors.ENDC}: {msg}")

def info(msg):
    print(f"{bcolors.OKBLUE}[ INFO  ]{bcolors.ENDC}: {msg}")

def ok(msg):
    print(f"{bcolors.OKGREEN}[  OK   ]{bcolors.ENDC}: {msg}")

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

###################### Application ######################

class Theme(enum.Enum):
    default = 'default'
    p10k_lean = 'p10k_lean'
    p10k_classic = 'p10k_classic'
    p10k_rainbow = 'p10k_rainbow'
    lazymechanic = 'lazymechanic'

    def __str__(self):
        return self.value

class Config:
    def __init__(self):
        self.theme = ""
        self.zsh_custom = ""

    def __repr__(self):
        return str(self)

    def __str__(self):
        return "<Config: " + ", ".join(["{key}={value}".format(key=key, value=self.__dict__.get(key)) for key in self.__dict__]) + ">"

class App:
    def __init__(self):
        self.parser = argparse.ArgumentParser(description="Installer zsh theme")
        self.config = self._read_cli()


    def _read_cli(self):
        # CLI setting up
        self.parser.add_argument("theme", type=Theme, choices=list(Theme), default=["default"], nargs=1, help="Zsh theme name")
        self.parser.add_argument("-c", "--zsh-custom", default=["~/.oh-my-zsh/custom"], nargs=1, help="Zsh custom path")
        args = self.parser.parse_args()

        if args.theme == None:
            raise Exception("Theme not found")

        config = Config()
        config.theme = args.theme[0]
        config.zsh_custom = args.zsh_custom[0]
        config.zsh_custom = config.zsh_custom.replace("~", os.path.expanduser("~"))

        return config


    def _install_p10k(self):
        p10k_dir = os.path.join(self.config.zsh_custom, "themes", "powerlevel10k")
        if os.path.exists(p10k_dir):
            answ = query_yes_no("Powerlevel10k directory already exists, delete dir and clone repo?", "yes")
            if answ:
                info("Remove Powerlevel10k directory...")
                shutil.rmtree(p10k_dir)
                ok("Done!")
            else:
                info("Do nothing")
                return
        
        info("Clone Powerlevel10k repo...")

        exit_code = exec_and_print(f"git clone --depth=1 https://github.com/romkatv/powerlevel10k.git {p10k_dir}")
        if exit_code != 0:
            raise Exception("git clone of 'https://github.com/romkatv/powerlevel10k.git' repo failed, try install manually")
        
        ok("Done!")

    def _install_p10k_theme(self, filename):
        None

    def _install_custom_theme(self, name):
        None

    def _install_default_theme(self, name):
        None

    def run(self):
        if not has_tool("git"):
            raise Exception("'git' is not installed")
        
        info("pre install p10k")
        self._install_p10k()
        

def main():
    try:
        app = App()
        return app.run()
    except Exception as err:
        error(err)
    except KeyboardInterrupt:
        warning("Process aborted by keyboard interrupt")

    return 1

if __name__ == "__main__":
    main()