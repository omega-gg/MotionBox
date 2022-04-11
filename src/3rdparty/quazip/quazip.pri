# QuaZip module

INCLUDEPATH += $$SK_CORE/3rdparty/quazip \

HEADERS += $$SK_CORE/3rdparty/quazip/ioapi.h \
           $$SK_CORE/3rdparty/quazip/JlCompress.h \
           $$SK_CORE/3rdparty/quazip/minizip_crypt.h \
           $$SK_CORE/3rdparty/quazip/quaadler32.h \
           $$SK_CORE/3rdparty/quazip/quachecksum32.h \
           $$SK_CORE/3rdparty/quazip/quacrc32.h \
           $$SK_CORE/3rdparty/quazip/quagzipfile.h \
           $$SK_CORE/3rdparty/quazip/quaziodevice.h \
           $$SK_CORE/3rdparty/quazip/quazip.h \
           $$SK_CORE/3rdparty/quazip/quazip_global.h \
           $$SK_CORE/3rdparty/quazip/quazip_qt_compat.h \
           $$SK_CORE/3rdparty/quazip/quazipdir.h \
           $$SK_CORE/3rdparty/quazip/quazipfile.h \
           $$SK_CORE/3rdparty/quazip/quazipfileinfo.h \
           $$SK_CORE/3rdparty/quazip/quazipnewinfo.h \
           $$SK_CORE/3rdparty/quazip/unzip.h \
           $$SK_CORE/3rdparty/quazip/zip.h \

SOURCES += $$SK_CORE/3rdparty/quazip/JlCompress.cpp \
           $$SK_CORE/3rdparty/quazip/qioapi.cpp \
           $$SK_CORE/3rdparty/quazip/quaadler32.cpp \
           $$SK_CORE/3rdparty/quazip/quachecksum32.cpp \
           $$SK_CORE/3rdparty/quazip/quacrc32.cpp \
           $$SK_CORE/3rdparty/quazip/quagzipfile.cpp \
           $$SK_CORE/3rdparty/quazip/quaziodevice.cpp \
           $$SK_CORE/3rdparty/quazip/quazip.cpp \
           $$SK_CORE/3rdparty/quazip/quazipdir.cpp \
           $$SK_CORE/3rdparty/quazip/quazipfile.cpp \
           $$SK_CORE/3rdparty/quazip/quazipfileinfo.cpp \
           $$SK_CORE/3rdparty/quazip/quazipnewinfo.cpp \
           $$SK_CORE/3rdparty/quazip/unzip.c \
           $$SK_CORE/3rdparty/quazip/zip.c \
