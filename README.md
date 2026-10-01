# cover

Record vocal covers on Linux: sing over a song in your headphones while your mic and webcam record, and get back a mixed video of you over the song with the original vocals removed.

Built for death metal covers, but nothing in it is genre-specific except the defaults.

## What it does

- **Hear the original, keep only yours.** You sing along to the full song; the final mix uses an instrumental made with [Demucs](https://github.com/adefossez/demucs) (done once per song, cached).
- **Webcam video**, lined up with the audio, shrunk on the GPU (NVENC) right after the take.
- **Scrolling synced lyrics** from [LRCLIB](https://lrclib.net), with a countdown into each vocal entry. Songs with only plain lyrics can be timed once with a tap-along (`cover-lyrics sync`).
- **Sounds like the record.** Your vocal is matched to the band's own isolated vocal: tone (EQ, two passes), width (stereo doubles + room reverb), level, and the whole mix to the record's loudness. After mixing, it splits its own result with Demucs and corrects the vocal level against the record measured the same way.
- **Distortion** from 0 (clean) to 10 (fully distorted), level-matched so it changes tone, not volume.
- **Remix any take** with new settings without singing it again.
- **Grades** every take against the record (vocal level, width, tone) and saves it.
- **A terminal UI**: run `cover` with no arguments.

## Requirements

Arch Linux packages (names may differ elsewhere):

```
sudo pacman -S ffmpeg pipewire v4l-utils python uv
uv tool install demucs --python 3.11 --with 'torch<2.9' --with 'torchaudio<2.9' --with soundfile
```

- PipeWire for low-latency playback and recording (`pw-play`, `pw-record`)
- A V4L2 webcam at `/dev/video0` (optional; `--no-cam` for audio only). Tested with a Logitech C920.
- An NVIDIA GPU is optional: Demucs and video encoding fall back to the CPU, just slower.

## Install

```
git clone https://github.com/5TN1rcZRS79VAEFuUCRB/cover ~/src/cover
ln -s ~/src/cover/cover ~/src/cover/cover-lyrics ~/src/cover/cover-tui ~/.local/bin/
mkdir -p ~/covers
```

## Use

```
cover                          # the menu app: songs, takes, record, remix, play, delete, time lyrics
cover song.flac                # record a take (distortion 3 by default)
cover song.flac -d 0 --no-cam  # clean, audio only
cover -r ~/covers/NAME-cover-TIME.mp4 -d 6   # remix a take you already made
cover --help                   # everything else
```

Songs are any `.mp3`, `.flac`, `.ogg` or `.wav` you own (bought downloads, CD rips). The TUI lists songs from `~/Music` and `~/Downloads`.

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
