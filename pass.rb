require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'
require 'data_mapper'
# require 'digest/sha1'
# require 'digest/md5'
require 'util/pbkdf2.rb'
require 'models/user.rb'
require 'models/statistic.rb'
require 'models/word.rb'
require 'rubypython'


#erb stuff for models?
DataMapper.finalize

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db_pass.sqlite3")
DataMapper.setup(:corpus, "sqlite3://#{Dir.pwd}/wordnet.corpus")
DataMapper.auto_upgrade!

enable :logging
use Rack::CommonLogger #if logging breaks for you, re-enable it with this.. 
#c.f.: https://github.com/sinatra/sinatra/issues/454

RubyPython.start
RubyPython.import('sys').path.append('.')
$generator = RubyPython.import 'generator'
$generator.startup
$passphrases = {}

before do
end

get '/' do
    send_file 'public/index.html'
end

get '/password.js' do
    send_file 'public/password.js'
end

get '/password.css' do
    send_file 'public/password.css'
end

get '/jquery-1.7.2.min.js' do
    send_file 'public/jquery-1.7.2.min.js'
end

get '/next.png' do
    send_file 'public/next.png'
end

get '/throbber.png' do
    send_file 'public/throbber.png'
end

get '/:site/newaccount' do |site|
    # Make a passphrase, then show it to the user
    new_passphrase site
    erb :newaccount, :layout => whichlayout(site), :locals => { :site => site }
end

get '/:site/login' do
    # Ask the user to log in
    erb :login, :layout => whichlayout(site)

end

post '/:site/login' do
    # Check that the supplied password is right
    erb :success, :layout => whichlayout(site)

    erb :failure, :layout => whichlayout(site)
end

def whichlayout(site)
    { 'email' => :email,
      'bank' => :bank,
      'domesday' => :domesday
    }[site]
end

def new_passphrase(site)
    $passphrases[site] = $generator.generate(tree site).to_a
end

def tree(site)
    { 'email' => 0, 'bank' => 1, 'domesday' => 2 }[site]
end
    

#########################
# API
#########################

get '/:site/api/nextchunk/*' do |site,path|
    words = path.split '/'
    chunk = $generator.nextbranch(tree(site), words)
    "#{chunk.to_json}"
end


###################
#
# Word API
#
###################

# Gets a random word of type :pos ("a" for adjective, "n" for noun, "v" for verb)
get '/api/corpus/random/:pos' do

	content_type 'application/json'
	DataMapper.repository(:corpus) {
		@words = Word.all(:word_pos => params[:pos], :order => [:word_name.asc])
	}

	return {
		:status => "error",
		:error => "No words in the corpus. Maybe an invalid point of speech or perhaps you need to generate it by running corpus_gen.rb"
	}.to_json if @words.length < 1


	word = @words[rand(@words.length)]

	return {
		:status => "OK",
		:word => {
			:pos => params[:pos],
			:name => word.word_name,
			:definition => word.word_definition
		}
	}.to_json
end



############
# User API
############


# Here's where we'd generate our passphrase to be shown for the user.
get '/api/phrase/suggest' do
	content_type 'application/json'
	
	return {
		:status => "OK",
		:phrase => "An example passphrase which is super secure!"
	}.to_json
end


# User stuff
post '/api/user/login' do
	content_type 'application/json'

	if (!check_parameters("username", "password"))
		return {
			:status => "error",
			:error => "Email and Password are both required fields."
		}.to_json
	end


	auth_token,api_secret = check_user_credentials(params[:username], params[:password])

	if auth_token
		
		# Create a login statistic
		stat = Statistic.create
		stat.stat_name = "Logged In"
		stat.sequence = 0
		stat.success = true
		stat.stat_date = DateTime.now
		stat.stat_type = Statistic::StatTypeMainLogin
		stat.duration = 0
		stat.attempt_number = 0
		
		stat.user = get_user_by_email params[:username]
		stat.save
		
		puts stat.to_s
		puts stat.user.email.to_s
		
		return {
			:status => "OK",
			:auth_token => auth_token,
			:api_secret => api_secret
		}.to_json
	else
		return {
			:status => "error",
			:error => "No valid email or matching password was found."
		}.to_json
	end

