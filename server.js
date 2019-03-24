'use strict'

const express = require('express')
const favicon = require('serve-favicon')
const path = require('path')
const app = express()
const port = 3000

app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')))
app.use('/', express.static(path.join(__dirname, 'public')))

app.listen(port)