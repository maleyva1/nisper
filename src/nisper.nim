import std/strutils
import std/options

import uing

import backend/whisper

type
  ThreadArgs = tuple
    com: ptr Channel[string]
    file: Option[string]
    model: Option[string]

proc process(args: ThreadArgs) =
  discard
  # var transcription: string
  # if args.model.isEmptyOrWhitespace():
    # transcription = transcribe(args.file)
  # else:
    # transcription = transcribe(args.file, args.model)
  # args.com[].send(transcription)

proc main() =
  init()
  var 
    window: Window
    processing: Thread[ThreadArgs]
    com: Channel[string]
    selected: Option[string]
    model: Option[string]
  com.open()

  window = newWindow("Nisper", 600, 480, true)
  window.margined = true

  var 
    container = newHorizontalBox(true)
    leftContainer = newVerticalBox(true)
    rightContainer = newVerticalBox(true)
    seperator = newVerticalSeparator()
  window.child = container

  container.add(leftContainer)
  container.add(seperator)
  container.add(rightContainer)

  var
    optionsGroup = newGroup("Options", true)
    optionsContainer = newVerticalBox(true)
    modelSelected = newEntry("Default")
    modelSelection = newCombobox(["A", "B"])
    modelUpload = newButton("Use local custom model")
    modelDownload = newButton("Download more models")
    modelContainer = newVerticalBox(true)
    outputSaveFormatLabel = newLabel("Output format")
    outputSaveFormat = newRadioButtons(["txt", "srt", "vtt", "csv"])
    outputSaveFormatContainer = newVerticalBox(true)
    taskLabel = newLabel("Task")
    taskButtons = newRadioButtons(["Transcribe", "Translate"])
    taskContainer = newVerticalBox(true)
    radioContainer = newHorizontalBox(true)
  
  modelSelected.readOnly = true
  modelContainer.add(modelSelected)
  modelContainer.add(modelSelection)
  modelContainer.add(modelDownload)
  modelContainer.add(modelUpload)

  leftContainer.add(optionsGroup)
  optionsGroup.child = optionsContainer

  optionsContainer.add(modelContainer)

  outputSaveFormatContainer.add(outputSaveFormatLabel)
  outputSaveFormatContainer.add(outputSaveFormat)

  taskContainer.add(taskLabel)
  taskContainer.add(taskButtons)

  radioContainer.add(outputSaveFormatContainer)
  radioContainer.add(taskContainer)

  optionsContainer.add(radioContainer)

  # Actions
  var 
    taskForm = newForm(true)
    taskResults = newMultilineEntry()
    mediaLoadBtn = newButton("Load Media")
    transcribeBtn = newButton("Run")
    saveBtn = newButton("Save Result")
  rightContainer.add(taskForm)
  taskForm.add("Results", taskResults, true)
  taskForm.add("a", mediaLoadBtn)
  taskForm.add("b", transcribeBtn)
  taskForm.add("c", saveBtn)

  proc recvResult(): bool =
    let read = com.tryRecv()
    if read.dataAvailable:
      taskResults.text = read.msg
      return false
    else:
      return true

  transcribeBtn.onClick = proc(sender: Button) =
    taskResults.text = ""
    if selected.isSome():
      window.error("Error", "No file selected!")
    else:
      let temp = (addr com, selected, model)
      createThread(processing, process, temp)
      timer(50, recvResult)
      selected = none(string)

  show(window)
  mainLoop()

when isMainModule:
  main()
