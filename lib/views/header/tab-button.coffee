{Emitter} = require('atom')

class TabButton extends HTMLElement
  prepare: (@name, id, @active) ->
    @.id = 'tab-button-' + id

    @emitter = new Emitter()

    @.classList.add('btn')
    @.textContent = @name

    @.addEventListener('click', =>
      @emitter.emit('tab:button:clicked', @.getId())
    )

    return @

  getId: ->
    return @.id.split('tab-button-')[1]

  isActive: ->
    return @active

  setActive: (value) ->
    @active = value
    if @active
      @.classList.add('selected')
    else
      @.classList.remove('selected')

  onDidClick: (callback) ->
    return @emitter.on 'tab:button:clicked', callback

  destroy: ->

module.exports = document.registerElement('tab-button', {
  prototype: TabButton.prototype
})
