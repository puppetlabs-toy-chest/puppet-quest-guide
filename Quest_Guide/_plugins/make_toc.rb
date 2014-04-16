require 'nokogiri'

module Jekyll
    module TOCer
        def toc(html)
            doc = Nokogiri::HTML::DocumentFragment.parse(html)
            as = doc.css "a"
            
            ul = Nokogiri::XML::Node.new "ul", doc

            as.each do |a|
                if a["id"]
                    li = Nokogiri::XML::Node.new "li", ul
                    link = Nokogiri::XML::Node.new "a", ul
                    link["href"] = '#' + a["id"]
                    link["class"]
                    h2 = a.first_element_child
                    link.content = h2.content
                    link.parent = li
                    li.parent = ul
                end
            end
            
            return ul.to_html

        end

# Indexes your html, inserting anchors into all your h2s
# Liquid syntax is {{ html | indexer}}

        def indexer(html)
            doc = Nokogiri::HTML::DocumentFragment.parse(html)
            
            h2s = doc.css "h2"
            
            h2s.each do |h2|
                id = h2.text.downcase.tr(" ", "-").gsub!(/\(|\)/,'')
                a = Nokogiri::XML::Node.new "a", doc
                a["id"] = id
                h2.add_next_sibling a # Insert a after h2
                h2.parent = a # Then put h2 inside of a

            end
            return doc.to_html
        end
    end
end

Liquid::Template.register_filter(Jekyll::TOCer)
