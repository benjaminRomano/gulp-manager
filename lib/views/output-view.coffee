{View, $} = require('space-pen')
{Emitter, CompositeDisposable} = require('atom')
GulpfileUtil = require('../gulpfile-util')
GulpfileRunner = require('../gulpfile-runner')
Converter = require('ansi-to-html')

class OutputView extends View
  @content: ->
    @div =>
      @div outlet: 'taskContainer', =>
        @div outlet: 'taskListContainer', =>
          @ul outlet: 'taskList'
        @div outlet: 'customTaskContainer', =>
          @span outlet: 'customTaskLabel', 'Custom Task:'
        @div outlet: 'controlContainer', =>
          @button outlet: 'backButton', click: 'onBackClicked', 'Back'
          @button outlet: 'stopButton', click: 'onStopClicked', 'Stop'
      @div outlet: 'outputContainer'

  initialize: ->
    @emitter = new Emitter()
    @gulpfileUtil = new GulpfileUtil()
    @converter = new Converter()
    @subscriptions = new CompositeDisposable()

    @addClass('output-view')
    @css('display','flex')

    @setupTaskContainer()
    @setupOutputContainer()

  setupTaskContainer: ->
    @taskContainer.addClass('task-container')
    @taskListContainer.addClass('task-list-container')
    @setupCustomTaskContainer()
    @setupControlContainer()


  setupOutputContainer: ->
    @outputContainer.addClass('output-container')

  setupTaskList: (tasks) ->
    for task in @tasks.sort()
      listItem = $("<li><span class='icon icon-zap'>#{task}</span></li>")

      do (task) => listItem.first().on('click', =>
        @runTask(task)
      )

      @taskList.append(listItem)

  setupControlContainer: ->
    @controlContainer.addClass('control-container')
    @backButton.addClass('btn')
    @stopButton.addClass('btn')


  setupCustomTaskContainer: ->
    @customTaskContainer.addClass('custom-task-container')
    @customTaskLabel.addClass('inline-block')

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
