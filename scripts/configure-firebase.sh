#!/bin/sh

# Selects the GoogleService-Info plist matching the current build configuration,
# copies it into the app bundle, and rewrites the Google Sign-In callback URL
# scheme in the built Info.plist from that plist's REVERSED_CLIENT_ID.
#
# Deriving the URL scheme here keeps the Firebase plist as the single source of
# truth: swapping a plist can never leave a stale scheme behind in Info.plist.

set -eu

if [ -z "${GOOGLE_SERVICE_PLIST:-}" ]; then
    echo "error: GOOGLE_SERVICE_PLIST build setting is not set for configuration '${CONFIGURATION}'."
    exit 1
fi

SOURCE_PLIST="${SRCROOT}/WorkoutTracker/Resources/Firebase/${GOOGLE_SERVICE_PLIST}"

if [ ! -f "${SOURCE_PLIST}" ]; then
    echo "error: ${SOURCE_PLIST} not found. Download it from the Firebase console for bundle ID ${PRODUCT_BUNDLE_IDENTIFIER}."
    exit 1
fi

PLIST_BUDDY=/usr/libexec/PlistBuddy
DESTINATION_DIR="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}"

EXPECTED_BUNDLE_ID=$("${PLIST_BUDDY}" -c "Print :BUNDLE_ID" "${SOURCE_PLIST}")

if [ "${EXPECTED_BUNDLE_ID}" != "${PRODUCT_BUNDLE_IDENTIFIER}" ]; then
    echo "error: ${GOOGLE_SERVICE_PLIST} is registered for '${EXPECTED_BUNDLE_ID}' but this target builds '${PRODUCT_BUNDLE_IDENTIFIER}'. Google Sign-In would be rejected at runtime."
    exit 1
fi

cp "${SOURCE_PLIST}" "${DESTINATION_DIR}/GoogleService-Info.plist"

# REVERSED_CLIENT_ID is only present once an iOS OAuth client exists for this app in the
# Firebase console (i.e. Google is enabled as a sign-in provider). Without it there is no
# correct value to write, so the scheme is left as the placeholder and Google Sign-In will
# fail at runtime — as will FirebaseApp.options.clientID, which AuthService requires.
#
# Debug builds only warn, so that unrelated work is not blocked by Firebase configuration.
# Shipping configurations still fail the build, because a build that looks fine but cannot
# complete Google Sign-In must never leave a developer's machine.
if ! REVERSED_CLIENT_ID=$("${PLIST_BUDDY}" -c "Print :REVERSED_CLIENT_ID" "${SOURCE_PLIST}" 2>/dev/null); then
    MESSAGE="${GOOGLE_SERVICE_PLIST} has no REVERSED_CLIENT_ID, so Google Sign-In is not configured. Enable Google as a sign-in provider for '${PRODUCT_BUNDLE_IDENTIFIER}' in the Firebase console, then re-download the plist."

    if [ "${CONFIGURATION}" = "Debug" ]; then
        echo "warning: ${MESSAGE}"
        echo "Configured Firebase for ${PRODUCT_BUNDLE_IDENTIFIER} using ${GOOGLE_SERVICE_PLIST} (without Google Sign-In)"
        exit 0
    fi

    echo "error: ${MESSAGE}"
    exit 1
fi

"${PLIST_BUDDY}" -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 ${REVERSED_CLIENT_ID}" "${DESTINATION_DIR}/Info.plist"

echo "Configured Firebase for ${PRODUCT_BUNDLE_IDENTIFIER} using ${GOOGLE_SERVICE_PLIST}"
