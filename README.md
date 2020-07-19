# get-m3u8-sh
A lite shell script(get.sh) to download m3u8 video. More and more websites take measures to limit network flow during you are downloading viedeos via external tools.
So many tools(include ffpmeg) or scripts will not work well. get-m3u8-sh choose a simple but reliable ways to face various m3u8 resource. In other words, get-m3u8-sh
may take more time, but it can make sure to download completed files finally as long as it support such m3u8 files.

# Usage
You can get all usage via `-h` parameter, the script support following parameters
```
    -m, --m3u8=M3U8              url of target M3U8
    -t, --task, --thread=N       the number of parallel download task (default: 3)
    -o, --out, --output=NAME     name of output file (default: out.mp4)

    -h, --help                   show usage then exit
    -v, --version                show version then exit
```

# Example

```
  ./get.sh -m "https://www.example.com/m3u8/index.m3u8" -t 3
```

# Distribution

Every website has their own m3u8 files with different formats and encrypt methods, it may make get-m3u8-sh can't download m3u8 video successfully. You can create a 
PR and upload the m3u8 files you meet to <i>m3u8</i> directory and improve the script. Please rename your m3u8 file in numerical order before committing！
