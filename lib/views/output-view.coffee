{View, $} = require('space-pen')
{Emitter, CompositeDisposable} = require('atom')
GulpfileUtil = require('../gulpfile-util')
GulpfileRunner = require('../gulpfile-runner')
Converter = require('ansi-to-html')

class OutputView extends View
  @content: ->
    @div class: 'output-view', style: "display:flex;", =>
      @div outlet: 'taskContainer', class: 'task-container', =>
        @div outlet: 'taskListContainer', class: 'task-list-container', =>
          @ul outlet: 'taskList'
        @div outlet: 'customTaskContainer', class: 'custom-task-container', =>
          @span outlet: 'customTaskLabel', class: 'inline-block', 'Custom Task:'
        @div outlet: 'controlContainer', class: 'control-container', =>
          @button outlet: 'backButton', class: 'btn', click: 'onBackClicked', 'Back'
          @button outlet: 'stopButton', class: 'btn', click: 'onStopClicked', 'Stop'
      @div outlet: 'outputContainer', class: 'output-container'

  initialize: ->
    @emitter = new Emitter()
    @gulpfileUtil = new GulpfileUtil()
    @converter = new Converter()
    @subscriptions = new CompositeDisposable()

    @setupCustomTaskInput()

  setupTaskList: (tasks) ->
    for task in @tasks.sort()
      listItem = $("<li><span class='icon icon-zap'>#{task}</span></li>")

      do (task) => listItem.first().on('click', =>
        @runTask(task)
      )

      @taskList.append(listItem)

  setupCustomTaskInput: ->
    customTaskInput = document.createElement('atom-text-editor')
    customTaskInput.setAttribute('mini', '')
    customTaskInput.getModel().setPlaceholderText('Press Enter to run')

    customTaskInput.addEventListener('keyup', (e) =>
      #Run if user presses enter
      @runTask(customTaskInput.getModel().getText()) if e.keyCode == 13
    )

    @customTaskContainer.append(customTaskInput)

  addGulpTasks: ->
    @tasks = []
    output = "fetching gulp tasks for #{@filePath}"
    output += " with args: #{@gulpfile.args}" if @gulpfile.args
    @writeOutput(output, 'text-info')

    @taskList.empty()

    onTaskOutput = (output) =>
      for task in output.split('\n') when task.length
        @tasks.push(task)

    onTaskExit = (code) =>
      if code is 0

        @setupTaskList(@tasks)

        @writeOutput("#{@tasks.length} tasks found", "text-info")
      else
        @onExit(code)

    @gulpfileRunner.getGulpTasks(onTaskOutput.bind(@),
      @onError.bind(@), onTaskExit.bind(@), @gulpfile.args)

  onStopClicked: ->
    if @gulpfileRunner
      @gulpfileRunner.destroy()
      @writeOutput('Task Stopped', 'text-info')

  onBackClicked: ->
    @emitter.emit('backButton:clicked')

  onDidClickBack: (callback) ->
    return @emitter.on('backButton:clicked', callback)

  setupGulpfileRunner: (@gulpfile) ->
    @filePath = @gulpfileUtil.createFilePath(@gulpfile.dir, @gulpfile.fileName)
    @gulpfileRunner = new GulpfileRunner(@filePath)

  runTask: (task) ->
    @gulpfileRunner.runGulp(task,
      @onOutput.bind(@), @onError.bind(@), @onExit.bind(@))

  writeOutput: (line, klass) ->
    if line and line.length

      el = $('<pre>')
      el.append(line)
      if klass
        el.addClass(klass)
      @outputContainer.append(el)
      @outputContainer.scrollToBottom()

  onOutput: (output) ->
    for line in output.split('\n')
      @writeOutput(@converter.toHtml(line))

  onError: (output) ->
    for line in output.split('\n')
      @writeOutput(@converter.toHtml(line), 'text-error')

  onExit: (code) ->
    @writeOutput("Exited with code #{code}",
      "#{if code then 'text-error' else 'text-success'}")

  refresh: (gulpfile) ->
    @destroy()
    @outputContainer.empty()
    @taskList.empty()

    if gulpfile
      @setupGulpfileRunner(gulpfile)

    if @gulpfileRunner
      @addGulpTasks()

  destroy: ->
    @gulpfileRunner.destroy() if @gulpfileRunner
    @subscriptions.dispose() if @subscriptions

module.exports = OutputView
