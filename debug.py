import os
import sys
from threading import Thread
from os.path import expanduser, splitdrive

BASE_DIR = os.path.dirname(os.path.realpath(__file__))
HOME_DIR = HOME_PATH = expanduser("~")
SKYRIM_DIR = os.path.join(HOME_DIR, "Documents\My Games\Skyrim Special Edition")
LOGDIR = os.path.join(SKYRIM_DIR, "Logs\Script\Papyrus.0.log")
INIDIR = os.path.join(SKYRIM_DIR, "Skyrim.ini")

SETTING_ENABLE_FILTERS = 'bEnableFilters'
SETTING_FILTER_CHARS = 'sFilterChars'

class Main():
    def __init__(self):
        print("initializing...\r\n")
        self.cache = []
        self.updating = False
        self.done_debugging = False
        self.filters_enabled = False

        self.user_settings = self.fetch_settings()
        self.set_filter_switch()

        self.populate_cache()
        self.report_status()

    def fetch_settings(self):
        if os.path.exists(INIDIR):
            try:
                with open(INIDIR, 'r', encoding='utf-8') as ini:
                    lines = ini.readlines()
            except:
                print("unable to read {0}".format(INIDIR))
                lines = []

            return self.make_settings_dict(lines)
        else:
            print("unable to locate {0}".format(INIDIR))
            return {}

    def make_settings_dict(self, lines):
        prefix = ["i", "f", "s", "b"]
        settings_dict = {}
        validation_dict = {
            SETTING_ENABLE_FILTERS: lambda x: self.make_bool(x),
            SETTING_FILTER_CHARS: lambda x: self.make_list(x)
        }
        for line in lines:
            if line and line[0] in prefix:
                split_line = line.split("=")
                if len(split_line) == 2:
                    key = split_line[0].strip()
                    value = split_line[1].strip()
                    if key in validation_dict:
                        settings_dict[key] = value
        return settings_dict

    def make_bool(self, char):
        try:
            valid_chars = ['false', 'true', '0', '1']
            if char.lower() in valid_chars:
                return char.lower() in ['true', '1']
            return None
        except:
            return None

    def make_list(self, char):
        try:
            return [item.strip() for item in char.split(",") if item.strip()]
        except:
            return None

    def settings_valid(self):
        return None not in self.user_settings.values() and self.user_settings != {}

    def get_filters(self):
        return self.user_settings.get('sFilterChars', [])

    def filters_allowed(self):
        return self.user_settings.get('bEnableFilters', False)

    def report_status(self):
        size_bytes = self.get_log_size()
        size_kilobytes = size_bytes / 1000.0
        size_megabytes = size_kilobytes / 1000.0
        size_gigabytes = size_megabytes / 1024.0
        print(f"listening @ {LOGDIR}")
        print(f"file size: {size_kilobytes:.2f}KB = {size_megabytes:.2f}MBs = {size_gigabytes:.2f}GBs")
        print(f"number of cache: {len(self.cache)}")
        print(f"user settings: {self.user_settings if self.settings_valid() else 'not found'}\r\n")

    def get_new_lines(self):
        try:
            with open(LOGDIR, 'r', encoding='utf-8') as log_file:
                return log_file.readlines()
        except IOError:
            return []

    def populate_cache(self):
        self.cache = self.get_new_lines()

    def display_cache(self):
        for line in self.cache:
            print(line)

    def update_display(self):
        new_lines = list(set(self.get_new_lines()) - set(self.cache))
        if not self.filters_enabled:
            for line in new_lines:
                print(line)
                self.cache.append(line)
        else:
            for line in new_lines:
                if any(filter in line for filter in self.get_filters()):
                    print(line)
                    self.cache.append(line)

    def display_needs_update(self):
        return self.cache != self.get_new_lines()

    def set_filter_switch(self):
        self.filters_enabled = self.filters_allowed() and self.settings_valid()

    def update_settings(self):
        self.user_settings = self.fetch_settings()
        self.set_filter_switch()

        print("updated settings...")
        print(f"user settings: {self.user_settings}\r\n")

    def settings_need_update(self):
        return self.user_settings != self.fetch_settings()

    def get_log_size(self):
        return os.path.getsize(LOGDIR) if os.path.exists(LOGDIR) else 0

    def handle_display(self):
        while not self.done_debugging:
            if self.display_needs_update():
                self.update_display()

    def handle_settings(self):
        while not self.done_debugging:
            if self.settings_need_update():
                self.update_settings()

    def exit(self):
        self.done_debugging = True
        sys.exit(0)

    def handle_input(self):
        try:
            while not self.done_debugging:
                command = input(">>").lower()
                if command in ['q', 'qq', 'quit', 'exit', '/exit', 'done', '/q']:
                    self.exit()
                elif command in ['help', '/help', '/h', '/commands']:
                    print("not yet implemented")
        except:
            self.exit()

    def start_debug(self):
        try:
            self.handler_1 = Thread(target=self.handle_display)
            self.handler_2 = Thread(target=self.handle_settings)
            self.handler_3 = Thread(target=self.handle_input)

            self.handler_1.start()
            self.handler_2.start()
            self.handler_3.start()

        except:
            self.exit()

if __name__ == '__main__':
    main = Main()
    main.start_debug()