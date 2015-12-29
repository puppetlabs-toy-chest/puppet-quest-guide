Dir.glob('./quests/*.md').each do |f|
  text = File.read(f)
  text.gsub!(/{% task (\d+) %}.+?{% endtask %}/m, '<div class = "lvm-task-number"><p>Task \1:</p></div>')
  text.gsub!(/{% highlight puppet %}/, '```puppet')
  text.gsub!(/{% endhighlight %}/, '```')
  text.gsub!(/---.*?---\s\s/m, '')
  text.gsub!(/{% figure '(.+?)' %}/, '![image](\1)')
  File.write(f, text)
end

