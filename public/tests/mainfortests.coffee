
module.exports =
	parse: (source)->
          parse(source)

Object.constructor::error = (message, t) ->
  t = t or this
  t.name = "SyntaxError"
  t.message = message
  throw treturn

RegExp::bexec = (str) ->
  i = @lastIndex
  m = @exec(str)
  return m  if m and m.index is i
  null

String::tokens = ->
  from = undefined # The index of the start of the token.
  i = 0 # The index of the current character.
  n = undefined # The number value.
  m = undefined # Matching
  result = [] # An array to hold the results.
  tokens =
    WHITES: /\s+/g
    ID: /[a-zA-Z_]\w*/g
    NUM: /\b\d+(\.\d*)?([eE][+-]?\d+)?\b/g
    STRING: /('(\\.|[^'])*'|"(\\.|[^"])*")/g
    ONELINECOMMENT: /\/\/.*/g
    MULTIPLELINECOMMENT: /\/[*](.|\n)*?[*]\//g
    COMPARISONOPERATOR: /[<>=!]=|[<>]/g
    ADDSUBOPERATORS: /[+-]/g
    MULTDIVOPERATORS: /[*\/]/g
    ONECHAROPERATORS: /([=()&|;:,{}[\]])/g

  RESERVED_WORD =
    p: "P"
    #const = "CONST"
    #var = "VAR"
    #procedure = "PROCEDURE"
    call: "CALL"
    begin: "BEGIN"
    end: "END"
    if: "IF"
    then: "THEN"
    while: "WHILE"
    do: "DO"
    odd: "ODD"

  # Make a token object.
  make = (type, value) ->
    type: type
    value: value
    from: from
    to: i

  getTok = ->
    str = m[0]
    i += str.length # Warning! side effect on i
    str


  # Begin tokenization. If the source string is empty, return nothing.
  return  unless this

  # Loop through this text
  while i < @length
    for key, value of tokens
      value.lastIndex = i

    from = i

    # Ignore whitespace and comments
    if m = tokens.WHITES.bexec(this) or
           (m = tokens.ONELINECOMMENT.bexec(this)) or
           (m = tokens.MULTIPLELINECOMMENT.bexec(this))
      getTok()

    # name.
    else if m = tokens.ID.bexec(this)
      rw = RESERVED_WORD[m[0]]
      if rw
        result.push make(rw, getTok())
      else
        result.push make("ID", getTok())

    # number.
    else if m = tokens.NUM.bexec(this)
      n = +getTok()
      if isFinite(n)
        result.push make("NUM", n)
      else
        make("NUM", m[0]).error "Bad number"

    # string
    else if m = tokens.STRING.bexec(this)
      result.push make("STRING",
                        getTok().replace(/^["']|["']$/g, ""))

    # add y sub operators
    else if m = tokens.ADDSUBOPERATORS.bexec(this)
      result.push make("ADDSUBOPERATORS", getTok())

    # mult y div operators
    else if m = tokens.MULTDIVOPERATORS.bexec(this)
      result.push make("MULTDIVOPERATORS", getTok())

    # comparison operator
    else if m = tokens.COMPARISONOPERATOR.bexec(this)
      result.push make("COMPARISON", getTok())

    # single-character operator
    else if m = tokens.ONECHAROPERATORS.bexec(this)
      result.push make(m[0], getTok())
    else
      throw "Syntax error near '#{@substr(i)}'"
  result

parse = (input) ->
  tokens = input.tokens()
  lookahead = tokens.shift()
  match = (t) ->
    if lookahead.type is t
      lookahead = tokens.shift()
      lookahead = null  if typeof lookahead is "undefined"
    else # Error. Throw exception
      throw "Syntax Error. Expected #{t} found '" +
            lookahead.value + "' near '" +
            input.substr(lookahead.from) + "'"
    return

  block = ->
    result = null
    if lookahead and lookahead.type is "CONST"
      match "CONST"
      left = factor()
      match "="
      right = factor()
      result =
        type: "CONST"
        left: left
        right: right
    result

  statements = ->
    result = [statement()]
    while lookahead and lookahead.type is ";"
      match ";"
      result.push statement()
    (if result.length is 1 then result[0] else result)

  statement = ->
    result = null
    if lookahead and lookahead.type is "ID"
      left =
        type: "ID"
        value: lookahead.value

      match "ID"
      match "="
      right = expression()
      result =
        type: "="
        left: left
        right: right
    else if lookahead and lookahead.type is "P"
      match "P"
      right = expression()
      result =
        type: "P"
        value: right
    else if lookahead and lookahead.type is "CALL"
      match "CALL"
      right = factor()
      result =
        type: "CALL"
        right: right
    else if lookahead and lookahead.type is "BEGIN"
      match "BEGIN"
      left = statements()
      match "END"
      result =
        type: "BEGIN"
        left: left
    else if lookahead and lookahead.type is "IF"
      match "IF"
      left = condition()
      match "THEN"
      right = statement()
      result =
        type: "IF"
        left: left
        right: right
    else if lookahead and lookahead.type is "WHILE"
      match "WHILE"
      left = condition()
      match "DO"
      right = statement()
      result =
        type: "WHILE"
        left: left
        right: right
    else # Error!
      throw "Syntax Error. Expected identifier but found " +
        (if lookahead then lookahead.value else "end of input") +
        " near '#{input.substr(lookahead.from)}'"
    result

  condition = ->
    if lookahead and lookahead.type is "ODD"
      match "ODD"
      right = expression()
      result =
        type: "ODD"
        right: right
    else
      left = expression()
      type = lookahead.value
      match "COMPARISON"
      right = expression()
      result =
        type: type
        left: left
        right: right
    result

  expression = ->
    result = term()
    while lookahead and lookahead.type is "ADDSUBOPERATORS"
      type = lookahead.value
      match "ADDSUBOPERATORS"
      right = term()
      result =
        type: type
        left: result
        right: right
    result

  term = ->
    result = factor()
    if lookahead and lookahead.type is "MULTDIVOPERATORS"
      type =  lookahead.value
      match "MULTDIVOPERATORS"
      right = term()
      result =
        type: type
        left: result
        right: right
    result

  factor = ->
    result = null
    if lookahead.type is "NUM"
      result =
        type: "NUM"
        value: lookahead.value

      match "NUM"
    else if lookahead.type is "ID"
      result =
        type: "ID"
        value: lookahead.value

      match "ID"
    else if lookahead.type is "("
      match "("
      result = expression()
      match ")"
    else # Throw exception
      throw "Syntax Error. Expected number or identifier or '(' but found " +
        (if lookahead then lookahead.value else "end of input") +
        " near '" + input.substr(lookahead.from) + "'"
    result

  tree = statements(input)
  if lookahead?
    throw "Syntax Error parsing statements. " +
      "Expected 'end of input' and found '" +
      input.substr(lookahead.from) + "'"
  tree
