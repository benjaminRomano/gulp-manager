{DockPaneView} = require('atom-bottom-dock')
{Emitter, CompositeDisposable} = require('atom')
GulpView = require('./gulp-view')
OutputView = require('./output-view')

class GulpPaneView extends DockPaneView
  @content: ->
    @div class: 'gulp-pane', =>
      @subview 'gulpView', new GulpView()
      @subview 'outputView', new OutputView()

  initialize: ->
    super()
    @emitter = new Emitter()
    @subscriptions = new CompositeDisposable()
    @gulpView.show()
    @outputView.hide()
    @activeView = @gulpView

    @subscriptions.add(@gulpView.onDidClickGulpfile(@switchToOutputView.bind(@)))
    @subscriptions.add(@outputView.onDidClickBack(@switchToGulpView.bind(@)))

  switchToGulpView: ->
    @outputView.destroy()
    @outputView.hide()
    @gulpView.show()
    @activeView = @gulpView

  switchToOutputView: (gulpfile) ->
    @gulpView.destroy()
    @gulpView.hide()
    @outputView.show()
    @activeView = @outputView
    @outputView.refresh(gulpfile)

  refresh: ->
    @activeView.refresh()


  destroy: ->
    @outputView.destroy()
    @gulpView.destroy()
    @subscriptions.dispose()
    @remove()

module.exports = GulpPaneView
