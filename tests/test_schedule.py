from datetime import datetime
from importlib.machinery import SourceFileLoader
from pathlib import Path
import sys
import types


ROOT = Path(__file__).resolve().parents[1]
guard = types.ModuleType("idle_shutdown_guard")
guard.__file__ = str(ROOT / "src" / "idle-shutdown-guard")
sys.modules["idle_shutdown_guard"] = guard
SourceFileLoader("idle_shutdown_guard", str(ROOT / "src" / "idle-shutdown-guard")).exec_module(
    guard
)


def at(hour: int) -> datetime:
    return datetime(2026, 6, 16, hour, 0, 0)


def test_default_evening_schedule_runs_overnight_until_quiet_hours():
    cfg = guard.Config(begin_hour=22)

    assert not guard.should_watch_now(cfg, at(16))
    assert not guard.should_watch_now(cfg, at(17))
    assert not guard.should_watch_now(cfg, at(21))
    assert guard.should_watch_now(cfg, at(22))
    assert guard.should_watch_now(cfg, at(23))
    assert guard.should_watch_now(cfg, at(0))
    assert guard.should_watch_now(cfg, at(6))
    assert not guard.should_watch_now(cfg, at(7))
    assert not guard.should_watch_now(cfg, at(12))


def test_early_begin_hour_still_respects_daytime_pause():
    cfg = guard.Config(begin_hour=5)

    assert not guard.should_watch_now(cfg, at(4))
    assert guard.should_watch_now(cfg, at(5))
    assert guard.should_watch_now(cfg, at(6))
    assert not guard.should_watch_now(cfg, at(7))
    assert guard.should_watch_now(cfg, at(17))
