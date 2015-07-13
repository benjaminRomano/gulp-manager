OutputView = require './views/output-view'
GulpView = require './views/gulp-view'
GulpManagerHeader = require './header/gulp-manager-header'
{CompositeDisposable} = require 'atom'

class GulpManagerPanel extends HTMLElement
  prepare: (@state) ->
    #used to create unique ids
    @viewId = 0

    @subscriptions = new CompositeDisposable()

    gulpView = new GulpView().prepare(@viewId++, true)
    @subscriptions.add(gulpView.onDidClick(@createNewOutputView.bind(@)))

    @views = [
      gulpView
    ]

    buttonInfo = []
    for view in @views
      buttonInfo.push({
        name: view.name
        id: view.getId(),
        active: @views.indexOf(view) == 0
      })

    @gulpManagerHeader = new GulpManagerHeader().prepare(buttonInfo)

    for button in @gulpManagerHeader.buttons
      @subscriptions.add(button.onDidClick(@changeView.bind(@)))

    @panel = @createPanel()
    @.appendChild(@gulpManagerHeader)
    @.appendChild(@createViewContainer(@views))

    return @

  createPanel: ->
    options = item: this,
    visible: false,
    priority: 1000

    panel =  atom.workspace.addBottomPanel(options)
    panel.className = 'gulp-manager-panel'
    return panel


  createViewContainer: (views) ->
    viewContainer = document.createElement('div')
    viewContainer.id = 'gulpManagerViewContainer'
    viewContainer.className = 'inset-panel'
    for view in views
      viewContainer.appendChild(view)

    return viewContainer

  createNewOutputView: (gulpfile) ->
    viewContainer = document.getElementById('gulpManagerViewContainer')

    id = @viewId++

    for view in @views
      view.setVisibility(false)

    newView = new OutputView().prepare(gulpfile, id, true)
    @views.push(newView)

    if not viewContainer
      @createViewContainer(@views)
    else
      viewContainer.appendChild(newView)

    button = @gulpManagerHeader.addButton('Output', id, true)
    @subscriptions.add(button.onDidClick(@changeView.bind(@)))

  changeView: (id) ->
    for button in @gulpManagerHeader.buttons
      if button.getId() == id
        button.setActive(true)
      else
        button.setActive(false)

    for view in @views
      if view.getId() == id
        view.setVisibility(true)
      else
        view.setVisibility(false)
    return

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
