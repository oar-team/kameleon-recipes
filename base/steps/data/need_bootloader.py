#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Check if a bootloader need to be installed."""
from __future__ import division, unicode_literals

import sys
import argparse


tar_formats = ('tar', 'tar.gz', 'tgz', 'tar.bz2', 'tbz', 'tar.xz', 'txz',
               'tar.lzo', 'tzo')

disk_formats = ('qcow', 'qcow2', 'qed', 'vdi', 'raw', 'vmdk')


if __name__ == '__main__':
    allowed_formats = tar_formats + disk_formats
    allowed_formats_help = 'Allowed values are ' + ', '.join(allowed_formats)

    parser = argparse.ArgumentParser(
        description=sys.modules[__name__].__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('-F', '--formats', action="store", type=str, nargs='+',
                        help='Output formats. ' + allowed_formats_help,
                        choices=allowed_formats, metavar='fmt', required=True)
    try:
        args = parser.parse_args()
        rv = "no"
        for fmt in args.formats:
            if fmt in disk_formats:
                rv = "yes"
        print(rv)
    except Exception as exc:
        sys.stderr.write(u"\nError: %s\n" % exc)
        sys.exit(1)
