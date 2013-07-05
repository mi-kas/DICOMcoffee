###
@desc Takes the files of the HTML input and parses them with the DicomParser.
@author Michael Kaserer e1025263@student.tuwien.ac.at
###
class @FileParser

  constructor: ->
    @files = []

  # Parses all files and sets default values for not existing values of RescaleSlope, RescaleIntercept, WindowWith and WindowCenter.
  # Sorts the files alphabetically by PatientsName.
  # @param {Array} rawFiles      Files to be parsed
  # @param {function} callback   Function to be called after all files are parsed
  parseFiles: (rawFiles, callback) ->
    @files = []
    goal = rawFiles.length
    setupReader = (rawFile) =>
      reader = new FileReader()
      reader.readAsArrayBuffer(rawFile)
      reader.onload = (e) =>
        if e.target.readyState is FileReader.DONE
          array = new Uint8Array(e.target.result)
          parser = new DicomParser(array)
          file = parser.parse_file()

          # if typeof file is 'undefined'
          unless file?
            goal -= 1
            $('#errorMsg').append("<p class='ui-state-error ui-corner-all'><span class='ui-icon ui-icon-alert'></span>Can't read file: #{rawFile.name}</p>")
            return

#          if typeof file.RescaleSlope is 'undefined' then file.RescaleSlope = 1
#          if typeof file.RescaleIntercept is 'undefined' then file.RescaleIntercept = 0
#          if typeof file.WindowCenter is 'undefined' then file.WindowCenter = 85
#          if typeof file.WindowWidth is 'undefined' then file.WindowWidth = 171
#          if $.isArray file.WindowCenter then file.WindowCenter = file.WindowCenter[0]
#          if $.isArray file.WindowWidth then file.WindowWidth = file.WindowWidth[0]
          unless file.RescaleSlope? then file.RescaleSlope = 1
          unless file.RescaleIntercept? then file.RescaleIntercept = 0
          unless file.WindowCenter? then file.WindowCenter = 85
          unless file.WindowWidth? then file.WindowWidth = 171
          if $.isArray file.WindowCenter then file.WindowCenter = file.WindowCenter[0]
          if $.isArray file.WindowWidth then file.WindowWidth = file.WindowWidth[0]
          @files.push file

      reader.onloadend = (e) =>
        # Fire callback only when all files are parsed
        if @files.length is goal
          @files.sort (a, b) ->
            A = a.PatientsName.toLowerCase()
            B = b.PatientsName.toLowerCase()
            if A < B then return -1
            if A > B then return 1
            0
          callback @files

      reader.onerror = (e) ->
        e = e or window.event
        switch e.target.error.code
          when e.target.error.NOT_FOUND_ERR then $('#errorMsg').append("<p>File not found!</p>")
          when e.target.error.NOT_READABLE_ERR then $('#errorMsg').append("<p>File not readable</p>")
          when e.target.error.ABORT_ERR then $('#errorMsg').append("<p>Read operation was aborted</p>")
          when e.target.error.SECURITY_ERR then $('#errorMsg').append("<p>File is in a locked state</p>")
          when e.target.error.ENCODING_ERR then $('#errorMsg').append("<p>Encoding error</p>")
          else $('#errorMsg').append("<p>Read error</p>")

    # call setupReader for all files
    setupReader(rawFile) for rawFile in rawFiles