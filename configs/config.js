const fs = require('fs');

module.exports = {
    creds:{
         key: fs.readFileSync('./configs/Certs/cert.key'),
        cert: fs.readFileSync('./configs/Certs/cert.cer')
    },
    port: 5370,
}