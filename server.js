const express = require('express');
const logger = require('morgan');
const favicon = require('serve-favicon');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const session = require('express-session');
const MemcachedStore = require('connect-memcached')(session);
const flash = require('connect-flash');
const passport = require('passport');
const path = require('path');
const db = require('./db');

const app = express();

// view engine setup
app.set('views', 'views');
app.set('view engine', 'pug');

// application middleware
app.use(favicon(path.join(__dirname, 'favicon.ico')));
app.use(logger('dev'));
app.use(express.static(path.join(__dirname, 'dist')));
app.use(cookieParser());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(session({ secret: 'call your girlfriend', resave: true, saveUninitialized: true, store: new MemcachedStore({ hosts: ['127.0.0.1:11211'], secret: 'have a cigar' }) }));
app.use(flash());
app.use(passport.initialize());
app.use(passport.session());

app.use(function(req, res, next){
  res.locals.isAuthenticated = req.isAuthenticated();
  next();
});

// application routes
app.use('/', require('./routes/index'));
app.use('/profile', require('./routes/profile'));

// catch 404 and forward to error handler
app.use(function (req, res, next) {
	let err = new Error('Not Found');
	err.status = 404;

	next(err);
});

// error handler
app.use(function (err, req, res, next) {
	res.locals.message = err.message;
	res.locals.error = req.app.get('env') === 'development' ? err : {};

	res.status(err.status || 500);
	res.render('error');
});

// listen for incoming requests
app.listen(3000, function () {
	console.log('Example app listening on port 3000!');
});
