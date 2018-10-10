const express = require('express');
const logger = require('morgan');
const favicon = require('serve-favicon');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const session = require('express-session');
const RedisStore = require('connect-redis')(session);
const flash = require('connect-flash');
const passport = require('passport');
const path = require('path');
const db = require('./mongo');
const client = require('./redis');

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
app.use(session({ secret: 'call your girlfriend', resave: false, saveUninitialized: true, cookie: {maxAge: 3600000}, store: new RedisStore({ client: client }) }));
app.use(flash());
app.use(passport.initialize());
app.use(passport.session());

// check if this is an authenticated request
app.use((req, res, next) => {
  res.locals.isAuthenticated = req.isAuthenticated();
  next();
});

// application routes
app.use('/', require('./routes/index'));
app.use('/skills', require('./routes/skills'));

// catch 404 and forward to error handler
app.use((req, res, next) => {
	let err = new Error('Not Found');
	err.status = 404;

	next(err);
});

// error handler
app.use((err, req, res, next) => {
	res.locals.message = err.message;
	res.locals.error = req.app.get('env') === 'development' ? err : {};

	res.status(err.status || 500);
	res.render('error');
});

// listen for incoming requests
app.listen(process.env.PORT || 8080, () => console.log('Example app listening on port 8080!'));
