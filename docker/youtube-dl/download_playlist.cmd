docker run --rm --name youtube-dl -v E:/Download/musiques:/download youtube-dl --yes-playlist --extract-audio --audio-format mp3 -o %(title)s.%(ext)s --download-archive archive.txt "%~1"

REM https://www.youtube.com/playlist?list=PLzCxunOM5WFI6f87uu1pmrlVdAymVe-BV
REM --proxy 127.0.0.1:3128