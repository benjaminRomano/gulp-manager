ViewElement = require('./view-element')
GulpfileRunner = require('../../gulpfile-runner')
GulpfileUtil = require('../../gulpfile-util')
Converter = require 'ansi-to-html'
{Emitter, CompositeDisposable} = require('atom')
$ = require('jquery')

class OutputView extends ViewElement
  prepare: (@gulpfile, id, @active) ->
    super(id, @active)
    @type = 'Output'

    @converter = new Converter()
    @emitter = new Emitter()
    @subscriptions = new CompositeDisposable()
    @gulpfileUtil = new GulpfileUtil()

    @filePath = @gulpfileUtil.createFilePath(@gulpfile.dir, @gulpfile.fileName)
    @gulpfileRunner = new GulpfileRunner(@filePath)

    @addTaskContainer()
    @addOutputContainer()

    @subscriptions.add @onTaskClicked(@runTask.bind(@))

    if @active
      @addGulpTasks()

    return @

  onTaskClicked: (callback) ->
    return @emitter.on('task:clicked', callback)

  addOutputContainer: ->
    if @outputContainer
      @.removeChild(@outputContainer)

    @outputContainer = document.createElement('div')
    @outputContainer.className = 'output-container'

    @appendChild(@outputContainer)

  addTaskContainer: ->
    if @taskContainer
      @.removeChild(@taskContainer)

    @taskContainer = document.createElement('div')
    @taskContainer.className = 'task-container'

    @appendChild(@taskContainer)

  setVisibility: (value) ->
    super(value)
    if value
      @classList.add('flex-view')
    else
      @classList.remove('flex-view')

  addGulpTasks: ->
    @tasks = []
    @writeOutput("fetching gulp tasks...", "info")

    $(@taskContainer).empty()

    onTaskOutput = (output) =>
      for task in output.split('\n') when task.length
        @tasks.push(task)

    onTaskExit = (code) =>
      if code is 0
        taskList = @createTaskList(@tasks)

        @taskContainer.appendChild(taskList)

        @writeOutput("#{@tasks.length} tasks found", "info")
      else
        @onExit(code)

    @gulpfileRunner.getGulpTasks(onTaskOutput, @onError, onTaskExit)

  createTaskList: (tasks) ->
    taskList = document.createElement('ul')
    for task in @tasks.sort()
      listItem = document.createElement('li')
      $(listItem).append("<span class='icon icon-zap'>#{task}</span>")

      do (task, @emitter) -> listItem.firstChild.addEventListener('click', ->
        emitter.emit('task:clicked', task)
      )

      taskList.appendChild(listItem)


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

  onOutput: (output) ->
    for line in output.split('\n')
      @writeOutput(@converter.toHtml(line))

  onError: (output) ->
    for line in output.split('\n')
      @writeOutput(@converter.toHtml(line), 'error')

  onExit: (code) ->
    @writeOutput("Exited with code #{code}",
      "#{if code then 'error' else 'success'}")

  refresh: ->
    @destroy()
    @addTaskContainer()
    @addOutputContainer()

    @subscriptions.add @onTaskClicked(@runTask.bind(@))

    if @active
      @addGulpTasks()

  destroy: ->
    @gulpfileRunner.destroy()
    @subscriptions.dispose()


module.exports = document.registerElement('output-view', {
  prototype: OutputView.prototype
})
