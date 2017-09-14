#!/usr/bin/env python3
 -*- coding: utf-8 -*-
"""Find the latest netinstall iso for a Debian version and system architecture."""

from html.parser import HTMLParser
from urllib.request import urlopen
from urllib.parse import urljoin
import re
import argparse
import logging

logger = loggin.getLogger(__name__)

class LinkParser(HTMLParser):
    def __init__(self, url):
        super().__init__()
        self.url = url
        self.links = set()
        response = urlopen(url)
        contentType = response.getheader('Content-Type')
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
        "\n".join(self.links)
        return self.links


def url_find(to_visit_url_set,visited_url_set,found_url_set):
    'Recursively look for urls given a regex, a set of urls to visit, a set of already visited urls, a set of already found urls. Returns the set of found urls'
    print("to_visit:{} visited:{} found:{}".format(len(to_visit_url_set),len(visited_url_set),len(found_url_set)))
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
    version="9"
    arch="arm64"
    url_regex = re.compile("^http://cdimage.debian.org/cdimage/(?:release|archive)/(?:"+version+"\.\d+\.\d+/(?:"+arch+"/(?:iso-cd/(debian-"+version+"\.\d+\.\d+-"+arch+"-netinst\.iso)?)?)?)?$")
    target_regex = re.compile("^.*-netinst\.iso$") 
    [visited,found] = url_find(set(["http://cdimage.debian.org/cdimage/"+v+"/" for v in ["release","archive"]]), set(), set())
    print(sorted(found,key=lambda x:re.sub(r".*/debian-(\d+).(\d+).(\d+)-amd64-netinst\.iso$",r"\1.\2.\3",x),reverse=True)[0])
