express = require('express')
router = express.Router()

### GET home page. ###

router.get '/', (req, res, next) ->
  res.render 'index', title: 'Analizador Descendente Predictivo Recursivo'
  return
module.exports = router
