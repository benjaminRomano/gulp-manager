{CompositeDisposable} = require 'atom'
{BasicTabButton} = require 'atom-bottom-dock'

GulpPane = require './views/gulp-pane'

module.exports =
  activate: (state) ->
    @subscriptions = new CompositeDisposable()
    @gulpPanes = []

    packageFound = atom.packages.getAvailablePackageNames()
      .indexOf('bottom-dock') != -1

    unless packageFound
      atom.notifications.addError 'Could not find Bottom-Dock',
        detail: 'Gulp-Manager: The bottom-dock package is a dependency. \n
        Learn more about bottom-dock here: https://atom.io/packages/bottom-dock'
        dismissable: true

    @subscriptions.add atom.commands.add 'atom-workspace',
      'gulp-manager:add': => @add()

  consumeBottomDock: (@bottomDock) ->
    @add true

  add: (isInitial) ->
    if @bottomDock
      newPane = new GulpPane()
      @gulpPanes.push newPane

      config =
        name: 'Gulp'
        id: newPane.getId()
        active: newPane.isActive()

      @bottomDock.addPane newPane, 'Gulp', isInitial

  deactivate: ->
    @subscriptions.dispose()
    @bottomDock.deletePane pane.getId() for pane in @gulpPanes
