#!/bin/bash

# Set the playlist ID and API key
playlist_id="YOUR_YT_PLAYLIST"
api_key="YOUR_API_KEY"

# Set the starting page token to the first page
page_token=""

# Loop through all pages of the playlist
while true; do
  # Construct the API request URL with the current page token
  url="https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&pageToken=$page_token&playlistId=$playlist_id&key=$api_key"

  # Send the API request and save the response to a file
  curl -s "$url" -o response.json

  # Parse the video IDs from the response using jq
  video_ids=$(jq -r '.items[].snippet.resourceId.videoId' response.json)

  # Download each video using youtube-dl
  for video_id in $video_ids; do
    youtube-dl "https://www.youtube.com/watch?v=$video_id"
  done

  # Get the next page token, if any
  page_token=$(jq -r '.nextPageToken' response.json)
  if [ -z "$page_token" ]; then
    break
  fi
done

# Clean up the response file
rm -f response.json
