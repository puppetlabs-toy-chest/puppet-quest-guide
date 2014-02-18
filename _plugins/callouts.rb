require 'redcarpet'

class Tip < Liquid::Block
    def render(context)
        "<div class = \"lvm-callout lvm-tip\"><p>#{super}</p></div></div>"
    end
end

class Warning < Liquid::Block
    def render(context)
        "<div class = \"lvm-callout lvm-warning\"><p>#{super}</p></div></div>"
    end
end

class Fact < Liquid::Block
    def render(context)
        "<div class = \"lvm-callout lvm-fact\"><p>#{super}</p></div></div>"
    end
end

Liquid::Template.register_tag('tip', Tip)
Liquid::Template.register_tag('warning', Warning)
Liquid::Template.register_tag('fact', Fact)
