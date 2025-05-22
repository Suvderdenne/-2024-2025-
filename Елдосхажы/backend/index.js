#!/usr/bin/env node
require('dotenv').config()
const entry = require('./src/entry')
const port = process.env.PORT

entry.listen(port, () => {
    console.log(`Eldos app listening at http://localhost:${port}`)
})
