###
@desc Builds a tree structure from a array of Dicom files.
@author Michael Kaserer e1025263@student.tuwien.ac.at
###
class @Tree
  constructor: ->
    # @dcmTree = {}
    @html = []

  # Takes an array of Dicom files as input and computes a tree structure with html unordered lists.
  # @param {Array} list
  render: (list) ->
    # @dcmTree = {}
    @html = []
    # Render the tree with the jqueryTree plugin
    $('#fileTree').empty().html(@dcmRender(buildFromDcmList(list))).tree(
      expanded: 'li:first'
    )

  # Builds a JSON tree structure form a array of Dicom files. 1st level --> PatientsName. 2nd level --> SeriesDescription.
  # @param {Array} files Array with Dicom files
  # @returns JSON tree structure
  buildFromDcmList = (files) ->
    dcmTree = {}
    for file, i in files
      level1 = if file.PatientsName then file.PatientsName else 'undefined'
      level2 = if file.SeriesDescription then file.SeriesDescription else 'undefined'
      if not dcmTree[level1]
        dcmTree[level1] = {}
        dcmTree[level1][level2] = []
        dcmTree[level1][level2].push(i)
      else
        if not dcmTree[level1][level2]
          dcmTree[level1][level2] = []
          dcmTree[level1][level2].push(i)
        else
          dcmTree[level1][level2].push(i)
    dcmTree

  # Build a HTML unordered list from a JSON tree structure.
  # @param {JSON} tree
  # @returns HTML ul
  dcmRender: (tree) ->
    if tree
      for object of tree
        if $.isArray(tree[object]) # series have an array - patients a object
          @html.push("<li><a href='#' data-type='file' data-index='#{tree[object]}'>", object, '</a></li>')
        else
          @html.push('<li><a href="#" data-type="folder">', object, '</a>')
          @html.push('<ul>')
          @dcmRender(tree[object])
          @html.push('</ul>')
      @html.join('')