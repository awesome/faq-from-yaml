# A simple script for converting YAML files to standard, internally-linked
# HTML FAQ pages.  In-line comments, links and email addresses use Markdown-like syntax.

require 'YAML'
verbose = true

faq = YAML.load(File.read("example.yml"))
if verbose
  p "YAML loaded"
#  p "Found #{faq.count} categories with an average of #{faq.inject{ |sum, el| sum + el["questions"].count }.to_f / faq.size} questions each."
#  p "FYI: The following categories have only one question:"
#  p "FYI: The following categories have no questions:"
end

f = File.open('example.html', 'w')
old_out = $stdout
$stdout = f

# LOOP THROUGH ANSWERS TO DO FORMATTING
faq.each do |category|
  category["questions"].each do |question|
    #drop comments: anything between {}
    question["question"].gsub!(/{.*}/,'')
    question["answer"].gsub!(/{.*}/,'')

    #put answers in <p></p>
    question["answer"] = "<p>#{question["answer"]}</p>"
    question["answer"].gsub!(/\n(.)/,'</p><p>\1')

    #NOTE: The important thing below is to NOT find bracketed text that contains other bracketed text.  That
    # would mean there are multiple links in the paragraph and we've grabbed the first bracket of the first one and
    # the last bracket of the last one.

    #email links and link text
    question["answer"].gsub!(/\[([^\[\]]*)\][[:blank:]]*\[([^@\[\]]+@[^@\[\]]+)\]/,'<a href=\'mailto:\2\'>\1</a>')
    #email links w/o link text
    question["answer"].gsub!(/\[([^@\[\]]+@[^@\[\]]+)\]/,'<a href=\'mailto:\1\'> \1</a>')

    #links and link text WITH target
    question["answer"].gsub!(/\[([^\[\]]*)\][[:blank:]]*\[([^\[\]]*), NEW\]/,'<a href=\'\2\' target=\'_blank\'>\1</a>')
    #links and link text
    question["answer"].gsub!(/\[([^\[\]]*)\][[:blank:]]*\[([^\[\]]*)\]/,'<a href=\'\2\'>\1</a>')

    #links w/o text WITH target
    question["answer"].gsub!(/\[([^\[\]]*), NEW\]/,'<a href=\'\1\' target=\'_blank\'> \1</a>')
    #links w/o link text
    question["answer"].gsub!(/\[([^\[\]]*)\]/,'<a href=\'\1\'> \1</a>')

  end
end

#BUILD TABLE OF CONTENTS
faq.each do |category|
  puts "<a href='\##{category["nickname"]}'>#{category["category"]}</a><br>"
  puts "<p>#{category["description"]}</p>"
  puts "<ul>"
  category["questions"].each do |question|
    puts "<li><a href='\##{question["nickname"]}'>#{question["question"]}</a></li>"
  end
  puts "</ul>"
end

#BUILD QUESTIONS AND ANSWERS
faq.each do |category|
  puts "<h2 class='anchor' id='#{category["nickname"]}'>#{category["category"]}</h2>"
  puts "<p>#{category["description"]}</p>"
  category["questions"].each do |question|
    puts "<p class='anchor' id='#{question["nickname"]}'><b>#{question["question"]}</b></p>"
    # the regex below prevents us from replacing the last newline
    puts "#{question["answer"]}"

  end
end

f.close
$stdout = old_out