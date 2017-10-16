const path = require('path');
const express = require('express');
const app = express();

app.set('views', 'views');
app.set('view engine', 'pug');

app.use(express.static(path.join(__dirname, 'dist')));

app.get('/', function (req, res) {
	res.render('index');
});

app.listen(3000, function () {
	console.log('Example app listening on port 3000!');
});
