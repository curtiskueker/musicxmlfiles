#!/bin/sh

EXEC_DIR=/usr/bin
EXECUTABLE=$EXEC_DIR/musicxmltasks
INSTALL_DIR=/usr/lib/musicxmltasks
INSTALL_BIN_DIR=$INSTALL_DIR/bin
INSTALL_DIR_EXECUTABLE=$INSTALL_BIN_DIR/musicxmltasks

if [ -L $EXECUTABLE ]; then
    echo "Executable $EXECUTABLE already exists.  Run uninstall.sh.  Then reinstall."
    exit
fi

if [ -d $INSTALL_DIR ]; then
    echo "Install directory $INSTALL_DIR already exists.  Run uninstall.sh.  Then reinstall."
    exit
fi

if [ -z "$JAVA_HOME" ]; then
  echo "Required JAVA_HOME environment variable not set"
  exit
fi

TEMP_DIR=$(mktemp -d /tmp/musicxmltasks.XXXXX)

if [ ! -d $TEMP_DIR ]; then
    echo "Failed to create temp install directory $TEMP_DIR.  Exiting."
    exit
fi

BIN_DIR=$TEMP_DIR/bin
LIB_DIR=$TEMP_DIR/lib
IMAGE_DIR=$TEMP_DIR/images

mkdir $BIN_DIR
TEMP_FILE=$BIN_DIR/musicxmltasks.tmp
EXEC_FILE=$BIN_DIR/musicxmltasks
sed "s|\(MUSICXMLTASKS_HOME=\)|\1${INSTALL_DIR}|g" bin/musicxmltasks > $TEMP_FILE
mv $TEMP_FILE $EXEC_FILE

mkdir $LIB_DIR
cp lib/musicxmltasks.jar $LIB_DIR

APPLICATIONS_DIR=/usr/share/applications
mkdir $IMAGE_DIR
cp images/musicxmltasks.png $IMAGE_DIR

if [ -d $APPLICATIONS_DIR ]; then
    DESKTOP_TEMP_FILE=$IMAGE_DIR/musicxmltasks.desktop.tmp
    sed "s|\(MUSICXMLTASKS_HOME\)|${INSTALL_DIR}|g; s|\(JAVA_HOME\)|${JAVA_HOME}|g" images/musicxmltasks.desktop > $DESKTOP_TEMP_FILE
    chmod 0755 $DESKTOP_TEMP_FILE
    mv $DESKTOP_TEMP_FILE /usr/share/applications/musicxmltasks.desktop
fi

chmod -R 0755 $TEMP_DIR

if [ -d $INSTALL_DIR ]; then
    echo "Install direction $INSTALL_DIR already exists.  Run install.sh.  Then reinstall."
    exit
fi

mv $TEMP_DIR $INSTALL_DIR

if [ ! -f $INSTALL_DIR_EXECUTABLE ]; then
    echo "Install to $INSTALL_DIR not successful.  Exit."
    exit
fi

ln -s  $INSTALL_DIR_EXECUTABLE $EXECUTABLE
chmod 0755 $EXECUTABLE

echo "Done."
