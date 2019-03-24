'use strict'

const express = require('express')
const favicon = require('serve-favicon')
const sha256 = require('js-sha256')
const path = require('path')
const app = express()
const port = 3000

app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')))
app.use('/', express.static(path.join(__dirname, 'public')))

app.get('/hash', (req, res) => {
    const hash = sha256.sha256(req.query.description)
    res.send(hash)
})

app.listen(port)