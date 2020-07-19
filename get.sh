#!/bin/bash

# ------------------------------------------------------------
#  Author     : Weilun Fong
#  E-mail     : wlf@zhishan-iot.tk
#  Description: a lite script which obtains m3u8 video on the 
# Internet and convert to .mp4 format
# ------------------------------------------------------------

# Variable define
help="Try '$0' --help for more information."

version="\
[`basename $0`]
Copyright (C) 2020 Weilun Fong
 A lite script which obtains m3u8 video on the Internet and 
convert to .mp4 format.
Written by Weilun Fong <wlf@zhishan-iot.tk>"

# Environment check
utilities="ffmpeg wget"
for i in $utilities
do
    which $i > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        "$0:error: tool $i is required ..." && exit 1
    fi
done

# Get parameters
while test $# -gt 0 ; do
    case $1 in
        -m | --m3u8)
            m3u8="$2"; shift 2;;
        -t | --task | --thread)
            thread="$2"; shift 2 ;;
        -o | --out |--output)
            out="$2" ; shift 2 ;;
        --help | -h )
            echo "$usage"; return 0 ;;
        --version | -v )
            echo "$version" && return 0 ;;
        -- )
            shift; break ;;
        - )
            break ;;
        -* )
            echo "$0:error: invalid option $1"
            echo "$help" >&2 && return 1 ;;
        * )
            break ;;
    esac
done

if [ -z "$m3u8" ]; then
    echo "$0:error: parameter --m3u8=URL is necessary ..." && exit 1
fi
if [ -z "$thread" ]; then
    thread=3
fi
if [ -z "$out" ]; then
    out=out.mp4
fi

# Init work directory
if [ ! -d ts ]; then
    mkdir ts
else
    rm -rf ts/*
fi
cd ts

f_m3u8="`echo $m3u8 | awk -F '/' '{print $NF}'`"
url="`echo $m3u8 | awk -F "${f_m3u8}" '{print $1}'`"

# Obtain root url
echo " - Root URL: $url"
echo " <m3u8> $f_m3u8 "

# Obtain key
wget -t 3 -q $m3u8
if [ $? -ne 0 ]; then
    echo "$0:error: can't download target m3u8 file ..." && exit 0
fi
EXT_X_KEY="`cat $f_m3u8 | grep -w EXT-X-KEY | awk -F ':' '{printf $NF}'`"
for i in `echo $EXT_X_KEY | awk -F ',' '{for(i=1;i<=NF;i++){print $i}}'`
do
    if [ -n "`echo "$i" | grep -w URI`" ]; then
        f_key="`echo $i | awk -F '=' '{print $NF}' | sed 's/\"//g' `"
    fi
done

if [ -n "$f_key" ]; then
    echo " <key>  $f_key"
    wget -t 3 -q $url/$f_key
    if [ $? -ne 0 ]; then
        echo "$0:error: can't download target key file ..." && exit 0
    fi
fi

# Obtain playlist
echo " - Obtain playlist"
playlist="`cat $f_m3u8 | grep "\.ts$"`"
playlist_a=(${playlist})  
playlist_n="`cat $f_m3u8 | grep "\.ts$" | wc -l`"
n=`expr $playlist_n / $thread`
m=`expr $playlist_n % $thread`

# Download .ts files
# ----------------------------------------
#  @NOTE: more and more websites start to
# limit download threads due to network 
# flow limitation, so most tool(include 
# ffmpeg) or scripts on the Internet may 
# be work well. This script provide the 
# option for users to decide how many 
# download threads/tasks work
# ----------------------------------------
echo " - Download .ts files"
for((i=0;i<$n;i++))
do
    for((j=0;j<$thread;j++))
    do
    {
        index=`expr $i \* $thread + $j`
        echo " > download ${playlist_a[${index}]}"
        wget -q $url/${playlist_a[${index}]}
        if [ $? -ne 0 ]; then
            echo "$0:error: failed to download ${playlist_a[${index}]}" && exit 1
        fi
    }&
    done
    wait
done

if [ $m -ne 0 ]; then
    for((i=1;i<=$m;i++))
    do
    {
        index=`expr $n \* $thread + $i - 1`
        echo " > download ${playlist_a[${index}]}"
        wget -q $url/${playlist_a[${index}]}
    }&
    done
    wait
fi

# Merget & Convert
echo " - Merge and convert to .mp4 format by ffmpeg "
ffmpeg -allowed_extensions ALL -i $f_m3u8 -c copy $out > /dev/null
mv $out ..
cd - > /dev/null && rm -rf ts
