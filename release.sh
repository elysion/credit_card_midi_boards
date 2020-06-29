#!/bin/bash
set -e

BOARDS_DIR=$(dirname "$0")
VERSION=$1

if [ -z ${VERSION} ]; then
	echo "Version not provided!"
	exit
elif [[ ! ${VERSION} =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "Version ${VERSION} is in valid format (should be e.g. 1.0.0)"
	exit
else
	echo "Building version ${VERSION}"
fi

ZIP_FILE_NAME="credit_card_midi-${VERSION}.zip"
mv ${BOARDS_DIR}/hardware/* "${BOARDS_DIR}/hardware/${VERSION}"
git add "${BOARDS_DIR}/hardware/${VERSION}"
cd "${BOARDS_DIR}/hardware"; zip -r "${BOARDS_DIR}/../${ZIP_FILE_NAME}" "${VERSION}"; cd -
SHA=$(shasum -a 256 "${BOARDS_DIR}/../${ZIP_FILE_NAME}")
SIZE=$(stat -f "%z" "${BOARDS_DIR}/../${ZIP_FILE_NAME}")

echo "SHA: ${SHA}, zip size: ${SIZE}"

PACKAGE_FILE="${BOARDS_DIR}/package_credit_card_midi_index.json"
sed -e "s/\([0-9]*\.[0-9]*\.[0-9]*\)/${VERSION}/g" -i "" "${PACKAGE_FILE}"
sed -e 's/"SHA\-256\:\(.*\)"/"SHA\-256\:${SHA}"/' -i "" "${PACKAGE_FILE}"
sed -e 's/\("size"\: \)"\([0-9]*\)"/\1"${SIZE}"/' -i "" "${PACKAGE_FILE}"

git add "${PACKAGE_FILE}"
git commit -m "Release v${VERSION}"
git tag "v${VERSION}"

#echo Updating version to v${NEW_VERSION}
#sed -e 's/\(<text \)\(.*v1\.0\.0\)/\1locked="yes" \2/' -i "" *.brd
#sed -e 's/\(<text locked=\"yes\".*v\)\(\d+\.\d+\.\d+\)/\1${NEW_VERSION}/' -i "" ./eagle/*.brd
#sed -e "s/\(<text locked=\"yes\".*\)\(v[0-9]*\.[0-9]*\.[0-9]*\)/\1v${NEW_VERSION}/" -i "" eagle/*.brd
