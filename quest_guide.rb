require 'redcarpet'
require 'nokogiri'
require 'json'

def md2html (filename)

    md_file = File.read("./quests/#{filename}.md")

    nav = File.read("./html/nav.html")

    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)

    html = markdown.render(md_file)

    doc = Nokogiri::HTML(html)

    body = doc.at_css "body"

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

for f in quest_guide["quests"]
    md2html f
end

