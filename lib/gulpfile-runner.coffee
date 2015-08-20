{BufferedProcess} = require 'atom'

class GulpfileRunner
  constructor: (@filePath) ->

  getGulpTasks: (onOutput, onError, onExit, args) ->
    @runGulp '--tasks-simple', onOutput, onError, onExit, args

  runGulp: (task, stdout, stderr, exit, extraArgs) ->
    @process?.kill()
    @process = null

    args = ['--color', '--gulpfile', @filePath]


    for arg in task.split ' '
      args.push(arg)

    if extraArgs
      for arg in extraArgs.split ' '
        args.push arg

    process.env.PATH = switch process.platform
      when 'win32' then process.env.PATH
      else "#{process.env.PATH}:/usr/local/bin"

    @process = new BufferedProcess
      command: 'gulp'
      args: args
      options:
        env: process.env
      stdout: stdout
      stderr: stderr
      exit: exit

  destroy: ->
    @process?.kill()
    @process = null

module.exports = GulpfileRunner
