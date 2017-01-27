#!/bin/bash
set -eu

# Options
tex_make="latexmk"
tex_commits="git rev-list --reverse master"
tex_output="paper.pdf"
gif_output="animation.gif"
montage_geometry=250x
montage_tile=6x
delay=10
ask_before_execution=true

usage() {
  echo "usage: $(basename "$0") [options]"
  echo
  echo "Options:"
  echo "  -h, --help"
  echo "  -y, --yes"
  echo "  --tex-build <command>"
  echo "  --tex-commits <command>"
  echo "  --tex-pdf <pdf_file>"
  echo "  --image-geometry <geometry>"
  echo "  --image-tile <geometry>"
  echo "  --animation-delay <value>"
  echo "  --animation-file <path>"
  echo
  exit 1
}

for opt in "$@"; do
  case "$opt" in
    "-h"|"--help" )
      usage
      ;;
    "-y"|"--yes" )
      ask_before_execution=false
      ;;
    "--tex-build" )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "option requires an argument: $1" 1>&2
        exit 1
      fi
      tex_make="$2"
      shift 2
      ;;
    "--tex-commits" )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "option requires an argument: $1" 1>&2
        exit 1
      fi
      tex_commits="$2"
      shift 2
      ;;
    "--tex-pdf" )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "option requires an argument: $1" 1>&2
        exit 1
      fi
      tex_output="$2"
      shift 2
      ;;
    "--image-geometry" )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "option requires an argument: $1" 1>&2
        exit 1
      fi
      montage_geometry="$2"
      shift 2
      ;;
    "--image-tile" )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "option requires an argument: $1" 1>&2
        exit 1
      fi
      montage_tile="$2"
      shift 2
      ;;
    "--animation-delay" )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "option requires an argument: $1" 1>&2
        exit 1
      fi
      delay="$2"
      shift 2
      ;;
    "--animation-file" )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "option requires an argument: $1" 1>&2
        exit 1
      fi
      gif_output="$2"
      shift 2
      ;;
    -*)
      echo "illegal option: '$1'" 1>&2
      exit 1
      ;;
  esac
done

echo "TeX options:"
echo "  Build command: $tex_make"
echo "  Commits command: $tex_commits"
echo "  PDF file: $tex_output"
echo "Image generation options:"
echo "  Montage geometry: $montage_geometry"
echo "  Tile: $montage_tile"
echo "Output options:"
echo "  Output file: $gif_output"
echo "  Animation delay: $delay"

if $ask_before_execution; then
  echo
  while true; do
    read -p "Execute? [Y/n]" answer
    case $answer in
      '' | [Yy]* )
        break
        ;;
      [nN]* )
        exit 1
        ;;
    esac
  done
fi

# Internal variables
temp_dir=$(mktemp -d)
count=0
width=0
height=0

# Create frames
for commit in $(bash -c "$tex_commits"); do
  # Checkout & build a PDF file
  git checkout "$commit"
  set +e
  eval "$tex_make"
  if [ $? -ne 0 ]; then
    echo "Failed to build"
    continue
  fi
  set -e

  # Convert PDF file to GIF file
  frame_file=$(printf "$temp_dir/%05d.gif" $count)
  convert -background white -alpha remove "$tex_output" miff:- | \
     montage - -geometry "$montage_geometry" -tile "$montage_tile" \
     "$frame_file"

  # Calculate max width and height
  new_width=$(identify -format "%[w]" "$frame_file")
  new_height=$(identify -format "%[h]" "$frame_file")
  if [ $new_width -gt $width ]; then width=$new_width; fi
  if [ $new_height -gt $height ]; then height=$new_height; fi

  count=$(( count + 1 ))
done

# Generate animation GIF file
echo "Generating animation GIF..."
convert \
  -gravity northwest -background white -extent "${width}x${height}" \
  -layers optimize -loop 0 -delay "$delay" \
  "$temp_dir/*" "$gif_output"

rm -rf "$temp_dir"

echo "Completed!! Frames: $count"
