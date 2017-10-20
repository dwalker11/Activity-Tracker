const express = require('express');
const logger = require('morgan');
const favicon = require('serve-favicon');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const session = require('express-session');
const flash = require('connect-flash');
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const path = require('path');
const bcrypt = require('bcrypt');

const app = express();

// view engine setup
app.set('views', 'views');
app.set('view engine', 'pug');

// application middleware
/* app.use(favicon(path.join(__dirname, 'dist', 'favicon.ico'))); */
app.use(logger('dev'));
app.use(express.static(path.join(__dirname, 'dist')));
app.use(cookieParser());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(session({ secret: 'call your girlfriend', resave: true, saveUninitialized: true }));
app.use(flash());
app.use(passport.initialize());
app.use(passport.session());

// authentication middleware
const db = require('./db');
const User = require('./models/User');

passport.use(new LocalStrategy(function (username, password, done) {
	User.findOne({username: username}, function (err, user) {
		if (err) return done(err);

		if (!user) {
			return done(null, false, { message: 'Incorrect username.' });
		}

		if (!bcrypt.compareSync(password, user.password)) {
			return done(null, false, { message: 'Incorrect username.' });
		}

		return done(null, user);
	});
}));

passport.serializeUser(function (user, done) {
	done(null, user.id);
});

passport.deserializeUser(function (id, done) {
	User.findById(id, function (err, user) {
		done(err, user);
	})
});

// application routes
app.get('/', function (req, res) {
	res.render('index');
});

app.get('/home', function (req, res) {
	res.render('home');
});

app.get('/register', function (req, res) {
	res.render('register');
});

app.post('/register', function (req, res) {
	res.render('register');
});

app.get('/login', function (req, res) {
	res.render('login');
});

app.post('/login', passport.authenticate('local', {
	successRedirect: '/home',
	failureRedirect: '/login',
	failureFlash: true
}));

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
