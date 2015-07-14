GulpManagerHeader = require './header/gulp-manager-header'
ViewManager = require './views/view-manager'
{CompositeDisposable} = require 'atom'

class GulpManagerPanel extends HTMLElement
  prepare: (@state) ->
    #used to create unique ids
    @viewId = 0

    @subscriptions = new CompositeDisposable()

    #@subscriptions.add(gulpView.onDidClick(@createNewOutputView.bind(@)))

    viewInfo = [{
      type: 'Gulpfiles',
      id: @viewId++,
      active: true
    }]

    buttonInfo = []
    for info in viewInfo
      buttonInfo.push({
        name: info.type
        id: info.id
        active: info.active
      })

    @viewManager = new ViewManager().prepare(viewInfo)
    @gulpManagerHeader = new GulpManagerHeader().prepare(buttonInfo)

    @viewManager.onGulpfileClicked(@createNewOutputView.bind(@))
    @gulpManagerHeader.onHeaderButtonClicked(@changeView.bind(@))
    @gulpManagerHeader.onDeleteButtonClicked(@deleteView.bind(@))
    @gulpManagerHeader.onRefreshButtonClicked(@refrshView.bind(@))

    @panel = @createPanel()
    @.appendChild(@gulpManagerHeader)
    @.appendChild(@viewManager)

    return @

  createNewOutputView: (gulpfile) ->
    viewInfo =
      type: 'Output'
      gulpfile: gulpfile
      id: @viewId++
      active: true

    @viewManager.addView(viewInfo)
    button = @gulpManagerHeader.addButton('Output', viewInfo.id, true)

  changeView: (id) ->
    @viewManager.changeView(id)

  refrshView: ->
    @viewManager.refreshCurrentView()

  deleteView: ->
    success = @viewManager.deleteCurrentView()
    if success
      @gulpManagerHeader.deleteCurrentHeaderButton()


  createPanel: ->
    options = item: this,
    visible: false,
    priority: 1000

    panel =  atom.workspace.addBottomPanel(options)
    panel.className = 'gulp-manager-panel'
    return panel

  destroy: ->
    @subscriptions.dispose()

  toggleVisibility: ->
    if @panel.isVisible()
      @panel.hide()
    else
      @panel.show()

module.exports = document.registerElement('gulp-manager-panel', {
  prototype: GulpManagerPanel.prototype
})
