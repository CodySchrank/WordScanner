var express = require('express');
var app = express();

app.use(express.static(__dirname + "/client"));

var server = app.listen(3000,function(){
	console.log("Listening on port 3000");
});

var io = require('socket.io').listen(server);

io.sockets.on('connection',function(socket){
	console.log(socket.id + " connected");
});