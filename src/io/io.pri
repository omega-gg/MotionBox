# Io module

HEADERS += $$SK_CORE/io/WAbstractLoader.h \
           $$SK_CORE/io/WAbstractLoader_p.h \
           $$SK_CORE/io/WLoaderNetwork.h \
           $$SK_CORE/io/WLoaderNetwork_p.h \
           $$SK_CORE/io/WLoaderVbml.h \
           $$SK_CORE/io/WLoaderVbml_p.h \
           $$SK_CORE/io/WLocalObject.h \
           $$SK_CORE/io/WLocalObject_p.h \
           $$SK_CORE/io/WFileWatcher.h \
           $$SK_CORE/io/WFileWatcher_p.h \
           $$SK_CORE/io/WCache.h \
           $$SK_CORE/io/WCache_p.h \
           $$SK_CORE/io/WZipper.h \
           $$SK_CORE/io/WUnzipper.h \
           $$SK_CORE/io/WYamlReader.h \
           $$SK_GUI/io/WBackendLoader.h \
           $$SK_GUI/io/WBackendLoader_p.h \
           $$SK_BARCODE/io/WBarcodeWriter.h \
           $$SK_BARCODE/io/WBarcodeReader.h \
           $$SK_BARCODE/io/WLoaderBarcode.h \
           $$SK_BARCODE/io/WLoaderBarcode_p.h \
           $$SK_BACKEND/io/WBackendIndex.h \
           $$SK_BACKEND/io/WBackendIndex_p.h \
           $$SK_BACKEND/io/WBackendCache.h \
           $$SK_TORRENT/io/WLoaderTorrent.h \
           $$SK_TORRENT/io/WLoaderTorrent_p.h \
           src/io/DataLocal.h \
           src/io/DataOnline.h \

SOURCES += $$SK_CORE/io/WAbstractLoader.cpp \
           $$SK_CORE/io/WLoaderNetwork.cpp \
           $$SK_CORE/io/WLoaderVbml.cpp \
           $$SK_CORE/io/WLocalObject.cpp \
           $$SK_CORE/io/WFileWatcher.cpp \
           $$SK_CORE/io/WCache.cpp \
           $$SK_CORE/io/WZipper.cpp \
           $$SK_CORE/io/WUnzipper.cpp \
           $$SK_CORE/io/WYamlReader.cpp \
           $$SK_GUI/io/WBackendLoader.cpp \
           $$SK_BARCODE/io/WBarcodeWriter.cpp \
           $$SK_BARCODE/io/WBarcodeReader.cpp \
           $$SK_BARCODE/io/WLoaderBarcode.cpp \
           $$SK_BACKEND/io/WBackendIndex.cpp \
           $$SK_BACKEND/io/WBackendCache.cpp \
           $$SK_TORRENT/io/WLoaderTorrent.cpp \
           src/io/DataLocal.cpp \
           src/io/DataLocal_patch.cpp \
           src/io/DataOnline.cpp \
