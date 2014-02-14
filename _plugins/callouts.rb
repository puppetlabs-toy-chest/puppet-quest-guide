require 'nokogiri'

class Tip < Liquid::Block
    def initialize(tag_name, markup, tokens)
        super
    end

    def render(context)
        "<div class = \"lvm-callout lvm-tip\">#{super}</div>"
    end
end

class Warning < Liquid::Block
    def initialize(tag_name, markup, tokens)
        super
    end

    def render(context)
        "<div class = \"lvm-callout lvm-warning\">#{super}</div>"
    end
end

class Fact < Liquid::Block
    def initialize(tag_name, markup, tokens)
        super
    end

    def render(context)
        "<div class = \"lvm-callout lvm-fact\">#{super}</div>"
    end
end

Liquid::Template.register_tag('tip', Tip)
Liquid::Template.register_tag('warning', Warning)
Liquid::Template.register_tag('fact', Fact)
