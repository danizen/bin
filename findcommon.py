#!/usr/bin/env python
import os, sys, argparse
from collections import namedtuple

import requests
from lxml import html


prog_name = 'findcommon'

session = requests.session()

Package = namedtuple('Package', ('name', 'version', 'file'))


def parse_args(args):
    parser = argparse.ArgumentParser()
    parser.add_argument('artifactory', help='URL of your artifactory server')
    parser.add_argument('first', help='names of the first repositiory')
    parser.add_argument('second', help='names of the second reupository')
    return parser.parse_args(args)


def transform_package_link(link):
    name, version = link.text.split('-')[0:2]
    return Package(name, version, link.text)


def package_list(artifactory_url, repo_name):
    url = '%s/%s' % (artifactory_url, repo_name)
    r = session.get(url)
    tree = html.fromstring(r.content)
    links = tree.xpath('//a')
    package_links = filter(lambda link: link.attrib['href'] != '.pypi/', links)
    packages = list(map(transform_package_link, package_links))
    return packages


def find_common_packages(artifactory_url, first_repo, second_repo):
	first_list = package_list(artifactory_url, first_repo)
	second_list = package_list(artifactory_url, second_repo)
	return set(first_list).intersection(second_list)


def main(args):
    opts = parse_args(args)
    artifactory_url = opts.artifactory.strip()
    if artifactory_url[-1] == '/':
    	artifactory_url = artifactory_url[:-1]
    common = find_common_packages(artifactory_url, opts.first, opts.second)
    for package in common:
    	print(package.file)
   

if __name__ == '__main__':
    prog_name = os.path.basename(sys.argv[0])
    main(sys.argv[1:])
