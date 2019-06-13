#!/bin/bash
# Create output directory 'dash' (if not exists)
mkdir -p dash

# Define sizes for video variants.
# Format: width:height:bitrate
#SIZES=("240:135:1k" "480:270:2k" "640:360:100k" "960:540:500k" "1280:720:1000k" "1920:1080:3500k")
SIZES=("240:135:1k")

counter=0

# Loop over all defined SIZES to generate a video variant
for i in "${SIZES[@]}"
do
    # Extract width, height and bitrate from string
    width=$(echo $i | cut -f1 -d:)
    height=$(echo $i | cut -f2 -d:)
    bitrate=$(echo $i | cut -f3 -d:)

    # Generate filename
    filename="dash/${width}x${height}-30-${bitrate}.webm"

    # Actual ffmpeg command to generate the dash variant
    ffmpeg \
        -hide_banner \
        -i original.mp4 \
        -c:v libvpx-vp9 \
        -row-mt 1 \
        -keyint_min 60 \
        -g 60 \
        -tile-columns 4 \
        -frame-parallel 1 \
        -movflags faststart \
        -f webm \
        -dash 1 \
        -speed 3 \
        -threads 4 \
        -an \
        -b:v $bitrate \
        -r 30 \
        -dash 1 \
        "${filename}"

    # Update variables for manifest generation
    manifest_inputs+=( -f webm_dash_manifest -i $filename )
    map+=( -map $counter )
    ((counter++))
done

# Generate comma separated list of video stream indices
for i in $(seq 0 $(($counter-1)))
do
    videoStreamIndices="${videoStreamIndices}${videoStreamIndices:+,}$i"
done

# Generate audio variant
ffmpeg \
    -hide_banner \
    -i actionable.mp3 \
    -c:a libvorbis \
    -b:a 192k \
    -vn \
    -f webm \
    -dash 1 \
    dash/actionable.webm

# Add audio variant to mapped streams
map+=( -map $counter )

# Generate dash manifest
ffmpeg \
    "${manifest_inputs[@]}" \
    -f webm_dash_manifest -i dash/actionable.webm \
    -c copy \
    "${map[@]}" \
    -f webm_dash_manifest \
    -adaptation_sets "id=0,streams=${videoStreamIndices} id=1,streams=${counter}" \
    dash/manifest.mpd
