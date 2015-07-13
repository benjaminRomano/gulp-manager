class ViewElement extends HTMLElement
  prepare: (id, @visible) ->
    @.id = 'view-' + id

    @setActive(@active)
    return @

  setActive: (value) ->
    @active = value
    if value
      this.removeAttribute('hidden')
    else
      this.setAttribute('hidden', true)

  isActive: ->
    return @active


  getId: ->
    return @.id.split('view-')[1]

module.exports = ViewElement
