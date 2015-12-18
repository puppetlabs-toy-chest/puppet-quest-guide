Dir.glob('./quests/*.md').each do |f|
  text = File.read(f)
  text.gsub!(/{% figure '(.+?)' %}/, '![image](\1)')
  File.write(f, text)
end

