# Divine Logic (c) 2019, Sjshovan (LoTekkie)
# Licensed under BSD 3-Clause (see main file or LICENSE)

from __future__ import annotations

import argparse
import re
import sys
from collections import Counter
from datetime import datetime
from pathlib import Path
from threading import Event, Thread


SKYRIM_DIR = Path.home() / "Documents" / "My Games" / "Skyrim Special Edition"
LOG_PATH = SKYRIM_DIR / "Logs" / "Script" / "Papyrus.0.log"
PROFILE_DIR = SKYRIM_DIR / "Logs" / "Script" / "Profiling"
TRANSLATOR_PROFILE_PATH = PROFILE_DIR / "Script_DivineTranslator.0.log"
INI_PATH = SKYRIM_DIR / "Skyrim.ini"

SETTING_ENABLE_FILTERS = "bEnableFilters"
SETTING_FILTER_CHARS = "sFilterChars"

DEFAULT_POLL_SECONDS = 0.25
EXIT_COMMANDS = {"q", "qq", "quit", "exit", "/exit", "done", "/q"}
HELP_COMMANDS = {"help", "/help", "/h", "/commands"}

TIMESTAMP_RE = re.compile(r"^\[(?P<ts>\d{2}/\d{2}/\d{4} - \d{2}:\d{2}:\d{2}[AP]M)\]")
SIGNAL_RE = re.compile(r"fireSignalEvent \| fired signal from: \[(?P<script>\w+) < \((?P<ref>[0-9A-F]+)\)>\]")
PROFILE_RE = re.compile(
    r"^(?P<tick>\d+):(?P<kind>QUEUE_PUSH|PUSH|POP):(?P<stack>\d+):(?P<depth>\d+):"
    r"\s+\((?P<ref>[^)]+)\):(?P<script>[^.]+)\.\.?(?P<fn>.*)$"
)


