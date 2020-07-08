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
    "gen6",
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
    "/Generation_VII_learnset"
]

def base_page_name(name):
    return name.strip().replace(' ', '_')
    
def process_table(table):
    node = table.find_all('td')[1]

    rows = node.find_all('tr')
    moves = []
    for row in rows:
        rowNodes = row.find_all('td')
        if len(rowNodes) < 2:
            continue
        levelNode = rowNodes[0]
        moveNode = rowNodes[1]
        
        level = levelNode.text.strip() if levelNode.span is None else levelNode.span.text.strip()
        name = moveNode.text.strip()
        
        moveDict = {
            'level': level,
            'name': name
        }
        moves.append(moveDict)
    
    return moves

def process_file(name, contents):
    soup = BeautifulSoup(contents, 'lxml').html.body
    allMoves = []

    node = soup.find('span', id='By_leveling_up')
    if node is None:
        return allMoves
        
    node = node.find_parent().find_next_sibling()
    form_name = None
    
    while True:
        if node.name != u"table":
            if node.name == u"h5":
                form_name = node.span.text.strip()
            resolved_table = node.find_next_sibling()
        else:
            resolved_table = node
        
        moves = process_table(resolved_table)
        
        if moves:
            wrapped = {}
            wrapped['moves'] = moves
            if form_name:
                wrapped['formName'] = form_name
            else:
                wrapped['formName'] = name
            
            allMoves.append(wrapped)
        
        if form_name:
            node = resolved_table.find_next_sibling()
            if node is None:
                break
            if node.name != u'h5':
                break
        else:
            break
    
    return allMoves
    
#    node = node.find_parent().find_next_sibling('table')
#    if node is None:
#        return ""
#    node = node.find_all('td')[1]
#
#    rows = node.find_all('tr')
#    moves = []
#    for row in rows:
#        rowNodes = row.find_all('td')
#        if len(rowNodes) < 2:
#            continue
#        levelNode = rowNodes[0]
#        moveNode = rowNodes[1]
#        
#        level = levelNode.text.strip() if levelNode.span is None else levelNode.span.text.strip()
#        name = moveNode.text.strip()
#        
#        moveDict = {
#            'level': level,
#            'name': name
#        }
#        moves.append(moveDict)
#    
#    return moves

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

                entries = process_file(line.strip(), contents)
                key = moveset_keys[i]
                pokemon_entries[key] = entries
            
            if not pokemon_entries:
                print(u"Empty entries for {}".format(pokemon))
                sys.exit(1)
            
            all_entries[line.strip()] = pokemon_entries

    crawler.write_data_to_file(all_entries, "Data/LearnsetLevel")

if __name__ == '__main__':
    main()
