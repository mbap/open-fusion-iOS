#! /bin/bash
appledoc \
   --project-name "GSFDataCollector" \
   --project-company "GSF SDP Team" \
   --company-id "com.sdpllnl" \
   --docset-feed-url "https://github.com/mbaptist23/open-fusion-ios" \
   --docset-package-url "https://github.com/mbaptist23/open-fusion-ios" \
   --docset-fallback-url "https://github.com/mbaptist23/open-fusion-ios" \
   --output "~/help" \
   --publish-docset \
   --logformat xcode \
   --keep-undocumented-objects \
   --keep-undocumented-members \
   --no-repeat-first-par \
   --ignore "*.m" \
   --ignore "*.mm" \
   --ignore "Crashlytics.framework" \
   --ignore "GoogleMaps.bundle" \
   --ignore "GoogleMaps.framework" \
   --ignore "GSFDataCollecter.*" \
   --ignore "Pods" \
   --ignore "Podfile" \
   --ignore "Podfile.lock" \
   --ignore "LICENCE" \
   --index-desc "./README.md" \
   "."


