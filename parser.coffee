Parser = require('jison').Parser

module.exports = (env) ->
  grammar =
    lex:
      rules: [
        ["\\s+",      "/*Skip whitespaces*/"]
        ["[a-zA-Z]+", "return 'WORD';"      ]
        ["\"",        "return 'QUOT';"      ]
        ["\\(",       "return '(';"         ]
        ["\\)",       "return ')';"         ]
        ["!",         "return '!';"         ]
        ["&&",        "return '&&';"        ]
        ["\\|\\|",    "return '||';"        ]
        ["$",         "return 'EOF';"       ]
      ]
    operators: [
      ["left", "||"   ]
      ["left", "&&"   ]
      ["left", "!"    ]
    ]
    bnf:
      expressions: [["e EOF", "return $1;"]]
      e: [
        ["e || e",            "$$ = yy.search.or($1, $3);"       ]
        ["e && e",            "$$ = yy.search.and($1, $3);"      ]
        ["! e",               "$$ = yy.search.not($2, yy.env);"  ]
        ["( e )",             "$$ = $2;"                         ]
        ["QUOT strict QUOT",  "$$ = Object.keys($2);"            ]
        ["WORD",              "$$ = yy.search.get($1, yy.env);"  ]
      ]
      strict: [
        ["WORD strict", "$$ = yy.search.strict_and($2, yy.search.strict_get($1, yy.env), yy.env);" ]
        ["WORD",        "$$ = yy.search.strict_get($1, yy.env);"                                   ]
      ]


  parser = new Parser(grammar)
  parser.yy = env: env, search: require('./search')
  return parser
