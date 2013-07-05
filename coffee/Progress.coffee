###
@desc This JavaScript worker takes the number of files and perform
progress with a certain delay for the progressbar.
It posts the current percentual value of the progressbar back to the HTML file.
@author Michael Kaserer e1025263@student.tuwien.ac.at
###
current = 0
max = 100

@.addEventListener 'message',
  (e) =>
    max = e.data
    @postMessage "Max: #{max}"
  , false

progress = setInterval =>
    @postMessage "Max: #{max}"
    if current >= max then clearInterval(progress)
    else
      current += 5
      @postMessage ((current / max) * 100).toFixed(0)
  ,20
