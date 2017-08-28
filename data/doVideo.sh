ffmpeg -r 7 -f image2 -s 1920x1080 -i out-%06d.tiff -vcodec libx264 -crf 5  -pix_fmt yuv420p test.mp4
