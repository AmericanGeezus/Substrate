const express = require('express');
const router = express.Router();
const {LogRecord} = require('../../server')



router.post('/push',(req,res,next) =>{
    
    res.setHeader('Connection','Close')
    req.io.emit('console',req.body)
    res.json({Msg:"Received data."})
   next()
});



module.exports = router;