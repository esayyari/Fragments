#!/usr/bin/env python
import re
import sys

#sed -e "s/>\(.*\)/@>\1@/g" $1|tr -d "\n"|tr "@" "\n"|tail -n+2


def main(filename):
	tmpfile = filename + ".tmp"
	g = open(tmpfile, 'w')
	f = open(filename, 'r')
	for line in f:
		line = line.rstrip('\n')
		r = re.sub('>(.*)', '@>\\1@', line)	
		g.write(r)
	g.close()
	g = open(tmpfile, 'r')
	for line in g:
		line = re.sub('@','\n',line)
		line = re.sub('^\n','',line)
		return line

if "__main__" == __name__:
	filename = sys.argv[1]
	tmpfile = filename + ".tmp"
        g = open(tmpfile, 'w')
        f = open(filename, 'r')
        for line in f:
                line = line.rstrip('\n')
                r = re.sub('>(.*)', '@>\\1@', line)
                g.write(r)
        g.close()
        g = open(tmpfile, 'r')
        for line in g:
                linet = re.sub('@','\n',line)
		linet = re.sub('^\n','',linet)
                print linet
	