class PapyrusLogTailer:
    def __init__(
        self,
        log_path: Path = LOG_PATH,
        ini_path: Path = INI_PATH,
        poll_seconds: float = DEFAULT_POLL_SECONDS,
        from_start: bool = False,
    ) -> None:
        self.log_path = log_path
        self.ini_path = ini_path
        self.poll_seconds = poll_seconds
        self.from_start = from_start
        self.stop_event = Event()
        self.position = 0
        self.ini_mtime = 0.0
        self.settings: dict[str, object] = {}
        self.filters_enabled = False

    def start(self) -> None:
        self.reload_settings(force=True)
        self.position = 0 if self.from_start else self.current_log_size()
        self.report_status()

        command_thread = Thread(target=self.handle_input, daemon=True)
        command_thread.start()

        try:
            while not self.stop_event.is_set():
                self.reload_settings()
                self.print_new_log_lines()
                self.stop_event.wait(self.poll_seconds)
        except KeyboardInterrupt:
            self.stop()
        finally:
            print("\nStopped Papyrus log watcher.")

    def stop(self) -> None:
        self.stop_event.set()

    def report_status(self) -> None:
        size_bytes = self.current_log_size()
        print("Initializing...")
        print(f"Listening @ {self.log_path}")
        print(f"Skyrim.ini @ {self.ini_path}")
        print(f"File size: {size_bytes / 1000.0:.2f}KB")
        print(f"Filters: {self.describe_filters()}")
        print("Commands: q/quit/exit, status, filters, help")
        print()

    def current_log_size(self) -> int:
        try:
            return self.log_path.stat().st_size
        except FileNotFoundError:
            return 0

    def print_new_log_lines(self) -> None:
        try:
            size = self.log_path.stat().st_size
        except FileNotFoundError:
            return

        if size < self.position:
            self.position = 0

        if size == self.position:
            return

        try:
            with self.log_path.open("r", encoding="utf-8", errors="replace") as log_file:
                log_file.seek(self.position)
                lines = log_file.readlines()
                self.position = log_file.tell()
        except OSError as error:
            print(f"Unable to read {self.log_path}: {error}")
            return

        for line in lines:
            if self.should_print(line):
                print(line, end="")

    def should_print(self, line: str) -> bool:
        if not self.filters_enabled:
            return True
        filters = self.get_filters()
        return bool(filters) and any(token in line for token in filters)

    def reload_settings(self, force: bool = False) -> None:
        try:
            mtime = self.ini_path.stat().st_mtime
        except FileNotFoundError:
            if force or self.settings:
                self.settings = {}
                self.ini_mtime = 0.0
                self.filters_enabled = False
                print(f"Unable to locate {self.ini_path}")
            return

        if not force and mtime == self.ini_mtime:
            return

        self.ini_mtime = mtime
        self.settings = self.fetch_settings()
        self.filters_enabled = self.filters_allowed() and self.settings_valid()

        if not force:
            print(f"\nUpdated settings. Filters: {self.describe_filters()}")

    def fetch_settings(self) -> dict[str, object]:
        settings: dict[str, object] = {}
        try:
            lines = self.ini_path.read_text(encoding="utf-8", errors="replace").splitlines()
        except OSError as error:
            print(f"Unable to read {self.ini_path}: {error}")
            return settings

        for line in lines:
            stripped = line.strip()
            if not stripped or stripped.startswith(("#", ";")) or "=" not in stripped:
                continue

            key, value = [part.strip() for part in stripped.split("=", 1)]
            if key == SETTING_ENABLE_FILTERS:
                parsed_bool = self.parse_bool(value)
                if parsed_bool is not None:
                    settings[key] = parsed_bool
            elif key == SETTING_FILTER_CHARS:
                settings[key] = self.parse_filter_list(value)

        return settings

    @staticmethod
    def parse_bool(value: str) -> bool | None:
        normalized = value.strip().lower()
        if normalized in {"true", "1"}:
            return True
        if normalized in {"false", "0"}:
            return False
        return None

    @staticmethod
    def parse_filter_list(value: str) -> list[str]:
        return [item.strip() for item in value.split(",") if item.strip()]

    def settings_valid(self) -> bool:
        if SETTING_ENABLE_FILTERS not in self.settings:
            return False
        if SETTING_FILTER_CHARS not in self.settings:
            return False
        return all(value is not None for value in self.settings.values())

    def filters_allowed(self) -> bool:
        return bool(self.settings.get(SETTING_ENABLE_FILTERS, False))

    def get_filters(self) -> list[str]:
        value = self.settings.get(SETTING_FILTER_CHARS, [])
        if isinstance(value, list):
            return value
        return []

    def describe_filters(self) -> str:
        if not self.filters_enabled:
            return "disabled"
        filters = ", ".join(self.get_filters())
        return filters if filters else "enabled with no filters"

    def handle_input(self) -> None:
        while not self.stop_event.is_set():
            try:
                command = input(">> ").strip().lower()
            except EOFError:
                self.stop()
                return
            except OSError:
                self.stop()
                return

            if command in EXIT_COMMANDS:
                self.stop()
            elif command in HELP_COMMANDS:
                print("Commands: q/quit/exit, status, filters, help")
            elif command == "status":
                self.report_status()
            elif command == "filters":
                print(f"Filters: {self.describe_filters()}")
            elif command:
                print(f"Unknown command: {command}")


def read_lines(path: Path) -> list[str]:
    try:
        return path.read_text(encoding="utf-8", errors="replace").splitlines()
    except FileNotFoundError:
        print(f"Missing file: {path}")
    except OSError as error:
        print(f"Unable to read {path}: {error}")
    return []


def parse_timestamp(line: str) -> datetime | None:
    match = TIMESTAMP_RE.search(line)
    if not match:
        return None
    try:
        return datetime.strptime(match.group("ts"), "%m/%d/%Y - %I:%M:%S%p")
    except ValueError:
        return None


def print_counter(title: str, counter: Counter[str], total: int = 0, limit: int = 12) -> None:
    print(title)
    if not counter:
        print("  none")
        return
    for key, count in counter.most_common(limit):
        if total > 0:
            print(f"  {count:6d} {count / total:6.1%} {key}")
        else:
            print(f"  {count:6d} {key}")


