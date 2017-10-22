const express = require('express');
const router = express.Router();

router.use(function (req, res, next) {
  if (req.isAuthenticated()) {
    return next();
	}

  res.redirect('/login');
});

router.get('/', function (req, res) {
  let user = {
    skills: req.user.skills
  };

	res.render('profile', { user: user });
});

router.post('/skills', function (req, res) {
  res.json({});
});

router.patch('/skills/:id', function (req, res) {
  res.json({});
});

router.delete('/skills/:id', function (req, res) {
  res.json({});
});

module.exports = router;
