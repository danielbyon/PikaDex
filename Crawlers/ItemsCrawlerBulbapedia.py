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
from BulbapediaManualItems import MANUAL_ITEMS

def process_file(contents, item_name):
    soup = BeautifulSoup(contents, 'lxml').html.body
    entries = {}
    
    outer_table = soup.find('div', id='mw-content-text')
    
    # Pocket
    for th in outer_table.find_all('th'):
        if th.text.strip() != 'Pocket':
            continue
        
        pocket = {}
        for row in th.parent.find_next_siblings('tr'):
            gen = row.th.text.strip()
            if row.td.sup is not None or row.td.small is not None:
                if row.td.small is not None:
                    to_remove = row.td.small.text.strip()
                else:
                    to_remove = row.td.sup.text.strip()
                name = row.td.text.strip().replace(to_remove, '').strip().lower()
                
                games = pdb.parse_game_titles(row.td)
                if games:
                    for game in pdb.parse_game_titles(row.td):
                        pocket[game] = name
                else:
                    pocket[gen] = name
            else:
                name = row.td.text.strip().lower()
                pocket[gen] = name
        if not pocket:
            print("Invalid pocket entries")
            return None
        entries['pocket'] = pocket
        break
        
    # Price
    price_header = outer_table.find('span', id='Price')
    if price_header is not None:
        for table_candidate in price_header.parent.find_next_siblings('table'):
            if table_candidate.table is None:
                continue
        
            price = {}
            for row in table_candidate.table.find_all('tr')[1:]:
                tds = row.find_all('td')
                cost = tds[1].text.strip().replace(',', '')
                sell = tds[2].text.strip().replace(',', '')
                
                game_price = {}
                game_price['cost'] = cost
                game_price['sell'] = sell
                
                pdb.parse_game_specific_values(tds[0], price, game_price)
            
            if not price:
                print("Invalid price entries")
                return None
            entries['prices'] = price
            break
    
    # Description
    description_header = outer_table.find('span', id='Description')
    if description_header is not None:
        for table_candidate in description_header.parent.find_next_siblings('table'):
            if table_candidate.table is None:
                continue
            
            descriptions = {}
            for row in table_candidate.table.find_all('tr')[1:]:
                tds = row.find_all('td')
                
                description = tds[1].text.strip()
                
                pdb.parse_game_specific_values(tds[0], descriptions, description)
            
            if not descriptions:
                print("Invalid descriptions entries")
                return None
            entries['descriptions'] = descriptions
            break
    
    if not 'pocket' in entries:
        return None
    if not 'prices' in entries:
        return None
    if not 'descriptions' in entries:
        return None
    return entries

def main():
    print('This is the Pokepedia Items Crawler')

    all_entries = []
    
    file_path = 'Cached/Items/Bulbapedia/'
    
    filename = file_path + '_AllItems.html'
    url = 'https://bulbapedia.bulbagarden.net/wiki/List_of_items_by_name'
    contents = crawler.fetch_or_download(filename, url)
    soup = BeautifulSoup(contents, 'lxml').html.body
    
    items = []
    
    for h3 in soup.h2.find_next_siblings('h3'):
        table = h3.find_next_sibling('table')
        
        for row in table.find_all('tr'):
            if row.td is None:
                continue
            
            tds = row.find_all('td')
            if len(tds) != 4:
                print('invalid row')
                continue
            
            link = tds[1].a['href']
            name = tds[1].text.strip()
            
            if 'mail' in name.lower():
                continue
            
            raw_gen = tds[2].text.strip().split('-')[0]
            if raw_gen == "I":
                gen = "1"
            elif raw_gen == "II":
                gen = "2"
            elif raw_gen == "III":
                gen = "3"
            elif raw_gen == "IV":
                gen = "4"
            elif raw_gen == "V":
                gen = "5"
            elif raw_gen == "VI":
                gen = "6"
            elif raw_gen == "VII":
                gen = "7"
            elif raw_gen == "VIII":
                gen = "8"
            else:
                print('Invalid gen: {}'.format(raw_gen))
                sys.exit(1)
            
            url = 'https://bulbapedia.bulbagarden.net' + link
            
            item = {
                'name': name,
                'generationIntroduced': gen,
                'url': url,
            }
            items.append(item)
    
    for item in MANUAL_ITEMS:
        items.append(item)
    
    for item in items:
        name = item['name']
        generationIntroduced = item['generationIntroduced']
        url = item['url']
        
        filename = file_path + '{}.html'.format(name.replace(' ', '-'))
        
        print('Processing {}'.format(name))
        
        contents = crawler.fetch_or_download(filename, url)
        entries = process_file(contents, name)
        if entries:
            entries['name'] = name
            entries['imageName'] = name.replace(' ', '-').lower()
            entries['generationIntroduced'] = generationIntroduced
            all_entries.append(entries)
    
    crawler.write_data_to_file(all_entries, "Data/BulbapediaItems")
#    print(all_entries)
    print("Done!")

if __name__ == '__main__':
    main()
