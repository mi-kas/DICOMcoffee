###
@desc Controller of the Dicom Viewer. Handles all user event from the GUI.
@author Michael Kaserer e1025263@student.tuwien.ac.at
###
class @DcmViewer
  # Initialization. Calls matrixHandler function.
  constructor: (a)->
    @scrollIndex = 0
    @numFiles = 0
    @eventsEnabled = false
    @painters = []
    @parsedFileList = []
    # Initialization. Calls matrixHandler function.
    @toolbox = new Toolbox()
    @matrixHandler($('#matrixView').val())
    @tree = new Tree()
    @fileParser = new FileParser()


  # @param {String} toolName Sets the current tool of the toolbox by using the name of it. See Toolbox.js.
  setCurrentTool: (tool_name) ->
    @toolbox.setCurrentTool(tool_name)


  # Sets the files to all painter of the viewer and enables the slider.
  # @param {Array} files Array of Dicom files
  showSeries: (files) ->
    @numFiles = files.length
    for painter, i in @painters
      painter.setSeries(files)
      # setting files shifted to the painters
      index = (@scrollIndex + i) % @numFiles
      painter.currentFile = painter.series[index]
      @painters[i] = painter
      painter.drawImg()
      # update info
      updateInfo(painter, getSelector(painter))
    @eventsEnabled = true
    # Enable the slider
    if @numFiles > 1
      $('#slider').slider 'option',
        max: @numFiles - 1
        disabled: false
        slide: (e, ui) =>
          @scrollOne(ui.value)


  # Handles the change-event of the input element. Updates the progress bar, parses the files and renders it on a tree. Only Dicom files are processed.
  # @param {Event} e Change-event of the input element.
  inputHandler: (e) ->
    # detect 'cancel' or no files in fileList
    if e.target.files.length is 0 then return
    # for the progressbar
    progress(e.target.files.length)
    fileList = e.target.files
    dcmList = (file for file in fileList when file.type is 'application/dicom')
    @fileParser.parseFiles dcmList, (e) =>
      @parsedFileList = e
      @tree.render @parsedFileList


  # Handles click, mousemove, mousedown, mouseup, mouseout, mousewhell and scroll events of the viewer and passes the event to the current tool of the toolbox.
  # @param {Event} e
  eventHandler: (e) ->
    if @eventsEnabled
      # Firefox doesn't have the offsetX/offsetY properties -> own calculation
      e.x = e.offsetX ? e.pageX - $(e.target).offset().left
      e.y = e.offsetY ? e.pageY - $(e.target).offset().top

      $('.xPos').text "X: #{e.x.toFixed(0)}"
      $('.yPos').text "Y: #{e.y.toFixed(0)}"

      # pass the event to the currentTool of the toolbox
      eventFunc = @toolbox.currentTool[e.type]
      if eventFunc
        eventFunc e.x, e.y, @painters, e.target


  # Scroll handler of the viewer. Updates also the slider.
  # @param {Event} evt
  scrollHandler: (evt) ->
    if @numFiles > 1 and @eventsEnabled
      evt.preventDefault()
      e = evt.originalEvent
      # Firefox uses detail. Chrome and Safari wheelDelta. Normalizing the different units.
      delta = if e.detail then e.detail else -e.wheelDelta / 3.0
      @scrollIndex = if (delta >= 1) then @scrollIndex + 1 else (if (delta <= -1) then @scrollIndex - 1 else @scrollIndex)
      # cyclic scrolling
      @scrollIndex = if (@scrollIndex < 0) then @numFiles - 1 else (if (@scrollIndex > @numFiles - 1) then 0 else @scrollIndex)

      for painter, i in @painters
        index = (@scrollIndex + i) % @numFiles
        painter.currentFile = painter.series[index]
        @painters[i] = painter
        painter.drawImg()
        instanceNumber = painter.currentFile.InstanceNumber ? " - "
        $(getSelector(painter) + ' #instanceNum').text("#{instanceNumber} / #{@numFiles}")

      @scrollIndex


  # Event handler for the slider.
  # @param {Number} num Current position of the slider
  scrollOne: (@scrollIndex) ->
    for painter, i in @painters
      index = (@scrollIndex + i) % @numFiles
      painter.currentFile = painter.series[index]
      @painters[i] = painter
      painter.drawImg()
      instanceNumber = painter.currentFile.InstanceNumber ? " - "
      $(getSelector(painter) + ' #instanceNum').text("#{instanceNumber} / #{@numFiles}")


  # Event handler of the drop-down menu. Calculates the sizes of each canvas according to the useres screen size.
  # @param {Event} e
  matrixHandler: (e) ->
    rows = e.split(',')[0]
    columns = e.split(',')[1]
    width = parseInt($('#viewer').width())
    height = parseInt($('#viewer').height()) - 72 - (rows * 0.5)
    # calculate canvas sizes
    cellWidth = width / columns
    cellHeight = height / rows
    $('#viewerScreen').empty()
    newPainters = []

    for y in [0...rows]
      rowName = "row#{y}"
      $('#viewerScreen').append("<div id='#{rowName}' class='viewerRows'></div>")
      for x in [0...columns]
        $("##{rowName}").append("<div id='column#{x}' class='viewerCells' style='width: #{cellWidth}px; height: #{cellHeight}px;'></div>")
        tmpId = "##{rowName} #column#{x}"
        newId = "canvas#{x}#{y}"
        $(tmpId).append("<canvas id='#{newId}' width='#{cellWidth}px' height='#{cellHeight}px'>Your browser does not support HTML5 canvas</canvas>")
        $(tmpId).append("<div class='studyInfo'></div>")
        $(tmpId).append("<div class='patientInfo'></div>")

        tmpPainter = new CanvasPainter(newId)
        newPainters.push tmpPainter
        if @eventsEnabled
          # setting files shifted to the painters
          index = (@scrollIndex + x + y) % @numFiles
          tmpPainter.setSeries(@painters[0].series)
          tmpPainter.currentFile = tmpPainter.series[index]
          # set old values to the new painters
          tmpPainter.setWindowing(@painters[0].getWindowing()[0], @painters[0].getWindowing()[1])
          tmpPainter.setPan(@painters[0].getPan()[0], @painters[0].getPan()[1])
          tmpPainter.drawImg()
          # update study and patient info
          updateInfo(tmpPainter, getSelector(tmpPainter))

    # Show or hide infos
    if $('#showStudyData').val() is 'true'
      $('.studyInfo').show()
      $('.patientInfo').show()
    else
      $('.studyInfo').hide()
      $('.patientInfo').hide()

    # set new painters
    @painters = newPainters;


  # Resets all painters.
  resetHandler: ->
    if @eventsEnabled
      painter.reset() for painter in @painters


  # Click handler of the tree. Sets the clicked series and calls showSeries.
  # @param {Event} e Click event
  treeClick: (e) ->
    if e.target.nodeName is 'A' and e.target.dataset.type is 'file'
      serie = (@parsedFileList[num] for num in e.target.dataset.index.split(','))
      @showSeries(serie)


  # Builds a HTML-table with the Dicom file's meta data for jQuery Dialog.
  # @returns {HTML} table
  openMetaDialog: ->
    sortObject = (o) ->
      sorted = {}
      key = []
      a = []
      a.push(key) for key of o when o.hasOwnProperty(key)
      a.sort()
      sorted[a[key]] = o[a[key]] for key in [0...a.length]
      sorted

    file = sortObject @painters[0].currentFile
    table = document.createElement 'table'
    head = document.createElement 'thead'
    headRow = document.createElement 'tr'
    headCell1 = document.createElement 'th'
    headText1 = document.createTextNode 'Field Name'
    headCell1.appendChild headText1
    headCell2 = document.createElement 'th'
    headText2 = document.createTextNode 'Content'
    headCell2.appendChild headText2
    headRow.appendChild headCell1
    headRow.appendChild headCell2
    head.appendChild headRow
    table.appendChild head
    body = document.createElement 'tbody'

    for key, value of file
      unless $.isFunction value
        currentRow = document.createElement 'tr'
        cell1 = document.createElement 'td'
        text1 = document.createTextNode key
        cell1.appendChild text1
        cell2 = document.createElement 'td'
        text2 = document.createTextNode value
        cell2.appendChild text2
        currentRow.appendChild cell1
        currentRow.appendChild cell2
        body.appendChild currentRow

    table.appendChild(body)
    table


  # Updates the study and patient info using a given painter and selector.
  # @param {CanvasPainter} _this
  # @param {String} selector
  updateInfo = (painter, selector) ->
    isValidDate = (d) ->
      return false if Object.prototype.toString.call(d) isnt '[object Date]'
      not isNaN d.getTime()

    pName = if painter.currentFile.PatientsName then painter.currentFile.PatientsName else ' - '
    pSex = if painter.currentFile.PatientsSex then " (#{painter.currentFile.PatientsSex}) " else ' '
    pID = if painter.currentFile.PatientID then painter.currentFile.PatientID else ' - '
    x = painter.currentFile.PatientsBirthDate
    instanceNum = if painter.currentFile.InstanceNumber then painter.currentFile.InstanceNumber else " - "
    x = painter.currentFile.SeriesDate
    time = painter.currentFile.SeriesTime
    pDate = ''
    sDate = ''

    if x
      d = new Date("#{x.slice(0, 4)}/#{x.slice(4, 6)}/#{x.slice(6, 8)}")
      if isValidDate(d)
        pDate = d.toLocaleDateString()
        sDate = d.toLocaleDateString()
        pDate += "  #{painter.currentFile.PatientsAge}" if painter.currentFile.PatientsAge
        sDate += "  #{time.slice(0, 2)}:#{time.slice(2, 4)}:#{time.slice(4, 6)}" if time

    sDesc = if painter.currentFile.StudyDescription then painter.currentFile.StudyDescription else ' - '
    ul1 = document.createElement 'ul'
    li11 = document.createElement 'li'
    li11.appendChild(document.createTextNode(pName + pSex + pID))
    li12 = document.createElement 'li'
    li12.appendChild(document.createTextNode(pDate))
    li13 = document.createElement 'li'
    li13.appendChild(document.createTextNode(sDesc))
    li14 = document.createElement 'li'
    li14.appendChild(document.createTextNode(sDate))
    ul1.appendChild li11
    ul1.appendChild li12
    ul1.appendChild li13
    ul1.appendChild li14
    ul2 = document.createElement 'ul'
    li21 = document.createElement 'li'
    li21.appendChild(document.createTextNode("WC: #{painter.wc.toFixed(0)}"))
    li21.setAttribute("class", "wCenter")
    li22 = document.createElement 'li'
    li22.appendChild(document.createTextNode("WW: #{painter.ww.toFixed(0)}"))
    li22.setAttribute("class", "wWidth")
    li23 = document.createElement 'li'
    li23.appendChild(document.createTextNode('X: 0'))
    li23.setAttribute("class", "xPos")
    li24 = document.createElement 'li'
    li24.appendChild(document.createTextNode('Y: 0'))
    li24.setAttribute("class", "yPos")
    li25 = document.createElement 'li'
    li25.appendChild(document.createTextNode("#{instanceNum} / #{painter.series.length}"))
    li25.setAttribute("id", "instanceNum")
    ul2.appendChild li21
    ul2.appendChild li22
    ul2.appendChild li23
    ul2.appendChild li24
    ul2.appendChild li25
    $("#{selector} .studyInfo").empty().append(ul2)
    $("#{selector} .patientInfo").empty().append(ul1)


  # Calculates the id of the div containing the painter.
  # @param {CanvasPainter} painter
  getSelector = (painter) ->
    "#row#{painter.canvas.id.charAt(7)} #column#{painter.canvas.id.charAt(6)}"