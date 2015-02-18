class Task < Liquid::Block
  def initialize(tag_name, markup, tokens)
     super
     @number = markup
  end

    def render(context)
        "<div class = \"lvm-task-number\"><p>Task #{@number}:</p></div></div>"
    end
end

Liquid::Template.register_tag('task', Task)
