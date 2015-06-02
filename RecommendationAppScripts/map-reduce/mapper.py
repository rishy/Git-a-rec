#!/usr/bin/python

# Reads user_languages_count.csv file from HDFS
# Creates key/value pairs, with user as keys 
# and the dict containing language count as value
# It finally emits these key value pairs to reducer.python

import numpy as np
import pandas as pd
from mrjob.protocol import JSONValueProtocol
from mrjob.job import MRJob
from decimal import *


class CreateUserTokens(MRJob):

	OUTPUT_PROTOCOL = JSONValueProtocol

	def mapper(self, _, line):
		data = line.strip().split(',')		
		if(data[0] == 'login'):
			pass
		else:
			yield (data[0], {"language": data[1], "count": data[2]})

	def reducer(self, key, values):
		
		values = list(values)
		# Set the precision of floats
		getcontext().prec = 3

		# Get total number of lines
		total_lines = 0
		for value in values:
			total_lines = total_lines + int(value['count'])

		user_dict = {}

		# Add proportions
		for value in values:
			user_dict[value['language']] = float(Decimal(int(value['count']))/Decimal(total_lines))

		yield None, {key:user_dict}


if __name__ == '__main__':
	CreateUserTokens.run()
