SK = $$_PRO_FILE_PWD_/../Sky

TARGET = MotionBox

greaterThan(QT_MAJOR_VERSION, 4) {
    DESTDIR = $$_PRO_FILE_PWD_/latest
} else {
    DESTDIR = $$_PRO_FILE_PWD_/bin
}

QT += declarative network xml

macx: CONFIG -= app_bundle

greaterThan(QT_MAJOR_VERSION, 4): DEFINES += QT_LATEST

#CONFIG += deploy

deploy {
    DEFINES += SK_DEPLOY

    #RESOURCES = dist/MotionBox.qrc
}

include(src/global/global.pri)
include(src/controllers/controllers.pri)
include(src/io/io.pri)

INCLUDEPATH += \
            $$SK/include/SkCore \
            $$SK/include/SkGui \
            $$SK/include/SkMedia \
            $$SK/include/SkWeb \
            $$SK/include/SkBackend \
            src/controllers \
            src/io \

CONFIG(debug, debug|release) {
    LIBS += \
         -L$$SK/lib -lSkCoreD \
         -L$$SK/lib -lSkGuiD \
         -L$$SK/lib -lSkMediaD \
         -L$$SK/lib -lSkWebD \
         -L$$SK/lib -lSkBackendD \

} else {
    LIBS += \
         -L$$SK/lib -lSkCore \
         -L$$SK/lib -lSkGui \
         -L$$SK/lib -lSkMedia \
         -L$$SK/lib -lSkWeb \
         -L$$SK/lib -lSkBackend \

}

RC_FILE = dist/MotionBox.rc

OTHER_FILES += configure.sh \
               deploy.sh \
               README.md \
               LICENSE.md \
               content/text/credits.txt \
               content/Main.qml \
               content/StyleApplication.qml \
               content/Splash.qml \
               content/Gui.qml \
               content/AreaContextualApplication.qml \
               content/AreaDrag.qml \
               content/ItemNew.qml \
               content/ItemTabMini.qml \
               content/TextLogo.qml \
               content/PanelApplication.qml \
               content/PanelSearch.qml \
               content/PanelLibrary.qml \
               content/PanelFolder.qml \
               content/PanelTracks.qml \
               content/PanelPlayer.qml \
               content/PanelBrowse.qml \
               content/PanelRelated.qml \
               content/PanelCover.qml \
               content/PanelSettings.qml \
               content/PanelShare.qml \
               content/PanelAdd.qml \
               content/PanelPreview.qml \
               content/BarWindowApplication.qml \
               content/BarTop.qml \
               content/BarControls.qml \
               content/ButtonPianoTitle.qml \
               content/ButtonLogo.qml \
               content/ButtonLogoBorders.qml \
               content/ButtonsBrowse.qml \
               content/ButtonsUpdater.qml \
               content/LineEditSearch.qml \
               content/ListFolder.qml \
               content/ListPlaylist.qml \
               content/ScrollFolder.qml \
               content/ScrollFolderCreate.qml \
               content/ScrollPlaylist.qml \
               content/ScrollPlaylistCreate.qml \
               content/ComponentLibraryItem.qml \
               content/ComponentTrack.qml \
               content/ComponentFolder.qml \
               content/PageSettings.qml \
               content/PageSettingsMain.qml \
               content/PageSettingsProxy.qml \
               content/PageAbout.qml \
               content/PageAboutMain.qml \
               content/PageAboutText.qml \
               content/PageAboutMessage.qml \
               content/PageAboutCredits.qml \
               dist/MotionBox.rc \
               dist/qrc.sh \
               dist/doc/readme.md \
               dist/doc/shortcuts.md \
               dist/doc/about.md \
               dist/doc/license.md \
               dist/doc/fr/readme.md \
               dist/doc/fr/shortcuts.md \
               dist/doc/fr/about.md \
               dist/changes/1.0.1.md \
               dist/changes/1.1.0.md \
               dist/changes/1.1.1.md \
               dist/changes/1.1.2.md \
               dist/installer/config/config-win32.xml \
               dist/installer/config/controller.qs \
               dist/installer/packages/setup/meta/package.xml \
               dist/installer/packages/setup/meta/component.qs \
               dist/installer/packages/setup/meta/form.ui \
               dist/installer/packages/setup/data/setup.xml \
               dist/installer/packages/MotionBox/meta/package.xml \
               dist/installer/packages/Sky/meta/package.xml \
               dist/installer/packages/Qt/meta/package.xml \
               dist/installer/packages/VLC/meta/package.xml \

macx {
CONFIG(debug, debug|release) {
    QMAKE_POST_LINK  = install_name_tool -change libSkCoreD.dylib \
                       @executable_path/libSkCoreD.dylib $${DESTDIR}/$${TARGET} ;

    QMAKE_POST_LINK += install_name_tool -change libSkGuiD.dylib \
                       @executable_path/libSkGuiD.dylib $${DESTDIR}/$${TARGET} ;

    QMAKE_POST_LINK += install_name_tool -change libSkMediaD.dylib \
                       @executable_path/libSkMediaD.dylib $${DESTDIR}/$${TARGET} ;

    QMAKE_POST_LINK += install_name_tool -change libSkWebD.dylib \
                       @executable_path/libSkWebD.dylib $${DESTDIR}/$${TARGET} ;

    QMAKE_POST_LINK += install_name_tool -change libSkBackendD.dylib \
                       @executable_path/libSkBackendD.dylib $${DESTDIR}/$${TARGET} ;
} else {
    QMAKE_POST_LINK  = install_name_tool -change libSkCore.dylib \
                       @executable_path/libSkCore.dylib $${DESTDIR}/$${TARGET} ;

    QMAKE_POST_LINK += install_name_tool -change libSkGui.dylib \
                       @executable_path/libSkGui.dylib $${DESTDIR}/$${TARGET} ;

    QMAKE_POST_LINK += install_name_tool -change libSkMedia.dylib \
                       @executable_path/libSkMedia.dylib $${DESTDIR}/$${TARGET} ;

    QMAKE_POST_LINK += install_name_tool -change libSkWeb.dylib \
                       @executable_path/libSkWeb.dylib $${DESTDIR}/$${TARGET} ;

    QMAKE_POST_LINK += install_name_tool -change libSkBackend.dylib \
                       @executable_path/libSkBackend.dylib $${DESTDIR}/$${TARGET} ;
}
}
