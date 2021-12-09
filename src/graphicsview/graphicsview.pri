# Graphics view module

HEADERS += $$SK_GUI/graphicsview/WAbstractView.h \
           $$SK_GUI/graphicsview/WAbstractView_p.h \
           $$SK_GUI/graphicsview/WView.h \
           $$SK_GUI/graphicsview/WView_p.h \
           $$SK_GUI/graphicsview/WViewResizer.h \
           $$SK_GUI/graphicsview/WViewDrag.h \
           $$SK_GUI/graphicsview/WWindow.h \
           $$SK_GUI/graphicsview/WWindow_p.h \
           $$SK_GUI/graphicsview/WResizer.h \
           $$SK_GUI/graphicsview/WResizer_p.h \

greaterThan(QT_MAJOR_VERSION, 5): HEADERS += $$SK_GUI/graphicsview/WTextureVideo.h \
                                             $$SK_GUI/graphicsview/WTextureVideo_p.h \

SOURCES += $$SK_GUI/graphicsview/WAbstractView.cpp \
           $$SK_GUI/graphicsview/WView.cpp \
           $$SK_GUI/graphicsview/WViewResizer.cpp \
           $$SK_GUI/graphicsview/WViewDrag.cpp \
           $$SK_GUI/graphicsview/WWindow.cpp \
           $$SK_GUI/graphicsview/WResizer.cpp \

greaterThan(QT_MAJOR_VERSION, 5): SOURCES += $$SK_GUI/graphicsview/WTextureVideo.cpp \
