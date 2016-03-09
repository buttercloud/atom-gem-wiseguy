shell = require 'shelljs'
path = require 'path'

module.exports = Bundler =

  getGemfileLock: (gemfilePath)->
    self = this
    new Promise (result, reject) ->
      shell.cd path.dirname(gemfilePath)
      if not shell.which('bundle')
        console.log("Couldn't find bundler path in #{gemfilePath}")
      else
        shell.exec 'bundle list', (code, out, err) ->
          if code == 0
            result(self.parseGemfileLock(out))
          else
            result({})
            console.log('Exit code:', code)
            console.log('Program output:', out)
            console.log('Program stderr:', err);

  parseGemfileLock: (bundleOutput) ->
    rgx = /(\w+-*\w*_*\w*) \(((\w*\.*)*)\)*/g
    match = null
    gems = {}
    
    loop
      match = rgx.exec(bundleOutput)
      break unless match
      gems[match[1]] = {version: match[2]}
    
    return gems