import json
from subprocess import *
from bs4 import BeautifulSoup, Tag
import markdown
import codecs
import yaml

def pull_content(filename):
    
    # Open an html file and return a BeautifulSoup tag object of that file's 
    # <div role='main'> contents. (Strips out header, footer, sidebar content.)

    with open(filename, 'r') as f:
        html = f.read()
    soup = BeautifulSoup(html, "html5lib")
    
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
    full_quest_urls.append(path + '/setup/setup.html')

    for quest in full_quest_urls:
                
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
    
    # Uncomment to write the html output for testing purposes.

    with open('test.html', 'w') as f:
        f.write(str(shell))

    # Subprocess to render with PrinceXML:

    p = Popen(["prince", "-", "--style=./css/main.css", "../../Quest_Guide.pdf"], cwd=r'./Quest_Guide/_site', stdin=PIPE)
    p.stdin.write(str(shell))
    p.stdin.close()

def main():
    
    print "Generating HTML from markdown source..."
    p = Popen(["jekyll", "build"], cwd=r'./Quest_Guide')
    p.communicate()
    
    quest_guide()
        
if __name__ == '__main__':
    main()
