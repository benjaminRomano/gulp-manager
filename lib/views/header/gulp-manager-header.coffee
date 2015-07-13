HeaderButton = require('./header-button')
{Emitter, CompositeDisposable} = require('atom')

class GulpManagerHeader extends HTMLElement

  prepare: (buttonInfo) ->

    @buttons = []
    @subscriptions = new CompositeDisposable()

    for info in buttonInfo
      button = new HeaderButton().prepare(info.name, info.id, info.active)
      @buttons.push(button)
      @.classList.add('inline-block')
      @.classList.add('btn-group')
      @.classList.add('gulp-manager-header')
      @.appendChild(button)
      @subscriptions.add(button.onDidClick(@setActiveButton.bind(@)))

    if @buttons and @buttons.length
      @setActiveButton(@buttons[0].getId())


    return @

  addButton: (name, id, active) ->
    button = new HeaderButton().prepare(name, id)
    @buttons.push(button)
    @.appendChild(button)

    if active or @buttons.length == 1
      @setActiveButton(id)

    return button

  removeButton: (id) ->
    for button in @buttons
      if button.getId() == String(id)
        @.removeChild(button)

    @buttons = @buttons.filter((b) -> b.getId() != id)

    if @buttons and @buttons.length
      @setActiveButton(@buttons[0].getId())

  setActiveButton: (id) ->
    for button in @buttons
      if button.getId() == String(id)
        button.setActive(true)
      else
        button.setActive(false)


  destroy: ->
    @subscriptions.dispose()


module.exports = document.registerElement('gulp-manager-header', {
  prototype: GulpManagerHeader.prototype,
  extends: 'div'
})
