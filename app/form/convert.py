import ffmpeg
ffmpeg.input('Another S01 E01.mkv').output('out.mkv', vf='format=gray', pix_fmt='yuv420p').run()
