require "RubyGems"
require "rubypython"
require 'rubygems'
require 'data_mapper'
require 'models/word.rb'

#Start rp

RubyPython.start

# Silly hack to get RubyPython to look in the right place on my Mac for the nltk module
system = RubyPython.import "sys"
system.path.append('/Library/Python/2.7/site-packages')
system.path.append('.')

nltk = RubyPython.import "nltk"
binder = RubyPython.import "nltk_binder"

wn = nltk.corpus.wordnet

# setup datamapper
DataMapper.finalize
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db_pass.sqlite3")
DataMapper.auto_upgrade!


# Iterate over all the nouns provided by the binder script, each object is a Synset defined bere:
# http://nltk.github.com/api/nltk.corpus.reader.html?highlight=synset#nltk.corpus.reader.wordnet.Synset

synsets = Array.new

binder.wn_noun_iter.to_enum.each do |s|
	
	synsets << s
	
end


# process the array of synsets
synsets.each do |s|
	syn_name = s.name.split(".")[0].to_s # throw out everything after the first dot
	
	next if (syn_name.include? "_") # just skip things with underscores... we only want 1 word
	next if (syn_name.include? "-") # skip anything with a dash, too.
	
	
	
	puts "New word: " + syn_name
	syn_pos = s.pos.to_s
	# Create a word
	# word = Word.first_or_create(:word_name => syn_name)
	# word.word_created_at = DateTime.now
	# word.word_pos = syn_pos
	# word.word_definition = s.definition
	# 
	# 
	# word.save
end
