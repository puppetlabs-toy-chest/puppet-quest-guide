import json
from subprocess import *
from bs4 import BeautifulSoup, Tag

quest_path = "./_site/quests/"

quests =["welcome.html",
         "resources.html",
         "manifest_quest.html",
         "variables.html",
         "resource_ordering.html",]

quest_list = [quest_path + quest for quest in quests]

def pull_content(filename):
    with open(filename, 'r') as f:
        html = f.read()
    soup = BeautifulSoup(html, "html5lib")
    return soup.select("div[role=main]")[0]

html_doc = ''

shell = BeautifulSoup("<html><body></body></html>", "html5lib")
body = shell.body

quest_list.reverse()

for quest in quest_list:
    body.insert(0, pull_content(quest))
    pagebreak = Tag(name='div')
    pagebreak['class'] = 'page-break'
    body.insert(1, pagebreak)

p = Popen(["prince", "-", "--style=./css/print.css", "Quest_Guide.pdf"], stdin=PIPE)

p.stdin.write(str(shell))
p.stdin.close()
