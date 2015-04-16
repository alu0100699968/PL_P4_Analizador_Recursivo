chai    = require 'chai'
expect  = chai.expect
routes  = require "../../routes/index.coffee"
main    = require("./mainfortests.coffee")

describe "Rutas", ->
  req = {}
  res = {}
  describe "Index", ->
    it "Debe existir una ruta index con el titulo de la practica", ->
      res.render = (view, vars) ->
          expect(view).equal "index"
          expect(vars.title).equal "Analizador Descendente Predictivo Recursivo"
      routes.index(req, res)

describe "Parser", ->
  it "Prueba de multiplicacion y resta", ->
    result = main.parse("a = 4 * (3 - 1)")
    expect(result.type).equal("=")
    expect(result.right.type).equal("*")
    expect(result.right.left.value).equal(4)
    expect(result.right.right.type).equal("-")
    expect(result.right.right.left.value).equal(3)
    expect(result.right.right.right.value).equal(1)

  it "Prueba de suma y division", ->
    result = main.parse("b = 3 + (4 / 2)")
    expect(result.type).equal("=")
    expect(result.right.type).equal("+")
    expect(result.right.left.value).equal(3)
    expect(result.right.right.type).equal("/")
    expect(result.right.right.left.value).equal(4)
    expect(result.right.right.right.value).equal(2)

  it "Prueba de sentencia IF", ->
    result = main.parse("if c == 3 then d = 15")
    expect(result.type).equal("IF")
    expect(result.left.type).equal("==")
    expect(result.right.type).equal("=")

  it "Prueba de sentencia WHILE DO", ->
    result = main.parse("while a==3 do b = 4")
    expect(result.type).equal("WHILE")
    expect(result.left.type).equal("==")
    expect(result.right.type).equal("=")

  it "Prueba de llamada", ->
    result = main.parse("call (a)")
    expect(result.type).equal("CALL")
    expect(result.right.type).equal("ID")
    expect(result.right.value).equal("a")

  it "Prueba de operador ODD", ->
    result = main.parse("if odd 3 then b = 4")
    expect(result.left.type).equal("ODD")
    expect(result.left.right.value).equal(3)

  it "Prueba de BEGIN END", ->
    result = main.parse("begin a = 3 end")
    expect(result.type).equal("BEGIN")
    expect(result.left.right.value).equal(3)
