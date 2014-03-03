import json
from subprocess import *
from bs4 import BeautifulSoup, Tag
import argparse
import markdown
import codecs

parser = argparse.ArgumentParser(description='Generate PDF documents for the Quest Guide and the Setup Guide')
parser.add_argument('--quest', '-q', action='store_true', help='Create a PDF version of the Quest Guide')
parser.add_argument('--setup', '-s', action='store_true', help='Create a VirtualBox, VMware and OVF Setup Guide PDFs')


def pull_content(filename):
    with open(filename, 'r') as f:
        html = f.read()
    soup = BeautifulSoup(html, "html5lib")
    return soup.select("div[role=main]")[0]

def quest_guide():
    
    # You must run Jekyll first to generate the html content

    path = "./Quest_Guide/_site/quests/"

    quests =["welcome.html",
             "resources.html",
             "manifest_quest.html",
             "variables.html",
             "resource_ordering.html",]

    quest_list = [path + quest for quest in quests]

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
        p = Popen(["prince", "-", "--style=../Quest_Guide/css/print.css", "../%s.pdf" %version['name']], stdin=PIPE, cwd=r'./Setup_guide')
        p.stdin.write(str(shell))
        p.stdin.close()

def main(quest, setup):
    
    if quest:
        quest_guide()
    if setup:
        setup_guide()
        
if __name__ == '__main__':
    args = parser.parse_args()
    main(args.quest, args.setup)
