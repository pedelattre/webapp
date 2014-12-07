
http = require 'http'
stylus = require 'stylus'
nib = require 'nib'
express = require 'express'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
methodOverride = require 'method-override'
session = require 'express-session'
errorhandler = require 'errorhandler'
dojo = require 'connect-dojo'
coffee = require 'connect-coffee-script'
serve_favicon = require 'serve-favicon'
serve_index = require 'serve-index'
serve_static = require 'serve-static'
db = require './db'
new_db = db "#{__dirname}/../db"
# config = require '../conf/hdfs'

app = express()

app.set 'views', __dirname + '/../views'
app.set 'view engine', 'jade'
app.use serve_favicon "#{__dirname}/../public/favicon.ico"
app.use bodyParser.json()
app.use bodyParser.urlencoded()
app.use cookieParser 'toto'
app.use methodOverride '_method'
app.use session secret: 'toto', resave: true, saveUninitialized: true

app.use coffee
  src: "#{__dirname}/../views"
  dest: "#{__dirname}/../public"
  bare: true
app.use stylus.middleware
  src: "#{__dirname}/../views"
  dest: "#{__dirname}/../public"
  compile: (str, path) ->
    stylus(str)
    .set('filename', path)
    .set('compress', config?.css?.compress)
    .use nib()
app.use serve_static "#{__dirname}/../public"

app.get '/', (req, res, next) ->
  res.render 'index', title: 'Express'

app.post '/user/login', (req, res, next) ->
  res.new_db.users.get req.body.username,
    (err) ->
      return next err if err
  res.json
    type : 'Successfully logged in'

app.post '/user/signup', (req, res, next) ->
  new_db.users.set req.body.username,
    password: req.body.password
    firstname: req.body.firstname
    lastname: req.body.lastname
    email: req.body.email
  , (err) ->
    return next err if err
  res.json
    type : 'New user added'

app.use serve_index "#{__dirname}/../public"
if process.env.NODE_ENV is 'development'
  app.use errorhandler()

module.exports = app
