express      = require 'express'
path         = require 'path'
bodyParser   = require 'body-parser'
search       = require './search'
coffeescript = require 'connect-coffee-script'
rmDiacr      = require('diacritics').remove

app = express()

printObj = (o) ->
  console.log require('util').inspect(o, colors: true, depth: null)

glob =
  gen: 0,
  dIdNb: 0,
  dIds: {},
  dData: {},
  dWords: {},
  dGen: {}
  indexes: []
tokenizers = [((s) -> s.toLowerCase()), ((s) -> rmDiacr(s))]
search.fetchFolder './data', true, tokenizers, glob, ->
  search.index(glob)
  search.save('save.txt', glob)
  search.load('save.txt', glob)

pub = path.join(__dirname, 'public')
app.use express.static pub
app.use express.static path.join(__dirname, 'bower_components')
app.use bodyParser.urlencoded(extended: true)
app.use bodyParser.json()
app.use require('compression')()
app.use require('method-override')()
app.use coffeescript src: pub

app.get '/api/search/:query', (req, res) ->
  res.send 200, results: search.search(req.params.query, glob)

app.get '/api/index_test', (req, res) ->
  search.newGen(glob)
  search.fetchFolder 'test', true, tokenizers, glob, ->
    search.index(glob)
    res.send 200, "New generation created (See server log for more details)"

app.get '/api/delete_test', (req, res) ->
  search.delete path.join(__dirname, 'test/test.txt'), glob
  res.send 200, "File should now be deleted"

app.listen process.env.PORT || 3000, ->
  console.log "Server running"
  console.log "\tPort:\t#{this.address().port}"
  console.log "\tMode:\t#{app.settings.env}"
