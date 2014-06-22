_ = require 'lodash'
fs = require 'fs'
path = require 'path'
readdirp = require 'readdirp'
xregexp = require('xregexp').XRegExp
now = require 'performance-now'

module.exports =
  fetchFile: (p, tokenizers, env) ->
    p = path.normalize(path.join(__dirname, p))
    dId = env.dIds[p] || (env.dIdNb += 1)
    env.dIds[p] ||= dId

    env.dGen[dId] = env.gen

    meta = _.pick(fs.statSync(p), ['mtime', 'ctime', 'size'])
    data = {path: p, meta: meta}
    env.dData[dId] = data

    data = fs.readFileSync(p).toString()
    for tokenizer in tokenizers
      data = tokenizer(data)
      undefined
    splitted = data.split xregexp('\\P{L}+')
    meta.mtime = meta.mtime.getTime()
    meta.ctime = meta.ctime.getTime()
    env.dWords[dId] = {}
    for word, ind in splitted
      if word != ''
        env.dWords[dId][word] ||= []
        env.dWords[dId][word].push ind if env.dWords[dId].hasOwnProperty(word)
      undefined

  fetchFolder: (p, recursive, tokenizers, env, cb) ->
    options = {root: p}
    options.depth = 0 unless recursive

    self = this
    files = []

    readdirp(options)
      .on 'warn', (err) ->
        console.log "WARN: #{err}"
      .on 'error', (err) ->
        console.log "FATAL: #{err}"
      .on 'data', (entry) ->
        files.push(entry)
      .on 'end', ->
        for entry in files
          self.fetchFile(path.join(p, entry.path), tokenizers, env)
          undefined
        cb()

  newGen: (env) ->
    env.gen += 1

  index: (env) ->
    start = now()
    res = env.indexes[env.gen] = {}
    for dId, words of env.dWords when env.dGen[dId] == env.gen
      for word, pos of words
        res[word] ||= {}
        res[word][dId] = pos
        undefined
      undefined
    env.dWords = {}
    console.log "Indexing took : #{(now() - start)} ms (Generation = #{env.gen})"

  save: (path, env) ->
    start = now()
    fs.writeFileSync path, JSON.stringify(env)
    console.log "Save took : #{(now() - start)} ms"

  load: (path, env) ->
    start = now()
    data = JSON.parse(fs.readFileSync path)
    for key, v of data
      env[key] = v
      undefined
    console.log "Load took : #{(now() - start)} ms"

  delete: (path, env) ->
    env.dGen[env.dIds[path]] = -1

  get: (word, env) ->
    res = []
    for gen in [0..env.gen]
      for dId in Object.keys(env.indexes[gen][word] || {})
        res.push dId if env.dGen[dId] == gen
        undefined
      undefined
    res

  not: (list, env) ->
    _.difference(Object.keys(env.dData), list)

  and: (list1, list2) ->
    _.intersection(list1, list2)

  or: (list1, list2) ->
    _.union(list1, list2)

  strict_get: (word, env) ->
    res = {}
    for gen in [0..env.gen]
      for dId, pos of (env.indexes[gen][word] || {})
        res[dId] = pos if env.dGen[dId] == gen
        undefined
      undefined
    res

  strict_and: (list1, list2) ->
    res = {}
    for dId, positions of list1
      continue unless list2[dId]?
      for pos in positions
        if list2[dId].indexOf(pos - 1) != -1
          res[dId] ||= []
          res[dId].push(pos - 1)
        undefined
      undefined
    res

  search: (query, env) ->
    start = now()
    dids = require('./parser')(env).parse(query)
    res = _.pick(env.dData, dids)
    console.log "Query took : #{(now() - start)} ms (#{query})"
    res
