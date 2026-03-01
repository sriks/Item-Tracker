#!/bin/sh
set -e

# Generate TestFlight "What to Test" notes from recent git commits.
# Xcode Cloud picks up TestFlight/WhatToTest.<locale>.txt automatically.

mkdir -p "$CI_PRIMARY_REPOSITORY_PATH/TestFlight"

git -C "$CI_PRIMARY_REPOSITORY_PATH" log \
    --oneline \
    --no-merges \
    --pretty=format:"• %s" \
    -20 \
    > "$CI_PRIMARY_REPOSITORY_PATH/TestFlight/WhatToTest.en-US.txt"
