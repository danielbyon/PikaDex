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
    "gen1", 
    "gen2",
    "gen3",
    "gen4", 
    "gen5",
    "gen6",
    "gen7",
    "gen8"
]
moveset_file_suffixes = [
    "-Generation_I_learnset", 
    "-Generation_II_learnset",
    "-Generation_III_learnset",
    "-Generation_IV_learnset", 
    "-Generation_V_learnset",
    "-Generation_VI_learnset",
    "-Generation_VII_learnset",
    ""
]
moveset_page_suffixes = [
    "/Generation_I_learnset", 
    "/Generation_II_learnset",
    "/Generation_III_learnset",
    "/Generation_IV_learnset", 
    "/Generation_V_learnset",
    "/Generation_VI_learnset",
    "/Generation_VII_learnset",
    ""
]
EXPECTED_COLUMN_COUNT = [
    6,
    6,
    9,
    9,
    7,
    10,
    7,
    7
]
ENTRY_KEYS = {
    0: ['red', 'blue', 'yellow'],
    1: ['gold', 'silver', 'crystal'],
    2: ['ruby', 'sapphire', 'emerald', 'fireRed', 'leafGreen'],
    3: ['diamond', 'pearl', 'platinum', 'heartGold', 'soulSilver'],
    4: ['black', 'white', 'black2', 'white2'],
    5: ['x' ,'y', 'omegaRuby', 'alphaSapphire'],
    6: ['sun', 'moon', 'ultraSun', 'ultraMoon'],
    7: ['sword', 'shield']
}
ENTRY_LEVEL_INDICES = {
    0: [0, 0, 1],
    1: [0, 0, 1],
    2: [0, 0, 0, 1, 1],
    3: [0, 0, 0, 1, 1],
    4: [0, 0, 1, 1],
    5: [0, 0, 1, 1],
    6: [0, 0, 1, 1],
    7: [0, 1]
}
ENTRY_MOVE_INDICES = {
    0: [2, 2, 2],
    1: [2, 2, 2],
    2: [2, 2, 2, 2, 2],
    3: [2, 2, 2, 2, 2],
    4: [2, 2, 2, 2],
    5: [2, 2, 2, 2],
    6: [2, 2, 2, 2],
    7: [2, 2]
}

def base_page_name(name):
    return name.strip().replace(' ', '_')
    
def process_table(table, level_index, move_index):
    node = table.find_all('td')[1]

    rows = node.find_all('tr')
    moves = []
    for row in rows:
        rowNodes = row.find_all('td')
        if len(rowNodes) < 2:
            continue
        levelNode = rowNodes[level_index]
        moveNode = rowNodes[move_index]
        
        level = levelNode.text.strip() if levelNode.span is None else levelNode.span.text.strip()
        name = moveNode.text.strip()
        if level == "N/A":
            continue
        elif level == "Evo.":
            level = "-1"
        
        moveDict = {
            'level': level,
            'name': name
        }
        moves.append(moveDict)
    
    return moves

def process_file(name, generation_index, contents):
    soup = BeautifulSoup(contents, 'lxml').html.body
    entries = []

    levelUpNodes = soup.find_all('span', id=re.compile('By_leveling_up*'))
    if levelUpNodes is None or len(levelUpNodes) == 0:
        return entries
        
    for levelUpNode in levelUpNodes:
        node_parent = levelUpNode.find_parent()
        node = node_parent.find_next_sibling()
        form_name = None
        
        while True:
            if node.name != u"table":
                if node.name == u"h5":
                    form_name = node.span.text.strip()
                resolved_table = node.find_next_sibling()
            else:
                resolved_table = node
                
            entry_keys = []
            entry_level_indexes = []
            entry_move_indexes = []
            if node_parent.name == 'h4': # Normal, non-game specific
                entry_keys.append(moveset_keys[generation_index])
            else:
                game_node_text = node_parent.find_previous_sibling('h4').span.text
                if game_node_text == u'Pokémon: Let\'s Go, Pikachu! and Let\'s Go, Eevee!':
                    entry_keys.append('letsGoPikachu')
                    entry_keys.append('letsGoEevee')
                elif game_node_text == u'Pokémon Sun, Moon, Ultra Sun and Ultra Moon':
                    entry_keys.append('sun')
                    entry_keys.append('moon')
                    entry_keys.append('ultraSun')
                    entry_keys.append('ultraMoon')
                    
            if len(resolved_table.find_all('td')[1].table.tr.find_all('th')) != EXPECTED_COLUMN_COUNT[generation_index]:
                if len(entry_keys) > 2:
                    entry_level_indexes.append(0)
                    entry_level_indexes.append(0)
                    entry_level_indexes.append(1)
                    entry_level_indexes.append(1)
                    entry_move_indexes.append(2)
                    entry_move_indexes.append(2)
                    entry_move_indexes.append(2)
                    entry_move_indexes.append(2)
                elif len(entry_keys) > 1:
                    entry_level_indexes.append(0)
                    entry_level_indexes.append(1)
                    entry_move_indexes.append(2)
                    entry_move_indexes.append(2)
                else:
                    entry_keys = ENTRY_KEYS[generation_index]
                    entry_level_indexes = ENTRY_LEVEL_INDICES[generation_index]
                    entry_move_indexes = ENTRY_MOVE_INDICES[generation_index]
            else: # Column count matches expected
                for x in range(0, len(entry_keys)):
                    entry_level_indexes.append(0)
                    entry_move_indexes.append(1)
            
            for j in range(0, len(entry_keys)):
                game = entry_keys[j]
                level_index = entry_level_indexes[j]
                move_index = entry_move_indexes[j]
                
                moves = process_table(resolved_table, level_index, move_index)
                
                wrapped = {}
                wrapped['game'] = game
                wrapped['moves'] = moves
                if form_name:
                    wrapped['formName'] = form_name
                else:
                    wrapped['formName'] = name
                
                entries.append(wrapped)
            
            if form_name:
                node = resolved_table.find_next_sibling()
                if node is None:
                    break
                if node.name != u'h5':
                    break
            else:
                break
                
    return entries

def main():
    print("This is the Pokepedia Pokemon Crawler")

    all_entries = {}
        
    with codecs.open("PokemonList.txt", 'r', encoding='utf8') as f:
        for line in f:
            pokemon = base_page_name(line)
            pokemon_entries = {}
            for i in range(0, len(moveset_keys)):
                file_suffix = moveset_file_suffixes[i]
                page_suffix = moveset_page_suffixes[i]

                print(u"Processing {0}{1}".format(pokemon.encode('ascii', 'ignore').decode('ascii'), file_suffix))

                filename = u"Cached/Learnsets/{0}{1}.html".format(pokemon.rstrip('.'), file_suffix)

                url = u"http://bulbapedia.bulbagarden.net/wiki/{0}_(Pokémon){1}".format(pokemon, page_suffix)
                contents = crawler.fetch_or_download(filename, url)
                if contents is None:
                    continue

                entries = process_file(line.strip(), i, contents)
                key = moveset_keys[i]
                pokemon_entries[key] = entries
                
            if not pokemon_entries:
                print(u"Empty entries for {}".format(pokemon))
                sys.exit(1)
            
            all_entries[line.strip()] = pokemon_entries
            
    crawler.write_data_to_file(all_entries, "Data/LearnsetLevel2")

if __name__ == '__main__':
    main()
