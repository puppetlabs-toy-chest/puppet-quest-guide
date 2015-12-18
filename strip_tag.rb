Dir.glob('./quests/*.md').each do |f|
  text = File.read(f)
  text.gsub!(/{% task (\d+) %}.+?{% endtask %}/m, '<div class = "lvm-task-number"><p>Task \1:</p></div>')
  File.write(f, text)
end

