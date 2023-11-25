import utils

from macros import getProjectPath

when defined(mingw):
  const dir = getProjectPath() & "/../whisper.cpp/winbuild"
  {.passl: "-lwhisper -L" & dir.}
else:
  const dir = getProjectPath() & "/../whisper.cpp/build"
  {.passl: "-lwhisper -L" & dir.}

const 
    model = slurp("../../ggml-base.en.bin")
    wheader = "../whisper.cpp/whisper.h"

type
    ContextParams {.importc: "struct whisper_context_params", header: wheader.} = object
        use_gpu: bool
    FullParams {.importc: "struct whisper_full_params", header: wheader.} = object
    Context {.importc: "struct whisper_context", header: wheader.} = object
    SamplingStrategy {.importc: "enum whisper_sampling_strategy", header: wheader.} = enum
        samplingGreedy, samplingBeamSearch

proc contextDefaultParams(): ContextParams {.importc: "whisper_context_default_params", header: wheader.}
proc initFromBufferWithParams(buffer: pointer; bufferSize: csize_t; params: ContextParams): ptr Context {.importc: "whisper_init_from_buffer_with_params", header: wheader.}
proc fullDefaultParams(strategy: SamplingStrategy): FullParams {.importc: "whisper_full_default_params", header: wheader.}

proc full(ctx: ptr Context; params: FullParams; buffer: ptr cfloat; bufferSize: cint): cint {.importc: "whisper_full", header: wheader.}

proc fullNSegments(ctx: ptr Context): cint {.importc: "whisper_full_n_segments", header: wheader.}
proc fullGetSegmentText(ctx: ptr Context; segment: cint): cstring {.importc: "whisper_full_get_segment_text", header: wheader.}

proc free(ctx: ptr Context) {.importc: "whisper_free", header: wheader.}

proc transcribe*(path: string): string = 
    var params = contextDefaultParams()
    var ctx = initFromBufferWithParams(model.cstring, model.len, params)
    if ctx == nil:
        stderr.writeLine("Failed to initialize whisper context")
        quit(3)

    var wparams = fullDefaultParams(samplingGreedy)

    var pcm = newSeq[cfloat]()
    if not readWav(path, pcm):
        stderr.writeLine("Unable to read WAV file")
        free(ctx)
        quit(1)

    let p = 1
    # if whisperfullparallel(ctx, wparams, pcm[0].addr, pcm.len.cint, p.cint) != 0:
    if full(ctx, wparams, pcm[0].addr, pcm.len.cint) != 0:
        stderr.writeLine("Failed to process audio!")
        free(ctx)
        quit(10)

    let n = fullNSegments(ctx)
    result = ""
    for i in countup(0 , n - 1):
        result &= fullGetSegmentText(ctx, i.cint)

    free(ctx)

when isMainModule:
    echo transcribe("test.wav")
