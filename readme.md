HCI Project part 1 (at least)
===

Most of the code here so far is part of **Part 1** of the project. It's a Ruby Sinatra web app. The interesting code is all in the `pass.rb` file. For the basics of the Sinatra framework, [read up on it here] (http://sinatrarb.com). The gist of it is you implement HTTP verbs (`GET`, `POST`, etc.) and give them blocks of code to execute when a matching URI is found. For example:

    get '/users/all' do
    	<html><body>Oh no, no users!</body></html>
    end
    
The above code would get executed when a user makes a request to `http://our-domain.com/users/all`. Basically, whatever string (or object, really) we return from the `do` block is what gets sent as the HTTP response. It's nice. I'm also using it to send JSON objects in the API methods.

Installation
------------

1. Make sure you have ruby installed on your machine. If you've got OS X or a flavor of Linux, this is probably already done. Windows-land people...I'm sure it can be done.
2. You'll also need rubygems. If you've got ruby, you've probably also got this too.
3. You'll also need sqlite3 installed. This is probably available for your system too.
4. Then install the following gems. On OS X, `sudo` is required for the default install. I don't know about Linux (probably not)...
		sudo gem install sinatra data_mapper json haml dm-sqlite-adapter

Then, change into the project directory and do `ruby pass.rb`. This will start up a little webserver running on port 4567 and you can check it out in the browser.

Known Issues
------------

It's really not done yet. The login stuff mostly works, but I want to improve it so it'll automatically suggest a passphrase to the user. At this time, it doesn't matter *what* the suggestion is (we'll implement that properly when we decide on a scheme) but I'd just like to get the flow down.

GitHub Usage
------------

Basically: **don't commit on the master branch**. Use your own branch instead to develop features, then we'll merge in those changes when they're stable. Preferably, when you've got your changes ready, use the `Pull Request` feature of Github and we'll pull in the changes back to master. Example, starting from master

	git clone git@github.com:jbrennan/hci.git
	cd hci
	git checkout -b my_awesome_feature_branch_name
	// make your changes
	git add .
	git commit -m "I just made changes on my branch!"
	git push origin my_awesome_feature_branch_name // so we have the branch in github
	// more changes, commits, pushes, etc.
	// done
	// do a pull request OR...
	
	
	git checkout master
	git pull origin master // get all the changes which might have been pushed to master in the meantime
	git merge my_awesome_branch_name
	git push origin master // but really... pull requests are nicer because they let everyone else review the code before it gets checked in to master.
	