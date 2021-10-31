const util = require('ethereumjs-util')

const priv_key = "0x11f2b30c9479ccaa639962e943ca7cfd3498705258ddb49dfe25bba00a555e48cb35a79f3d084ce26dbac0e6bb887463774817cb80e89b20c0990bc47f9075d5"
const pub_key = util.privateToPublic(priv_key)

console.log(priv_key)
console.log(pub_key)