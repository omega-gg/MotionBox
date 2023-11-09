# zlib module

INCLUDEPATH += $$SK_CORE/3rdparty/zlib \

HEADERS += $$SK_CORE/3rdparty/zlib/crc32.h \
           $$SK_CORE/3rdparty/zlib/deflate.h \
           $$SK_CORE/3rdparty/zlib/gzguts.h \
           $$SK_CORE/3rdparty/zlib/inffast.h \
           $$SK_CORE/3rdparty/zlib/inffixed.h \
           $$SK_CORE/3rdparty/zlib/inflate.h \
           $$SK_CORE/3rdparty/zlib/inftrees.h \
           $$SK_CORE/3rdparty/zlib/trees.h \
           $$SK_CORE/3rdparty/zlib/zconf.h \
           $$SK_CORE/3rdparty/zlib/zlib.h \
           $$SK_CORE/3rdparty/zlib/zutil.h \

SOURCES += $$SK_CORE/3rdparty/zlib/adler32.c \
           $$SK_CORE/3rdparty/zlib/compress.c \
           $$SK_CORE/3rdparty/zlib/crc32.c \
           $$SK_CORE/3rdparty/zlib/deflate.c \
           $$SK_CORE/3rdparty/zlib/gzclose.c \
           $$SK_CORE/3rdparty/zlib/gzlib.c \
           $$SK_CORE/3rdparty/zlib/gzread.c \
           $$SK_CORE/3rdparty/zlib/gzwrite.c \
           $$SK_CORE/3rdparty/zlib/infback.c \
           $$SK_CORE/3rdparty/zlib/inffast.c \
           $$SK_CORE/3rdparty/zlib/inflate.c \
           $$SK_CORE/3rdparty/zlib/inftrees.c \
           $$SK_CORE/3rdparty/zlib/trees.c \
           $$SK_CORE/3rdparty/zlib/uncompr.c \
           $$SK_CORE/3rdparty/zlib/zutil.c \
