#!/bin/bash
set -e
D=6
V() { # name size rate
  echo "testsrc2=size=$2:rate=$3:duration=$D,noise=alls=10:allf=t,format=yuv420p"
}
A="aevalsrc=0.35*sin(2*PI*440*t)*lt(mod(t\,1)\,0.5)|0.35*sin(2*PI*660*t)*lt(mod(t\,1)\,0.5):s=48000:d=$D"
MF="-movflags +frag_keyframe+empty_moov+default_base_moof"
run() { echo ">>> $1"; shift; ffmpeg -hide_banner -loglevel error -y "$@"; ls -la "$OUT" | awk '{print $5, $9}'; }

OUT=h264_1080p30.mp4; run $OUT -f lavfi -i "$(V x 1920x1080 30)" -f lavfi -i "$A" -c:v libx264 -profile:v high -level 4.2 -preset veryfast -b:v 8M -maxrate 8M -bufsize 16M -g 30 -keyint_min 30 -sc_threshold 0 -c:a aac -b:a 128k -shortest $MF $OUT
OUT=h264_1080p60.mp4; run $OUT -f lavfi -i "$(V x 1920x1080 60)" -f lavfi -i "$A" -c:v libx264 -profile:v high -level 4.2 -preset veryfast -b:v 12M -maxrate 12M -bufsize 24M -g 60 -keyint_min 60 -sc_threshold 0 -c:a aac -b:a 128k -shortest $MF $OUT
OUT=h264_2160p30.mp4; run $OUT -f lavfi -i "$(V x 3840x2160 30)" -f lavfi -i "$A" -c:v libx264 -profile:v high -level 5.1 -preset veryfast -b:v 25M -maxrate 25M -bufsize 50M -g 30 -keyint_min 30 -sc_threshold 0 -c:a aac -b:a 128k -shortest $MF $OUT
OUT=vp9_1080p30.webm; run $OUT -f lavfi -i "$(V x 1920x1080 30)" -f lavfi -i "$A" -c:v libvpx-vp9 -b:v 5M -deadline realtime -cpu-used 8 -row-mt 1 -tile-columns 2 -g 30 -c:a libopus -b:a 96k -shortest $OUT
OUT=vp9_2160p30.webm; run $OUT -f lavfi -i "$(V x 3840x2160 30)" -f lavfi -i "$A" -c:v libvpx-vp9 -b:v 16M -deadline realtime -cpu-used 8 -row-mt 1 -tile-columns 3 -g 30 -c:a libopus -b:a 96k -shortest $OUT
OUT=av1_1080p30.mp4; run $OUT -f lavfi -i "$(V x 1920x1080 30)" -f lavfi -i "$A" -c:v libaom-av1 -b:v 4M -usage realtime -cpu-used 8 -row-mt 1 -tiles 2x1 -g 30 -c:a aac -b:a 128k -shortest $MF $OUT
OUT=av1_2160p30.mp4; run $OUT -f lavfi -i "$(V x 3840x2160 30)" -f lavfi -i "$A" -c:v libaom-av1 -b:v 12M -usage realtime -cpu-used 8 -row-mt 1 -tiles 2x2 -g 30 -c:a aac -b:a 128k -shortest $MF $OUT
OUT=audio_aac.m4a; run $OUT -f lavfi -i "$A" -c:a aac -b:a 128k $OUT
OUT=audio_opus.webm; run $OUT -f lavfi -i "$A" -c:a libopus -b:a 96k $OUT
echo ALL_DONE
