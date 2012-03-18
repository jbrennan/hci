require 'data_mapper'

class User
	include DataMapper::Resource
	
	property :id,	Serial
	property :email,	String
	property :salt,		String
	property :password,	String
	property :user_created_at,	DateTime
	property :auth_token,	String
	property :api_secret,	String
	property :user_flags,	String #is admin, etc
end