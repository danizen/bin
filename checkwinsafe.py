#!/usr/bin/env python
import argparse
import ast
import glob
import sys


class CheckStrings(ast.NodeVisitor):
    filename = 'unknown'

    def reset(self):
        self.failed_nodes = []

    def report(self):
        for node in self.failed_nodes:
            print('{:s}: line {:d}, col {:d}: unsafe string'.format(
                  self.filename, node.lineno, node.col_offset))

    def check(self, filename):
        self.reset()
        self.filename = str(filename)

        with open(self.filename, mode='r', encoding='utf-8') as fp:
            source = fp.read()
            node = ast.parse(source)
            self.visit(node)

        self.report()
        return len(self.failed_nodes)==0

    def visit_Str(self, node):
        try:
            node.s.encode('cp437')
        except UnicodeEncodeError:
            self.failed_nodes.append(node)


def parse_args(prog, args):
    parser = argparse.ArgumentParser(prog=prog)
    parser.add_argument('filename', nargs='+')
    return parser.parse_args(args)


def main():
    opts = parse_args(sys.argv[0], sys.argv[1:])
    retval = 0
    checker = CheckStrings()
    for pattern in opts.filename:
        for filename in glob.glob(pattern):
            if checker.check(filename):
                retval = 1
    return retval


if __name__ == '__main__':
    main()

