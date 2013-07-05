###
@desc Implements the length measurement functionality. Lenght is calculated by using the PixelSpacing of the image and Pythagoras' theorem.
@author Michael Kaserer e1025263@student.tuwien.ac.at
@required All tools must implement following functions:
click(x, y, painters)
mousedown(x, y, painters)
mouseup(x, y, painters)
mousemove(x, y, painters)
mouseout(x, y, painters)
###
class @Roi
  constructor: ->
    @started = false
    @startX = 0
    @startY = 0
    @lineColor = '#0f0'

  click: ->

  mousedown: (x, y) ->
    @startX = x
    @startY = y;
    @started = true
    @lineColor = '#0f0'

  mouseup: (x, y, painters, target) ->
    if @started and @startX isnt x and @startY isnt y
      # calculate and show length
      painter = getPainterFromId(target.id, painters)
      context = painter.context
      dist = calculateDist(painter, @startX, @startY, x, y)
      context.font = '.8em Helvetica'
      context.fillStyle = @lineColor
      context.fillText(dist, x + 3, y + 3)
    @started = false

  mousemove: (x, y, painters, target) ->
    if @started
      painter = getPainterFromId(target.id, painters)
      context = painter.context
      getPainterFromId(target.id, painters).drawImg()
      context.beginPath()
      context.moveTo @startX, @startY
      context.lineTo x, y
      context.strokeStyle = @lineColor
      context.stroke()
      context.closePath()

  mouseout: ->
    @started = false

  getPainterFromId = (id, painters) ->
    return painter for painter in painters when painter.canvas.id is id
    return null

  # Calculates the distance between two points considering the PixelSpacing and scale.
  # @param {CanvasPainter} painter
  # @param {Number} startX   X-value of the start point
  # @param {Number} startY   Y-value of the start point
  # @param {Number} endX     X-value of the end point
  # @param {Number} endY     Y-value of the end point
  # @returns {Number} Length betwen the two points
  calculateDist = (painter, startX, startY, endX, endY) ->
    pixelSpacing = if painter.currentFile.PixelSpacing then painter.currentFile.PixelSpacing else [1, 1]
    a = (endX - startX) * pixelSpacing[0] / painter.getScale()
    b = (endY - startY) * pixelSpacing[1] / painter.getScale()
    "#{(Math.sqrt(Math.pow(a, 2) + Math.pow(b, 2)) / 10).toFixed(3)} cm"



