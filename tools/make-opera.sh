#!/usr/bin/env bash
#
# This script assumes a linux environment

hash jq 2>/dev/null || { echo; echo >&2 "Error: this script requires jq (https://stedolan.github.io/jq/), but it's not installed"; exit 1; }

echo "*** AdNauseam::Opera: Creating opera package"
echo "*** AdNauseam::Opera: Copying files"

DES=dist/build/adnauseam.opera

rm -r $DES
mkdir -p $DES

VERSION=`jq .version manifest.json` # top-level adnauseam manifest
UBLOCK=`jq .version platform/chromium/manifest.json | tr -d '"'` # ublock-version no quotes

bash ./tools/make-assets.sh $DES
bash ./tools/make-locales.sh $DES

cp -R src/css $DES/
cp -R src/img $DES/
cp -R src/js $DES/
cp -R src/lib $DES/

#mkdir -p $DES/_locales
#cp -R src/_locales/en $DES/_locales
#cp -R src/_locales/zh_CN $DES/_locales
#cp -R src/_locales/zh_TW $DES/_locales

cp src/*.html $DES/
cp platform/chromium/*.html $DES/
cp platform/chromium/*.js   $DES/js/
cp -R platform/chromium/img $DES/
cp platform/chromium/*.html $DES/
cp platform/chromium/*.json $DES/
cp LICENSE.txt              $DES/

echo "*** AdNauseam.chromium: concatenating content scripts"
cat $DES/js/vapi-usercss.js > /tmp/contentscript.js
echo >> /tmp/contentscript.js
grep -v "^'use strict';$" $DES/js/contentscript.js >> /tmp/contentscript.js
mv /tmp/contentscript.js $DES/js/contentscript.js
rm $DES/js/vapi-usercss.js

cp platform/opera/manifest.json $DES/  # adn: overwrites chromium manifest
cp LICENSE.txt $DES/

sed -i '' "s/\"{version}\"/${VERSION}/" $DES/manifest.json
sed -i '' "s/{UBLOCK_VERSION}/${UBLOCK}/" $DES/popup.html
sed -i '' "s/{UBLOCK_VERSION}/${UBLOCK}/" $DES/links.html

echo "*** AdNauseam::Opera: Package Done."
echo
# python tools/make-webext-meta.py $DES/  ADN: user our own version

#rm -r $DES/_locales/cv
#rm -r $DES/_locales/hi
#rm -r $DES/_locales/mr
#rm -r $DES/_locales/ta

# grep version $DES/manifest.json
