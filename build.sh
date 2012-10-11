#!/bin/bash

BUILDDIR=./build

# Determine architecture
ARCH=`arch`
if [ "$ARCH" = "x86_64" ]; then
    ARCHITECTURE="amd64"
else
    ARCHITECTURE="i386"
fi

# Get input
echo "Enter package name:"
read PACKAGENAME
echo "Enter package version:"
read VERSION

PACKAGE="${PACKAGENAME}_${VERSION}_${ARCHITECTURE}"

echo "Creating package called ${PACKAGE}.deb. Is this correct (Y/n)"
read yesno

case $yesno in
    n|N)
        echo "Stopping."
        exit ;;
    *) ;;
esac

# Create builddir
if [ ! -d "$BUILDDIR" ]; then
    mkdir $BUILDDIR
else
    rm -fr $BUILDDIR
    mkdir $BUILDDIR
fi

# Make install
make install DESTDIR=$BUILDDIR

# Creating DEBIAN files
echo "Creating control file.."
mkdir -p $BUILDDIR/DEBIAN
cp tools/Linux/buildpackage/control.in $BUILDDIR/DEBIAN/control
sed -i 's/<!-- packagename -->/'$PACKAGENAME'/g' $BUILDDIR/DEBIAN/control
sed -i 's/<!-- version -->/'$VERSION'/g' $BUILDDIR/DEBIAN/control
sed -i 's/<!-- architecture -->/'$ARCHITECTURE'/g' $BUILDDIR/DEBIAN/control

cp tools/Linux/buildpackage/postinst.in $BUILDDIR/DEBIAN/postinst
cp tools/Linux/buildpackage/postrm.in $BUILDDIR/DEBIAN/postrm
cp tools/Linux/buildpackage/prerm.in $BUILDDIR/DEBIAN/prerm
chmod +x $BUILDDIR/DEBIAN/postinst
chmod +x $BUILDDIR/DEBIAN/postrm
chmod +x $BUILDDIR/DEBIAN/prerm

# Create postinst, postrm and prerm
echo "#!/bin/sh" > $BUILDDIR/DEBIAN/postinst
echo "set -e" > $BUILDDIR/DEBIAN/postinst

# Create menu file
mkdir -p $BUILDDIR/usr/share/menu/
cp tools/Linux/xbmc-menu.in $BUILDDIR/usr/share/menu/xbmc

# Build package
echo "Building package in ./${PACKAGE}.deb"
if [ -f "./${PACKAGE}.deb" ]
then
  rm -fr "./${PACKAGE}.deb"
fi
fakeroot dpkg-deb --build $BUILDDIR "./${PACKAGE}.deb"


