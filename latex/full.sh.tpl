#!/bin/bash

set -e

trap 'error_handler $?' 0

error_handler() {
  [ 0 -eq "$1" ] || cat LOG
}

# pdflatex seems to assume some tools are in $PWD?
for tool in makeindex;
do 
  ln -s $(which $tool) $tool
done

{PULL}

{BODY}

{COPY}
