#!/bin/bash

EXEC_DIR=/usr/bin
EXECUTABLES=(musicxmltasks musicXml2Db musicXml2Ly musicXml2Pdf db2MusicXml db2Ly db2Pdf ly2Pdf musicXmlValidate musicXmlDiff musicXmlProcess)
INSTALL_DIR=/usr/lib/musicxmltasks
INSTALL_BIN_DIR=$INSTALL_DIR/bin

for EXECUTABLE in "${EXECUTABLES[@]}" ; do
  if [ -L $EXEC_DIR/$EXECUTABLE ]; then
      echo "Executable $EXECUTABLE already exists.  Run uninstall.sh.  Then reinstall."
      exit
  fi
done

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
for BIN_FILENAME in bin/* ; do
  BASE_BIN_FILENAME="$(basename ${BIN_FILENAME})"
  TEMP_FILE=$BIN_DIR/${BASE_BIN_FILENAME}.tmp
  EXEC_FILE=$BIN_DIR/${BASE_BIN_FILENAME}

  JAR_FILENAME=musicxmltasks.jar
  cat $BIN_FILENAME | sed "s|\(JAR_FILE=\)|\1${JAR_FILENAME}|g" | sed "s|\(MUSICXMLTASKS_HOME=\)|\1${INSTALL_DIR}|g" | sed "s|\(JAR_DIR=\)|\1${INSTALL_DIR}/lib|g" > $TEMP_FILE

  mv $TEMP_FILE $EXEC_FILE
done

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

for EXECUTABLE in "${EXECUTABLES[@]}" ; do
  INSTALL_DIR_EXECUTABLE=${INSTALL_BIN_DIR}/${EXECUTABLE}
  if [ ! -f $INSTALL_DIR_EXECUTABLE ]; then
      echo "Install to $INSTALL_DIR not successful.  Exit."
      exit
  fi

  EXEC_DIR_EXECUTABLE=${EXEC_DIR}/${EXECUTABLE}
  ln -s  $INSTALL_DIR_EXECUTABLE $EXEC_DIR_EXECUTABLE
  chmod 0755 $EXEC_DIR_EXECUTABLE
done

echo "Done."
