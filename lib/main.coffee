GulpManagerPanel = require './views/gulp-manager-panel'
{CompositeDisposable} = require 'atom'

module.exports = GulpManager =
  gulpManangerPanel: null
  subscriptions: null

  activate: (state) ->
    @gulpManagerPanel = new GulpManagerPanel()
    @gulpManagerPanel.prepare()

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @subscriptions.add(atom.commands.add('atom-workspace', 'gulp-manager:toggle': => @toggle()))

  deactivate: ->
    @gulpManagerPanel.destroy()
    @subscriptions.dispose()

  toggle: ->
    @gulpManagerPanel.toggleVisibility()
