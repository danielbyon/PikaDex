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
import re
import PokemonDB as pdb

def process_file(contents):
    soup = BeautifulSoup(contents, 'lxml').html.body
    entries = {}
    
    for h2 in soup.main.find_all('h2'):
        if h2.text.strip() == 'Game descriptions':
            table = h2.find_next_sibling().table
            if not table:
                print('Could not find table')
                return entries
    
    for row in table.find_all('tr'):
        description = row.td.text.strip()
        for game_node in row.find_all('span'):
            game = game_node.text.strip()
            entries[game] = description
    
    return entries

def main():
    print('This is the PikaDex Ability Crawler')

    all_entries = {}
    
    file_path = 'Cached/PokemonDBAbilities/'
    
    with codecs.open("AbilitiesList.txt", 'r', encoding='utf8') as f:
        for line in f:
            name = line.strip()
            url_name = name.replace(' ', '-').replace('\'', '')
            print('Processing {}'.format(url_name))
            
            filename = file_path + '{}.html'.format(url_name)
            url = 'https://pokemondb.net/ability/' + url_name
            
            contents = crawler.fetch_or_download(filename, url)
            entries = process_file(contents)
            if entries:
                all_entries[name] = entries

    crawler.write_data_to_file(all_entries, "Data/Abilities")
#   print(all_entries)
    print("Done!")

if __name__ == '__main__':
    main()
    