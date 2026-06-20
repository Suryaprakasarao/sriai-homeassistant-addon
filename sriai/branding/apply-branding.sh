#!/usr/bin/env sh
# Overlays SriAi branding over the upstream static assets baked into the image.
# Runs at Docker build time. It locates every favicon / logo / splash asset in
# the application tree and replaces it with the matching SriAi asset, so none of
# the original branding is visible in the dashboard UI. Missing files are skipped.
set -u

BRAND="$(dirname "$0")"

replace() {
    # $1 = source asset, $2 = destination path
    if [ -f "$2" ]; then
        cp -f "$1" "$2" && echo "branded: $2"
    fi
}

# Replace every PNG favicon / icon / logo / splash anywhere under /app, picking
# the closest matching size from the filename.
find /app -type f \
    \( -iname 'favicon*.png' -o -iname 'apple-touch-icon*.png' \
       -o -iname 'web-app-manifest*.png' -o -iname 'logo*.png' \
       -o -iname 'splash*.png' -o -iname 'icon*.png' \) 2>/dev/null \
| while IFS= read -r f; do
    case "$f" in
        *512*)          src="$BRAND/icon-512.png" ;;
        *192*)          src="$BRAND/icon-192.png" ;;
        *apple-touch*)  src="$BRAND/icon-180.png" ;;
        *96*)           src="$BRAND/icon-96.png" ;;
        *splash*)       src="$BRAND/splash.png" ;;
        *32*)           src="$BRAND/icon-32.png" ;;
        *)              src="$BRAND/icon-512.png" ;;
    esac
    cp -f "$src" "$f" && echo "branded: $f"
done

# Vector favicons and .ico
find /app -type f -iname 'favicon*.svg' 2>/dev/null | while IFS= read -r f; do
    cp -f "$BRAND/favicon.svg" "$f" && echo "branded: $f"
done
find /app -type f -iname 'favicon*.ico' 2>/dev/null | while IFS= read -r f; do
    cp -f "$BRAND/favicon.ico" "$f" && echo "branded: $f"
done

# Always succeed: branding is best-effort and must never fail the build.
exit 0
