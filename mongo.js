const mongoose = require('mongoose');

const user = encodeURIComponent(process.env.MONGO_INITDB_ROOT_USERNAME);
const password = encodeURIComponent(process.env.MONGO_INITDB_ROOT_PASSWORD);
const authMechanism = 'DEFAULT';

const url = process.env.MONGODB_URI || `mongodb://${user}:${password}@mongo:27017/?authMechanism=${authMechanism}`;

mongoose.connect(url, { useMongoClient: true });
mongoose.Promise = global.Promise;

const db = mongoose.connection;

db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function() {
	console.log('We\'re in mongo!');
});
