#!/bin/bash

export outdir=""$ROM_DIR"/out/target/product/"$device""
BUILD_START=$(date +"%s")
echo "Build started for "$device""
if [ "$jenkins" == "true" ] || [ "$jenkins" == "1" ]; then
telegram -M "Build "$BUILD_DISPLAY_NAME" started for "$device": [See Progress]("$BUILD_URL"console)"
else
telegram -M "Build started for "$device""
fi
. build/envsetup.sh
. "$my_dir"/config.sh
if [ "$official" == "true" ] || [ "$official" == "1" ]; then
export CUSTOM_BUILD_TYPE=OFFICIAL
fi
lunch "$rom_vendor_name"_"$device"-userdebug
rm -r $OUT/*201*.zip
mka "$bacon"
BUILD_END=$(date +"%s")
BUILD_DIFF=$((BUILD_END - BUILD_START))

export finalzip_path=$(ls "$outdir"/*201*.zip | tail -n -1)
export zip_name=$(echo "$finalzip_path" | sed "s|"$outdir"/||")
export tag=$( echo "$zip_name" | sed 's|.zip||')
if [ -e "$finalzip_path" ]; then
    echo "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"

    echo "Uploading"

    github-release "$release_repo" "$tag" "master" ""$ROM" for "$device"

Date: $(env TZ="$timezone" date)" "$finalzip_path"

    echo "Uploaded"

    telegram -M "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds

Download: ["$zip_name"](https://github.com/"$release_repo"/releases/download/"$tag"/"$zip_name")"

else
    echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    telegram -N -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    exit 1
fi
