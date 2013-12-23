require 'redcarpet'
require 'nokogiri'

md_file = File.read("./template.md")

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

File.open("./template.html", "w") { |file| file.write doc.to_html }
