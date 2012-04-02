require 'data_mapper'



class Word # aka a Synset, but with most info stripped
	include DataMapper::Resource

	property :id,	Serial
	property :word_name,	String
	property :word_pos,		String
	property :word_definition,	String
	property :word_created_at,	DateTime

end