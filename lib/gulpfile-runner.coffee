GulpfileUtil = require('./gulpfile-util')
{BufferedProcess} = require 'atom'

class GulpfileRunner
  constructor: (@filePath) ->
    @gulpfileUtil = new GulpfileUtil()
    return

  getGulpTasks: (onOutput, onError, onExit, args) ->
    @runGulp('--tasks-simple', onOutput, onError, onExit, args)
    return

  runGulp: (task, stdout, stderr, exit, extraArgs) ->
    if @process
      @process.kill()
      @process = null

    args = ['--color', '--gulpfile', @filePath]

    for arg in task.split(' ')
      args.push(arg)

    if extraArgs
      for arg in extraArgs.split(' ')
        args.push(arg)

    process.env.PATH = switch process.platform
      when 'win32' then process.env.PATH
      else "#{process.env.PATH}:/usr/local/bin"

    options =
      env: process.env

    @process = new BufferedProcess({
      command: 'gulp'
      args: args
      options: options
      stdout: stdout
      stderr: stderr
      exit: exit
    })


  destroy: ->
    if @process
      @process.kill()
      @process = null
    return

module.exports = GulpfileRunner
