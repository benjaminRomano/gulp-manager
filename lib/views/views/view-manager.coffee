OutputView = require('./output-view')
GulpView = require('./gulp-view')

{Emitter, CompositeDisposable} = require('atom')

class ViewManager extends HTMLElement
  prepare: (viewInfo) ->
    @views = []
    @subscriptions = new CompositeDisposable()
    @emitter = new Emitter()

    for info in viewInfo
      @addView(info)

    return @

  addView: (info) ->
    newView = @createNewView(info)

    @views.push(newView)

    if newView.isActive()
      @changeView(newView.getId())

    @.appendChild(newView)

  onGulpfileClicked: (callback) ->
    return @emitter.on('gulpfile:selected', callback)

  createNewView: (info) ->
    switch info.type
      when 'Gulpfiles'
        return @createGulpView(info.id, info.active)
      when 'Output'
        return new OutputView().prepare(info.gulpfile, info.id, info.active)

  createGulpView: (id, active) ->
    view = new GulpView().prepare(id, active)
    @subscriptions.add(view.onGulpfileClicked((gulpfile) =>
      @emitter.emit('gulpfile:selected', gulpfile)
    ))
    return view

  changeView: (id) ->
    for view in @views
      if view.getId() == String(id)
        view.setActive(true)
      else
        view.setActive(false)

  refreshCurrentView: ->
    for view in @views
      if view.isActive()
        view.refresh()

  deleteCurrentView: ->
    currentView = null
    for view in @views
      if view.isActive()
        currentView = view

    if currentView.type == 'Gulpfiles'
      return false

    @views = @views.filter((v) ->
      return v.getId() != currentView.getId()
    )

    currentView.destroy()
    @.removeChild(currentView)

    @changeView(@views[0].getId())

    return true

  destroy: ->
    @subscriptions.dispose()
    for view in @views
      view.destroy()

module.exports = document.registerElement('view-manager', {
  prototype: ViewManager.prototype
})
