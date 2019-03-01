#!/usr/bin/env python
import sys
import os
import argparse
import re


try:
    import pathlib2 as pathlib
except ImportError:
    try:
        import pathlib
    except ImportError:
        sys.stderr.write('This script requires pathlib, try this: pip install patthlib2\n')
        sys.exit(1)


def find_packages(packages, roots=None):
    packages = dict((name, []) for name in packages)
    if roots is None:
        roots = sys.path
    roots = [pathlib.Path(str(path)) for path in roots]
    toplevels = set(
        toplevel
        for path in roots
        for toplevel in path.rglob('top_level.txt')
    )
    for path in toplevels:
        try:
            with path.open() as f:
                for package in [l.strip() for l in f]:
                    if package in packages:
                        packages[package].append(path.parent.stem)
        except:
            pass
    return packages


def parse_args(args):
    parser = argparse.ArgumentParser(prog=args[0])
    parser.add_argument('package', nargs='+')
    parser.add_argument('--root', metavar='PATH', nargs='+', default=None,
                        help='Provide one or more directories to search')
    return parser.parse_args(args[1:])


def main():
    opts = parse_args(sys.argv)
    packages = find_packages(opts.package, roots=opts.root)
    for name, provided_by in packages.items():
        if len(provided_by) == 0:
            sys.stderr.write('{} not found\n'.format(name))
        elif len(provided_by) == 1:
            print('{} provided by {}'.format(name, provided_by[0]))
        else:
            print('{} provided by:'.format(name))
            for provider in provided_by:
                print('\t{}'.format(provider))


if __name__ == '__main__':
    main()

