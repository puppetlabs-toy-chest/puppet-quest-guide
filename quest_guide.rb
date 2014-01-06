require 'redcarpet'
require 'nokogiri'
require 'json'

def md2html (filename, nav_node)

    md_file = File.read("./quests/#{filename}.md")

    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)

    html = markdown.render(md_file)

    doc = Nokogiri::HTML(html)

    body = doc.at_css "body"

    # Wrap content in content div tag
    body.children = '<div id=content>' + body.children.to_html + '</div>'

    # Insert the sideNav template into the body
    nav_node.parent = body

    head = doc.create_element "head"

    style = doc.create_element "link"
    style["rel"] = "stylesheet"
    style["type"] = "text/css"
    style["href"] = "main.css"
    style.parent = head

    body.add_previous_sibling(head)

    File.open("./html/#{filename}.html", "w") { |file| file.write doc.to_html }

end

quest_guide = JSON.parse(File.read("./quest_guide.json"))

nav_template = Nokogiri::HTML::DocumentFragment.parse(File.read("./html/nav.html"))

nav_node = nav_template.at_css "div"

for f in quest_guide["quests"]
    md2html f, nav_node
end

