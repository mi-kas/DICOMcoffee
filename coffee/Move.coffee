###
@desc Implements the move functionality. Images can be moved by clicking and dragging on it.
@author Michael Kaserer e1025263@student.tuwien.ac.at
@required All tools must implement following functions:
click(x, y, painters)
mousedown(x, y, painters)
mouseup(x, y, painters)
mousemove(x, y, painters)
mouseout(x, y, painters)
###
class @Move
  constructor: ->
    @started = false
    @curX = 0
    @curY = 0

  click: ->

  mousedown: ->
    @started = true

  mouseup: ->
    @started = false

  mousemove: (x, y, painters) ->
    if @started
      deltaX = x - @curX
      deltaY = y - @curY
      newPanX = painters[0].getPan()[0] + deltaX
      newPanY = painters[0].getPan()[1] + deltaY
      for painter in painters
        painter.setPan(newPanX, newPanY)
        painter.drawImg()
    @curX = x
    @curY = y

  mouseout: ->
    @started = false

