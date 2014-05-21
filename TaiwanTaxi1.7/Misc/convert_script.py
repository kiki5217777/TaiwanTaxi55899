# coding: utf-8

import re
import plistlib

class City:
	def __init__(self):
		self.name = None
		self.zones = []
	def description(self):
		return "- {0} \n \t{1}".format(self.name.encode('utf-8'), '\n\t'.join(self.zones).encode('utf-8'))

def read_source_file():
	source_file = 'tw_location.txt'
	print 'reading {0} into list'.format(source_file)
	str = None;
	with open(source_file, 'r') as f:
		str = f.read()
	return str.decode("utf-8") # strings may contain UTF-8 character bytes but they are not of type unicode
	
def get_city_list(city_line):
	regexp = r'("[^"]+")'
	cities = []
	for city in re.findall(regexp, city_line):
		if city.startswith('"') and city.endswith('"'):
			processed = city[1:-1].strip() # for removing quotes and spaces
			if len(processed) > 0:
				cities.append(processed) 
	return cities

def generate_city_and_zone(city_name, zone_line):
	regexp = r'("[^"]+")'
	firstZoneItem = u'(請選擇)'
	zones = [firstZoneItem]
	for zone in re.findall(regexp, zone_line):
		if zone.startswith('"') and zone.endswith('"'):
			processed = zone[1:-1].strip() # for removing quotes and spaces
			if len(processed) > 0:
				zones.append(processed)
	city = City()
	city.name = city_name
	city.zones = zones
	return city
	
def generate_plist(cities):
	pl = []
	for city in cities:
		item = dict(
			region = city.name,
			zones = city.zones
		)
		pl.append(item)
	plistlib.writePlist(pl, 'tw_regions1.plist')
		
def parse():
	str = read_source_file()
	lines = str.split(';')
	city_list = get_city_list(lines[0])
	index = 1
	cities = []
	for city_name in city_list:
		city = generate_city_and_zone(city_name, lines[index])
		cities.append(city)
		index += 1
		print city.description()
	print 'begin generating plist for region and zones'
	generate_plist(cities)

parse()


	