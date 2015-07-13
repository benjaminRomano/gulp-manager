fs = require 'fs'
path = require 'path'

class GulpfileUtil

  createFilePath: (dir, fileName) ->
    isWin = /^win/.test(process.platform)
    if isWin
      return dir + '\\' + fileName
    else
      return dir + '/' + fileName

  getGulpfiles: ->
    projPaths = atom.project.getPaths()
    gulpfiles = []

    for projPath in projPaths
      gulpfiles = gulpfiles.concat(@getGulpfilesHelper(projPath))

    return gulpfiles

  getGulpfilesHelper: (cwd, gulpfiles) ->
    dirs = []
    if not gulpfiles
      gulpfiles = []

    gfregx = /^gulpfile\.[js|coffee]/i
    for entry in fs.readdirSync(cwd) when entry.indexOf('.') isnt 0
      if gfregx.test(entry)
        gulpfiles.push({
          dir: cwd,
          fileName: entry
        })

      else if entry.indexOf('node_modules') is -1
        abs = path.join(cwd, entry)
        if fs.statSync(abs).isDirectory()
          dirs.push abs

    for dir in dirs
      if foundGulpfiles = @getGulpfilesHelper(dir)
        gulpfiles = gulpfiles.concat(foundGulpfiles)

    return gulpfiles

module.exports = GulpfileUtil
