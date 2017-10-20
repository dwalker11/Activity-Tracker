const mongoose = require('mongoose');

const url = 'mongodb://localhost:27017/skillz';

mongoose.connect(url, { useMongoClient: true });
mongoose.Promise = global.Promise;

const db = mongoose.connection;

db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function() {
	console.log('We\'re in mongo!');
});
