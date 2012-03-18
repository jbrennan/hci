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

function logout() {
	document.cookie = encodeURIComponent("auth") + "=deleted; expires=" + new Date(0).toUTCString();
	window.location.replace("/");
}