HeaderButton = require('./header-button')
{Emitter, CompositeDisposable} = require('atom')

class GulpManagerHeader extends HTMLElement

  prepare: (buttonInfo) ->

    @buttons = []
    @subscriptions = new CompositeDisposable()
    @emitter = new Emitter()

    @.classList.add('inline-block')
    @.classList.add('btn-group')
    @.classList.add('gulp-manager-header')

    for info in buttonInfo
      @addButton(info.name, info.id, info.active)

    return @

  addButton: (name, id, active) ->
    button = new HeaderButton().prepare(name, id, active)
    @buttons.push(button)

    @subscriptions.add(button.onDidClick((id) =>
      @setActiveButton(id)
      @emitter.emit('header:button:clicked', id)
    ))

    if button.isActive()
      @setActiveButton(id)

    @.appendChild(button)

  removeButton: (id) ->
    for button in @buttons
      if button.getId() == String(id)
        @.removeChild(button)

    @buttons = @buttons.filter((b) -> b.getId() != id)

  setActiveButton: (id) ->
    for button in @buttons
      if button.getId() == String(id)
        button.setActive(true)
      else
        button.setActive(false)

  onHeaderButtonClicked: (callback) ->
    return @emitter.on('header:button:clicked', callback)

  destroy: ->
    @subscriptions.dispose()


module.exports = document.registerElement('gulp-manager-header', {
  prototype: GulpManagerHeader.prototype,
  extends: 'div'
})
