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
    
def gen_key(name, form_name):
    if form_name:
        return "{}.{}".format(name, form_name)
    else:
        return name

def process_table(table, key):
    entries = {}
    
    if key == "gen6" or key == "gen7" or key == "gen8":
        table = table.find_all('tr', recursive=False)[1].find('table')
        if table is None:
            print("could not find inner table")
            return entries
        moveRows = table.find_all('tr', recursive=False)[1:]
    else:
        moveRows = table.find_all('tr', recursive=False)[2:-1]

    if len(moveRows) > 0 and moveRows[0].text.strip() == "This Pokémon learns no moves by tutoring.":
        print("No moves for {0}".format(key))
        return entries

    for row in moveRows:
        gameNodes = row.find_all('th')
        games = []
        for gameNode in gameNodes:
            style = gameNode.get('style')
            if style is None:
                print("FAIL: Couldn't get style, wrong table?")
                return {}
            if 'background:#FFFFFF' in style or 'background:#FFF' in style:
                continue
            # a = gameNode.a
            # if a is None:
            #     continue
            game = gameNode.span.text.strip()
            if game == "XD":
                continue
            games.append(game)
        if len(games) == 0:
            continue
        gameString = ",".join(games)
        
        moveName = row.find('td').a.text.strip()
        entries[moveName] = gameString
    
    return entries

def process_file(key, contents, pokemon_entries):
    soup = BeautifulSoup(contents, 'lxml').html.body

    node = soup.find('span', id='By_tutoring')
    if node is None:
        return
    
    node = node.find_parent().find_next_sibling()
    if node is None:
        print("Could not find table node")
        return entries
    
    form_name = None
    
    form_header_name = ""
    while True:
        if node.name != u"table":
            if node.name == u"h6" or node.name == u"h5":
                if node.name == u"h6":
                    form_header_name = u"h6"
                else:
                    form_header_name = u"h5"
                form_name = node.span.text.strip()
            table = node.find_next_sibling()
        else:
            table = node
        
        entries = process_table(table, key)
        if entries:
            form_key = gen_key(key, form_name)
            pokemon_entries[form_key] = entries
        
        if form_name:
            node = table.find_next_sibling()
            if node is None:
                break
            if node.name == u'p':
                node = node.find_next_sibling()
            if node.name != form_header_name:
                break
        else:
            break

def main():
    print("This is the Pokepedia Pokemon Crawler")

    all_entries = {}
    
    with codecs.open("PokemonList.txt", 'r', encoding='utf8') as f:
        count = 0
        for line in f:
#            count += 1
#            if count != 20:
#                continue
#            if count > 20:
#                break
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

                process_file(key, contents, pokemon_entries)
            
            if pokemon_entries:
                all_entries[line.strip()] = pokemon_entries

    crawler.write_data_to_file(all_entries, "Data/LearnsetTutoring")

if __name__ == '__main__':
    main()
