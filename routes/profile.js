const express = require('express');
const User = require('../models/User');
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
  let user = req.user;
  let name = req.body.name;
  let desc = req.body.description;

  user.skills.push({
    name: name,
    description: desc
  });

  user.save(function (err) {
    if (err) return next(err);

    res.json({
      status: "success"
    });
  });
});

router.patch('/skills/:id', function (req, res) {
  let user = req.user;
  let field = req.body.field;
  let value = req.body.value;
  let skill = user.skills.id(req.params.id);

  skill.field = value;

  console.log(req.user.skills);

  user.save(function (err) {
    if (err) return next(err);

    res.json({
      status: "success"
    });
  });
});

router.delete('/skills/:id', function (req, res) {
  let user = req.user;
  let skill = user.skills.id(req.params.id).remove();

  console.log(req.user.skills);

  user.save(function (err) {
    if (err) return next(err);

    res.json({
      status: "success"
    });
  });
});

module.exports = router;
