'use strict'
# Use ECMAScript 5 strict mode in browsers that support it
$(document).ready ->
  # Drag and drop listeners.
  dropZone = document.getElementById('INPUT')

  handleDrop = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    files = evt.dataTransfer.files
    # FileList object.
    reader = new FileReader

    reader.onload = (event) ->
      document.getElementById('INPUT').value = event.target.result
      return

    reader.readAsText files[0], 'UTF-8'
    return

  handleDragOver = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    evt.dataTransfer.dropEffect = 'copy'
    return

  handleFileSelect = (evt) ->
    files = evt.target.files
    # FileList object.
    reader = new FileReader

    reader.onload = (event) ->
      document.getElementById('INPUT').value = event.target.result
      return

    reader.readAsText files[0], 'UTF-8'
    return

  dropZone.addEventListener 'dragover', handleDragOver, false
  dropZone.addEventListener 'drop', handleDrop, false
  # File select listeners.
  fileSelect = document.getElementById('select')
  fileSelect.addEventListener 'change', handleFileSelect, false
  return