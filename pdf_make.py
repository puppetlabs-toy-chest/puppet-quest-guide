import json
from subprocess import *
from bs4 import BeautifulSoup, Tag
import argparse
import markdown
import codecs
import yaml

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
   
    with open('Quest_Guide/_data/quest_order.yml', 'r') as f:
        quest_data = yaml.safe_load(f)

    quest_urls = [quest['url'] for quest in quest_data]

    path = "./Quest_Guide/_site"

    full_quest_urls = [path + quest for quest in quest_urls]

    shell = BeautifulSoup("<html><body><cover></cover><toc></toc><content></content></body></html>", "html5lib")
    content = shell.content

    # It's easier to reverse the list and index to 0 with .insert methods
    full_quest_urls.reverse()


    for quest in full_quest_urls:
        # insert placeholder tags for navigation.
        #content.insert(0, BeautifulSoup("<div class='pdfnav'></div>", 'html5lib').body.next)
        # insert quest content
        content.insert(0, pull_content(quest))

    # Table of Contents:

    titles = content.find_all('h1')
    titles.reverse()

    for title in titles:
        title['id'] = '_'.join(title.string.split()).lower()
        shell.toc.insert(0, BeautifulSoup("<ul><li><a href='#%(href)s'>%(title)s</a></li></ul>" % {'title': title.string, 'href': title['id']}, 'html5lib').body.next)
    
    shell.toc.insert(0, BeautifulSoup("<h1>Table of Contents:</h1>", 'html5lib').body.next)

    # PDF Cover Page:

    cover = shell.cover

    cover.insert(0, pull_content("./Quest_Guide/_includes/cover.html"))
    

    # Navigation Section (pdfnav):
    
#    navpoints = content.find_all('div', 'pdfnav')
#    
#    for nav in navpoints:
#        #print nav.parent
#        current_quest = nav.find_previous_sibling('div', id='content').find_all('h1')[0]
#        for title in titles:
#            if title == current_quest:
#                nav.insert(0, BeautifulSoup("<ul><li><a href='#%(href)s' class='current'>%(title)s</a></li></ul>" % {'title': title.string, 'href': title['id']}, 'html5lib').body.next)
#            else:
#                nav.insert(0, BeautifulSoup("<ul><li><a href='#%(href)s'>%(title)s</a></li></ul>" % {'title': title.string, 'href': title['id']}, 'html5lib').body.next)
#        nav.insert(0, BeautifulSoup("<strong>Quest Progress</strong>").body.next)
#
    # Uncomment to write the html output for testing purposes.

    with open('test.html', 'w') as f:
        f.write(str(shell))

    # Subprocess to render with PrinceXML:

    p = Popen(["prince", "-", "--style=./css/main.css", "../../Quest_Guide.pdf"], cwd=r'./Quest_Guide/_site', stdin=PIPE)
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
