{DockPaneView, Toolbar} = require 'atom-bottom-dock'
{Emitter, CompositeDisposable} = require 'atom'
OutputView = require './output-view'
ControlsView = require './controls-view'
FileFinderUtil = require '../file-finder-util'
{$} = require 'space-pen'

class GulpPaneView extends DockPaneView
  @content: ->
    @div class: 'gulp-pane', style: 'display:flex;', =>
      @subview 'toolbar', new Toolbar()
      @subview 'outputView', new OutputView()

  initialize: ->
    super()
    @fileFinderUtil = new FileFinderUtil()
    @emitter = new Emitter()
    @subscriptions = new CompositeDisposable()
    @controlsView = new ControlsView()

    @outputView.show()

    @toolbar.addLeftTile item: @controlsView, priority: 0

    @subscriptions.add @controlsView.onDidSelectGulpfile @setGulpfile
    @subscriptions.add @controlsView.onDidClickRefresh @refresh
    @subscriptions.add @controlsView.onDidClickStop @stop
    @subscriptions.add @controlsView.onDidClickClear @clear

    @getGulpfiles()

  getGulpfiles: ->
    gulpfiles = []

    for filePath in @fileFinderUtil.findFiles /^gulpfile\.[babel.js|js|coffee]/i
      gulpfiles.push
        path: filePath
        relativePath: FileFinderUtil.getRelativePath filePath

    @controlsView.updateGulpfiles gulpfiles

  setGulpfile: (gulpfile) =>
    @outputView.refresh gulpfile

  refresh: =>
    @outputView.refresh()
    @getGulpfiles()

  stop: =>
    @outputView.stop()

  clear: =>
    @outputView.clear()

  destroy: ->
    @outputView.destroy()
    @subscriptions.dispose()
    @remove()

module.exports = GulpPaneView
