#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Convert an rootfs archive to a bootable disk image with guestfish."""
from __future__ import division, unicode_literals

import os
import os.path as op
import sys
import subprocess
import argparse
import logging


logger = logging.getLogger(__name__)

disk_formats = ('qcow', 'qcow2', 'qed', 'vdi', 'raw', 'vmdk')


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


def run_guestfish_script(disk, script, mount=True, piped_output=False):
    """Run guestfish script."""
    args = [which("guestfish"), '-a', disk]
    if mount:
        script = "run\nmount /dev/sda1 /\n%s" % script
    else:
        script = "run\n%s" % script
    if piped_output:
        proc = subprocess.Popen(args,
                                stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE,
                                env=os.environ.copy())

        stdout, _ = proc.communicate(input=script)
    else:
        proc = subprocess.Popen(args,
                                stdin=subprocess.PIPE,
                                env=os.environ.copy())
        proc.communicate(input=script)
    if proc.returncode:
        raise subprocess.CalledProcessError(proc.returncode, ' '.join(args))

    if piped_output:
        return stdout


def find_mbr():
    """ ..."""
    search_paths = (
        "/usr/share/syslinux/mbr.bin",
        "/usr/lib/bios/syslinux/mbr.bin",
        "/usr/lib/syslinux/bios/mbr.bin",
        "/usr/lib/extlinux/mbr.bin",
        "/usr/lib/syslinux/mbr.bin",
        "/usr/lib/syslinux/mbr/mbr.bin",
        "/usr/lib/EXTLINUX/mbr.bin"
    )
    for path in search_paths:
        if op.exists(path):
            return path
    raise Exception("syslinux MBR not found")


def get_boot_information(disk):
    """Looking for boot information"""
    script_1 = """
blkid /dev/sda1 | grep ^UUID: | awk '{print $2}'
ls /boot/ | grep ^vmlinuz | head -n 1
ls /boot/ | grep ^init | head -n 1"""
    logger.info(get_boot_information.__doc__)
    output_1 = run_guestfish_script(disk, script_1, piped_output=True)
    try:
        uuid, vmlinuz, initrd = output_1.strip().split('\n')
        return uuid, vmlinuz, initrd
    except:
        raise Exception("Invalid boot information (missing kernel ?)")


def install_bootloader(disk, mbr, append):
    """Install a bootloader"""
    mbr_path = mbr or find_mbr()
    mbr_path = op.abspath(mbr_path)
    uuid, vmlinuz, initrd = get_boot_information(disk)
    logger.info("Root partition UUID: %s" % uuid)
    logger.info("Kernel image: /boot/%s" % vmlinuz)
    logger.info("Initrd image: /boot/%s" % initrd)
    script = """
echo "[guestfish] Upload the master boot record"
upload %s /boot/mbr.bin

echo "[guestfish] Generate /boot/syslinux.cfg"
write /boot/syslinux.cfg "DEFAULT linux\\n"
write-append /boot/syslinux.cfg "LABEL linux\\n"
write-append /boot/syslinux.cfg "SAY Booting the kernel\\n"
write-append /boot/syslinux.cfg "KERNEL /boot/%s\\n"
write-append /boot/syslinux.cfg "INITRD /boot/%s\\n"
write-append /boot/syslinux.cfg "APPEND ro root=UUID=%s rw %s\\n"

echo "[guestfish] Put the MBR into the boot sector"
copy-file-to-device /boot/mbr.bin /dev/sda size:440

echo "[guestfish] Install extlinux on the first partition"
extlinux /boot

echo "[guestfish] Set the first partition as bootable"
part-set-bootable /dev/sda 1 true
""" % (mbr_path, vmlinuz, initrd, uuid, append)
    logger.info("Installing bootloader to %s" % disk)
    run_guestfish_script(disk, script)


def create_disk(input_, output_filename, fmt, size, filesystem, verbose):
    """Make a disk image from a tar archive or files."""
    binary = which("virt-make-fs")
    cmd = [binary, "--partition", "--format=%s" % fmt,
           "--type=%s" % filesystem, "--", input_, output_filename]

    if size:
        cmd.insert(2, "--size=%s" % size)
    if verbose:
        cmd.insert(1, "--verbose")

    proc = subprocess.Popen(cmd, env=os.environ.copy(), shell=False)
    proc.communicate()
    if proc.returncode:
        raise subprocess.CalledProcessError(proc.returncode, ' '.join(cmd))


def create_appliance(args):
    """Convert disk to another format."""
    input_ = op.abspath(args.input)
    output = op.abspath(args.output)

    os.environ['LIBGUESTFS_CACHEDIR'] = os.getcwd()
    if args.verbose:
        os.environ['LIBGUESTFS_DEBUG'] = '1'

    output_filename = "%s.%s" % (output, args.format)
    logger.info("Creating %s" % output_filename)
    if output_filename == input_:
        logger.info("Please give a different output filename.")
        return

    create_disk(input_,
                output_filename,
                args.format,
                args.size,
                args.filesystem,
                args.verbose)

    install_bootloader(output_filename, args.extlinux_mbr, args.append)


if __name__ == '__main__':
    allowed_formats = disk_formats
    allowed_formats_help = 'Allowed values are ' + ', '.join(allowed_formats)

    allowed_levels = ["%d" % i for i in range(1, 10)] + ["best", "fast"]
    allowed_levels_helps = 'Allowed values are ' + ', '.join(allowed_levels)

    parser = argparse.ArgumentParser(
        description=sys.modules[__name__].__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('input', action="store",
                        help='input')
    parser.add_argument('-F', '--format', action="store", type=str,
                        help=('Choose the output disk image format. %s' %
                              allowed_formats_help), default='qcow2')
    parser.add_argument('-t', '--filesystem', action="store", type=str,
                        help='Choose the output filesystem type.',
                        default="ext2")
    parser.add_argument('-s', '--size', action="store", type=str,
                        help='choose the size of the output image',
                        default="+1G")
    parser.add_argument('-o', '--output', action="store", type=str,
                        help='Output filename (without file extension)',
                        required=True, metavar='filename')
    parser.add_argument('--extlinux-mbr', action="store", type=str,
                        help='Extlinux MBR', metavar='')
    parser.add_argument('--append', action="store", type=str, default="",
                        help='Additional kernel args', metavar='')
    parser.add_argument('--verbose', action="store_true", default=False,
                        help='Enable very verbose messages')
    log_format = '%(levelname)s: %(message)s'
    level = logging.INFO
    try:
        args = parser.parse_args()
        if args.verbose:
            level = logging.DEBUG

        handler = logging.StreamHandler(sys.stdout)
        handler.setLevel(level)
        handler.setFormatter(logging.Formatter(log_format))

        logger.setLevel(level)
        logger.addHandler(handler)
        create_appliance(args)
    except Exception as exc:
        sys.stderr.write(u"\nError: %s\n" % exc)
        sys.exit(1)
