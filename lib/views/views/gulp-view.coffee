ViewElement = require('./view-element')
GulpfileUtil = require('../../gulpfile-util')

{Emitter} = require('atom')

class GulpView extends ViewElement
  prepare: (id, visible) ->
    super(id, visible)

    @name = 'Gulpfiles'
    @emitter = new Emitter()
    @gulpfileUtil = new GulpfileUtil()


    header = document.createElement('h5')
    header.textContent = 'Gulpfiles: '
    @.appendChild(header)

    if visible
      @createGulpfileList()

    return @


  createGulpfileList: ->
    @gulpfiles = @gulpfileUtil.getGulpfiles()

    if @fileContainer
      @.removeChild(@fileContainer)

    @fileContainer = document.createElement('ul')

    for gulpfile in @gulpfiles
      el = document.createElement('li')
      el.textContent = @gulpfileUtil.createFilePath(gulpfile.dir, gulpfile.fileName)

      #Coffeescript syntax to create closure and capture gulpfile
      do (gulpfile, @emitter) -> el.addEventListener('click', ->
        emitter.emit('gulpfile:selected', gulpfile)
      )

      @fileContainer.appendChild(el)

    @.appendChild(@fileContainer)

  onDidClick: (callback) ->
    return @emitter.on('gulpfile:selected', callback)

  setVisibility: (value) ->
    super(value)


  destroy: ->

module.exports = document.registerElement('gulp-view', {
  prototype: GulpView.prototype
})
