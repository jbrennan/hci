require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'
require 'data_mapper'
# require 'digest/sha1'
# require 'digest/md5'
require 'util/pbkdf2.rb'
require 'models/user.rb'

#erb stuff for models?
DataMapper.finalize

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db_pass.sqlite3")
DataMapper.auto_upgrade!


before do
	$user = nil
	authorize_user(request.cookies['auth'])
end


get '/' do
	@logged_in = true if $user
	haml :index
end


get '/login' do
	redirect '/' if $user
	haml :login
end


get '/logout' do
	request.cookies['auth'] = nil
	redirect '/'
end


get '/about' do
	"Enough about me, how about you?"
end


get '/protected' do
	redirect "/login" if !$user
	"It looks like you've got access!"
end


get '/phrase/test' do
	@logged_in = true if $user
	haml :phrase
end




#########################
# API
#########################


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

