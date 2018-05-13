const mongoose = require('mongoose');

const url = process.env.MONGODB_URI;

mongoose.connect(url, { useMongoClient: true });
mongoose.Promise = global.Promise;

const db = mongoose.connection;

db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function() {
	console.log('We\'re in mongo!');
});
