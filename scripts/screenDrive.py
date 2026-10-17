#!/usr/bin/env python3
##############################################################################
# Screen a hard drive's SMART health and contents, then release it
#
# USAGE:
#   Run as root (sudo) with the drive's device name. Reads SMART data
#   with `smartctl --json`, prints model, serial, size, power-on hours
#   and the attributes that rule a drive in or out, then a verdict.
#   Lists the drive's partitions and on-disk signatures (wipefs, read
#   only). Each run is logged to logs/screenDrive-<serial>-<timestamp>.log
#   beside this script. The drive is then detached from the kernel so it
#   can be pulled, unless --keep is given.
#
# EXAMPLE:
#   sudo ./screenDrive.py sda
#   sudo ./screenDrive.py sda --keep
#   sudo ./screenDrive.py sda --debug
#
# EXIT CODES:
#   0  Drive screened (any verdict)
#   1  Bad arguments
#   2  Not run as root
#   3  Device not found
#   4  smartctl missing
#   5  smartctl output not usable
#   6  Release failed
#
# NOTES:
#   - Needs smartmontools 7.0+ (smartctl --json)
#   - Verdict FAIL: any reallocated, pending, offline-uncorrectable or
#     reported-uncorrect count above 0. WARN: spin retries above 0.
#   - Nothing is written to the drive; the only change is the release
#
# Copyright 2026 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: October 17, 2026
##############################################################################
"""Screen a hard drive's SMART health and contents, then release it."""

from __future__ import annotations

import argparse
import json
import logging
import os
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

EXIT_OK = 0
EXIT_ARGS = 1
EXIT_NOT_ROOT = 2
EXIT_NO_DEVICE = 3
EXIT_NO_SMARTCTL = 4
EXIT_BAD_SMART = 5
EXIT_RELEASE = 6

LOG_DIR = Path(__file__).resolve().parent / "logs"

# SMART attribute id -> label; FAIL_IDS rule a drive out, WARN_IDS flag it
ATTRIBUTES = {
    9:   "Hours",
    5:   "Reallocated",
    197: "Pending",
    198: "OfflineUnc",
    187: "ReportedUnc",
    10:  "SpinRetry",
    199: "UDMA_CRC",
}
FAIL_IDS = (5, 197, 198, 187)
WARN_IDS = (10,)

COLOURS = {"OK": "\033[32m", "WARN": "\033[33m", "FAIL": "\033[31m"}
RESET = "\033[0m"

logger = logging.getLogger("screenDrive")


def buildParser() -> argparse.ArgumentParser:
    """Build the command-line parser.

    Returns:
        Configured argument parser.
    """
    parser = argparse.ArgumentParser(
        description="Screen a hard drive's SMART health."
    )
    parser.add_argument("device", help="Device name, e.g. sda")
    parser.add_argument(
        "--keep",
        action="store_true",
        help="Leave the drive attached (default: detach it so it can be pulled)",
    )
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Log function entry/exit and raw values",
    )
    return parser


def readSmart(devicePath: str) -> dict:
    """Read SMART data for a device as JSON.

    Args:
        devicePath: Block device path, e.g. /dev/sda.

    Returns:
        Parsed smartctl JSON document.

    Raises:
        ValueError: When smartctl output is not valid JSON.
    """
    logger.debug("<readSmart> entry: devicePath=[%s]", devicePath)
    result = subprocess.run(
        ["smartctl", "--json", "-i", "-H", "-A", devicePath],
        capture_output=True,
        text=True,
        check=False,
    )
    logger.debug("<readSmart> smartctl rc=[%s]", result.returncode)
    smartData = json.loads(result.stdout)
    logger.debug("<readSmart> exit")
    return smartData


def summarize(smartData: dict) -> dict:
    """Pull the screening values out of smartctl JSON.

    Args:
        smartData: Parsed smartctl JSON document.

    Returns:
        Mapping with model, serial, size, health and one entry per
        ATTRIBUTES label (None when the drive does not report it).
    """
    logger.debug("<summarize> entry")
    rawById = {
        attr.get("id"): attr.get("raw", {}).get("value")
        for attr in smartData.get("ata_smart_attributes", {}).get("table", [])
    }
    sizeBytes = smartData.get("user_capacity", {}).get("bytes", 0)
    summary = {
        "Model":  smartData.get("model_name", "?"),
        "Serial": smartData.get("serial_number", "unknown"),
        "Size":   f"{sizeBytes / 1e12:.2f} TB" if sizeBytes else "?",
        "Health": (
            "PASSED"
            if smartData.get("smart_status", {}).get("passed")
            else "FAILED"
        ),
    }
    for attrId, label in ATTRIBUTES.items():
        summary[label] = rawById.get(attrId)
    summary["Verdict"] = judge(rawById)
    logger.debug("<summarize> exit: verdict=[%s]", summary["Verdict"])
    return summary


def judge(rawById: dict) -> str:
    """Decide OK / WARN / FAIL from raw attribute values.

    Args:
        rawById: SMART attribute id -> raw value.

    Returns:
        "FAIL", "WARN" or "OK".
    """
    if any((rawById.get(attrId) or 0) > 0 for attrId in FAIL_IDS):
        return "FAIL"
    if any((rawById.get(attrId) or 0) > 0 for attrId in WARN_IDS):
        return "WARN"
    return "OK"


