{Emitter} = require('atom')

class HeaderButton extends HTMLElement
  prepare: (@name, id) ->
    @.id = 'header-button-' + id

    @emitter = new Emitter()

    @.classList.add('btn')
    @.textContent = @name

    @.addEventListener('click', =>
      @emitter.emit('header:button:clicked', @.getId())
    )

    return @

  getId: ->
    return @.id.split('header-button-')[1]

  setActive: (value) ->
    if value
      @.classList.add('selected')
    else
      @.classList.remove('selected')

  onDidClick: (callback) ->
    return @emitter.on 'header:button:clicked', callback

module.exports = document.registerElement('header-button', {
  prototype: HeaderButton.prototype
})
