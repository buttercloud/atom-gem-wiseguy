{CompositeDisposable} = require 'atom'
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
  
  activate: (state) ->
    @messages = []
    @messenger = null

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'gem-wiseguy:toggle': => @toggleAll()
    
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
    self = this
    @allToggled = !@allToggled
    
    if @allToggled
      if @messenger
        gemfilePath = atom.workspace.getActiveTextEditor().getPath()
        
        if gemfilePath.endsWith('Gemfile')
          activeEditor = atom.workspace.getActiveTextEditor()
          buffer = activeEditor.getBuffer()
          Bundler.getGemfileLock(gemfilePath).then (gemfileLock) ->
            try
              buffer.scan ///^[^\S\r\n]*gem\s*['"]{1}([\w-_]+)['"]{1}///igm, (res) ->
                gemName = res.match[1]
                start = res.range.start
                start.column = res.match[0].indexOf(gemName)
                range = _.clone(res.range)
                range.start = start
                self.displayGemInfo(gemName, gemfileLock[gemName], range)
            catch e
              console.log(e)
              return false
        else
          console.log "you're not in gemfile"
      else
          console.log "Messenger not loaded"
    else
      @destroyMessages()

  displayGemInfo: (gemName, currentInfo, range) ->
    self = this
    RubyGems.getGemInfo(gemName).then (result) ->
      if result.error
        self.messages.push self.messenger.message
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
          
        self.messages.push self.messenger.message
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