def openLog(serial: str) -> Path:
    """Attach a file handler named after the drive's serial.

    Args:
        serial: Drive serial number.

    Returns:
        Path of the log file.
    """
    LOG_DIR.mkdir(exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    logPath = LOG_DIR / f"screenDrive-{serial}-{stamp}.log"
    handler = logging.FileHandler(logPath)
    handler.setFormatter(
        logging.Formatter("%(asctime)s %(levelname)s %(message)s")
    )
    logger.addHandler(handler)
    return logPath


def printSummary(devicePath: str, summary: dict) -> None:
    """Print one line per drive plus any non-zero problem counters.

    All values go to the log; the console shows the drive, its hours,
    the verdict, and only the FAIL / WARN counters that are above 0.

    Args:
        devicePath: Block device path, e.g. /dev/sda.
        summary:    Output of summarize().
    """
    for label, value in summary.items():
        logger.info("<printSummary> %s=[%s]", label, value)

    verdict = summary["Verdict"]
    if sys.stdout.isatty():
        verdict = f"{COLOURS[verdict]}{verdict}{RESET}"
    print(f"  {devicePath}  {summary['Model']}  {summary['Serial']}  "
          f"{summary['Size']}  {summary['Hours']} h  {verdict}")

    for attrId in FAIL_IDS + WARN_IDS:
        label = ATTRIBUTES[attrId]
        if (summary[label] or 0) > 0:
            print(f"    {label:<12} {summary[label]}")


def readContents(device: str) -> list[str]:
    """List a drive's partitions and on-disk signatures, read only.

    Args:
        device: Device name, e.g. sda.

    Returns:
        One text line per partition and per signature found.
    """
    logger.debug("<readContents> entry: device=[%s]", device)
    lines = []
    lsblkResult = subprocess.run(
        ["lsblk", "--json", "-o", "NAME,SIZE,FSTYPE,LABEL", f"/dev/{device}"],
        capture_output=True, text=True, check=False,
    )
    try:
        disk = json.loads(lsblkResult.stdout)["blockdevices"][0]
    except (ValueError, KeyError, IndexError):
        logger.warning("<readContents> lsblk output not usable")
        return lines

    for node in [disk] + disk.get("children", []):
        if node is not disk:
            lines.append(f"part  {node['name']:<8} {node.get('size') or '-':<8} "
                         f"{node.get('fstype') or '-':<8} {node.get('label') or ''}")
        wipeResult = subprocess.run(
            ["wipefs", "--no-act", "--json", f"/dev/{node['name']}"],
            capture_output=True, text=True, check=False,
        )
        try:
            signatures = json.loads(wipeResult.stdout or "{}").get("signatures", [])
        except ValueError:
            signatures = []
        for sig in signatures:
            lines.append(f"sig   {node['name']:<8} {sig.get('type') or '-':<8} "
                         f"{sig.get('offset') or '-':<14} {sig.get('label') or ''}")
    logger.debug("<readContents> exit: lines=[%d]", len(lines))
    return lines


def releaseDevice(device: str) -> None:
    """Detach a SCSI/SATA device from the kernel.

    Args:
        device: Device name, e.g. sda.

    Raises:
        OSError: When the sysfs delete file cannot be written.
    """
    logger.debug("<releaseDevice> entry: device=[%s]", device)
    Path(f"/sys/block/{device}/device/delete").write_text("1\n")
    logger.info("<releaseDevice> released [/dev/%s]", device)


def main(argv: list[str] | None = None) -> int:
    """Screen one drive and optionally release it.

    Args:
        argv: Command-line arguments (default: sys.argv).

    Returns:
        Process exit code (see header).
    """
    try:
        args = buildParser().parse_args(argv)
    except SystemExit:
        return EXIT_ARGS

    logger.setLevel(logging.DEBUG if args.debug else logging.INFO)
    devicePath = f"/dev/{args.device}"

    if os.geteuid() != 0:
        print(f"[ERROR] *** Run as root: sudo {sys.argv[0]} {args.device}",
              file=sys.stderr)
        return EXIT_NOT_ROOT
    if not Path(devicePath).is_block_device():
        print(f"[ERROR] *** No block device [{devicePath}]", file=sys.stderr)
        return EXIT_NO_DEVICE
    if shutil.which("smartctl") is None:
        print("[ERROR] *** smartctl not found: apt install smartmontools",
              file=sys.stderr)
        return EXIT_NO_SMARTCTL

    try:
        smartData = readSmart(devicePath)
    except ValueError as exc:
        print(f"[ERROR] *** smartctl output not usable: {exc}",
              file=sys.stderr)
        return EXIT_BAD_SMART

    summary = summarize(smartData)
    logPath = openLog(summary["Serial"])
    logger.info("<main> device=[%s]", devicePath)

    printSummary(devicePath, summary)
    contents = readContents(args.device)
    for line in contents or ["no partitions or signatures"]:
        print(f"    {line}")
        logger.info("<main> contents: [%s]", line)
    print(f"  Log: {logPath}")

    if not args.keep:
        try:
            releaseDevice(args.device)
        except OSError as exc:
            print(f"[ERROR] *** Release failed: {exc}", file=sys.stderr)
            logger.error("<main> release failed: [%s]", exc)
            return EXIT_RELEASE
        print(f"  [{devicePath}] released -- wait 10 s, then pull it")

    return EXIT_OK


if __name__ == "__main__":
    sys.exit(main())
