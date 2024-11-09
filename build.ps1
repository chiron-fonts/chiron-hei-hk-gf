$curDir = Get-Location

echo "Preparing Docker image..."
docker build -t chiron-hei-hk-gf-builder .

echo "Building font binaries..."
docker run -it --rm --name build-chiron-hei-hk-gf --mount type=bind,source="$curDir",target=/build chiron-hei-hk-gf-builder "/usr/local/bin/fontmake" -m /build/source/ChironHeiHKVF.designspace -o variable --output-path /build/fonts/variable/ChironHeiHK-[wght].ttf
docker run -it --rm --name build-chiron-hei-hk-gf --mount type=bind,source="$curDir",target=/build chiron-hei-hk-gf-builder "/usr/local/bin/fontmake" -m /build/source/ChironHeiHKItVF.designspace -o variable --output-path /build/fonts/variable/ChironHeiHK-Italic-[wght].ttf