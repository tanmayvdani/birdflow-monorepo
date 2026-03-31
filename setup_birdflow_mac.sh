#!/bin/bash

REPOS=(
    "https://github.com/birdflow-science/BirdFlowExtras.git"
    "https://github.com/birdflow-science/BirdFlowModels.git"
    "https://github.com/birdflow-science/BirdFlowPipeline.git"
    "https://github.com/birdflow-science/BirdFlowPy.git"
    "https://github.com/birdflow-science/BirdFlowR.git"
)

for url in "${REPOS[@]}"
do
    echo "Cloning $url..."
    git clone "$url"
done

echo "All repositories cloned successfully!"
