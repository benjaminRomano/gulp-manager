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
      @appendChild(@createArgsContainer())
      @insertBefore(@createGulpfileList(), @argsContainer)

    return @

  createGulpfileList: ->
    @gulpfiles = @gulpfileUtil.getGulpfiles()

    if @fileContainer
      @removeChild(@fileContainer)

    @fileContainer = document.createElement('div')
    @fileContainer.className = 'file-container'
    fileList = document.createElement('ul')
    @fileContainer.appendChild(fileList)

    for gulpfile in @gulpfiles
      listItem = document.createElement('li')
      filePath = @gulpfileUtil.createFilePath(gulpfile.dir, gulpfile.fileName)

      $(listItem).append("<span class='icon icon-file-text'>#{filePath}</span>")

      do (gulpfile, @emitter, @argsInput) ->
        listItem.firstChild.addEventListener('click', ->
          gulpfile.args = argsInput.getModel().getText()
          emitter.emit('gulpfile:selected', gulpfile)
        )

      fileList.appendChild(listItem)

    return @fileContainer

  createArgsContainer: ->
    if @argsContainer
      @removeChild(@argsContainer)

    @argsContainer = document.createElement('div')
    @argsContainer.classList.add('args-container')
    argsInputLabel = document.createElement('span')
    argsInputLabel.classList.add('inline-block')
    argsInputLabel.textContent =  "Args required to fetch tasks (optional):"
    @argsInput = document.createElement('atom-text-editor')
    @argsInput.setAttribute('mini', '')

    @argsContainer.appendChild(argsInputLabel)
    @argsContainer.appendChild(@argsInput)

    return @argsContainer

  onGulpfileClicked: (callback) ->
    return @emitter.on('gulpfile:selected', callback)

  setVisibility: (value) ->
    super(value)

  refresh: ->
    @destroy()
    if @active
      @appendChild(@createArgsContainer())
      @insertBefore(@createGulpfileList(), @argsContainer)

  destroy: ->

module.exports = document.registerElement('gulp-view', {
  prototype: GulpView.prototype
})
