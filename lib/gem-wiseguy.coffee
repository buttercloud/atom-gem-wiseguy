{CompositeDisposable, Range} = require 'atom'
shell = require 'shelljs'
path = require 'path'
_ = require 'lodash'
RubyGems = require './rubygems'
Bundler = require './bundler'

module.exports = GemWiseguy =
  messages: []
  messenger: null
  subscriptions: null
  allToggled: false
  gemNameRegex: '^[^\\S\\r\\n]*gem\\s*[\'"]{1}([\\w-_]+)[\'"]{1}'
  
  activate: (state) ->
    @messages = []
    @messenger = null

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'gem-wiseguy:toggle-all': => @toggleAll()
    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'gem-wiseguy:toggle-at-cursor': => @toggleAtCursor()
    
  deactivate: ->
    @destroyMessages()
    @subscriptions.dispose()
    
  serialize: ->
    {}
    
  consumeInlineMessenger: (messenger) ->
    @messenger = messenger
  
  destroyMessages: ->
    @messages.map (msg) -> msg.destroy()
    @messages = []

  toggleAll: ->
    if @messages.length == 0
      if @messenger
        gemfilePath = atom.workspace.getActiveTextEditor().getPath()
        
        if @inGemFile(gemfilePath)
          regex = new RegExp(@gemNameRegex, 'igm')
          Bundler.getGemfileLock(gemfilePath).then (gemfileLock) =>
            buffer = atom.workspace.getActiveTextEditor().getBuffer()
            try
              buffer.scan regex, (res) =>
                gemName = res.match[1]
                start = res.range.start
                start.column = res.match[0].indexOf(gemName)
                range = _.clone(res.range)
                range.start = start
                @displayGemInfo(gemName, gemfileLock[gemName], range)
            catch e
              console.log(e)
              return false
        else
          atom.notifications.addWarning "You must have your Gemfile open to use gem-wiseguy"
      else
        atom.notifications.addError("You need to install the 'inline-messenger' package in order to use gem-wiseguy")
    else
      @destroyMessages()

  toggleAtCursor: ->
    gemfilePath = atom.workspace.getActiveTextEditor().getPath()
    if @inGemFile(gemfilePath)
      regex = new RegExp(@gemNameRegex, 'i')
      Bundler.getGemfileLock(gemfilePath).then (gemfileLock) =>
        cursors = atom.workspace.getActiveTextEditor().getCursors()
        _(cursors).forEach (cursor) =>
          line = cursor.getCurrentBufferLine()
          match = regex.exec(line)
          gemName = match[1]
          row = cursor.getBufferRow()
          start_col = line.indexOf(gemName)
          range = new Range([row, start_col],
                            [row, start_col + gemName.length]) 
          @displayGemInfo(gemName, gemfileLock[gemName], range)
  
  inGemFile: (path) ->
    path.endsWith('Gemfile')
    
  displayGemInfo: (gemName, currentInfo, range) ->
    RubyGems.getGemInfo(gemName).then (result) =>
      if result.error
        @messages.push @messenger.message
          range: range
          text: result.error
          severity: 'error'
      else
        devDeps = ""
        _(result.dependencies.development).forEach (dep) ->
          devDeps += "<li>#{dep.name}: #{dep.requirements}</li>"
        runDeps = ""
        _(result.dependencies.runtime).forEach (dep) ->
          runDeps += "<li>#{dep.name}: #{dep.requirements}</li>"

        @messages.push @messenger.message
          range: range
          html: """
            <div class="wg-links">
              <ul>
                <li><a href="#{result.documentation_uri}">Docs</a></li>
                <li><a href="#{result.source_code_uri}">Source</a></li>
                <li><a href="#{result.bug_tracker_uri}">Bugs/Issues</a></li>
              </ul>
            </div>
            <div class="wg-info wg-current-v">Installed: #{currentInfo.version}</div>
            <div class="wg-info wg-result-v">Latest: #{result.version}</div>
            <div>
              <div class="wg-info wg-desc">
                <details open>
                  <summary>Description</summary>
                  #{result.info}
                </details>
              </div>
            </div>
            <div class="wg-info wg-deps">
              <details>
                <summary>Dev Dependencies</summary>
                <ul>#{devDeps}</ul>
              </details>
              <details>
                <summary>Runtime Dependencies</summary>
                <ul>#{runDeps}</ul>
              </details>
            </div>
          """
          severity: "info"