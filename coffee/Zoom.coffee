###
@desc Implements the zoom functionality.
@author Michael Kaserer e1025263@student.tuwien.ac.at
@required All tools must implement following functions:
click(x, y, painters)
mousedown(x, y, painters)
mouseup(x, y, painters)
mousemove(x, y, painters)
mouseout(x, y, painters)
###
class @Zoom
  constructor: ->
    @started = false
    @curY = 0

  click: ->

  mousedown: ->
    @started = true

  mouseup: ->
    @started = false

  mousemove: (x, y, painters) ->
    if @started
      deltaY = @curY - y
      newDeltaY = painters[0].getScale() + deltaY / 100.0

      for painter in painters
        painter.setScale newDeltaY
        painter.drawImg()
    @curY = y

  mouseout: ->
    @started = false