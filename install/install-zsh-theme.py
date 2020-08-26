#!/usr/bin/python3

from distutils.dir_util import copy_tree
import utils
import argparse
import subprocess
import shutil
import enum
import sys
import os

###################### Application ######################

class Theme(enum.Enum):
    default = "default"
    p10k_lean = "p10klean"
    p10k_classic = "p10kclassic"
    p10k_rainbow = "p10krainbow"
    lazymechanic = "lazymechanic"

    def __str__(self):
        return self.value

class Config:
    DEFAULT_THEME = "robbyrussell"
    DST_DIR = os.path.expanduser("~")
    ZSH_DIR = os.path.join(os.path.dirname(os.path.realpath(__file__)), "zsh")

    def __init__(self):
        self.theme = ""
        self.final_theme = ""
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
            answ = utils.query_yes_no("Powerlevel10k directory already exists, delete dir and clone repo?", "yes")
            if answ:
                utils.info("Remove Powerlevel10k directory...")
                shutil.rmtree(p10k_dir)
                utils.ok("Done")
            else:
                utils.ok("Do nothing")
                return
        
        utils.info("Clone Powerlevel10k repo...")

        exit_code = utils.exec_and_print(f"git clone --depth=1 https://github.com/romkatv/powerlevel10k.git {p10k_dir}")
        if exit_code != 0:
            raise Exception("git clone of 'https://github.com/romkatv/powerlevel10k.git' repo failed, try install manually")
        
        utils.ok("Done")

    def _copy_exists(self):
        utils.info("Backup existing files...")
        utils.copy_file_if_exists(os.path.join(Config.DST_DIR, ".p10k.zsh"), os.path.join(Config.DST_DIR, ".p10k.zsh.back"))
        utils.copy_file_if_exists(os.path.join(Config.DST_DIR, ".zshrc"), os.path.join(Config.DST_DIR, ".zshrc.back"))
        utils.copy_file_if_exists(os.path.join(Config.DST_DIR, ".zshenv"), os.path.join(Config.DST_DIR, ".zshenv.back"))
        utils.copy_file_if_exists(os.path.join(Config.DST_DIR, ".zshalias"), os.path.join(Config.DST_DIR, ".zshalias.back"))
        utils.ok("Done")

    def _install_theme_conf(self):
        utils.info("Install theme files...")

        if self.config.theme == Theme.default:
            self.config.final_theme = Config.DEFAULT_THEME

        elif self.config.theme == Theme.lazymechanic:
            dst_dir = os.path.join(self.config.zsh_custom, "themes", "lazymechanic")
            src_dir = os.path.join(Config.ZSH_DIR, "lazymechanic")
            copy_tree(src_dir, dst_dir)
            self.config.final_theme = "lazymechanic/lazymechanic"

        elif self.config.theme == Theme.p10k_lean:
            shutil.copy(
                os.path.join(self.config.ZSH_DIR, ".p10k.zsh.lean"),
                os.path.join(self.config.DST_DIR, ".p10k.zsh")
            )
            self.config.final_theme = "powerlevel10k/powerlevel10k"

        elif self.config.theme == Theme.p10k_classic:
            shutil.copy(
                os.path.join(self.config.ZSH_DIR, ".p10k.zsh.classic"),
                os.path.join(self.config.DST_DIR, ".p10k.zsh")
            )
            self.config.final_theme = "powerlevel10k/powerlevel10k"

        elif self.config.theme == Theme.p10k_rainbow:
            shutil.copy(
                os.path.join(self.config.ZSH_DIR, ".p10k.zsh.rainbow"),
                os.path.join(self.config.DST_DIR, ".p10k.zsh")
            )
            self.config.final_theme = "powerlevel10k/powerlevel10k"

        else:
            raise Exception("theme '%s' not found" % self.config.theme)
            
        utils.ok("Done")

    def _install_zsh_conf(self):
        utils.info("Install zsh config files...")
        utils.copy_file_if_exists(os.path.join(Config.ZSH_DIR, ".zshrc"), os.path.join(Config.DST_DIR, ".zshrc"))
        utils.copy_file_if_exists(os.path.join(Config.ZSH_DIR, ".zshenv"), os.path.join(Config.DST_DIR, ".zshenv"))
        utils.copy_file_if_exists(os.path.join(Config.ZSH_DIR, ".zshalias"), os.path.join(Config.DST_DIR, ".zshalias"))
        utils.ok("Done")

    def _install_zsh_plugins(self):
        utils.info("Install zsh plugins...")

        plugins_dir = os.path.join(self.config.zsh_custom, "plugins")
        plugins = [
            ("https://github.com/zsh-users/zsh-autosuggestions", "zsh-autosuggestions"),
        ]

        for plugin_git, plugin_name in plugins:
            dir = os.path.join(plugins_dir, plugin_name)

            if os.path.exists(dir):
            answ = utils.query_yes_no(f"{plugin_name} already installed, delete dir and clone repo?", "yes")
            if answ:
                utils.info(f"Remove {dir} directory...")
                shutil.rmtree(dir)
                utils.ok("Done")
            else:
                utils.ok("Do nothing")
                continue
        
            utils.info(f"Clone {plugin_name} repo...")

            exit_code = utils.exec_and_print(f"git clone {plugin_git} {dir}")
            if exit_code != 0:
                raise Exception(f"git clone of '{plugin_git}' repo failed, try install manually")

            utils.ok("Done")

        utils.ok("Plugins installed successfully")

    def _setup_theme(self):
        utils.info("Setup zsh theme...")

        zshrc_file_path = os.path.join(Config.DST_DIR, ".zshrc")

        # If .zshrc file not found
        if not os.path.isfile(zshrc_file_path):
            raise Exception("file '%s' not found" % zshrc_file_path)

        utils.sed(
            r'ZSH_THEME=\"[a-zA-Z0-9\/]*\"', 
            r'ZSH_THEME="%s"' % self.config.final_theme, 
            zshrc_file_path
        )
        
        utils.ok("Done")

    def _check_tools(self):
        if not utils.has_tool("git"):
            raise Exception("'git' is not installed")

    def run(self):
        self._check_tools()
        self._copy_exists()

        utils.info(f"Installation theme is '{self.config.theme}'")
        
        self._install_p10k()
        self._install_theme_conf()
        self._install_zsh_conf()
        self._install_zsh_plugins()
        self._setup_theme()
        
        return 0

def main():
    try:
        app = App()
        return app.run()
    except Exception as err:
        utils.error(err)
    except KeyboardInterrupt:
        utils.warning("Process aborted by keyboard interrupt")

    return 1

if __name__ == "__main__":
    code = main()
    sys.exit(code)