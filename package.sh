#!/bin/bash
VERSION=$(grep "## Version" AutoCombatLogClassic.toc | sed 's/## Version: //')
ADDON_NAME="AutoCombatLogClassic"
ZIPNAME="${ADDON_NAME}.zip"

echo "Packaging ${ADDON_NAME} v${VERSION}..."

rm -f "$ZIPNAME"

mkdir -p build/$ADDON_NAME/Libs/LibStub
mkdir -p build/$ADDON_NAME/Libs/CallbackHandler-1.0
mkdir -p build/$ADDON_NAME/Libs/LibDataBroker-1.1
mkdir -p build/$ADDON_NAME/Libs/LibDBIcon-1.0

cp AutoCombatLogClassic.toc Core.lua Skin.lua Instances.lua SessionTimer.lua \
   CombatLog.lua MinimapButton.lua Settings.lua README.md \
   build/$ADDON_NAME/

cp Libs/LibStub/LibStub.lua build/$ADDON_NAME/Libs/LibStub/
cp Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua build/$ADDON_NAME/Libs/CallbackHandler-1.0/
cp Libs/LibDataBroker-1.1/LibDataBroker-1.1.lua build/$ADDON_NAME/Libs/LibDataBroker-1.1/
cp Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua build/$ADDON_NAME/Libs/LibDBIcon-1.0/

cd build
zip -r "../$ZIPNAME" $ADDON_NAME
cd ..
rm -rf build

echo "Created $ZIPNAME"
echo ""
echo "Upload to:"
echo "  - CurseForge: https://www.curseforge.com/wow/addons"
echo "  - Wago: https://addons.wago.io"
echo "  - WoWInterface: https://www.wowinterface.com"
