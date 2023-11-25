import std/strutils

import uing

import backend/whisper

type
  ThreadArgs = tuple
    com: ptr Channel[string]
    file: string

proc process(args: ThreadArgs) =
  let transcription = transcribe(args.file)
  args.com[].send(transcription)

proc main() =
  init()
  var 
    window: Window
    menu = newMenu("File")
    processing: Thread[ThreadArgs]
    com: Channel[string]
    selected: string
  com.open()

  menu.addItem("Load", proc(_: MenuItem; win: Window) =
    let filename = win.openFile()
    if filename.len > 0:
      selected = filename
  )
  menu.addPreferencesItem()
  menu.addQuitItem(
    proc(): bool =
      com.close()
      window.destroy()
      return true
  )

  window = newWindow("Nisper", 600, 480, true)
  window.margined = true

  var 
    vcontainer = newVerticalBox(true)
    hcontainer = newHorizontalBox(true)
    h2container = newVerticalBox(true)
  window.child = vcontainer

  var textArea = newMultilineEntry()
  textArea.readOnly = true

  h2container.add(textArea)

  vcontainer.add(h2container)
  vcontainer.add(hcontainer)

  var 
    transcribeBtn = newButton("Transcribe")
  hcontainer.add(transcribeBtn)

  proc recvResult(): bool =
    let read = com.tryRecv()
    if read.dataAvailable:
      textArea.text = read.msg
      return false
    else:
      return true

  transcribeBtn.onClick = proc(sender: Button) =
    textArea.text = ""
    if selected.isEmptyOrWhitespace():
      window.error("Error", "No file selected!")
    else:
      let temp = (addr com, selected)
      createThread(processing, process, temp)
      timer(50, recvResult)
      selected = ""

  show(window)
  mainLoop()

when isMainModule:
  main()
