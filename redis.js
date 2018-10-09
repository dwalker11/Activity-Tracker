const redis = require('redis');
const client = redis.createClient(process.env.REDIS_URL || "redis://localhost:6379");

console.log('The redis client is: ' + client);

module.exports = client
