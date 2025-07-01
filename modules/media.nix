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
    sox            # Audio processing and effects
    ffmpegthumbnailer  # Generate video thumbnails
    mediainfo      # Media file information
    nodePackages.svgo  # SVG optimization
  ];
} 