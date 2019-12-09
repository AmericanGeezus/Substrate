const fs = require('fs')
const config = require('./configs/config')
const express = require('express');
const https = require('https');

const app = express()
const bodyParser = require('body-parser')
const httpsServer = https.createServer(config.creds,app);

const io = require('socket.io').listen(httpsServer)
const path = require('path');

app.use(express.static(path.join(__dirname,'public')));
app.use(bodyParser.json({limit:'5mb'}))



app.post('/push',(req,res)=>{
    res.setHeader('Connection','Close')
    console.log(req.headers["user-agent"])
    io.emit('console',req.body)
    res.json({Msg:"Received data."})
})

app.post('/push/:sid',(req,res)=>{
    console.log(io.sockets.rooms)
    console.log('New data for : ' + req.params)
    io.sockets.in(req.params.sid).emit('console',req.body)
    res.json({
        Msg:"Server Recieved data.",
        Target:req.params.sid
})
})



app.get('/',(req,res)=>{
console.log('we have reached this point.')
res.sendFile('/index.html')
try{
console.log(req.ip)
}catch(err){
    console.log(err);
}
})

var sessionList = []

io.on('connection',(socket)=>{


    socket.on('newSID',(sid)=>{
        sessionList.push(String(sid))
        socket.join(String(sid))
        console.log("socket joined : "+sid);
       

    })


    socket.on('requestSessionList',()=>{
        socket.emit('requestSessionListResponse',sessionList)

    });


})



//server start

httpsServer.listen(config.port, function(){

    console.log("Server running at https://geezus.net:"+config.port)
});
