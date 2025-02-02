#!/usr/bin/env bash
set -euo pipefail
#//////////////////////////////////////////////////////////////
#//   ____                                                   //
#//  | __ )  ___ _ __  ___ _   _ _ __   ___ _ __ _ __   ___  //
#//  |  _ \ / _ \ '_ \/ __| | | | '_ \ / _ \ '__| '_ \ / __| //
#//  | |_) |  __/ | | \__ \ |_| | |_) |  __/ |  | |_) | (__  //
#//  |____/ \___|_| |_|___/\__,_| .__/ \___|_|  | .__/ \___| //
#//                             |_|             |_|          //
#//////////////////////////////////////////////////////////////
#//                                                          //
#//  Script, 2021                                            //
#//  Created: 31, July, 2021                                 //
#//  Modified: 31, July, 2021                                //
#//  file: -                                                 //
#//  -                                                       //
#//  Source: https://unix.stackexchange.com/a/334148/359833                                               //
#//  OS: ALL                                                 //
#//  CPU: ALL                                                //
#//                                                          //
#//////////////////////////////////////////////////////////////

readonly VERSION="1.2.0"

DS_version() {
    echo "screen-capture: $VERSION"
}

# Values can by override
ENCODING_LIB=${ENCODING_LIB:-libx264}
RESOLUTION=${RESOLUTION:-1920x1080}
FRAMERATE=${FRAMERATE:-60}
SCREEN=${SCREEN:-:0}
QUALITY=${QUALITY:-0}
PRESET=${PRESET:-fast}
OUTPUT=${OUTPUT:-screen_capture.mkv}
PIXEL=${PIXEL:-yuv444p}
PROFILE=${PROFILE:-high444}
LEVEL=${LEVEL:-5.1}

PROFILE=${PROFILE:-high444}

FFMPEG_ARG=${FFMPEG_ARG:-}

TESTS=${TESTS:-none}
COPY=${COPY:-true}

DS_check() {
    type ffmpeg >/dev/null 2>&1 || { echo "ffmpeg could not be found!" >&2; exit 1; }
}

DS_help() {
    echo "Usage: ${0##*/} --output <output file>"
    echo "Others option:
    --lib libx264, libx265, huffyuv, h263p, hevc_nvenc, nvenc_h264, hevc_qsv, h264_qsv, h264_amf
    --resolution 1920x1080
    --framerate 60, 30...
    --quality 0 (lossless) to X
    --screen :0
    --preset ultrafast, fast, medium, slow... (fast, medium, slow on nvenc)
    --pixel yuv444p, yuv420p...
    --profile baseline, main, high, high10, high422, high444 (main, main10, high444p... for nvenc)
    --level auto, 0, 1, 1.0 ... 5.0, 5.1
    --ffmpeg_arg=\"<arg 1> <arg2> ...\" additional ffmpeg arguments
    -h or --help
    -v or --version"
    exit 0
}


DS_main() {
    if [[ -z $* ]]; then
        DS_version
        DS_help
        exit 0
    fi
  
    while [[ $# -gt 0 ]] && { [[ "$1" == "--"* ]] || [[ "$1" == "-"* ]]; } ;
    do
        opt="$1";
        shift; 
        case "$opt" in
            "--lib" )
            ENCODING_LIB="$1"; shift;;
            "--ffmpeg_arg="* )     # alternate format: --first=date
            FFMPEG_ARG="${opt#*=}";;
            "--screen" )
            SCREEN="$1"; shift;;
            "--framerate" )
            FRAMERATE="$1"; shift;;
            "--quality" )
            QUALITY="$1"; shift;;
            "--preset" )
            PRESET="$1"; shift;;
            "--pixel" )
            PIXEL="$1"; shift;;
            "--resolution" )
            RESOLUTION="$1"; shift;;
            "--profile" )
            PROFILE="$1"; shift;;
            "--level" )
            LEVEL="$1"; shift;;
            "--output" )
            OUTPUT="$1"; shift;;
            "--help" | "-h" )
            DS_help;;
            "--version" | "-v" )
            DS_version;;
            "--copy" )
            COPY=true;;
            *) echo >&2 "Invalid option: $*"; exit 1;;
    esac
    done
    DS_check
    DS_exec
}

DS_exec() {
    if [[ -z "$FFMPEG_ARG" ]]; then
        ffmpeg -f x11grab -video_size "$RESOLUTION" -framerate "$FRAMERATE" -i "$SCREEN" \
        -vcodec "$ENCODING_LIB" -preset "$PRESET" -qp "$QUALITY" -pix_fmt "$PIXEL" \
        -profile:v "$PROFILE" -level "$LEVEL" \
        "$OUTPUT"
    else
        ffmpeg "$FFMPEG_ARG" -f x11grab -video_size "$RESOLUTION" -framerate "$FRAMERATE" -i "$SCREEN" \
        -vcodec "$ENCODING_LIB" -preset "$PRESET" -qp "$QUALITY" -pix_fmt "$PIXEL" \
        -profile:v "$PROFILE" -level "$LEVEL" \
        "$OUTPUT"
    fi
    
}

if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
  DS_main "$@"
fi
