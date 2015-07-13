class ViewElement extends HTMLElement
  prepare: (id, visible) ->
    @.id = 'view-' + id

    @setVisibility(visible)
    return @

  setVisibility: (value) ->
    if value
      this.removeAttribute('hidden')
    else
      this.setAttribute('hidden', true)


  getId: ->
    return @.id.split('view-')[1]

module.exports = ViewElement
