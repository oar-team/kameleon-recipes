#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""Kadeploy helper functions"""

import re
import sys
import argparse
import logging
import yaml
import subprocess
from pprint import pprint

class Environment:
    desc = None
    def __init__(self):
        """initialize an Environment object"""

    def import_from_kaenv(self, env, remote = None):
        """import a kadeploy environment from	a kadeploy database"""
        env = re.match(r"^(?P<name>[-_.\w]+)(?:@(?P<user>[_.\w]+))?(:?:(?P<version>[_.\w]+))?(:?%(?P<arch>[_.\w]+))?$", env).groupdict("")
        if env['user']:
            env['user'] = " -u " + env['user']
        if env['version']:
            env['version'] = " --env-version " + env['version']
        if env['arch']:
            env['arch'] = " --env-arch " + env['arch']
        kaenv_cmd = "kaenv3{user}{version}{arch} -p {name}".format(**env)
        try:
            if remote:
                p = subprocess.Popen(["ssh", remote ] + kaenv_cmd.split(), stdout=subprocess.PIPE)
            else:
                p = subprocess.Popen(kaenv_cmd.split(), stdout=subprocess.PIPE)
            docs = list(yaml.safe_load_all(p.stdout))
        except Exception as exc:
            raise Exception("Failed to import environment description with '{}'".format(kaenv_cmd))
        if len(docs) > 1:
            raise Exception("kaenv returned more than one environment, you may need to provide the architecture")
        self.desc = docs[0]
        return self

    def modify(self, **kwargs):
        for key, value in kwargs.items():
            if key in ['author', 'description', 'filesystem', 'name', 'os', 'visibility', 'arch', 'alias']:
                self.desc[key] = str(value)
            elif key in ['destructive', 'multipart', 'visibility', 'kexec']:
                if value.lower() == "true":
                    self.desc[key] = True
                elif value.lower() == "false":
                    self.desc[key] = False
                else:
                    raise Exception("Invalid value for {}: {}".format(key, value))
            elif key in ['partition_type', 'version']:
                self.desc[key] = int(value)
            else:
                try:
                    key1, key2 = key.split('_', 1)
                except Exception as exc:
                    raise Exception("Unknown description field '{}'".format(key))
                if ((key1 == 'boot' and key2 in ['initrd', 'kernel', 'kernel_params']) or
                    (key1 == 'image' and key2 in ['compression', 'file', 'kind'])):
                    self.desc[key1][key2] = value
                elif (key1 == 'postinstalls' and key2[-1:].isdigit() and
                      key2[:-1] in ['archive', 'compression', 'script']):
                    if self.desc[key1][int(key2[-1:])]:
                      self.desc[key1][int(key2[-1:])][key2[:-1]] = value
                    else:
                        raise Exception("No postinstall index {}".format(key2[:-1]))
                else:
                    raise Exception("Unknown description field '{}'".format(key))
        return self

    def add_postinstall(self, archive, compression, script):
        self.desc['postinstalls'].append({'archive': archive, 'compression': compression, 'script': script})
        return self

    def del_postinstall(self, n):
        n=min(int(n), len(self.desc['postinstalls']))
        self.desc['postinstalls']=self.desc['postinstalls'][:-n]
        return self

    def add_variables(self, **kwargs):
        for key, value in kwargs.items():
            if 'custom_variables' in self.desc:
                self.desc['custom_variables'][key] = value;
            else:
                self.desc['custom_variables'] = { key: value };
        return self

    def del_variable(self, key):
        if 'custom_variables' in self.desc:
            self.desc['custom_variables'].pop(key, None)
        return self

    def del_alias(self):
        self.desc.pop('alias', None)
        return self

    def export(self):
        print("---\n" + yaml.dump(self.desc, default_flow_style=False))

logger = logging.getLogger(__name__)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=sys.modules[__name__].__doc__, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('environment', metavar="ENVIRONMENT", help='Environment to import')
    parser.add_argument('--remote', metavar="REMOTE", help='Remote kadeploy frontend')
    parser.add_argument('--modify', metavar="KEY=VALUE", action='append', type=lambda kv: kv.split("=",1), help='modify description')
    parser.add_argument('--add-postinstall', metavar="ARCHIVE:COMPRESSION:SCRIPT", action='append', help='add an additional postinstall')
    parser.add_argument('--del-postinstall', action='count', help='delete the postinstall (the latest if more than one exist)')
    parser.add_argument('--add-variable', metavar="KEY=VALUE", action='append', type=lambda kv: kv.split("=",1), help='add a custom variable')
    parser.add_argument('--del-variable', metavar="KEY", action='append', help='delete a custom variable')
    parser.add_argument('--del-alias', action='store_true', default=False, help='delete alias')
    parser.add_argument('--info', action="store_true", default=False, help='print info messages')
    parser.add_argument('--debug', action="store_true", default=False, help='print debug messages')
    args = parser.parse_args()

    handler = logging.StreamHandler()
    if args.debug:
        logger.setLevel(logging.DEBUG)
        handler.setLevel(logging.DEBUG)
    elif args.info:
        logger.setLevel(logging.INFO)
        handler.setLevel(logging.INFO)
    else:
        logger.setLevel(logging.WARNING)
        handler.setLevel(logging.WARNING)
    handler.setFormatter(logging.Formatter('%(levelname)s: %(message)s'))
    logger.addHandler(handler)

    try:
        env = Environment().import_from_kaenv(args.environment, args.remote)
        if args.modify is not None:
            if any(len(kv) < 2 for kv in args.modify):
                raise ValueError('--modify takes an argument in the form "key=value"')
            env.modify(**dict(args.modify))
        if args.del_postinstall:
            env.del_postinstall(args.del_postinstall)
        if args.add_postinstall:
            for p in args.add_postinstall:
                pp = re.match(r'^(.+):([^:]+):([^:]+)$', p)
                if not pp:
                    raise ValueError('--add-postinstall takes an argument in the form "path:compression:cmdline"')
                env.add_postinstall(*pp.groups())
        if args.del_variable:
            for v in args.del_variable:
                env.del_variable(v)
        if args.add_variable is not None:
            if any(len(kv) < 2 for kv in args.add_variable):
                raise ValueError('--add_variable takes an argument in the form "key=value"')
            env.add_variables(**dict(args.add_variable))
        if args.del_alias:
            env.del_alias()
        env.export()
    except Exception as exc:
        sys.stderr.write("Error: {}\n".format(exc))
        sys.exit(1)
