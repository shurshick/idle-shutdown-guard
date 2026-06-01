#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="idle-shutdown-guard"
VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  VERSION="$(awk '/^Version:/ { print $2; exit }' "$ROOT_DIR/packaging/$NAME.spec")"
fi

DIST_DIR="$ROOT_DIR/dist"
BUILD_DIR="$ROOT_DIR/build"
RPM_TOPDIR="$BUILD_DIR/rpmbuild"
DEB_ROOT="$BUILD_DIR/debroot"

rm -rf "$DIST_DIR" "$BUILD_DIR"
mkdir -p "$DIST_DIR" "$RPM_TOPDIR"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

SOURCE_ARCHIVE="$DIST_DIR/$NAME-$VERSION.tar.gz"
tar \
  --exclude=".git" \
  --exclude="build" \
  --exclude="dist" \
  --exclude="src/__pycache__" \
  --exclude="*.pyc" \
  --transform "s,^,$NAME-$VERSION/," \
  -czf "$SOURCE_ARCHIVE" \
  -C "$ROOT_DIR" .
cp "$SOURCE_ARCHIVE" "$RPM_TOPDIR/SOURCES/"

if command -v rpmbuild >/dev/null 2>&1; then
  rpmbuild \
    --define "_topdir $RPM_TOPDIR" \
    --nodeps \
    -ba "$ROOT_DIR/packaging/$NAME.spec"
  find "$RPM_TOPDIR/RPMS" "$RPM_TOPDIR/SRPMS" -type f \( -name "*.rpm" -o -name "*.src.rpm" \) \
    -exec cp {} "$DIST_DIR/" \;
else
  echo "rpmbuild is not installed; skipping RPM build" >&2
fi

if command -v dpkg-deb >/dev/null 2>&1; then
  install -Dpm0755 "$ROOT_DIR/src/$NAME" "$DEB_ROOT/usr/bin/$NAME"
  install -Dpm0644 "$ROOT_DIR/config/config.ini" "$DEB_ROOT/etc/$NAME/config.ini"
  install -Dpm0644 "$ROOT_DIR/desktop/$NAME.desktop" "$DEB_ROOT/etc/xdg/autostart/$NAME.desktop"
  install -Dpm0644 "$ROOT_DIR/systemd/$NAME.service" "$DEB_ROOT/usr/lib/systemd/user/$NAME.service"
  install -Dpm0644 "$ROOT_DIR/icons/$NAME.svg" "$DEB_ROOT/usr/share/icons/hicolor/scalable/apps/$NAME.svg"
  install -Dpm0644 "$ROOT_DIR/README.md" "$DEB_ROOT/usr/share/doc/$NAME/README.md"
  install -Dpm0644 "$ROOT_DIR/RELEASE.md" "$DEB_ROOT/usr/share/doc/$NAME/RELEASE.md"
  install -Dpm0644 "$ROOT_DIR/LICENSE" "$DEB_ROOT/usr/share/doc/$NAME/copyright"
  install -Dpm0644 "$ROOT_DIR/packaging/deb/conffiles" "$DEB_ROOT/DEBIAN/conffiles"
  sed "s/@VERSION@/$VERSION/g" "$ROOT_DIR/packaging/deb/control.in" > "$DEB_ROOT/DEBIAN/control"
  chmod -R go-w "$DEB_ROOT"
  dpkg-deb --root-owner-group --build "$DEB_ROOT" "$DIST_DIR/${NAME}_${VERSION}_all.deb"
else
  echo "dpkg-deb is not installed; skipping DEB build" >&2
fi

find "$DIST_DIR" -maxdepth 1 -type f -print | sort
