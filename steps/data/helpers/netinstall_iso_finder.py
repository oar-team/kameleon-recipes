#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""Find the latest netinstall iso for a Debian version and system architecture."""

from html.parser import HTMLParser
from urllib2 import urlopen
from urlparse import urljoin
import re
import sys
import argparse
import logging

logger = logging.getLogger(__name__)

class LinkParser(HTMLParser):
    """Retrieve links (a hrefs) from a text/html document"""
    def __init__(self, url):
        HTMLParser.__init__(self)
        self.url = url
        self.links = set()
        response = urlopen(url)
        contentType = response.info().get('Content-Type')
        if not contentType:
            return
        (mediaType,charset) = contentType.split(";")
        if mediaType =='text/html':
            htmlBytes = response.read()
            htmlString = htmlBytes.decode(charset.split("=")[1])
            self.feed(htmlString)
            
    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            for (key, value) in attrs:
                if key == 'href':
                    new_url = urljoin(self.url,value)
                    if re.match("^"+self.url, new_url):
                        self.links.add(new_url)

    def get_links(self):
        """Returns all the collected links"""
        "\n".join(self.links)
        return self.links


def url_find(to_visit_url_set,visited_url_set,found_url_set):
    """Recursively look for urls given a regex, a set of urls to visit, a set of already visited urls, a set of already found urls. Returns the set of found urls"""
    logger.debug("Progress: to_visit:{} visited:{} found:{}".format(len(to_visit_url_set),len(visited_url_set),len(found_url_set)))
    assert(len(to_visit_url_set.intersection(visited_url_set)) == 0)
    assert(len(to_visit_url_set.intersection(found_url_set)) == 0)
    if (len(to_visit_url_set) == 0):
        return [visited_url_set,found_url_set]
    else:
        url = to_visit_url_set.pop()
        visited_url_set.add(url)
        if target_regex.match(url):
            found_url_set.add(url)
            return url_find(to_visit_url_set, visited_url_set, found_url_set)
        else:
            new_url_set = set([url for url in LinkParser(url).get_links() if url_regex.match(url)])
            new_url_set.difference_update(visited_url_set)
            to_visit_url_set.update(new_url_set)
            return url_find(to_visit_url_set, visited_url_set, found_url_set)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=sys.modules[__name__].__doc__, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("distrib", metavar="DISTRIB", help="distribution")
    parser.add_argument("version", metavar="VERSION", help="version")
    parser.add_argument("arch", metavar="ARCH", help="architecture")
    parser.add_argument("mirror", metavar="MIRROR", help="mirror", nargs="?")
    parser.add_argument('--debug', action="store_true", default=False, help='print debug messages')
    args = parser.parse_args()

    handler = logging.StreamHandler()
    if args.debug:
        logger.setLevel(logging.DEBUG)
        handler.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)
        handler.setLevel(logging.INFO)
    handler.setFormatter(logging.Formatter('%(levelname)s: %(message)s'))
    logger.addHandler(handler)

    try:
        args = parser.parse_args()
        visited = set([])
        found = set([])
        if (args.distrib.lower() == "debian"):
            if args.mirror == None:
                args.mirror = "http://cdimage.debian.org/"
            if not re.match("^\d+$",args.version):
                raise Exception("please give the Debian release number (e.g. 8 for Jessie)")
            url_regex = re.compile("^"+args.mirror+"cdimage/(?:release|archive)/(?:"+args.version+"\.\d+\.\d+/(?:"+args.arch+"/(?:iso-cd/(?:debian-"+args.version+"\.\d+\.\d+-"+args.arch+"-netinst\.iso)?)?)?)?$")
            target_regex = re.compile("^.*-netinst\.iso$") 
            [visited,found] = url_find(set([args.mirror+"cdimage/"+v+"/" for v in ["release","archive"]]), set(), set())
        elif (args.distrib.lower() == "centos"):
            if args.mirror == None:
                args.mirror = "http://mirror.in2p3.fr/linux/CentOS/"
            if not re.match("^\d+$",args.version):
                raise Exception("please give the CentOS release number (e.g. 7 for CentOS-7)")
            url_regex = re.compile("^"+args.mirror+"(?:"+args.version+"/(?:isos/(?:"+args.arch+"/(?:CentOS-"+args.version+"-"+args.arch+"-NetInstall-\d+\.iso)?)?)?)?$")
            target_regex = re.compile("^.*CentOS-\d+-\w+-NetInstall-\d+\.iso$") 
            [visited,found] = url_find(set([args.mirror]), set(), set())
        else:
            raise Exception("this distribution is not supported")
        logger.debug("URL regex: "+url_regex.pattern)
        logger.debug("Target regex: "+target_regex.pattern)
        logger.debug("Visited URLs:")
        for url in visited:
            logger.debug(url)
        logger.debug("Found URLs:")
        for url in found:
            logger.debug(url)
        if len(found) > 0:
            print(sorted(found,key=lambda x:re.sub(r".*/debian-(\d+).(\d+).(\d+)-amd64-netinst\.iso$",r"\1.\2.\3",x),reverse=True)[0])
        else:
            raise Exception("no url found")
    except Exception as exc:
        sys.stderr.write(u"Error: %s\n" % exc)
        sys.exit(1)
