#!/bin/bash
VERSION=$(grep "## Version" AutoCombatLog.toc | sed 's/## Version: //')
ADDON_NAME="AutoCombatLog"
ZIPNAME="${ADDON_NAME}.zip"

echo "Packaging ${ADDON_NAME} v${VERSION}..."

rm -f "$ZIPNAME"

mkdir -p build/Libs/LibStub
mkdir -p build/Libs/CallbackHandler-1.0
mkdir -p build/Libs/LibDataBroker-1.1
mkdir -p build/Libs/LibDBIcon-1.0

cp AutoCombatLog.toc Core.lua Skin.lua Instances.lua SessionTimer.lua \
   CombatLog.lua MinimapButton.lua Settings.lua README.md \
   build/

cp Libs/LibStub/LibStub.lua build/Libs/LibStub/
cp Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua build/Libs/CallbackHandler-1.0/
cp Libs/LibDataBroker-1.1/LibDataBroker-1.1.lua build/Libs/LibDataBroker-1.1/
cp Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua build/Libs/LibDBIcon-1.0/

cd build
zip -r "../$ZIPNAME" .
cd ..
rm -rf build

echo "Created $ZIPNAME"
echo ""
echo "Upload to:"
echo "  - CurseForge: https://www.curseforge.com/wow/addons"
echo "  - Wago: https://addons.wago.io"
echo "  - WoWInterface: https://www.wowinterface.com"
