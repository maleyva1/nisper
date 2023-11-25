import nigui
import nigui/msgbox

import backend/whisper

proc main() =
  app.init
  var 
    window = newWindow("Nisper")
    processing: Thread[void]
  window.width = 600.scaleToDpi
  window.height = 400.scaleToDpi

  var 
    vcontainer = newLayoutContainer(Layout_Vertical)
    hcontainer = newLayoutContainer(Layout_Horizontal)
    h2container = newLayoutContainer(Layout_Vertical)
  vcontainer.padding = 10
  window.add(vcontainer)

  var textArea = newTextArea()
  textArea.editable = false

  var textLabel = newLabel("Transcription")

  h2container.add(textLabel)
  h2container.add(textArea)

  vcontainer.add(h2container)
  vcontainer.add(hcontainer)

  var 
    transcribeBtn = newButton("Transcribe")
    fileLoadBtn = newButton("Load audio")
  hcontainer.add(fileLoadBtn)
  hcontainer.add(transcribeBtn)

  var selected: string

  fileLoadBtn.onClick = proc(event: ClickEvent) =
    var dialog = newOpenFileDialog()
    dialog.title = "Select audio"
    dialog.multiple = false
    dialog.run()
    if dialog.files.len > 0:
      selected = dialog.files[0]

  transcribeBtn.onClick = proc(event: ClickEvent) =
    let result = transcribe(selected)
    textArea.text = ""
    textArea.addText(result)

  window.show()
  app.run()


when isMainModule:
  main()
