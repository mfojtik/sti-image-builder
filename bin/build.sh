#!/bin/bash

source_dir=$(echo $SOURCE_URI | grep -o -e "[^/]*$")

if [ -z "${IMAGE_NAME}" ]; then
  echo "[ERROR] The IMAGE_NAME variable must be set"
  exit 1
fi

# Clone the STI image repository
git clone $SOURCE_URI
if ! [ $? -eq 0 ]; then
  echo "[ERROR] Unable to clone the STI image repository."
  exit 1
fi

status=1

pushd $source_dir >/dev/null
  # Checkout desired ref
  if ! [ -z "$SOURCE_REF" ]; then
    git checkout $SOURCE_REF
  fi

  docker build -t ${IMAGE_NAME}-candidate .

  # Verify the 'test/run' is present
  if ! [ -x "./test/run" ]; then
    echo "[ERROR] Unable to locate the 'test/run' command for the image"
    exit $status
  fi

  # Execute tests
  ./test/run
  status=$?
  if [ $status -eq 0]; then
    echo "[SUCCESS] ${IMAGE_NAME} image tests executed successfully"
  else
    echo "[FAILURE] ${IMAGE_NAME} image tests failed ($status)" && exit $status
  fi
popd >/dev/null

# After successful build, retag the image to 'qa-ready'
# TODO: Define image promotion process
#
image_id=$(docker inspect --format="{{ .Id }}" ${IMAGE_NAME}-candidate:latest)
docker tag ${image_id} ${IMAGE_NAME}:qa-ready
docker tag ${image_id} ${IMAGE_NAME}:git-$SOURCE_REF
