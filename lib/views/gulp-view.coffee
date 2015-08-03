{View, $} = require('space-pen')
{Emitter} = require('atom')
FileFinderUtil = require('../file-finder-util')

class GulpView extends View
  @content: ->
    @div class: 'gulp-view', style: 'display:flex;', =>
      @div outlet: 'fileContainer', class: 'file-container',  =>
        @ul outlet: 'fileList'
      @div outlet: 'argsContainer', class: 'args-container inline-block',  =>
        @span outlet: 'argsInputLabel', 'Args required to fetch tasks (optional)'

  initialize: ->
    @emitter = new Emitter()
    @fileFinderUtil = new FileFinderUtil()

    @setupArgsContainer()
    @createGulpfileList()

  setupArgsContainer: ->
    @argsInput = document.createElement('atom-text-editor')
    @argsInput.setAttribute('mini', '')
    @argsContainer.append(@argsInput)

  createGulpfileList: ->
    @fileList.empty()
    for filePath in @fileFinderUtil.findFiles(/^gulpfile\.[js|coffee]/i)
      gulpfile =
        path: filePath
        relativePath: FileFinderUtil.getRelativePath(filePath)

      listItem = $("<li><span class='icon icon-file-text'>#{gulpfile.relativePath}</span></li>")

      do (gulpfile, @emitter, @argsInput) ->
        listItem.first().on('click', ->
          gulpfile.args = argsInput.getModel().getText()
          emitter.emit('gulpfile:selected', gulpfile)
        )

      @fileList.append(listItem)

  onDidClickGulpfile: (callback) ->
    return @emitter.on('gulpfile:selected', callback)

  refresh: ->
    @createGulpfileList()

  destroy: ->

module.exports = GulpView
