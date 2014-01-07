require 'redcarpet'
require 'nokogiri'
require 'json'



def nav_bar (quests)
    
    side_nav = Nokogiri::HTML::DocumentFragment.parse <<-EOHTML
    <div id=side_nav>
        <h2> Quests </h2>
        <ul>
        </ul>
    </div>
    EOHTML
    
    ul = side_nav.at_css "ul"
    
    for f in quests
        li = Nokogiri::XML::Node.new "li", side_nav
        li.parent = ul
        a = Nokogiri::XML::Node.new "a", side_nav        
        a["href"] = "#{f}.html"
        a.content = "#{f}"
        a.parent = li

    end

    return side_nav

end

def md2html (quest, quests)

    md_file = File.read("./quests/#{quest}.md")

    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)

    html = markdown.render(md_file)

    doc = Nokogiri::HTML(html)

    body = doc.at_css "body"

    # Wrap content in content div tag
    body.children = '<div id=content>' + body.children.to_html + '</div>'

    # Insert the sideNav template into the body

    nav_node = nav_bar quests
    nav_node.parent = body

    head = doc.create_element "head"

    style = doc.create_element "link"
    style["rel"] = "stylesheet"
    style["type"] = "text/css"
    style["href"] = "main.css"
    style.parent = head

    body.add_previous_sibling(head)

    File.open("./html/#{quest}.html", "w") { |file| file.write doc.to_html }

end

quest_guide = JSON.parse(File.read("./quest_guide.json"))

nav_template = Nokogiri::HTML::DocumentFragment.parse(File.read("./html/nav.html"))

nav_node = nav_template.at_css "div"

for quest in quest_guide["quests"]
    md2html quest, quest_guide["quests"]
end