end

post '/api/user/logout_sessions' do
	content_type 'application/json'
	
	if $user and check_api_secret
		update_auth_token
		return {
			:status => "OK"
		}.to_json
	else
		return {
			:status => "error",
			:error => "Wrong authentication credentials or API secret."
		}.to_json
	end
end

post '/api/user/create' do
	content_type 'application/json'
	
	if (!check_parameters("username", "password"))
		return {
			:status => "error",
			:error => "Email and Password are both required."
		}.to_json
	end
	
	min_password_length = 5
	if params[:password].length < min_password_length
		return {
			:status => "error",
			:error => "Password is too short. Must be at least #{min_password_length} characters."
		}.to_json
	end
	
	auth_token, error_message = create_user(params[:username], params[:password])
	if auth_token
		return {
			:status => "ok",
			:auth_token => auth_token
		}.to_json
	else
		return {
			:status => "error",
			:error => error_message
		}.to_json
	end
	
end


get '/api/user/exists' do
	content_type 'application/json'
	return {
		:exists => true
	}.to_json if user_already_exists(params[:username])
	
	return {
		:exists => false
	}.to_json
end






#########################
# Utilities
#########################

# Returns two values:
# => auth token if the registration succeeds, otherwise nil
# => error message if the registration failed
def create_user(email, password)
	if user_already_exists(email)
		return nil, "This email address is already in use."
	end

	auth_token = get_random()
	salt = get_random()

	# create the user, and save
	@new_user = User.create(
		:email => email,
		:salt => salt,
		:password => hash_password(password, salt),
		:user_created_at => Time.now,
		:auth_token => auth_token,
		:api_secret => get_random,
		:user_flags => "" 
	)
	return auth_token, nil
end


# User authentication
# This method tries to authenticate the user, and populates the $user gloabl on success
# Otherwise, $user is set to nil so it can be checked for later
# Note: this is called before every route
def authorize_user(auth)
	return if !auth

	# try to look up the user according to their auth_token
	user = User.first(:auth_token => auth)
	$user = user if user != nil
end



def get_random
	random = ""
	File.open("/dev/urandom").read(20).each_byte { |x|
		random << sprintf("%02x", x)
	}
	random
end


def user_already_exists(email)
	User.first(:email => email) != nil
end


def hash_password(password, salt)
	p = PBKDF2.new do |p|
		p.iterations = 1000#PBKDF2Iterations
		p.password = password
		p.salt = salt
		p.key_length = 160/8
	end
	p.hex_string
end


# Check to make sure the supplied list exists
def check_parameters *required
	required.each { |p|
		params[p].strip! if params[p] and params[p].is_a? String
		if !params[p] or (p.is_a? String and params[p].length == 0)
			return false
		end
	}
	true
end


# Checks if the credentials identify a user.
# If so, returns the auth and secret.
# Otherwise, returns nil
def check_user_credentials (email, password)
	user = get_user_by_email(email)
	return nil if !user
	hashed = hash_password(password, user[:salt])
	(user[:password] == hashed) ? [user[:auth_token], user[:api_secret]] : nil
end


# Checks to make sure a request is coming in with the proper API secret for this user
def check_api_secret
	return false if !$user
	return (params["apisecret"] and (params["apisecret"] == $user[:api_secret]))
end

# Updates the auth token for the given user.
# This has essentially logs the user out of all their sessions everywhere
def update_auth_token(user)
	new_auth_token = get_random
	user[:auth_token] = new_auth_token
	user.save
	return new_auth_token
end


def get_user_by_email(email)
	User.first(:email => email)
end

