# coding: utf-8

import re
import plistlib

class TaxiOrder:
	def __init__(self):
		self.name = ''
		self.tel = ''
		self.region = ''
		self.zone = ''
		self.road = ''
		self.section = ''
		self.alley = ''
		self.lane = ''
		self.number = ''
		self.useCreditCard = False
		self.hasLuggage = False
		self.hasPet = False
		self.hasWheelChair = False
		self.isDrunk = False
		self.memo = ''

def create_test_order_01():
	'''高雄市前金區五福三路 57 號 4 樓'''
	order = TaxiOrder()
	order.name = '郭瑩山'
	order.tel = '0927688670'
	order.region = '高雄市'
	order.zone = '前金區'
	order.road = '五福三路'
	order.number = '57'
	order.useCreditCard = True;
	order.hasLuggage = True;
	order.hasPet = False
	order.hasWheelChair = False
	order.isDrunk = False
	order.memo = 'STUDIO A 大立精品店'
	return order

def create_test_order_02():
	'''台中市西屯區福星路 407 號'''
	order = TaxiOrder()
	order.name = '方寧辰'
	order.tel = '0913814021'
	order.region = '台中市'
	order.zone = '西屯區'
	order.road = '福星路'
	order.section = ''
	order.number = '407'
	order.useCreditCard = False;
	order.hasLuggage = False;
	order.hasPet = False
	order.hasWheelChair = False
	order.isDrunk = False
	order.memo = '台中逢甲店'
	return order

def create_test_order_03():
	'''台中市台中港路一段 299 號 2 樓'''
	order = TaxiOrder()
	order.name = '馬淑燕'
	order.tel = '0932101333'
	order.region = '台中市'
	order.zone = ''
	order.road = '台中港路'
	order.section = '一'
	order.number = '299'
	order.useCreditCard = False;
	order.hasLuggage = False;
	order.hasPet = False
	order.hasWheelChair = True
	order.isDrunk = True
	order.memo = '2 樓'
	return order

def create_test_order_04():
	'''台北市大安區敦化南路一段 219 號'''
	order = TaxiOrder()
	order.name = '張怡君'
	order.tel = '0955503379'
	order.region = '台北市'
	order.zone = '大安區'
	order.road = '敦化南路'
	order.section = '一'
	order.number = '219'
	order.useCreditCard = False;
	order.hasLuggage = False;
	order.hasPet = False
	order.hasWheelChair = False
	order.isDrunk = True
	order.memo = '優仕 敦南店'
	return order
	
def create_test_order_05():
	'''新北市中和區中山路三段 122 號 1 樓'''
	order = TaxiOrder()
	order.name = '楊舒平'
	order.tel = '0916966288'
	order.region = '新北市'
	order.zone = '中和區'
	order.road = '中山路'
	order.section = '三'
	order.number = '122'
	order.useCreditCard = False;
	order.hasLuggage = False;
	order.hasPet = False
	order.hasWheelChair = False
	order.isDrunk = False
	order.memo = ''
	return order

def generate_plist():
	orders = [ 
	create_test_order_01(), 
	create_test_order_02(),
	create_test_order_03(),
	create_test_order_04(),
	create_test_order_05(),
	]
	pl = []
	for order in orders:
		item = dict(
			name = order.name.decode("utf-8"),
			tel = order.tel.decode("utf-8"),
			region = order.region.decode("utf-8"),
			zone = order.zone.decode("utf-8"),
			road = order.road.decode("utf-8"),
			section = order.section.decode("utf-8"),
			alley = order.alley.decode("utf-8"),
			lane = order.lane.decode("utf-8"),
			number = order.number.decode("utf-8"),
			useCreditCard = order.useCreditCard,
			hasLuggage = order.hasLuggage,
			hasPet = order.hasPet,
			hasWheelChair = order.hasWheelChair,
			isDrunk = order.isDrunk,
			memo = order.memo.decode("utf-8")
		)
		pl.append(item)
	plistlib.writePlist(pl, 'test_orders.plist')

generate_plist()
	