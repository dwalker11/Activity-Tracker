const mongoose = require('mongoose');

const Schema = mongoose.Schema;
const SkillSchema = new Schema({
  name: {
    type: String,
    required: true
  },
  description: {
    type: String,
    default: ''
  },
  minutes: {
    type: Number,
    min: 0,
    default: 0
  },
  locked: {
    type: Boolean,
    default: true
  }
});

const UserSchema = new Schema({
  username: {
    type: String,
    required: true
  },
  email: {
    type: String,
    required: true,
    unique: true
  },
  password: {
    type: String,
    required: true
  },
  skills: {
    type: [SkillSchema]
  }
});

UserSchema.set('toJSON', { getters: true, virtuals: true });
SkillSchema.set('toJSON', { getters: true, virtuals: true });

module.exports = mongoose.model('User', UserSchema);
