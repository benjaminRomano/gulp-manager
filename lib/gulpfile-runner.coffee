GulpfileUtil = require('./gulpfile-util')
{BufferedProcess} = require 'atom'

class GulpfileRunner
  constructor: (@filePath) ->
    @gulpfileUtil = new GulpfileUtil()
    return

  getGulpTasks: (onOutput, onError, onExit) ->
    @runGulp('--tasks-simple', onOutput, onError, onExit)
    return

  runGulp: (task, stdout, stderr, exit) ->
    if @process
      @process.kill()
      @process = null

    args = [task, '--color', '--gulpfile', @filePath]

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
