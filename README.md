# cover

Record vocal covers on Linux: sing over a song in your headphones while your mic and webcam record, and get back a mixed video of you over the song with the original vocals removed.

Built for death metal covers, but nothing in it is genre-specific except the defaults.

## What it does

- **Hear the original, keep only yours.** You sing along to the full song; the final mix uses an instrumental made with [Demucs](https://github.com/adefossez/demucs) (done once per song, cached).
- **Webcam video**, lined up with the audio, shrunk on the GPU (NVENC) right after the take.
- **Scrolling synced lyrics** from [LRCLIB](https://lrclib.net), with a countdown into each vocal entry. Songs with only plain lyrics are timed automatically on the first take, by lining the words up with the record's own vocal (torchaudio's forced aligner, which comes with Demucs; a 1.2 GB model is downloaded the first time). If that doesn't fit well enough they show as a page, and you can time them by hand with a tap-along (`l` in the menu app, or `cover-lyrics sync`).
- **Sounds like the record.** Your vocal is matched to the band's own isolated vocal: tone (EQ, two passes), width (stereo doubles + room reverb), level, and the whole mix to the record's loudness. After mixing, it splits its own result with Demucs and corrects the vocal level against the record measured the same way.
- **Distortion** from 0 (clean) to 10 (fully distorted), level-matched so it changes tone, not volume.
- **Remix any take** with new settings without singing it again.
- **Grades** every take against the record (vocal level, width, tone) and saves it.
- **A terminal UI**: run `cover` with no arguments.

## Requirements

Linux with PipeWire (the default audio system on current Arch, Debian, Ubuntu and Fedora).

| Distro | Packages |
|---|---|
| Arch | `sudo pacman -S ffmpeg pipewire v4l-utils python uv` |
| Debian / Ubuntu | `sudo apt install ffmpeg pipewire-bin v4l-utils python3 pipx && pipx install uv` |
| Fedora | enable [RPM Fusion](https://rpmfusion.org/Configuration), then `sudo dnf swap ffmpeg-free ffmpeg --allowerasing && sudo dnf install pipewire-utils v4l-utils python3 uv` (Fedora's own `ffmpeg-free` has no `libx264`, which `cover` uses to render the final video) |

Then Demucs, which removes the original vocals:

```
# NVIDIA GPU (about 6.5 GB installed):
uv tool install demucs --python 3.11 --with 'torch<2.9' --with 'torchaudio<2.9' --with soundfile
# no NVIDIA GPU (about 0.9 GB installed):
uv tool install demucs --python 3.11 --with 'torch<2.9' --with 'torchaudio<2.9' --with soundfile \
  --index https://download.pytorch.org/whl/cpu --index-strategy unsafe-best-match
```

- **Links instead of files (optional):** [yt-dlp](https://github.com/yt-dlp/yt-dlp) (`sudo pacman -S yt-dlp`, or `pipx install yt-dlp`; distro packages elsewhere are often too old for YouTube).
- **Webcam:** any V4L2 camera; pick it with `--cam /dev/videoN` (or in the menu app), or `--no-cam` for audio only. 1080p MJPEG is used when the camera can do it, otherwise the best format it has. Tested with a Logitech C920.
- **No NVIDIA GPU?** Everything works, just slower: Demucs runs on the CPU (about 75 s per pass for a 4-minute song on a 12-core CPU), so a first take or a remix takes 1.5 to 2 minutes instead of about 15 seconds. Video is encoded on the CPU too.

`cover` checks for the tools it needs when it starts and names anything missing.

## Install

```
git clone https://github.com/5TN1rcZRS79VAEFuUCRB/cover ~/src/cover
mkdir -p ~/.local/bin && ln -s ~/src/cover/cover ~/src/cover/cover-lyrics ~/src/cover/cover-tui ~/.local/bin/
```

(`~/.local/bin` needs to be on your `PATH`; it is by default on most distros.)

## Use

```
cover                          # the menu app: songs, takes, record, remix, play, delete, time lyrics
cover song.flac                # record a take (distortion 3 by default)
cover song.flac -d 0 --no-cam  # clean, audio only
cover 'https://youtu.be/…'     # download the song into ~/Downloads (yt-dlp), then record
cover --get 'https://youtu.be/…'   # just download it (or press d in the menu app)
cover -r ~/covers/NAME-cover-TIME.mp4 -d 6   # remix a take you already made
cover --help                   # everything else
```

Songs are any `.mp3`, `.flac`, `.ogg` or `.wav` you own (bought downloads, CD rips), or a link yt-dlp can download (saved as `.flac` in `~/Downloads`). The menu app lists songs from your Music folder (as set in your desktop's user directories, usually `~/Music`) and `~/Downloads`, and remembers your camera and each song's distortion and gain (in `~/.config/cover/settings`).

Ctrl+C during a take cancels it and deletes it.

## Files

Everything lives in `~/covers`, one set per take:

| File | What |
|---|---|
| `NAME-cover-TIME.mp4` / `.mp3` | finished video / audio |
| `NAME-cover-TIME-remix-NOW.*` | remixes of that take |
| `NAME-grade-…txt` | how close it came to the record |
| `NAME-vox-TIME.wav` | raw vocals (what remixes are made from) |
| `NAME-cam-TIME.mkv` | camera footage |
| `stems/` | instrumentals and isolated vocals, made once per song |
| `lyrics/` | lyrics fetched from LRCLIB (`.lrc` timed, `.txt` plain) |

## Notes

- Death metal vocals are loud: set your interface gain so your loudest growl doesn't clip. The raw take is kept clean; effects only go on the mix.
- **Posting covers:** the backing track is the original recording with the vocals removed, so YouTube's Content ID will likely match the label's recording, not just the song. The rights holder then decides: monetize (video stays up, they get the ad money, the most common outcome), track, or block. A claim isn't a copyright strike, but don't dispute one without permission: that can escalate to a takedown, which is a strike. If a video gets blocked, you need a backing track you're allowed to use. Not legal advice.

## Status

A personal tool, shared as is. Tested end to end on Arch; the install steps are checked on Debian, Ubuntu and Fedora (in containers, so without audio or a camera). Issues and pull requests are welcome, and get answered when I get to them.
