require 'rubygems'
require 'sinatra'
require 'json'
require 'rubypython'

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

get '/:site/login' do |site|
    # Ask the user to log in
    erb :login, :layout => whichlayout(site), :locals => { :site => site }
end

post '/:site/login' do |site|
    # Check that the supplied password is right
    success = true
    i = 0
    for chunk in $passphrases[site]
        if chunk.word.to_s.casecmp(params["word" + i.to_s]) != 0
            success = false
        end
        i += 1
    end

    if success
        logger.info "Successful login"
        erb :success, :layout => whichlayout(site), :locals => { :site => site }
    else
        logger.info "Login failed"
        erb :failure, :layout => whichlayout(site), :locals => { :site => site }
    end
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

