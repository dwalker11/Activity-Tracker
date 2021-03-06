const express = require('express');
const User = require('../models/User');
const router = express.Router();

router.use((req, res, next) => {
  if (res.locals.isAuthenticated) {
    return next();
	}

  res.redirect('/login');
});

router.get('/', (req, res) => {
  let user = {
    skills: req.user.skills
  };

	res.render('profile', { user: user });
});

router.post('/', (req, res) => {
  let user = req.user;
  let name = req.body.name;
  let desc = req.body.description;

  user.skills.push({
    name: name,
    description: desc
  });

  user.save((err, user) => {
    if (err) return next(err);

    let index = user.skills.length - 1;
    let skill = user.skills[index];

    res.json({
      id: skill.id,
      status: "success"
    });
  });
});

router.patch('/:id', (req, res) => {
  let user = req.user;
  let field = req.body.field;
  let value = req.body.value;
  let skill = user.skills.id(req.params.id);

  skill[field] = value;

  user.save((err) => {
    if (err) return next(err);

    res.json({
      status: "success"
    });
  });
});

router.delete('/:id', (req, res) => {
  let user = req.user;
  let skill = user.skills.id(req.params.id).remove();

  user.save((err) => {
    if (err) return next(err);

    res.json({
      status: "success"
    });
  });
});

module.exports = router;
