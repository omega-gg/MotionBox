# qwindowkit module

HEADERS += $$SK_GUI/3rdparty/qwindowkit/core/qwkconfig.h \
           $$SK_GUI/3rdparty/qwindowkit/core/qwkglobal.h \
           $$SK_GUI/3rdparty/qwindowkit/core/qwkglobal_p.h \
           $$SK_GUI/3rdparty/qwindowkit/core/windowagentbase.h \
           $$SK_GUI/3rdparty/qwindowkit/core/windowagentbase_p.h \
           $$SK_GUI/3rdparty/qwindowkit/core/windowitemdelegate_p.h \
           $$SK_GUI/3rdparty/qwindowkit/core/contexts/abstractwindowcontext_p.h \
           $$SK_GUI/3rdparty/qwindowkit/core/contexts/qtwindowcontext_p.h \
           $$SK_GUI/3rdparty/qwindowkit/core/kernel/nativeeventfilter_p.h \
           $$SK_GUI/3rdparty/qwindowkit/core/kernel/sharedeventfilter_p.h \
           $$SK_GUI/3rdparty/qwindowkit/core/kernel/winidchangeeventfilter_p.h \
           $$SK_GUI/3rdparty/qwindowkit/core/shared/qwkwindowsextra_p.h \
           $$SK_GUI/3rdparty/qwindowkit/core/shared/systemwindow_p.h \
           $$SK_GUI/3rdparty/qwindowkit/quick/quickitemdelegate_p.h \
           $$SK_GUI/3rdparty/qwindowkit/quick/quickwindowagent.h \
           $$SK_GUI/3rdparty/qwindowkit/quick/quickwindowagent_p.h \
           $$SK_GUI/3rdparty/qwindowkit/quick/qwkquickglobal.h \

win32:HEADERS += $$SK_GUI/3rdparty/qwindowkit/core/qwindowkit_windows.h \
                 $$SK_GUI/3rdparty/qwindowkit/core/contexts/win32windowcontext_p.h \
                 $$SK_GUI/3rdparty/qwindowkit/core/shared/windows10borderhandler_p.h \

macx:HEADERS += $$SK_GUI/3rdparty/qwindowkit/core/contexts/cocoawindowcontext_p.h \

unix:!macx:!android:HEADERS += $$SK_GUI/3rdparty/qwindowkit/core/qwindowkit_linux.h \
                               $$SK_GUI/3rdparty/qwindowkit/core/contexts/linuxwaylandcontext_p.h \
                               $$SK_GUI/3rdparty/qwindowkit/core/contexts/linuxx11context_p.h \

SOURCES += $$SK_GUI/3rdparty/qwindowkit/core/qwkglobal.cpp \
           $$SK_GUI/3rdparty/qwindowkit/core/windowagentbase.cpp \
           $$SK_GUI/3rdparty/qwindowkit/core/windowitemdelegate.cpp \
           $$SK_GUI/3rdparty/qwindowkit/core/contexts/abstractwindowcontext.cpp \
           $$SK_GUI/3rdparty/qwindowkit/core/contexts/qtwindowcontext.cpp \
           $$SK_GUI/3rdparty/qwindowkit/core/kernel/nativeeventfilter.cpp \
           $$SK_GUI/3rdparty/qwindowkit/core/kernel/sharedeventfilter.cpp \
           $$SK_GUI/3rdparty/qwindowkit/core/kernel/winidchangeeventfilter.cpp \
           $$SK_GUI/3rdparty/qwindowkit/quick/quickitemdelegate.cpp \
           $$SK_GUI/3rdparty/qwindowkit/quick/quickwindowagent.cpp \
           $$SK_GUI/3rdparty/qwindowkit/quick/qwkquickglobal.cpp \

win32:SOURCES += $$SK_GUI/3rdparty/qwindowkit/core/qwindowkit_windows.cpp \
                 $$SK_GUI/3rdparty/qwindowkit/core/contexts/win32windowcontext.cpp \
                 $$SK_GUI/3rdparty/qwindowkit/quick/quickwindowagent_win.cpp \

macx:SOURCES += $$SK_GUI/3rdparty/qwindowkit/core/contexts/cocoawindowcontext.mm \
                $$SK_GUI/3rdparty/qwindowkit/quick/quickwindowagent_mac.cpp \

unix:!macx:!android:SOURCES += $$SK_GUI/3rdparty/qwindowkit/core/qwindowkit_linux.cpp \
                               $$SK_GUI/3rdparty/qwindowkit/core/contexts/linuxwaylandcontext.cpp \
                               $$SK_GUI/3rdparty/qwindowkit/core/contexts/linuxx11context.cpp \
