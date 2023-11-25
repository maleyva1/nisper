import wave

proc readWav*(path: string; output: var seq[cfloat]): bool = 
    ## 
    var wav = openWaveReadFile(path)
    if (wav.numChannels != 1) and (wav.numChannels != 2):
        stderr.writeLine("Not mono nor stereo")
        stderr.writeLine(wav.numChannels)
        wav.close()
        return false
    let CommonSampleRate = 16000'u32
    if wav.sampleRate != CommonSampleRate:
        stderr.writeLine("Not a common sample rate " & $wav.sampleRate)
        wav.close()
        return false
    if wav.bitsPerSample != 16:
        stderr.writeLine("Not 16 bits per sample ")
        wav.close()
        return false
    var temp = wav.readFrames(2)
    var pcm16 = newSeq[int16]()
    for i in countup(0, temp.len, 2):
        if i in temp.low .. temp.high:
            let 
                upper = temp[i + 1].int16
                lower = temp[i].int16
                t: int16 = (upper shl 8) or lower
            pcm16.add(t)
    case wav.numChannels:
        of numChannelsMono:
            for i in pcm16:
                let t = i.float / 32768.0
                output.add(t.cfloat)
        of numChannelsStereo:
            for i in countup(0, (wav.numFrames - 1).int):
                let ch = pcm16[2*i].cfloat + (pcm16[2*i + 1].cfloat / 65536.0)
                output.add(ch)
        else:
            discard
    wav.close()
    return true
