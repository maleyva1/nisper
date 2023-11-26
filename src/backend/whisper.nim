import utils

from macros import getProjectPath

when defined(mingw):
  const dir = getProjectPath() & "/../winbuild"
  {.passl: "-lwhisper -L" & dir.}
else:
  const dir = getProjectPath() & "/../build"
  {.passl: "-lwhisper -L" & dir.}

const wheader = "../whisper.cpp/whisper.h"

type
    ContextParams {.importc: "struct whisper_context_params", header: wheader.} = object
        use_gpu: bool
    FullParams {.importc: "struct whisper_full_params", header: wheader.} = object
        language*: cstring
        detect_language*: bool
    Context {.importc: "struct whisper_context", header: wheader.} = object
    SamplingStrategy {.importc: "enum whisper_sampling_strategy", header: wheader.} = enum
        samplingGreedy, samplingBeamSearch

proc contextDefaultParams(): ContextParams {.importc: "whisper_context_default_params", header: wheader.}
proc initFromFileWithParams(buffer: cstring; params: ContextParams): ptr Context {.importc: "whisper_init_from_file_with_params", header: wheader.}
proc fullDefaultParams(strategy: SamplingStrategy): FullParams {.importc: "whisper_full_default_params", header: wheader.}

proc full(ctx: ptr Context; params: FullParams; buffer: ptr cfloat; bufferSize: cint): cint {.importc: "whisper_full", header: wheader.}

proc fullNSegments(ctx: ptr Context): cint {.importc: "whisper_full_n_segments", header: wheader.}
proc fullGetSegmentText(ctx: ptr Context; segment: cint): cstring {.importc: "whisper_full_get_segment_text", header: wheader.}

proc free(ctx: ptr Context) {.importc: "whisper_free", header: wheader.}

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
    var params = contextDefaultParams()
    var ctx = initFromFileWithParams(options.model.cstring, params)
    if ctx == nil:
        raise newException(CatchableError, "Failed to initialize whisper context")
    defer: free(ctx)

    var wparams = fullDefaultParams(samplingGreedy)

    case options.task:
        of Translate:
            wparams.language = options.language.cstring
            wparams.detect_Language = true
        of Transcribe:
            discard

    var pcm = newSeq[cfloat]()
    if not readWav(options.path, pcm):
        raise newException(CatchableError, "Unable to read WAV file")

    if full(ctx, wparams, pcm[0].addr, pcm.len.cint) != 0:
        raise newException(CatchableError, "Failed to process audio!")

    # TODO: Get timestampts
    let n = fullNSegments(ctx)
    result = ""
    for i in countup(0 , n - 1):
        result &= fullGetSegmentText(ctx, i.cint)

when isMainModule:
    discard
