{View, $} = require('space-pen')
{Emitter} = require('atom')
GulpfileUtil = require('../gulpfile-util')

class GulpView extends View
  @content: ->
    @div =>
      @div outlet: 'fileContainer', =>
        @ul outlet: 'fileList'
      @div outlet: 'argsContainer', =>
        @span outlet: 'argsInputLabel', 'Args required to fetch tasks (optional)'

  initialize: ->
    @emitter = new Emitter()
    @gulpfileUtil = new GulpfileUtil()

    @addClass('gulp-view')
    @css('display','flex')

    @setupArgsContainer()
    @setupFileContainer()

  setupArgsContainer: ->
    @argsContainer.addClass('args-container')
    #TODO: MOve this to css
    @argsInputLabel.addClass('inline-block')
    @argsInput = document.createElement('atom-text-editor')
    @argsInput.setAttribute('mini', '')
    @argsContainer.append(@argsInput)


  setupFileContainer: ->
    @fileContainer.addClass('file-container')
    @createGulpfileList()

  createGulpfileList: ->
    @gulpfiles = @gulpfileUtil.getGulpfiles()

    @fileList.empty()
    for gulpfile in @gulpfiles
      filePath = @gulpfileUtil.createFilePath(gulpfile.dir, gulpfile.fileName)
      listItem = $("<li><span class='icon icon-file-text'>#{filePath}</span></li>")

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
