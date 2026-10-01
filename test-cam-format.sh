#!/usr/bin/env bash
# shellcheck disable=SC2329  # the fake ffmpeg/v4l2-ctl/command below are called by cam_format, not directly
# Checks cover's camera format picker against fake cameras (CI runs this; no camera needed).
set -euo pipefail
eval "$(sed -n '/^biggest()/,/^}$/p' "$(dirname "$0")/cover")"
fails=0
t() {
  local got; got=$(cam_format x)
  if [[ $got == "$2" ]]; then echo "ok    $1"; else echo "FAIL  $1: got [$got], want [$2]"; fails=1; fi
}

ffmpeg() { printf '[in#0] Compressed:       mjpeg :          Motion-JPEG : 640x480 1920x1080\n'; }
t "1080p MJPEG camera" "mjpeg 1920x1080"
ffmpeg() { printf '[in#0] Compressed:       mjpeg :          Motion-JPEG : 640x480 1280x720 2304x1296\n[in#0] Raw       :     yuyv422 :           YUYV 4:2:2 : 640x480\n'; }
t "MJPEG up to 720p, plus a mode over 1080p" "mjpeg 1280x720"
ffmpeg() { printf '[in#0] Raw       :     yuyv422 :           YUYV 4:2:2 : 640x480 1280x720 1920x1080\n'; }
v4l2-ctl() { printf "\t[0]: 'YUYV' (YUYV 4:2:2)\n\t\tSize: Discrete 640x480\n\t\t\tInterval: Discrete 0.033s (30.000 fps)\n\t\tSize: Discrete 1280x720\n\t\t\tInterval: Discrete 0.100s (10.000 fps)\n"; }
t "raw only, only 640x480 does 24+ fps" "yuyv422 640x480"
v4l2-ctl() { printf "\t[0]: 'YUYV' (YUYV 4:2:2)\n\t\tSize: Discrete 640x480\n\t\t\tInterval: Discrete 0.033s (30.000 fps)\n\t\tSize: Discrete 1280x720\n\t\t\tInterval: Discrete 0.040s (25.000 fps)\n"; }
t "raw only, 720p does 25 fps" "yuyv422 1280x720"
command() { if [[ $2 == v4l2-ctl ]]; then return 1; fi; builtin command "$@"; }
t "raw only, no v4l2-ctl installed" "yuyv422 640x480"
ffmpeg() { echo "[in#0] Inappropriate ioctl for device"; }
t "no formats (a metadata node)" ""
exit $fails
