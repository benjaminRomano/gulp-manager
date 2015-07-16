TabManager = require './header/tab-manager'
ViewManager = require './views/view-manager'
{CompositeDisposable} = require 'atom'

class GulpManagerPanel extends HTMLElement
  prepare: (@state) ->
    #used to create unique ids
    @viewId = 0

    @subscriptions = new CompositeDisposable()

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
    @tabManager = new TabManager().prepare(buttonInfo)

    @viewManager.onGulpfileClicked(@createNewOutputView.bind(@))
    @tabManager.onHeaderButtonClicked(@changeView.bind(@))
    @tabManager.onDeleteButtonClicked(@deleteView.bind(@))
    @tabManager.onRefreshButtonClicked(@refreshView.bind(@))

    @panel = @createPanel()
    @.appendChild(@tabManager)
    @.appendChild(@viewManager)

    return @

  createNewOutputView: (gulpfile) ->
    viewInfo =
      type: 'Output'
      gulpfile: gulpfile
      id: @viewId++
      active: true

    @viewManager.addView(viewInfo)
    button = @tabManager.addButton('Output', viewInfo.id, true)

  changeView: (id) ->
    @viewManager.changeView(id)

  refreshView: ->
    @viewManager.refreshCurrentView()

  deleteView: ->
    success = @viewManager.deleteCurrentView()
    if success
      @tabManager.deleteCurrentHeaderButton()


  createPanel: ->
    options = item: this,
    visible: false,
    priority: 1000

    panel =  atom.workspace.addBottomPanel(options)
    panel.className = 'gulp-manager-panel'
    return panel

  destroy: ->
    @panel.destroy()
    @subscriptions.dispose()

  toggleVisibility: ->
    if @panel.isVisible()
      @panel.hide()
    else
      @panel.show()

module.exports = document.registerElement('gulp-manager-panel', {
  prototype: GulpManagerPanel.prototype
})
