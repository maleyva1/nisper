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
requires "wave >= 1.1.0"

task windows, "Build for Windows":
    exec "nim c --backend:cpp -d:release -d:mingw --opt:speed --out:nisper --app:gui src/nisper.nim"

task nixwhisper, "Build libwhisper":
  exec "cmake -G Ninja -B build -S ./whisper.cpp"
  exec "cmake --build build/ --config Release"

task winwhisper, "Build libwhisper for Windows":
  exec "cmake -G Ninja -B winbuild -S ./whisper.cpp -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc -DCMAKE_CXX_COMPILER=x86_64-w64-mingw32-g++ -DCMAKE_SYSTEM_PROCESSOR=x86_64"
  exec "cmake --build winbuild/ --config Release"
