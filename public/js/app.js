function login() {
	var data = {
		username: $("input[name=username]").val(),
		password: $("input[name=password]").val(),
	};
	
	var register = $("input[name=register]").attr("checked");
	$.ajax({
		
		type: "POST",//register ? "POST" : "GET",
		url: register ? "/api/user/create" : "/api/user/login",
		data: data,
		success: function(r) {
			if (r.status == "OK") {
				document.cookie = 'auth=' + r.auth_token +
				'; expires=Thu, 1 Aug 2030 20:00:00 UTC; path=/';
				window.location.href = "/";
			} else {
				alert(r.error);
			}
		}
		
		
	});
	return false;
}


function suggestPassphrase() {
	console.log("gonna suggest");
	$.ajax({
		type: "GET",
		url: "/api/phrase/suggest",
		success: function (response) {
			if (response.status == "OK") {
				alert(response.phrase);
			} else {
				alert("There was an error!");
			}
		}
	});
}


function checkEmailExists2(email) {

}

function cancelTimeout2() {

}


$(document).ready(function() {
	//suggestPassphrase();
	this.cancelTimeout = function() {
		if (typeof this.timeoutID == "number") {
			window.clearTimeout(this.timeoutID);
			delete this.timeoutID;
		}
	};
	
	
	this.checkEmailExists = function(email) {
		if (email.length < 1)
			return;
		console.log("Will check for email " + email);
		var data = {
			username: $("input[name=username]").val(),
		};
		$.ajax({
			type: "GET",
			url: "/api/user/exists",
			data: data,
			success: function (response) {
				if (response.exists == true) {
					//alert("Yep!");
					console.log("yep!");
				} else {
					//alert("Nope");
					console.log("nope");
				}
			}
		});
		delete this.timeoutID;
	}
	
	var self = this;
	$("#username").keyup(function() {
		//console.log($(this).val());
		var email = $(this).val();
		
		self.cancelTimeout();
		
		
		self.timeoutID = window.setTimeout(function() {
			//console.log(email);
			self.checkEmailExists(email);
		}, 1000);
	})
})

function logout() {
	document.cookie = encodeURIComponent("auth") + "=deleted; expires=" + new Date(0).toUTCString();
	window.location.replace("/");
}