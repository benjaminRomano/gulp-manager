{DockPaneView, Toolbar} = require 'atom-bottom-dock'
{Emitter, CompositeDisposable} = require 'atom'
GulpView = require './gulp-view'
OutputView = require './output-view'
{$} = require 'space-pen'

class GulpPaneView extends DockPaneView
  @content: ->
    @div class: 'gulp-pane', style: 'display:flex;', =>
      @subview 'toolbar', new Toolbar()
      @subview 'gulpView', new GulpView()
      @subview 'outputView', new OutputView()

  initialize: ->
    super()
    @emitter = new Emitter()
    @subscriptions = new CompositeDisposable()

    @toolbar.addRightTile item: @createRefreshButon(), priority: 0

    @gulpView.show()
    @outputView.hide()
    @activeView = @gulpView

    @subscriptions.add @gulpView.onDidClickGulpfile @switchToOutputView
    @subscriptions.add @outputView.onDidClickBack @switchToGulpView


  createRefreshButon: ->
    refreshButton = $('<span class="refresh-button icon icon-sync"></span>')
    refreshButton.on 'click', =>
      @activeView.refresh()

  switchToGulpView: =>
    @outputView.destroy()
    @outputView.hide()
    @gulpView.show()
    @activeView = @gulpView

  switchToOutputView: (gulpfile) =>
    @gulpView.destroy()
    @gulpView.hide()
    @outputView.show()
    @activeView = @outputView
    @outputView.refresh gulpfile

  refresh: ->
    @activeView.refresh()

  destroy: ->
    @outputView.destroy()
    @gulpView.destroy()
    @subscriptions.dispose()
    @remove()

module.exports = GulpPaneView
