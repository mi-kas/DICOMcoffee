###
@desc
@author Michael Kaserer e1025263@student.tuwien.ac.at
###
class @Toolbox
  constructor: ->
    @tools =
      'Window level': new WindowLevel()
      'Zoom': new Zoom()
      'Move': new Move()
      'Roi': new Roi()
    @currentTool = @tools['Window level']

  # Sets the currentTool by its name.
  # @param {String} funcName
  setCurrentTool: (funcName) ->
    @currentTool = @tools[funcName]