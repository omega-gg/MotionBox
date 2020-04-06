# Qt single application module

HEADERS += $$SK_CORE/3rdparty/qtsingleapplication/qtlocalpeer.h \
           $$SK_CORE/3rdparty/qtsingleapplication/qtlockedfile.h \
           $$SK_CORE/3rdparty/qtsingleapplication/qtsinglecoreapplication.h \
           $$SK_GUI/3rdparty/qtsingleapplication/qtsingleapplication.h \

SOURCES += $$SK_CORE/3rdparty/qtsingleapplication/qtlocalpeer.cpp \
           $$SK_CORE/3rdparty/qtsingleapplication/qtlockedfile.cpp \
           $$SK_CORE/3rdparty/qtsingleapplication/qtlockedfile_unix.cpp \
           $$SK_CORE/3rdparty/qtsingleapplication/qtlockedfile_win.cpp \
           $$SK_CORE/3rdparty/qtsingleapplication/qtsinglecoreapplication.cpp \
           $$SK_GUI/3rdparty/qtsingleapplication/qtsingleapplication.cpp \
