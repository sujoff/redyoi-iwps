#!/bin/bash

# Define the Docker images to load
IMAGES=("iwpms_client" "iwpms_server")

# Function to load Docker images if they are not present
load_image() {
    IMAGE=$1
    if [[ "$(docker images -q $IMAGE 2> /dev/null)" == "" ]]; then
        echo "Image $IMAGE not found locally. Loading..."
        docker load -i "$IMAGE.tar"
    else
        echo "Image $IMAGE already loaded."
    fi
}

# Load the Docker images
for IMAGE in "${IMAGES[@]}"; do
    load_image $IMAGE
done

echo "Docker images loading process complete."
