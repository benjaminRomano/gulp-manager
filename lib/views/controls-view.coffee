{DockPaneView} = require 'atom-bottom-dock'
{Emitter, CompositeDisposable} = require 'atom'
{$} = require 'space-pen'

class ControlsView extends DockPaneView
  @content: ->
    @div =>
      @span outlet: 'stopButton', class: 'stop-button icon icon-primitive-square', click: 'onStopClicked'
      @span outlet: 'refreshButton', class: 'refresh-button icon icon-sync', click: 'onRefreshClicked'
      @span outlet: 'clearButton', class: 'clear-button icon icon-history', click: 'onClearClicked'
      @select outlet: 'fileSelector'
      @span class: 'args-input-label', 'Args to fetch tasks (optional):'

  initialize: ->
    super()
    @emitter = new Emitter()
    @subscriptions = new CompositeDisposable()
    
    @fileSelector.change(@onGulpfileSelected)

    @setupTooltips()
    @setupCustomTaskInput()
    
  setupTooltips: ->
    config =
      trigger: 'hover focus'
      delay:
        show: 0
        
    stopConfig = $.extend true, title: 'Stop current task', config
    refreshConfig = $.extend true, title: 'Refetch gulp tasks', config
    clearConfig = $.extend true, title: 'Clear log', config
        
    atom.tooltips.add @stopButton, stopConfig
    atom.tooltips.add @refreshButton, refreshConfig
    atom.tooltips.add @clearButton, clearConfig

  setupCustomTaskInput: ->
    @argsInput = document.createElement 'atom-text-editor'
    @argsInput.classList.add 'text-editor'
    @argsInput.setAttribute 'mini', ''
    @argsInput.getModel().setPlaceholderText 'Press Enter to run'

    @argsInput.addEventListener 'keyup', @onFetchArgsChanged

    @append @argsInput

  updateGulpfiles: (gulpfiles) ->
    @gulpfiles = {}
    @fileSelector.empty()

    for gulpfile in gulpfiles
      @gulpfiles[gulpfile.relativePath] = gulpfile

      @fileSelector.append $("<option>#{gulpfile.relativePath}</option>")

    if gulpfiles.length
      @fileSelector.selectedIndex = 0
      @fileSelector.change()

  onDidClickRefresh: (callback) ->
    @emitter.on 'button:refresh:clicked', callback

  onDidClickStop: (callback) ->
    @emitter.on 'button:stop:clicked', callback

  onDidClickClear: (callback) ->
    @emitter.on 'button:clear:clicked', callback

  onDidSelectGulpfile: (callback) ->
    @emitter.on 'gulpfile:selected', callback

  onRefreshClicked: ->
    @emitter.emit 'button:refresh:clicked'

  onStopClicked: ->
    @emitter.emit 'button:stop:clicked'

  onClearClicked: (callback) ->
    @emitter.emit 'button:clear:clicked'

  onGulpfileSelected: (e) =>
    gulpfile = @gulpfiles[e.target.value]
    gulpfile.args = @argsInput.getModel().getText()
    @emitter.emit 'gulpfile:selected', gulpfile

  onFetchArgsChanged: (e) =>
    return unless e.keyCode is 13 and @fileSelector.val()

    gulpfile = @gulpfiles[@fileSelector.val()]
    gulpfile.args = @argsInput.getModel().getText()
    @emitter.emit 'gulpfile:selected', gulpfile


module.exports = ControlsView
