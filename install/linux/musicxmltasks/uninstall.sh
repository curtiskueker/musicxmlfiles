#!/bin/sh

EXEC_DIR=/usr/bin
EXECUTABLE=$EXEC_DIR/musicxmltasks
INSTALL_DIR=/usr/lib/musicxmltasks
DESKTOP_FILE=/usr/share/applications/musicxmltasks.desktop

if [ ! -L $EXECUTABLE ]; then
    echo "Executable $EXECUTABLE not found.  Exit."
    exit
fi

rm $EXECUTABLE

if [ ! -d $INSTALL_DIR ]; then
    echo "Install directory $INSTALL_DIR not found.  Exit."
    exit
fi

rm -rf $INSTALL_DIR

if [ -f $DESKTOP_FILE ]; then
    rm $DESKTOP_FILE
fi

echo "Done."
