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

moveset_keys = [
    "gen8", 
    "gen1", 
    "gen2",
    "gen3",
    "gen4", 
    "gen5",
    "xy",
    "oras",
    "gen7"
]
moveset_file_suffixes = [
    "", 
    "-Generation_I_learnset", 
    "-Generation_II_learnset",
    "-Generation_III_learnset",
    "-Generation_IV_learnset", 
    "-Generation_V_learnset",
    "-Generation_VI_learnset",
    "-Generation_VI_learnset",
    "-Generation_VII_learnset"
]
moveset_page_suffixes = [
    "", 
    "/Generation_I_learnset", 
    "/Generation_II_learnset",
    "/Generation_III_learnset",
    "/Generation_IV_learnset", 
    "/Generation_V_learnset",
    "/Generation_VI_learnset",
    "/Generation_VI_learnset",
    "/Generation_VII_learnset"
]

def base_page_name(name):
    return name.strip().replace(' ', '_')

def process_file(key, contents):
    soup = BeautifulSoup(contents, 'lxml').html.body

    node = soup.find('span', id=re.compile('By_TM*'))
    if node is None:
        return ""
    
    node = node.find_parent().find_next_sibling('table')
    if node is None:
        return ""

    machineNodes = node.find_all('a', class_='mw-disambig')
    machines = []
    for node in machineNodes:
        name = node.span.text.strip()
        if key == "xy" and (name == "HM06" or name == "HM07"):
            continue
        
        game_specific = node.find_parent().find_next_sibling('td')
        if game_specific is not None:
            game_specific = game_specific.sup
            if game_specific is not None:
                game_specific_key = game_specific.text.strip().lower()
                if game_specific_key != key:
                    continue
        
        machines.append(name)
    retVal = ";".join(machines)
    return retVal

def main():
    print("This is the Pokepedia Pokemon Crawler")

    all_entries = {}
    
    with codecs.open("PokemonList.txt", 'r', encoding='utf8') as f:
        for line in f:
            pokemon_entries = {}
            for i in range(0, len(moveset_keys)):
                pokemon = base_page_name(line)
                file_suffix = moveset_file_suffixes[i]
                page_suffix = moveset_page_suffixes[i]

                print(u"Processing {0}{1}".format(pokemon.encode('ascii', 'ignore').decode('ascii'), file_suffix))

                filename = u"Cached/Learnsets/{0}{1}.html".format(pokemon.rstrip('.'), file_suffix)

                url = u"http://bulbapedia.bulbagarden.net/wiki/{0}_(Pokémon){1}".format(pokemon, page_suffix)
                contents = crawler.fetch_or_download(filename, url)
                if contents is None:
                    continue

                key = moveset_keys[i]
                entries = process_file(key, contents)
                pokemon_entries[key] = entries
            
            if not pokemon_entries:
                print(u"Empty entries for {}".format(pokemon))
                sys.exit(1)
            
            all_entries[line.strip()] = pokemon_entries

    crawler.write_data_to_file(all_entries, "Data/LearnsetMachines")

if __name__ == '__main__':
    main()
