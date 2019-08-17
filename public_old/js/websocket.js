$(document).ready(function() {
	var user_id = $('.user-id').attr('data-id');

	connect(user_id);

	function connect (user) {
		if (user) {
			var ws = new WebSocket(url_ws);
			ws.onmessage = function (event) {
				var data = JSON.parse(event.data);
				$('.error').text(data.data);
				// setInfo(data);
			};
			ws.onopen	= function (event) {
				ws.send(JSON.stringify({"user":user,"data":"Connected"}));
				$('.error').text('Open connection '+user);
				var data = {'createmessage':'Open connection '+user};
				setInfo(data);
			};
			ws.onerror = function(e) {
			  	$(".error").text(e)
				var data = {'createmessage':'Error due connect' + e};
				setInfo(data);
			};
			ws.onclose = function(e) {
				$('.error').text('Socket is closed. Reconnect will be attempted in 1 second.', e.reason);
				var data = {'createmessage':'Socket is closed. Reconnect will be attempted in 1 second.'};
				setInfo(data);
				setTimeout(function() {
					connect(user);
				}, 5000)
			};
			return ws;
		}
		else {
			var data = {'createmessage':'Is not set user name for connection'};
			setInfo(data);
			$('.error').text('Is not set user name for connection');
			return null;	
		}
	}

	function setInfo(info) {
		$.each(info, function(k, v) {
			if (k != 'user') {
				if (typeof $('.'+k) != 'undefined') {
					$('.'+k).html(v);
				}
			}

		});
	}

	// for testing
	$(".send").click(function(){
		// var usr = $(".chanell").val();
		var usr = user_id;
		var dta = $("#data_s").val();

		var json = 
			{
				"user":usr,
				"data":dta,
				"error":"error here",
				"createmessage":2,
				"res":"Result",
				"url_post":url_post,
			}
		;

		$.ajax({
			url: url_post,
			type: "POST",
			data: JSON.stringify(json),
			dataType: 'json',
			contentType: 'application/json; charset=utf-8',
			success: function(data) {
// console.log('success', data);
			},
			error: function(data) {
// console.log('error', data);
				setInfo(data);
			}
		});
	});
});