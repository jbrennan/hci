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

@nltk = RubyPython.import "nltk"
@binder = RubyPython.import "nltk_binder"

@wn = @nltk.corpus.wordnet

# setup datamapper
DataMapper.finalize
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db_pass.sqlite3")
DataMapper.auto_upgrade!


if (ARGV.length < 1)
	puts "You must provide what part of speech you're looking for."
	puts "n or v or a are acceptable parts of speech."
	exit
end

which_set = ARGV[0]


def process_and_save(synsets)
	# process the array of synset hashes
	synsets.each do |s|

		puts "New word: " + s[:syn_name]
		syn_pos = s[:pos]
		#Create a word
		word = Word.first_or_create(:word_name => s[:syn_name])
		word.word_created_at = DateTime.now
		word.word_pos = syn_pos
		word.word_definition = s[:def]
		word.save
	end
end


# Iterate over all the nouns provided by the binder script, each object is a Synset defined bere:
# http://nltk.github.com/api/nltk.corpus.reader.html?highlight=synset#nltk.corpus.reader.wordnet.Synset
def find_nouns
	synsets = Array.new
	@binder.wn_noun_iter.to_enum.each do |s|

		syn_name = s.name.split(".")[0].to_s # throw out everything after the first dot

		next if (syn_name.include? "_") # just skip things with underscores... we only want 1 word
		next if (syn_name.include? "-") # skip anything with a dash, too.
		next if (syn_name.include? ".") # some things still appear to have more dots... skip them.
		next if (syn_name.length < 4) # skip small words

		# I've had to use native ruby objects (i.e. Hash) here to avoid a blowing-up problem with RubyPython.
		# My guess is under really heavy loads, something doesn't get garbage collected and the thing blows up.
		syn = Hash.new
		syn[:syn_name] = syn_name
		syn[:pos] = s.pos.to_s
		syn[:def] = s.definition.to_s
		synsets << syn

	end

	process_and_save(synsets)
	puts "Done."
end

def find_verbs
	synsets = Array.new

	@binder.wn_verb_iter.to_enum.each do |s|
		syn_name = s.name.split(".")[0].to_s # throw out everything after the first dot

		next if (syn_name.include? "_") # just skip things with underscores... we only want 1 word
		next if (syn_name.include? "-") # skip anything with a dash, too.
		next if (syn_name.include? ".") # some things still appear to have more dots... skip them.
		next if (syn_name.length < 4) # skip small words

		# I've had to use native ruby objects (i.e. Hash) here to avoid a blowing-up problem with RubyPython.
		# My guess is under really heavy loads, something doesn't get garbage collected and the thing blows up.
		syn = Hash.new
		syn[:syn_name] = syn_name
		syn[:pos] = s.pos.to_s
		syn[:def] = s.definition.to_s
		synsets << syn
	end

	process_and_save(synsets)
	puts "Done processing Verbs."

end


def find_adjectives
	synsets = Array.new

	@binder.wn_iter('a').to_enum.each do |s|
		syn_name = s.name.split(".")[0].to_s # throw out everything after the first dot

		next if (syn_name.include? "_") # just skip things with underscores... we only want 1 word
		next if (syn_name.include? "-") # skip anything with a dash, too.
		next if (syn_name.include? ".") # some things still appear to have more dots... skip them.
		next if (syn_name.length < 4) # skip small words

		# I've had to use native ruby objects (i.e. Hash) here to avoid a blowing-up problem with RubyPython.
		# My guess is under really heavy loads, something doesn't get garbage collected and the thing blows up.
		syn = Hash.new
		syn[:syn_name] = syn_name
		syn[:pos] = s.pos.to_s
		syn[:def] = s.definition.to_s
		synsets << syn
	end

	process_and_save(synsets)
	puts "Done processing adjectives."

end


case which_set
when "n"
	find_nouns
when "v"
	find_verbs
when "a"
	find_adjectives
end






