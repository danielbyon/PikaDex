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

TAB_HEADER_IDS = {
    1: ['tabs-moves-1', 'tabs-moves-2'],
    2: ['tabs-moves-3', 'tabs-moves-4'],
    3: ['tabs-moves-5', 'tabs-moves-6', 'tabs-moves-7'],
    4: ['tabs-moves-8', 'tabs-moves-9', 'tabs-moves-10'],
    5: ['tabs-moves-11', 'tabs-moves-12'],
    6: ['tabs-moves-13', 'tabs-moves-14'],
    7: ['tabs-moves-15', 'tabs-moves-16', 'tabs-moves-17'],
    8: ['tabs-moves-18']
}

GAMES_FOR_TAB = {
    'tabs-moves-1': ['red', 'blue'],
    'tabs-moves-2': ['yellow'],
    'tabs-moves-3': ['gold', 'silver'],
    'tabs-moves-4': ['crystal'],
    'tabs-moves-5': ['ruby', 'sapphire'],
    'tabs-moves-6': ['fireRed', 'leafGreen'],
    'tabs-moves-7': ['emerald'],
    'tabs-moves-8': ['diamond', 'pearl'],
    'tabs-moves-9': ['platinum'],
    'tabs-moves-10': ['heartGold', 'soulSilver'],
    'tabs-moves-11': ['black', 'white'],
    'tabs-moves-12': ['black2', 'white2'],
    'tabs-moves-13': ['x', 'y'],
    'tabs-moves-14': ['omegaRuby', 'alphaSapphire'],
    'tabs-moves-15': ['sun', 'moon'],
    'tabs-moves-16': ['ultraSun', 'ultraMoon'],
    'tabs-moves-17': ['letsGoPikachu', 'letsGoEevee'],
    'tabs-moves-18': ['sword', 'shield'],
}

def generations_from_number(number):
    gens = [8]
    if number < 810:
        gens.append(7)
    if number < 722:
        gens.append(6)
    if number < 650:
        gens.append(5)
    if number < 494:
        gens.append(4)
    if number < 387:
        gens.append(3)
    if number < 252:
        gens.append(2)
    if number < 152:
        gens.append(1)
    return gens

def process_file(contents, generation):
    soup = BeautifulSoup(contents, 'lxml').html.body
    entries = {}
    
    tab_ids = TAB_HEADER_IDS[generation]
    for tab_id in tab_ids:
        tab = soup.find('div', id=tab_id)
        if tab is None:
            return None
        headers = tab.find_all('h3')
        for header in headers:
            if header.text.strip() != 'Move Tutor moves':
                continue
            div = header.find_next_sibling().find_next_sibling()
            if div is None or div.name != 'div':
                continue
            
            form_names = None
            if div['class'] == ['tabset-moves-game-form', 'tabs-wrapper']:
                form_names = []
                tab_list = div.div
                for tab in tab_list.find_all('a'):
                    form_names.append(tab.text.strip())
                table = tab_list.find_next_sibling().table
            else:
                table = div.table
            
            if table is None or table.tbody is None:
                continue
            
            rows = table.tbody.find_all('tr')
            moves = []
            for row in rows:
                name = row.td.text.strip()
                moves.append(name)
            all_moves = ",".join(moves)
        
            games = GAMES_FOR_TAB[tab_id]
            for game in games:
                if form_names:
                    for form_name in form_names:
                        key = '{}.{}'.format(game, form_name)
                        entries[key] = all_moves
                else:
                    entries[game] = all_moves
    
    return entries

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
        
        if name in all_entries:
            # Don't process the same pokemon multiple times
            continue
            
        print('Processing {}'.format(name))
            
        pokemon_entries = {}
        
        generations = generations_from_number(int(number))
        for gen in generations:
            url = 'https://pokemondb.net' + urlPath + '/moves/{}'.format(gen)
            filename = 'Cached/PokemonDBPokemon/{}-{}-moves-{}.html'.format(number, name, gen)
            print('Processing {}'.format('{} - gen {}'.format(name, gen)))
            
            contents = crawler.fetch_or_download(filename, url)
            soup = BeautifulSoup(contents, 'lxml').html.body
            entries = process_file(contents, gen)
            if entries is not None:
                pokemon_entries['gen{}'.format(gen)] = entries
        
        all_entries[name] = pokemon_entries

    crawler.write_data_to_file(all_entries, "Data/LearnsetTutoring2")
    print(all_entries)
    print("Done!")

if __name__ == '__main__':
    main()
