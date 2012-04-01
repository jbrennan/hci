require 'data_mapper'
require 'models/user.rb'

class Statistic
	include DataMapper::Resource

	property :id,	Serial
	property :stat_name, String # the name of the task
	property :sequence, Integer # ex: when attempting 3 passwords, this was the second password
	property :success, Boolean, :default => false # whether or not this was a successful attempt
	property :stat_date, DateTime
	property :stat_type, String # Login, Log out, 
	property :duration, Integer # how long this task took.
	property :attempt_number, Integer # On what attempt did they get it?

	
	belongs_to :user
	
	
	#constants
	StatTypeAccountCreation = "Created account"
	StatTypeMainLogin = "Logging In"
	StatTypePhraseTrialGiven = "Phrase trial (given)"
	StatTypePhraseTrialBlind = "Phrase trial (blind)"
end