#!/bin/sh

# For each code directory, build a code archive that can be copied to the
# learning VM master
find . -type d -mindepth 1 -maxdepth 1 | cut -f2 -d/ | xargs -n1 -I % sh -c "tar -C % -cvf - . | gzip -9v > %.tar.gz"
