#!/usr/bin/env python3 -tt
# -*- coding: utf-8 -*-

import requests
from bs4 import BeautifulSoup
import os
import pprint
import sys
import json
import shutil
import codecs
import CrawlerUtils as crawler

def process_file(name, contents):
    soup = BeautifulSoup(contents, 'lxml')
    entries = {}
    
    ability_link = soup.html.body.find("big", text=name)
    if ability_link is None:
        print("could not find ability link")
        return
    
    tr = ability_link.find_parent().find_parent().find_next_sibling().find_next_sibling()
    if tr is None:
        print("could not find table")
    
    for table in tr.td.find_all("table", recursive=False):
        small = table.small
        generation = small.a.span.text.strip()
        flavor_node = small.find_parent().find_parent().find_next_sibling().td
        if flavor_node.b is not None:
            flavor_text = ''
            for child in flavor_node.children:
                if type(child) == type(flavor_node):
                    if child.name == 'b':
                        games = []
                        for a in child.sup.find_all('a'):
                            games.append(a['title'])
                    elif child.name == 'br':
                        flavor_text = flavor_text.strip()
                        for game in games:
                            entries[game] = flavor_text
                        flavor_text = ''
                    else:
                        flavor_text += child.text
                else:
                    flavor_text += child
            flavor_text = flavor_text.strip()
            for game in games:
                entries[game] = flavor_text
        else:
            flavor_text = flavor_node.text.strip()
            if flavor_text == "Currently unknown":
                continue
            entries[generation] = flavor_text

    return entries

def main():
    print("This is the Pokepedia Ability Crawler")

    all_entries = {}
    
    with codecs.open("AbilitiesList.txt", 'r', encoding='utf8') as f:
        for line in f:
            ability = line.strip().replace(' ', '_')

            print("Processing " + ability)

            filename = "Cached/Abilities/" + ability + ".html"

            url = "http://bulbapedia.bulbagarden.net/wiki/" + ability + "_(Ability)"
            contents = crawler.fetch_or_download(filename, url)
            if contents is None:
                continue
            
            sanitized_name = line.strip()
            entries = process_file(sanitized_name, contents)
            all_entries[sanitized_name] = entries

    crawler.write_data_to_file(all_entries, "Data/Abilities")

if __name__ == '__main__':
    main()
