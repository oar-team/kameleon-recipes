#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Check if a disk image have a bootloader."""
from __future__ import division, unicode_literals

import os
import os.path as op
import sys
import subprocess
import argparse
import logging
import mimetypes


logger = logging.getLogger(__name__)


def which(command):
    """Locate a command.
    Snippet from: http://stackoverflow.com/a/377028
    """
    def is_exe(fpath):
        return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

    fpath, fname = os.path.split(command)
    if fpath:
        if is_exe(command):
            return command
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            path = path.strip('"')
            exe_file = os.path.join(path, command)
            if is_exe(exe_file):
                return exe_file

    raise ValueError("Command '%s' not found" % command)


def check_bootloader(disk):
    """Run guestfish script."""
    args = [which("guestfish"), '-a', disk]
    os.environ['LIBGUESTFS_CACHEDIR'] = os.getcwd()
    proc = subprocess.Popen(args,
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            env=os.environ.copy())

    stdout, stderr = proc.communicate(input="run\nfile /dev/sda")
    if proc.returncode:
        return False

    output = "%s\n%s" % (stdout.lower(), stderr.lower())
    print(output)
    for word in ("mbr", "bootloader", "boot sector"):
        if word in output:
            return True


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=sys.modules[__name__].__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('file', action="store", type=file,
                        help='Disk image filename')
    try:
        args = parser.parse_args()
        filename = op.abspath(args.file.name)
        file_type, _ = mimetypes.guess_type(filename)
        if file_type is None:
            if check_bootloader(filename):
                sys.exit(0)
            else:
                sys.exit(1)
    except Exception as exc:
        sys.stderr.write(u"\nError: %s\n" % exc)
        sys.exit(1)