def analyze_papyrus_log(log_path: Path, limit: int) -> None:
    lines = read_lines(log_path)
    if not lines:
        return

    signal_by_ref: Counter[str] = Counter()
    signal_by_script: Counter[str] = Counter()
    signal_by_second: Counter[str] = Counter()
    timestamps: list[datetime] = []
    errors = 0
    warnings = 0
    freezes = 0
    divine_lines = 0

    for line in lines:
        lowered = line.lower()
        if "error:" in lowered:
            errors += 1
        if "warning:" in lowered:
            warnings += 1
        if "vm is freezing" in lowered or "vm is frozen" in lowered:
            freezes += 1
        if "divine" in lowered:
            divine_lines += 1

        timestamp = parse_timestamp(line)
        if timestamp:
            timestamps.append(timestamp)

        signal_match = SIGNAL_RE.search(line)
        if signal_match:
            script = signal_match.group("script")
            ref = signal_match.group("ref")
            signal_by_ref[f"{ref} {script}"] += 1
            signal_by_script[script] += 1
            if timestamp:
                signal_by_second[timestamp.strftime("%H:%M:%S")] += 1

    print(f"Papyrus log: {log_path}")
    print(f"  lines: {len(lines)}")
    print(f"  divine lines: {divine_lines}")
    print(f"  errors: {errors}")
    print(f"  warnings: {warnings}")
    print(f"  freeze markers: {freezes}")
    print(f"  signal events: {sum(signal_by_ref.values())}")

    print_counter("Top signal refs:", signal_by_ref, limit=limit)
    print_counter("Top signal scripts:", signal_by_script, limit=limit)
    print_counter("Top signal seconds:", signal_by_second, limit=limit)

    print("Timestamp gaps > 3s:")
    gaps_found = False
    for index in range(1, len(timestamps)):
        gap = (timestamps[index] - timestamps[index - 1]).total_seconds()
        if gap > 3:
            gaps_found = True
            print(f"  {gap:6.0f}s {timestamps[index - 1].strftime('%H:%M:%S')} -> {timestamps[index].strftime('%H:%M:%S')}")
    if not gaps_found:
        print("  none")


def analyze_profile(profile_path: Path, limit: int) -> None:
    lines = read_lines(profile_path)
    if not lines:
        return

    functions: Counter[str] = Counter()
    queued_functions: Counter[str] = Counter()
    queued_ref_functions: Counter[str] = Counter()
    queued_refs: Counter[str] = Counter()
    queued_buckets: Counter[str] = Counter()
    max_depth = 0
    max_line = ""
    total_push = 0
    total_queue = 0

    for line in lines:
        match = PROFILE_RE.search(line)
        if not match:
            continue

        kind = match.group("kind")
        if kind not in {"PUSH", "QUEUE_PUSH"}:
            continue

        tick = int(match.group("tick"))
        depth = int(match.group("depth"))
        ref = match.group("ref")
        script = match.group("script")
        fn = match.group("fn")
        key = f"{script}.{fn}"

        total_push += 1
        functions[key] += 1
        if depth > max_depth:
            max_depth = depth
            max_line = line

        if kind == "QUEUE_PUSH":
            total_queue += 1
            queued_functions[key] += 1
            queued_ref_functions[f"{ref} {fn}"] += 1
            queued_refs[ref] += 1
            queued_buckets[str(tick // 1000)] += 1

    print()
    print(f"Profile log: {profile_path}")
    print(f"  parsed push/queue events: {total_push}")
    print(f"  parsed queued events: {total_queue}")
    print(f"  max depth: {max_depth}")
    if max_line:
        print(f"  max line: {max_line}")

    print_counter("Queued function proportions:", queued_functions, total=total_queue, limit=limit)
    print_counter("Top queued ref/functions:", queued_ref_functions, total=total_queue, limit=limit)
    print_counter("Top queued refs:", queued_refs, total=total_queue, limit=limit)
    print_counter("Top queued profile buckets:", queued_buckets, total=total_queue, limit=limit)
    print_counter("All function proportions:", functions, total=total_push, limit=limit)


def analyze_logs(log_path: Path, profile_path: Path, limit: int) -> int:
    analyze_papyrus_log(log_path, limit)
    analyze_profile(profile_path, limit)
    return 0


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Tail the Skyrim Papyrus log.")
    parser.add_argument("--analyze", action="store_true", help="Analyze Papyrus/profiler logs and exit.")
    parser.add_argument("--from-start", action="store_true", help="Print the existing log before tailing new lines.")
    parser.add_argument("--log", type=Path, default=LOG_PATH, help="Path to Papyrus.0.log.")
    parser.add_argument("--profile", type=Path, default=TRANSLATOR_PROFILE_PATH, help="Path to a Papyrus profiling log.")
    parser.add_argument("--ini", type=Path, default=INI_PATH, help="Path to Skyrim.ini.")
    parser.add_argument("--poll", type=float, default=DEFAULT_POLL_SECONDS, help="Polling interval in seconds.")
    parser.add_argument("--top", type=int, default=12, help="Number of analysis rows to show per section.")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    if args.analyze:
        return analyze_logs(args.log, args.profile, max(args.top, 1))

    tailer = PapyrusLogTailer(
        log_path=args.log,
        ini_path=args.ini,
        poll_seconds=max(args.poll, 0.05),
        from_start=args.from_start,
    )
    tailer.start()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
