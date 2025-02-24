# Divine Logic (c) 2019, Sjshovan (LoTekkie)
# Licensed under BSD 3-Clause (see main file or LICENSE)

import os
import sys
from threading import Thread
from os.path import expanduser, splitdrive

# Define base directories
BASE_DIR = os.path.dirname(os.path.realpath(__file__))
HOME_DIR = HOME_PATH = expanduser("~")

# Paths to Skyrim Special Edition logs and settings
SKYRIM_DIR = os.path.join(HOME_DIR, "Documents", "My Games", "Skyrim Special Edition")
LOGDIR = os.path.join(SKYRIM_DIR, "Logs", "Script", "Papyrus.0.log")  # Log file path
INIDIR = os.path.join(SKYRIM_DIR, "Skyrim.ini")  # Skyrim INI file path

# Settings keys for filtering log output
SETTING_ENABLE_FILTERS = 'bEnableFilters'
SETTING_FILTER_CHARS = 'sFilterChars'


class Main:
    """
    The Main class handles reading Skyrim logs, monitoring for changes,
    filtering log output, and responding to user commands.
    """

    def __init__(self):
        """Initialize the log monitoring system."""
        print("Initializing...\r\n")
        self.cache = []  # Stores previous log lines
        self.updating = False  # Tracks if an update is in progress
        self.done_debugging = False  # Stops threads when set to True
        self.filters_enabled = False  # Determines if filtering is active

        self.user_settings = self.fetch_settings()  # Load user settings
        self.set_filter_switch()  # Enable or disable filters

        self.populate_cache()  # Preload log data
        self.report_status()  # Display startup status

    def fetch_settings(self):
        """Reads and parses Skyrim.ini settings for logging preferences."""
        if os.path.exists(INIDIR):
            try:
                with open(INIDIR, 'r', encoding='utf-8') as ini:
                    lines = ini.readlines()
            except:
                print(f"Unable to read {INIDIR}")
                lines = []

            return self.make_settings_dict(lines)
        else:
            print(f"Unable to locate {INIDIR}")
            return {}

    def make_settings_dict(self, lines):
        """
        Converts INI settings into a dictionary for easy access.
        Recognizes boolean and list settings.

        :param lines: List of lines from the INI file.
        :return: Dictionary of parsed settings.
        """
        prefix = ["i", "f", "s", "b"]  # Valid setting prefixes
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
                        valid_value = validation_dict[key](value)
                        settings_dict[key] = valid_value
        return settings_dict

    def make_bool(self, char):
        """Converts Skyrim.ini boolean values to Python booleans."""
        try:
            valid_chars = ['false', 'true', '0', '1']
            return char.lower() in ['true', '1'] if char.lower() in valid_chars else None
        except:
            return None

    def make_list(self, char):
        """Converts a comma-separated string into a list."""
        try:
            return [item.strip() for item in char.split(",") if item.strip()]
        except:
            return None

    def settings_valid(self):
        """Checks if fetched settings are valid."""
        return None not in self.user_settings.values() and self.user_settings != {}

    def get_filters(self):
        """Returns the list of filter characters from settings."""
        return self.user_settings.get(SETTING_FILTER_CHARS, [])

    def filters_allowed(self):
        """Checks if log filtering is enabled in settings."""
        return self.user_settings.get(SETTING_ENABLE_FILTERS, False)

    def report_status(self):
        """Displays log file size and current settings."""
        size_bytes = self.get_log_size()
        size_kilobytes = size_bytes / 1000.0
        size_megabytes = size_kilobytes / 1000.0
        size_gigabytes = size_megabytes / 1024.0

        print(f"Listening @ {LOGDIR}")
        print(f"File size: {size_kilobytes:.2f}KB = {size_megabytes:.2f}MB = {size_gigabytes:.2f}GB")
        print(f"Number of cached lines: {len(self.cache)}")
        print(f"User settings: {self.user_settings if self.settings_valid() else 'not found'}\r\n")

    def get_new_lines(self):
        """Reads new lines from the Papyrus log file."""
        try:
            with open(LOGDIR, 'r', encoding='utf-8') as log_file:
                return log_file.readlines()
        except IOError:
            return []

    def populate_cache(self):
        """Loads existing log data into the cache."""
        self.cache = self.get_new_lines()

    def update_display(self):
        """Displays new log entries while applying filters if enabled."""
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
        """Checks if the log file has been updated."""
        return self.cache != self.get_new_lines()

    def set_filter_switch(self):
        """Enables or disables filtering based on user settings."""
        self.filters_enabled = self.filters_allowed() and self.settings_valid()

    def update_settings(self):
        """Reloads user settings and applies changes."""
        self.user_settings = self.fetch_settings()
        self.set_filter_switch()
        print("Updated settings...")
        print(f"User settings: {self.user_settings}\r\n")

    def settings_need_update(self):
        """Checks if settings have changed since last read."""
        return self.user_settings != self.fetch_settings()

    def get_log_size(self):
        """Returns the size of the log file in bytes."""
        return os.path.getsize(LOGDIR) if os.path.exists(LOGDIR) else 0

    def handle_display(self):
        """Continuously monitors the log file for updates."""
        while not self.done_debugging:
            if self.display_needs_update():
                self.update_display()

    def handle_settings(self):
        """Monitors and reloads settings if they change."""
        while not self.done_debugging:
            if self.settings_need_update():
                self.update_settings()

    def exit(self):
        """Stops all background threads and exits the script."""
        self.done_debugging = True
        sys.exit(0)

    def handle_input(self):
        """Processes user input for quitting or help commands."""
        try:
            while not self.done_debugging:
                command = input(">>").lower()
                if command in ['q', 'qq', 'quit', 'exit', '/exit', 'done', '/q']:
                    self.exit()
                elif command in ['help', '/help', '/h', '/commands']:
                    print("Not yet implemented")
        except:
            self.exit()

    def start_debug(self):
        """Starts the main debugging and monitoring threads."""
        try:
            Thread(target=self.handle_display).start()
            Thread(target=self.handle_settings).start()
            Thread(target=self.handle_input).start()
        except:
            self.exit()


if __name__ == '__main__':
    main = Main()
    main.start_debug()
