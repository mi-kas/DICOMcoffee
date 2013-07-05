###
@desc CanvasPainter is used to draw a Dicom file on a HTML-canvas element. Scale, windowing and pan can be altered.
@param {String} canvasId Id of the HTML-canvas element for the painter.
@author Michael Kaserer e1025263@student.tuwien.ac.at
###
class @CanvasPainter

  constructor: (canvasId) ->
    @canvas = document.getElementById canvasId
    @context = @canvas.getContext '2d'
    @currentFile
    @series
    @ww
    @wc
    @scale
    @pan

  # Sets a Dicom series to the painter and sorts it by InstanceNumber.
  # @param {Array} serie An array with Dicom files of a series.
  setSeries: (@series) ->
    @series.sort (a, b) ->
      a.InstanceNumber - b.InstanceNumber

    @currentFile = @series[0]
    @wc = @series[0].WindowCenter
    @ww = @series[0].WindowWidth
    @scale = calculateRatio(@currentFile.Columns, @currentFile.Rows, @canvas.width, @canvas.height)
    @pan = [0, 0]


  # @param {Number} wc   Window center
  # @param {Number} ww   Window with
  setWindowing: (@wc, @ww) ->


  # @returns {Array} Window center and window with
  getWindowing: -> [@wc, @ww]


  # @param {Number} scale
  setScale: (@scale) ->


  # @returns {Number} scale
  getScale: -> @scale


  # @param {Number} panX
  # @param {Number} panY
  setPan: (panX, panY) -> @pan = [panX, panY]


  # @returns {Array}
  getPan: -> @pan


  # Resets window with & center, scale and pan to the original values and draws the Dicom image.
  reset: ->
    @wc = @series[0].WindowCenter
    @ww = @series[0].WindowWidth
    @scale = calculateRatio(@currentFile.Columns, @currentFile.Rows, @canvas.width, @canvas.height)
    @pan = [0, 0]
    @drawImg()


  # Draws the current Dicom file to the canvas element. Uses the windowing function to map the Dicom pixel values the 8bit canvas values.
  drawImg: ->
    width = @canvas.width
    height = @canvas.height
    tempCanvas = document.createElement 'canvas'
    tempCanvas.height = @currentFile.Rows
    tempCanvas.width = @currentFile.Columns
    tempContext = tempCanvas.getContext '2d'
    @context.fillStyle = '#000'
    @context.fillRect(0, 0, width, height)
#    tempContext.fillStyle = '#000'
#    tempContext.fillRect(0, 0, width, height)
    imgData = tempContext.createImageData(@currentFile.Columns, @currentFile.Rows)
    pixelData = @currentFile.PixelData
    # Windowing function
    lowestVisibleValue = @wc - @ww / 2.0
    highestVisibleValue = @wc + @ww / 2.0

    unless pixelData? and pixelData.length isnt 0
      $('#errorMsg').append("<p class='ui-state-error ui-corner-all'><span class='ui-icon ui-icon-alert'></span>Can't display image: #{@currentFile.PatientsName} #{@currentFile.SeriesDescription}</p>")
      return

    for i in [0...imgData.data.length] by 4
      intensity = pixelData[(i / 4)]
      intensity = intensity * @currentFile.RescaleSlope + @currentFile.RescaleIntercept
      intensity = (intensity - lowestVisibleValue) / (highestVisibleValue - lowestVisibleValue)
      intensity = if intensity < 0.0 then 0.0 else intensity
      intensity = if intensity > 1.0 then 1.0 else intensity
      intensity *= 255.0
      imgData.data[i + 0] = intensity # R
      imgData.data[i + 1] = intensity # G
      imgData.data[i + 2] = intensity # B
      imgData.data[i + 3] = 255 # alpha

    # Scale the image
    targetWidth = @scale * @currentFile.Rows
    targetHeight = @scale * @currentFile.Columns
    xOffset = (width - targetWidth) / 2 + @pan[0]
    yOffset = (height - targetHeight) / 2 + @pan[1]
    # Draw it on the referencing canvas
    tempContext.putImageData(imgData, 0, 0)
    @context.drawImage(tempCanvas, xOffset, yOffset, targetWidth, targetHeight)


  # Private help function to compute the perfect scale for the canvas element with a certain height and width.
  # @param {Number} srcWidth     Width of the Dicom image
  # @param {Number} srcHeight    Height of the Dicom image
  # @param {Number} maxWidth     Width of the canvas element
  # @param {Number} maxHeight    Height of the canvas element
  # @returns {Number} Computed scale
  calculateRatio =  (srcWidth, srcHeight, maxWidth, maxHeight) ->
    ratio = [maxWidth / srcWidth, maxHeight / srcHeight]
    ratio = Math.min(ratio[0], ratio[1])