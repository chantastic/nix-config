{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpeg         # Video and audio processing
    gifski         # GIF creation
    libavif        # AVIF image format
    exiftool       # Image metadata
    tesseract      # OCR
    yt-dlp         # YouTube downloader
    openai-whisper # Speech recognition
    whisper-cpp    # Whisper C++ implementation
    sox            # Audio processing and effects
    ffmpegthumbnailer  # Generate video thumbnails
    svgo           # SVG optimization
    mediainfo      # Media file information
  ];
} 