ViewElement = require('./view-element')
GulpfileRunner = require('../../gulpfile-runner')
GulpfileUtil = require('../../gulpfile-util')
Converter = require 'ansi-to-html'
{Emitter, CompositeDisposable} = require('atom')
$ = require('jquery')

class OutputView extends ViewElement
  prepare: (@gulpfile, id, visible) ->
    super(id, visible)
    @name = 'Output'

    @converter = new Converter()
    @emitter = new Emitter()
    @subscriptions = new CompositeDisposable()
    @gulpfileUtil = new GulpfileUtil()

    @filePath = @gulpfileUtil.createFilePath(@gulpfile.dir, @gulpfile.fileName)
    @gulpfileRunner = new GulpfileRunner(@filePath)

    @.classList.add('inset-panel')
    @taskContainer = @createTaskContainer()
    @outputContainer = @createOutputContainer()

    @.appendChild(@taskContainer)
    @.appendChild(@outputContainer)

    @subscriptions.add @onTaskClicked(@runTask.bind(@))

    if visible
      @addGulpTasks()

    return @

  onTaskClicked: (callback) ->
    return @emitter.on('task:clicked', callback)

  createOutputContainer: ->
    outputContainerEl = document.createElement('div')
    outputContainerEl.id = 'output-container-' + @.getId()
    outputContainerEl.className = 'output-container'

    return outputContainerEl

  createTaskContainer: ->
    taskContainerEl = document.createElement('div')
    taskContainerEl.id = 'task-container-' + @.getId()
    taskContainerEl.className = 'task-container'

    return taskContainerEl

  setVisibility: (value) ->
    super(value)
    if value
      @.classList.add('flex-view')
    else
      @.classList.remove('flex-view')

  addGulpTasks: ->
    @tasks = []
    @writeOutput("fetching gulp tasks...")

    if @taskList
      @taskContainer.removeChild(@taskList)

     onTaskOutput = (output) =>
      for task in output.split('\n') when task.length
        @tasks.push(task)

    onTaskExit = (code) =>
      if code is 0
        @taskList = @createTaskList(@tasks)

        @taskContainer.appendChild(@taskList)

        @writeOutput "#{@tasks.length} tasks found"
      else
        @onExit(code)

    @gulpfileRunner.getGulpTasks(onTaskOutput, @onError, onTaskExit)

  createTaskList: (tasks) ->
    taskList = document.createElement('ul')
    taskList.className = 'list-group'
    for task in @tasks.sort()
      taskEl = document.createElement('li')
      taskEl.className = 'list-item'
      taskEl.textContent = task

      taskEl.addEventListener('click', =>
        @emitter.emit('task:clicked', task)
      )

      taskList.appendChild(taskEl)


    return taskList

  runTask: (task) ->
    @gulpfileRunner.runGulp(task,
      @onOutput.bind(@), @onError.bind(@), @onExit.bind(@))

  writeOutput: (line, klass) ->
    if line and line.length

      el = document.createElement('pre')
      $(el).append(line)
      if klass
        el.classList.add(klass)
      el.classList.add('output')
      @outputContainer.appendChild(el)
      $(@outputContainer).scrollTop(@outputContainer.scrollHeight)
    return

  onOutput: (output) ->
    for line in output.split('\n')
      @writeOutput(@converter.toHtml(line))
    return

  onError: (output) ->
    for line in output.split('\n')
      @writeOutput(@converter.toHtml(line), 'error')
    return

  onExit: (code) ->
    @writeOutput("Exited with code #{code}", "#{if code then 'error' else ''}")
    @process = null
    return


  destroy: ->
    @subscriptions.dispose()


module.exports = document.registerElement('output-view', {
  prototype: OutputView.prototype
})
