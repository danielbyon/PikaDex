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

def process_move(contents):
    soup = BeautifulSoup(contents, 'lxml').html.body
    tab = soup.find('div', id='tabs-moves-17')
    if tab is None:
        return None
    headers = tab.find_all('h3')
    for header in headers:
        if header.text.strip() != 'Moves learnt by TM':
            continue
        table = header.parent.table
        if table is None or table.tbody is None:
            continue
        
        rows = table.tbody.find_all('tr')
        machines = []
        for row in rows:
            name = row.td.text.strip()
            machines.append(name)
        retVal = ";".join(machines)
    
        return retVal
    
    return None

def main():
    print("This is the Pokepedia Moves Crawler")

    all_entries = {}
    
    filename = "Cached/PokemonDBPokemon/_AllPokemon.html"
    url = "https://pokemondb.net/pokedex/all"
    contents = crawler.fetch_or_download(filename, url)
    soup = BeautifulSoup(contents, 'lxml').html.body
    table = soup.find('table', id='pokedex')
    
    for row in table.tbody.find_all('tr'):
        cells = row.find_all('td')
        number = cells[0].text.strip()
        moveNode = cells[1].a
        name = cells[1].a.text.strip()
        
        urlPath = moveNode['href']
        url = 'https://pokemondb.net' + urlPath + '/moves/7'
        filename = 'Cached/PokemonDBPokemon/{}-{}-moves-7.html'.format(number, name)
        print('Processing {}'.format(name))
        
        contents = crawler.fetch_or_download(filename, url)
        entries = process_move(contents)
        if entries is not None:
            all_entries[name] = entries

    crawler.write_data_to_file(all_entries, "Data/LearnsetMachines-TM-LGPLGE")

if __name__ == '__main__':
    main()
