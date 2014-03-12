import json
from subprocess import *
from bs4 import BeautifulSoup, Tag
import argparse
import markdown
import codecs

# Set up the argument parser and define arguments to create Quest Guide and Setup Guide PDFs
parser = argparse.ArgumentParser(description='Generate PDF documents for the Quest Guide and the Setup Guide')
parser.add_argument('--quest', '-q', action='store_true', help='Create a PDF version of the Quest Guide')
parser.add_argument('--setup', '-s', action='store_true', help='Create a VirtualBox, VMware and OVF Setup Guide PDFs')

# Open an html file and return a BeautifulSoup tag object of that file's <div role='main'> contents. (Strips out header, footer, sidebar content.)
def pull_content(filename, print_output=False):
    with open(filename, 'r') as f:
        html = f.read()
    soup = BeautifulSoup(html, "html5lib")
    if print_output:
        print str(soup.select("div[role=main]")[0])
    return soup.select("div[role=main]")[0]

def quest_guide():
   
    path = "./Quest_Guide/_site/quests/"

    quests =["welcome.html",
             "resources.html",
             "manifest_quest.html",
             "variables.html",
             "resource_ordering.html",]

    quest_list = [path + quest for quest in quests]

    shell = BeautifulSoup("<html><body><cover></cover><toc></toc><content></content></body></html>", "html5lib")
    content = shell.content

    quest_list.reverse()

    for quest in quest_list:
        content.insert(0, pull_content(quest))

    titles = content.find_all('h1')
    titles.reverse()

    for title in titles:
        title['id'] = '_'.join(title.string.split()).lower()
        shell.toc.insert(0, BeautifulSoup("<ul><li><a href='#%(href)s'>%(title)s</a></li></ul>" % {'title': title.string, 'href': title['id']}, 'html5lib'))

    shell.toc.insert(0, BeautifulSoup("<h2>Table of Contents</h2>", 'html5lib'))

    cover = shell.cover

    cover.insert(0, pull_content("./Quest_Guide/_includes/cover.html"))

    with open('test.html', 'w') as f:
        f.write(str(shell))

    p = Popen(["prince", "-", "--style=./Quest_Guide/css/main.css", "Quest_Guide.pdf"], stdin=PIPE)
    p.stdin.write(str(shell))
    p.stdin.close()

def setup_guide():

    path = './Setup_Guide/'

    versions = [
                 {'name'  :'SetupGuide(VBox)',
                 'virt' :'virtualbox_setup.md'},
                 {'name'  :'SetupGuide(VMWare)',
                 'virt' :'vmware_setup.md'},
                 {'name'  :'SetupGuide(OVF)',
                 'virt' :''}
                ]

    for version in versions:
        shell = BeautifulSoup("<html><body></body></html>", "html5lib")
        body = shell.body

        with codecs.open(path+'quest_guide_setup.md', encoding='utf-8') as f:
                quest_setup = BeautifulSoup(markdown.markdown(f.read()))
        body.insert(0, quest_setup)

        if version['virt']:
            with codecs.open(path+version['virt'], encoding='utf-8') as f:
                virt_setup = BeautifulSoup(markdown.markdown(f.read()))
            body.insert(0, virt_setup)
        p = Popen(["prince", "-", "--style=../Quest_Guide/css/main.css", "../%s.pdf" %version['name']], stdin=PIPE, cwd=r'./Setup_guide')
        p.stdin.write(str(shell))
        p.stdin.close()

def main(quest, setup):
    
    p = Popen(["jekyll", "build"], cwd=r'./Quest_Guide')
    
    if quest:
        quest_guide()
    if setup:
        setup_guide()
        
if __name__ == '__main__':
    args = parser.parse_args()
    main(args.quest, args.setup)
