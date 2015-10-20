{View, $} = require 'space-pen'
{Emitter, CompositeDisposable} = require 'atom'
GulpfileRunner = require '../gulpfile-runner'
Converter = require 'ansi-to-html'
{Toolbar} = require 'atom-bottom-dock'

class OutputView extends View
  @content: ->
    @div class: 'output-view', style: 'display:flex;', =>
      @div class: 'content-container', =>
        @div outlet: 'taskContainer', class: 'task-container', =>
          @div outlet: 'taskListContainer', class: 'task-list-container', =>
            @ul outlet: 'taskList'
          @div outlet: 'customTaskContainer', class: 'custom-task-container', =>
            @span outlet: 'customTaskLabel', class: 'inline-block', 'Custom Task:'
        @div outlet: 'outputContainer', class: 'output-container native-key-bindings', tabindex: -1

  initialize: ->
    @emitter = new Emitter()
    @converter = new Converter fg: $('<span>').css('color')
    @subscriptions = new CompositeDisposable()

    @setupCustomTaskInput()

  setupTaskList: (tasks) ->
    for task in @tasks.sort()
      listItem = $("<li><span class='icon icon-zap'>#{task}</span></li>")

      do (task) => listItem.first().on 'click', =>
        @runTask task

      @taskList.append listItem

  setupCustomTaskInput: ->
    customTaskInput = document.createElement 'atom-text-editor'
    customTaskInput.setAttribute 'mini', ''
    customTaskInput.getModel().setPlaceholderText 'Press Enter to run'

    #Run if user presses enter
    customTaskInput.addEventListener 'keyup', (e) =>
      @runTask customTaskInput.getModel().getText() if e.keyCode == 13

    @customTaskContainer.append customTaskInput

  addGulpTasks: ->
    @tasks = []
    output = "fetching gulp tasks for #{@gulpfile.relativePath}"
    output += " with args: #{@gulpfile.args}" if @gulpfile.args
    @writeOutput output, 'text-info'

    @taskList.empty()

    onTaskOutput = (output) =>
      @tasks = (task for task in output.split '\n' when task.length)

    onTaskExit = (code) =>
      if code is 0
        @setupTaskList @tasks

        @writeOutput "#{@tasks.length} tasks found", "text-info"
      else
        @onExit code

    @gulpfileRunner.getGulpTasks onTaskOutput, @onError, onTaskExit, @gulpfile.args

  setupGulpfileRunner: (gulpfile) ->
    @gulpfileRunner = new GulpfileRunner gulpfile.path

  runTask: (task) ->
    @gulpfileRunner?.runGulp task, @onOutput, @onError, @onExit

  writeOutput: (line, klass) ->
    return unless line?.length

    el = $('<pre>')
    el.append line

    el.addClass klass if klass
    @outputContainer.append el
    @outputContainer.scrollToBottom()

  onOutput: (output) =>
    for line in output.split '\n'
      @writeOutput @converter.toHtml(line)

  onError: (output) =>
    for line in output.split '\n'
      @writeOutput @converter.toHtml(line), 'text-error'

  onExit: (code) =>
    @writeOutput "Exited with code #{code}",
      "#{if code then 'text-error' else 'text-success'}"

  stop: ->
    if @gulpfileRunner
      @gulpfileRunner.destroy()
      @writeOutput('Task Stopped', 'text-info')

  clear: ->
    @outputContainer.empty()

  refresh: (gulpfile) ->
    @destroy()
    @outputContainer.empty()
    @taskList.empty()

    unless gulpfile
      @gulpfile = null
      return

    @gulpfile = gulpfile
    @setupGulpfileRunner @gulpfile
    @addGulpTasks()

  destroy: ->
    @gulpfileRunner?.destroy()
    @gulpfileRunner = null
    @subscriptions?.dispose()

module.exports = OutputView
