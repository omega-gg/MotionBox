# Media module

HEADERS += $$SK_GUI/media/WBackendNet.h \
           $$SK_GUI/media/WBackendNet_p.h \
           $$SK_GUI/media/WTrack.h \
           $$SK_GUI/media/WTrack_p.h \
           $$SK_GUI/media/WChapter.h \
           $$SK_GUI/media/WChapter_p.h \
           $$SK_GUI/media/WSubtitle.h \
           $$SK_GUI/media/WSubtitle_p.h \
           $$SK_GUI/media/WLibraryItem.h \
           $$SK_GUI/media/WLibraryItem_p.h \
           $$SK_GUI/media/WLibraryFolder.h \
           $$SK_GUI/media/WLibraryFolder_p.h \
           $$SK_GUI/media/WLibraryFolderRelated.h \
           $$SK_GUI/media/WLibraryFolderRelated_p.h \
           $$SK_GUI/media/WPlaylist.h \
           $$SK_GUI/media/WPlaylist_p.h \
           $$SK_GUI/media/WLoaderPlaylist.h \
           $$SK_GUI/media/WLoaderPlaylist_p.h \
           $$SK_GUI/media/WLoaderSuggest.h \
           $$SK_GUI/media/WLoaderSuggest_p.h \
           $$SK_GUI/media/WLoaderRecent.h \
           $$SK_GUI/media/WLoaderRecent_p.h \
           $$SK_GUI/media/WLoaderTracks.h \
           $$SK_GUI/media/WLoaderTracks_p.h \
           $$SK_GUI/media/WPlayer.h \
           $$SK_GUI/media/WPlayer_p.h \
           $$SK_GUI/media/WAbstractBackend.h \
           $$SK_GUI/media/WAbstractBackend_p.h \
           $$SK_GUI/media/WAbstractHook.h \
           $$SK_GUI/media/WAbstractHook_p.h \
           $$SK_GUI/media/WHookOutput.h \
           $$SK_GUI/media/WHookOutput_p.h \
           $$SK_GUI/media/WBookmarkTrack.h \
           $$SK_GUI/media/WBookmarkTrack_p.h \
           $$SK_GUI/media/WTabsTrack.h \
           $$SK_GUI/media/WTabsTrack_p.h \
           $$SK_GUI/media/WTabTrack.h \
           $$SK_GUI/media/WTabTrack_p.h \
           $$SK_BARCODE/media/WHookOutputBarcode.h \
           $$SK_BARCODE/media/WHookOutputBarcode_p.h \
           $$SK_BACKEND/media/WBackendUniversal.h \
           $$SK_BACKEND/media/WBackendUniversal_p.h \
           $$SK_MEDIA/media/WBackendManager.h \
           $$SK_MEDIA/media/WBackendManager_p.h \
           $$SK_MEDIA/media/WBackendVlc.h \
           $$SK_MEDIA/media/WBackendVlc_p.h \
           $$SK_MEDIA/media/WBackendSubtitle.h \
           $$SK_MEDIA/media/WBackendSubtitle_p.h \
           $$SK_TORRENT/media/WBackendTorrent.h \
           $$SK_TORRENT/media/WBackendTorrent_p.h \
           $$SK_TORRENT/media/WHookTorrent.h \
           $$SK_TORRENT/media/WHookTorrent_p.h \

greaterThan(QT_MAJOR_VERSION, 4) {
    HEADERS += $$SK_MULTIMEDIA/media/WFilterBarcode.h \
               $$SK_MULTIMEDIA/media/WFilterBarcode_p.h
}

contains(QT_MAJOR_VERSION, 5) {
    HEADERS += $$SK_MULTIMEDIA/media/Qt/qvideoframeconversionhelper_p.h
}

SOURCES += $$SK_GUI/media/WBackendNet.cpp \
           $$SK_GUI/media/WTrack.cpp \
           $$SK_GUI/media/WChapter.cpp \
           $$SK_GUI/media/WSubtitle.cpp \
           $$SK_GUI/media/WLibraryItem.cpp \
           $$SK_GUI/media/WLibraryFolder.cpp \
           $$SK_GUI/media/WLibraryFolderRelated.cpp \
           $$SK_GUI/media/WPlaylist.cpp \
           $$SK_GUI/media/WPlaylist_patch.cpp \
           $$SK_GUI/media/WLoaderPlaylist.cpp \
           $$SK_GUI/media/WLoaderSuggest.cpp \
           $$SK_GUI/media/WLoaderRecent.cpp \
           $$SK_GUI/media/WLoaderTracks.cpp \
           $$SK_GUI/media/WPlayer.cpp \
           $$SK_GUI/media/WAbstractBackend.cpp \
           $$SK_GUI/media/WAbstractHook.cpp \
           $$SK_GUI/media/WHookOutput.cpp \
           $$SK_GUI/media/WBookmarkTrack.cpp \
           $$SK_GUI/media/WTabTrack.cpp \
           $$SK_GUI/media/WTabTrack_patch.cpp \
           $$SK_GUI/media/WTabsTrack.cpp \
           $$SK_BARCODE/media/WHookOutputBarcode.cpp \
           $$SK_BACKEND/media/WBackendUniversal.cpp \
           $$SK_MEDIA/media/WBackendManager.cpp \
           $$SK_MEDIA/media/WBackendVlc.cpp \
           $$SK_MEDIA/media/WBackendSubtitle.cpp \
           $$SK_TORRENT/media/WBackendTorrent.cpp \
           $$SK_TORRENT/media/WHookTorrent.cpp \

greaterThan(QT_MAJOR_VERSION, 4) {
    SOURCES += $$SK_MULTIMEDIA/media/WFilterBarcode.cpp
}
