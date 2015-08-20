fs = require 'fs'
path = require 'path'

class FileFinderUtil

  @getRelativePath: (filePath) ->
    [projectPath, relativePath] = atom.project.relativizePath filePath

    if atom.project.getPaths().length == 1
      return relativePath

    dirs = projectPath.split path.sep
    path.join dirs[dirs.length - 1], relativePath


  findFiles: (regex) ->
    projPaths = atom.project.getPaths()

    foundFiles = projPaths.filter((p) -> p != 'atom://config' and p!= 'atom://.atom/config')
      .map((path) -> findFilesHelper path, regex)
      .reduce((results, files) ->
        results.concat files
      , [])

  findFilesHelper = (cwd, regex) ->
    dirs = []
    files = []

    for entry in fs.readdirSync(cwd) when entry.indexOf('.') isnt 0
      if regex.test entry
        files.push(path.join(cwd,entry))

      else if entry.indexOf('node_modules') is -1
        abs = path.join cwd, entry
        if fs.statSync(abs).isDirectory()
          dirs.push abs

    for dir in dirs
      if foundFiles = findFilesHelper dir, regex
        files = files.concat foundFiles

    files

module.exports = FileFinderUtil
