const express = require('express');
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const bcrypt = require('bcrypt');
const User = require('../models/User');

// passport authentication middleware
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
	if (res.locals.isAuthenticated) {
    return res.redirect('/skills');
	}

  res.render('index');
});

router.get('/register', function (req, res) {
	if (res.locals.isAuthenticated) {
    return res.redirect('/skills');
	}

  res.render('register');
});

router.post('/register', function (req, res, next) {
	const saltRounds = 10;

	bcrypt.hash(req.body.password, saltRounds, function (err, hash) {
		if (err) return next(err);

		let newUser = {
			username: req.body.username,
			email: req.body.email,
			password: hash
		};

		User.create(newUser, function (err, user) {
			if (err) return next(err);

			req.login(user, function (err) {
				if (err) return next(err);

				res.redirect('/skills');
			});
		});
	});
});

router.get('/login', function (req, res) {
	if (res.locals.isAuthenticated) {
    return res.redirect('/skills');
	}

  res.render('login');
});

router.post('/login', passport.authenticate('local', {
	successRedirect: '/skills',
	failureRedirect: '/login',
	failureFlash: true
}));

router.get('/logout', function (req, res) {
	req.logout();
	res.redirect('/login');
})

module.exports = router;
