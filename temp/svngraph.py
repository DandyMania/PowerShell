#! /usr/bin/env python
# -*- coding: utf-8 -*-
"""
	@brief	svnのリポジトリ構造を解析してGraphvisに渡す
	@author Yamauchi_Shoji
	@date   2014/07/14
"""

import os, os.path, sys, re, time
import json
import subprocess

from pprint import pprint
import logging
LOG_FILENAME = 'svngraph.log'
logging.basicConfig(filename=LOG_FILENAME,level=logging.DEBUG)

	

def __usage():
	print("usage:")
	print("svngraph.py [repositoryURL : default=root]")

def run_cmd(cmd):
	print(cmd)
	p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	stdout_data, stderr_data = p.communicate()
	return p.returncode, stdout_data, stderr_data
# ==============================================================================
# 	main
# ==============================================================================
def main():

	global EXPORT_LINK_LEVEL

	# 使い方表示
	if len(sys.argv) < 1 or len(sys.argv) > 2:
		__usage()
		sys.exit(0)
		
	start_time = time.clock()

	svnroot =  run_cmd(['svn','info'])[1].split("\r\n")[2].replace("URL: ","") #.replace("Repository Root: ","")
	print(svnroot)

	#svnpropinfo = run_cmd(['svn','proplist',svnroot,'-R',"-v"]).split("\r\n")
	
	#print(svnpropinfo)


	end_time = time.clock()
	print("complete![time: ",(end_time - start_time),"sec]")
		
# __main__
if __name__ == '__main__':
	#psyco.full()
	main()

