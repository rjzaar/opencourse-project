#!/bin/env python3
# using regex module to parse, os to delete, and sys to parse args
import re, os, sys

# regex to match the error files located inside xml
#  ((?<=Configuration <em class="placeholder">)(.*?)(?=<\/em>))+
regex = re.compile(r'Configuration <em class="placeholder">(.*?)</em>')

# input path of the error log (TODO change if stdin needed)
if len(sys.argv) > 1:
    input_path = sys.argv[1]
else:
    input_path = 'testregex.txt'

print("file to open"+input_path)
# open filestream and read in content
file_input= open(input_path, 'r')
file_text = file_input.read()
print (file_text)
# reresults = re.findall('/Configuration <em class="placeholder">(.*?)</em>/', file_text)
# print (reresults)
# Using compiled regex, send all found matches into a list
file_regexed = regex.match(file_text)
print (file_regexed)
# Remove duplicate files from the list
clean_file_regexed = list(dict.fromkeys(file_regexed))

# Print all matches
print("---->  Files parsed for error")
print(clean_file_regexed)

# ---------------------------------
# FOR TESTING TOUCH ALL FILES FIRST
# print("---->  Touching files for test")
# for file in file_regexed:
#     f = open(file, "w")
#     f.close()
# print("---->  Current directory")
# print(os.listdir())
# ---------------------------------

# Iterate over list, deleting as we go
# for file in clean_file_regexed:
#     os.remove(file)

# ---------------------------------
# FOR TESTING DISPLAY DIR
print("---->  Directory after")
print(os.listdir())
# ---------------------------------
