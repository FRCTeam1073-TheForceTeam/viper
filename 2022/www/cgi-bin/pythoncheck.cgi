#!/usr/bin/python3

import os


print ("Content-type: text/html\n\n")
print ("<!DOCTYPE html>\n")
print ("<html lang=\"en\">\n")
print ("<head>\n")
print ("<title>hello</title>")
print ("</head><body>")
print ("<H1>HELLO FROM PYTHON</H1>")
print ("<p>" + os.environ['QUERY_STRING'] + "</p>")
print ("</body></html>")
