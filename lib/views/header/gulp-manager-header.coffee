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

    @addViewButtons()

    for info in buttonInfo
      @addButton(info.name, info.id, info.active)

    return @

  addViewButtons: ->
    viewButtonContainer = document.createElement('div')
    viewButtonContainer.className = "view-button-container"


    refreshButton = document.createElement('span')
    refreshButton.className = 'refresh-button icon icon-sync'

    @subscriptions.add(refreshButton.addEventListener('click', =>
      @emitter.emit('refresh:button:clicked')
    ))

    deleteButton = document.createElement('span')
    deleteButton.className = 'delete-button icon icon-x'

    @subscriptions.add(deleteButton.addEventListener('click', =>
      @emitter.emit('delete:button:clicked')
    ))

    viewButtonContainer.appendChild(refreshButton)
    viewButtonContainer.appendChild(deleteButton)

    @.appendChild(viewButtonContainer)

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

  onRefreshButtonClicked: (callback) ->
    return @emitter.on('refresh:button:clicked', callback)

  onDeleteButtonClicked: (callback) ->
    return @emitter.on('delete:button:clicked', callback)

  deleteCurrentHeaderButton: ->
    currentView = null
    for button in @buttons
      if button.isActive()
        currentButton = button
    @buttons = @buttons.filter((b) ->
      return b.getId() != button.getId()
    )

    currentButton.destroy()
    @.removeChild(currentButton)

    @setActiveButton(@buttons[0].getId())

    return true


  destroy: ->
    @subscriptions.dispose()


module.exports = document.registerElement('gulp-manager-header', {
  prototype: GulpManagerHeader.prototype,
})
