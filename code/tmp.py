#!/usr/bin/env python


from string import ascii_lowercase
import itertools

def iter_all_strings():
	size = 1
	while True:
		for s in itertools.product(ascii_lowercase, repeat = size):
			yield "".join(s)
		size += 1
		print size

gen = iter_all_strings()
def label_gen():
	for s in gen:
		return s
for i in range(0,100):
	print label_gen()
