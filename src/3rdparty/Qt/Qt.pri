# Qt module

contains(QT_MAJOR_VERSION, 4):HEADERS += $$SK_GUI/3rdparty/Qt/qdeclarativemousearea_p.h \
                                         $$SK_GUI/3rdparty/Qt/qdeclarativeevents_p_p.h \

contains(QT_MAJOR_VERSION, 4):SOURCES += $$SK_GUI/3rdparty/Qt/qdeclarativemousearea.cpp \
