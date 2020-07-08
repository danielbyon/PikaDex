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

MOVES_TO_SKIP = [
    "terrainpulse",
    "burningjealousy",
    "flipturn",
    "grassyglide",
    "risingvoltage",
    "coaching",
    "scorchingsands",
    "dualwingbeat",
    "meteorbeam",
    "skittersmack",
    "tripleaxel",
    "corrosivegas",
    "expandingforce",
    "poltergeist",
    "scaleshot",
    "lashout",
    "steelroller",
    "mistyexplosion",
    "junglehealing", # Zarude level (not move tutor)
    "shellsidearm", # Galarian Slowbro level
    "surgingstrikes", # Urshifu
    "wickedblow" # Urshifu
]

def process_move(contents):
    entries = {}
    soup = BeautifulSoup(contents, 'lxml').html.body
    header = soup.find('h2', id='move-descr')
    table = header.find_next_sibling().table
    rows = table.find_all('tr')
    for row in rows:
        game_nodes = row.th.find_all('span')
        description = row.td.text.strip()
        for game_node in game_nodes:
            game_name = game_node.text.strip()
            entries[game_name] = description
    
    return entries

def main():
    print("This is the Pokepedia Moves Crawler")

    all_entries = {}
    
    filename = "Cached/PokemonDBMoves/_AllMoves.html"
    url = "https://pokemondb.net/move/all"
    contents = crawler.fetch_or_download(filename, url)
    soup = BeautifulSoup(contents, 'lxml').html.body
    table = soup.find('table', id='moves')
    
    for row in table.tbody.find_all('tr'):
        moveNode = row.td.a
        urlPath = moveNode['href']
        url = 'https://pokemondb.net' + urlPath
        slug = urlPath.split('/')[-1].replace('-', '')
        
        # Temp until PokemonDB updates their wiki pages for the new moves
        if slug in MOVES_TO_SKIP or 'gmax' in slug:
            continue
        
        filename = 'Cached/PokemonDBMoves/{}.html'.format(slug)
        print('Processing {}'.format(slug))
        
        contents = crawler.fetch_or_download(filename, url)
        entries = process_move(contents)
        all_entries[slug] = entries

    crawler.write_data_to_file(all_entries, "Data/MoveDescriptions")

if __name__ == '__main__':
    main()
