ViewElement = require('./view-element')
GulpfileUtil = require('../../gulpfile-util')
$ = require('jquery')

{Emitter} = require('atom')

class GulpView extends ViewElement
  prepare: (id, @active) ->
    super(id, @active)

    @type = 'Gulpfiles'
    @emitter = new Emitter()
    @gulpfileUtil = new GulpfileUtil()


    if @active
      @createGulpfileList()

    return @

  createGulpfileList: ->
    @gulpfiles = @gulpfileUtil.getGulpfiles()

    if @fileContainer
      @removeChild(@fileContainer)

    @fileContainer = document.createElement('div')
    @fileContainer.className = 'fileContainer'
    fileList = document.createElement('ul')
    @fileContainer.appendChild(fileList)

    for gulpfile in @gulpfiles
      listItem = document.createElement('li')
      filePath = @gulpfileUtil.createFilePath(gulpfile.dir, gulpfile.fileName)

      $(listItem).append("<span class='icon icon-file-text'>#{filePath}</span>")

      #Coffeescript syntax to create closure and capture gulpfile
      do (gulpfile, @emitter) ->
        listItem.firstChild.addEventListener('click', ->
          emitter.emit('gulpfile:selected', gulpfile)
        )

      fileList.appendChild(listItem)

    @appendChild(@fileContainer)

  onGulpfileClicked: (callback) ->
    return @emitter.on('gulpfile:selected', callback)

  setVisibility: (value) ->
    super(value)

  refresh: ->
    @destroy()
    if @active
      @createGulpfileList()

  destroy: ->

module.exports = document.registerElement('gulp-view', {
  prototype: GulpView.prototype
})
