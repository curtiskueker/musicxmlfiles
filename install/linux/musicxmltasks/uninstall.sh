#!/bin/bash

EXEC_DIR=/usr/bin
EXECUTABLES=(musicxmltasks musicXml2Db musicXml2Ly musicXml2Pdf db2MusicXml db2Ly db2Pdf ly2Pdf musicXmlValidate musicXmlCompress musicXmlDiff musicXmlProcess)
INSTALL_DIR=/usr/lib/musicxmltasks
DESKTOP_FILE=/usr/share/applications/musicxmltasks.desktop

for EXECUTABLE in "${EXECUTABLES[@]}" ; do
  EXEC_DIR_EXECUTABLE=${EXEC_DIR}/${EXECUTABLE}
  if [ ! -L $EXEC_DIR_EXECUTABLE ]; then
      echo "Executable $EXEC_DIR_EXECUTABLE not found.  Exit."
      exit
  fi

rm $EXEC_DIR_EXECUTABLE
done

if [ ! -d $INSTALL_DIR ]; then
    echo "Install directory $INSTALL_DIR not found.  Exit."
    exit
fi

rm -rf $INSTALL_DIR

if [ -f $DESKTOP_FILE ]; then
    rm $DESKTOP_FILE
fi

echo "Done."
