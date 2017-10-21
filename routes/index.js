const express = require('express');
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const bcrypt = require('bcrypt');

// passport authentication middleware
const db = require('../db');
const User = require('../models/User');

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
	});
});

// routes
const router = express.Router();

router.get('/', function (req, res) {
	res.render('index');
});

router.get('/register', function (req, res) {
	res.render('register');
});

router.post('/register', function (req, res) {
	res.render('register');
});

router.get('/login', function (req, res) {
	res.render('login');
});

router.post('/login', passport.authenticate('local', {
	successRedirect: '/profile',
	failureRedirect: '/login',
	failureFlash: true
}));

router.get('/logout', function (req, res) {
	req.logout();
	res.redirect('/login');
})

module.exports = router;
