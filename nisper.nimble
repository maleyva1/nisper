# Package

version       = "0.1.0"
author        = "Mark Leyva"
description   = "GUI frontend for Whisper"
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["nisper"]
# backend       = "cpp"


# Dependencies

requires "nim >= 2.0.0"
requires "uing >= 0.8.0"
requires "whisper >= 0.1.0"

task windows, "Build for Windows":
    exec "nim c --backend:cpp -d:release -d:mingw --opt:speed --out:nisper --app:gui src/nisper.nim"
