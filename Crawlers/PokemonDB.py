#!/usr/bin/env python3 -tt

MOVE_TAB_HEADER_IDS = {
	1: ['tabs-moves-1', 'tabs-moves-2'],
	2: ['tabs-moves-3', 'tabs-moves-4'],
	3: ['tabs-moves-5', 'tabs-moves-6', 'tabs-moves-7'],
	4: ['tabs-moves-8', 'tabs-moves-9', 'tabs-moves-10'],
	5: ['tabs-moves-11', 'tabs-moves-12'],
	6: ['tabs-moves-13', 'tabs-moves-14'],
	7: ['tabs-moves-15', 'tabs-moves-16', 'tabs-moves-17'],
	8: ['tabs-moves-18']
}

MOVE_GAMES_FOR_TAB = {
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
	
def parse_game_titles(node):
	games = []
	for game_node in node.find_all('a'):
		try:
			title = game_node['title']
		except KeyError:
			continue
		if title == u'Pokémon Red and Blue Versions':
			games.append('red')
			games.append('blue')
		elif title == u'Pokémon Yellow Version':
			games.append('yellow')
		elif title == u'Pokémon Gold and Silver Versions':
			games.append('gold')
			games.append('silver')
		elif title == u'Pokémon Crystal Version':
			games.append('crystal')
		elif title == u'Pokémon Ruby and Sapphire Versions':
			games.append('ruby')
			games.append('sapphire')
		elif title == u'Pokémon Emerald Version':
			games.append('emerald')
		elif title == u'Pokémon FireRed and LeafGreen Versions':
			games.append('fireRed')
			games.append('leafGreen')
		elif title == u'Pokémon Diamond and Pearl Versions':
			games.append('diamond')
			games.append('pearl')
		elif title == u'Pokémon Platinum Version':
			games.append('platinum')
		elif title == u'Pokémon HeartGold and SoulSilver Versions':
			games.append('heartGold')
			games.append('soulSilver')
		elif title == u'Pokémon Black and White Versions':
			games.append('black')
			games.append('white')
		elif title == u'Pokémon Black and White Versions 2':
			games.append('black2')
			games.append('white2')
		elif title == u'Pokémon X and Y':
			games.append('x')
			games.append('y')
		elif title == u'Pokémon Omega Ruby and Alpha Sapphire':
			games.append('omegaRuby')
			games.append('alphaSapphire')
		elif title == u'Pokémon Sun and Moon':
			games.append('sun')
			games.append('moon')
		elif title == u'Pokémon Ultra Sun and Ultra Moon':
			games.append('ultraSun')
			games.append('ultraMoon')
		elif title == u'Pokémon: Let\'s Go, Pikachu! and Let\'s Go, Eevee!':
			games.append('letsGoPikachu')
			games.append('letsGoEevee')
		elif title == u'Pokémon Sword and Shield':
			games.append('sword')
			games.append('shield')
	return games

def parse_game_specific_values(node, all_dict, game_specific_value):
	for game in parse_game_titles(node):
		all_dict[game] = game_specific_value
