import whisper/highlevel

type
    TaskType* = enum
        Transcribe, Translate
    TaskOptions* = object
        path*: string
        model*: string
        case isVideo*: bool
            of true:
                shouldMux*: bool
            else:
                discard
        case task*: TaskType
            of Transcribe:
                discard
            of Translate:
                language*: string

proc whisper*(options: TaskOptions): string = 
    ## Run whisper with `options
    ## 
    let
      opts = newDefaultOptions(options.model)
      w = newWhisper(opts)
    result = w.infer(options.path)

when isMainModule:
    discard
