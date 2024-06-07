#!/bin/bash

. $(dirname "$0")/profile

build_google_font_vf() {
  PADDING=0
  STYLE=$1
  FILENAME=$2
  OUTPUT_DIR=$3

  mkdir -p /tmp/gf

  # Build master OTFs
  for WEIGHT in "${WEIGHTS[@]}"
  do
    DIR=padding${PADDING}_weight${WEIGHT}
    MASTER_FILENAME=${FILENAME}-padding${PADDING}_weight${WEIGHT}-Master

    if [[ $WEIGHT -eq $INT_WEIGHT ]]; then
      CMD="makeotf -nshw -f ./source/$STYLE/vf/masters/$DIR/cidfont.ps -ff ./source/$STYLE/vf/masters/$DIR/features.fea -fi ./source/$STYLE/vf/masters/$DIR/cidfontinfo -r -nS -cs 2 -ch ./source/$STYLE/common/cmap -ci ./source/$STYLE/common/sequences.txt -o /tmp/gf/${MASTER_FILENAME}.otf"

      echo "Processing padding${PADDING}_weight${WEIGHT} (Intermediate): $CMD"
      $CMD
    else
      cp ./source/$STYLE/vf/masters/$DIR/features.fea ./source/$STYLE/vf/masters/$DIR/features.gf.fea
      sed -i 's/STAT.fea/STAT_GF.fea/' ./source/$STYLE/vf/masters/$DIR/features.gf.fea

      CMD="makeotf -nshw -f ./source/$STYLE/vf/masters/$DIR/cidfont.ps -ff ./source/$STYLE/vf/masters/$DIR/features.gf.fea -fi ./source/$STYLE/vf/masters/$DIR/cidfontinfo -mf ./source/$STYLE/vf/FontMenuNameDB -r -nS -cs 2 -ch ./source/$STYLE/common/cmap -ci ./source/$STYLE/common/sequences.txt -o /tmp/gf/${MASTER_FILENAME}.otf"
      echo "Processing padding${PADDING}_weight${WEIGHT} (Upstream): $CMD"
      $CMD

      rm ./source/$STYLE/vf/masters/$DIR/features.gf.fea
    fi
  done

  # Build CFF2 VF
  echo "Building CFF2 VF file..."
  cp ./designspaces/GoogleFont_$FILENAME.designspace /tmp/gf/$FILENAME.designspace
  buildcff2vf --omit-mac-names -d /tmp/gf/$FILENAME.designspace -o /tmp/gf/$FILENAME.otf

  # Convert masters to UFOs
  for WEIGHT in "${WEIGHTS[@]}"
  do
    DIR=padding${PADDING}_weight${WEIGHT}
    MASTER_FILENAME=${FILENAME}-padding${PADDING}_weight${WEIGHT}-Master
    build_vf_ufo "$STYLE" "$FILENAME" "$PADDING" "$WEIGHT" /tmp/gf
  done

  # Build Variable TTF
  echo "Building variable TTF file..."
  python3 ./scripts/build_var_ttf.py /tmp/gf/$FILENAME.designspace /tmp/gf/$FILENAME

  # Fix font tables
  echo "Fixing font tables..."
  sfntedit -x cmap=.tb_cmap,GDEF=.tb_GDEF,GPOS=.tb_GPOS,GSUB=.tb_GSUB,name=.tb_name,OS/2=.tb_OS2,hhea=.tb_hhea,post=.tb_post,STAT=.tb_STAT,fvar=.tb_fvar /tmp/gf/$FILENAME.otf
  sfntedit -a cmap=.tb_cmap,GDEF=.tb_GDEF,GPOS=.tb_GPOS,GSUB=.tb_GSUB,name=.tb_name,OS/2=.tb_OS2,hhea=.tb_hhea,post=.tb_post,STAT=.tb_STAT,fvar=.tb_fvar /tmp/gf/$FILENAME.ttf

  # Copy files to the build directory
  echo "Copying files to the build directory..."
  cp /tmp/gf/$FILENAME.ttf $OUTPUT_DIR
}

mkdir -p $1
build_google_font_vf "regular" "ChironHeiHKVF" $1
build_google_font_vf "italic" "ChironHeiHKItVF" $1
