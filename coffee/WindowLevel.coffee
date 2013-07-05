###
@desc Implements the windowing function functionality.
@author Michael Kaserer e1025263@student.tuwien.ac.at
@required All tools must implement following functions:
click(x, y, painters)
mousedown(x, y, painters)
mouseup(x, y, painters)
mousemove(x, y, painters)
mouseout(x, y, painters)
###
class @WindowLevel
  constructor: ->
    @started = false
    @curX = 0
    @curY = 0

  click = ->

  mousedown: ->
    @started = true

  mouseup: ->
    @started = false

  mousemove: (x, y, painters) ->
    if @started
      curWindowing = painters[0].getWindowing()
      # Calculate new values
      deltaX = x - @curX
      deltaY = @curY - y
      newX = curWindowing[0] + deltaX
      newY = curWindowing[1] + deltaY
      for painter in painters
        painter.setWindowing(newX, newY)
        painter.drawImg()
      #Update all infos
      $('.wCenter').text "WC: #{newX.toFixed(0)}"
      $('.wWidth').text "WW: #{newY.toFixed(0)}"
    @curX = x
    @curY = y

  mouseout: ->
    @started = false