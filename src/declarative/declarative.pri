# Declarative module

HEADERS += $$SK_GUI/declarative/WDeclarativeApplication.h \
           $$SK_GUI/declarative/WDeclarativeItem.h \
           $$SK_GUI/declarative/WDeclarativeItem_p.h \
           $$SK_GUI/declarative/WDeclarativeMouseArea.h \
           $$SK_GUI/declarative/WDeclarativeMouseArea_p.h \
           $$SK_GUI/declarative/WDeclarativeMouseWatcher.h \
           $$SK_GUI/declarative/WDeclarativeMouseWatcher_p.h \
           $$SK_GUI/declarative/WDeclarativeBorders.h \
           $$SK_GUI/declarative/WDeclarativeImageBase.h \
           $$SK_GUI/declarative/WDeclarativeImageBase_p.h \
           $$SK_GUI/declarative/WDeclarativeImage.h \
           $$SK_GUI/declarative/WDeclarativeImage_p.h \
           $$SK_GUI/declarative/WDeclarativeImageSvg.h \
           $$SK_GUI/declarative/WDeclarativeImageSvg_p.h \
           $$SK_GUI/declarative/WDeclarativeBorderImage.h \
           $$SK_GUI/declarative/WDeclarativeBorderImage_p.h \
           #$$SK_GUI/declarative/WDeclarativeText.h \
           $$SK_GUI/declarative/WDeclarativeTextSvg.h \
           $$SK_GUI/declarative/WDeclarativeTextSvg_p.h \
           $$SK_GUI/declarative/WDeclarativeAnimated.h \
           $$SK_GUI/declarative/WDeclarativeAnimated_p.h \
           $$SK_GUI/declarative/WDeclarativePlayer.h \
           $$SK_GUI/declarative/WDeclarativePlayer_p.h \
           $$SK_GUI/declarative/WDeclarativeAmbient.h \
           $$SK_GUI/declarative/WDeclarativeAmbient_p.h \
           $$SK_GUI/declarative/WDeclarativeListView.h \
           $$SK_GUI/declarative/WDeclarativeListView_p.h \
           $$SK_GUI/declarative/WDeclarativeContextualPage.h \
           $$SK_BARCODE/declarative/WDeclarativeScanner.h \
           $$SK_BARCODE/declarative/WDeclarativeScanner_p.h \
           $$SK_BARCODE/declarative/WDeclarativeScannerHover.h \
           $$SK_BARCODE/declarative/WDeclarativeScannerHover_p.h \

contains(QT_MAJOR_VERSION, 4) {
    HEADERS += $$SK_GUI/declarative/Qt/qdeclarativemousearea_p.h \
               $$SK_GUI/declarative/Qt/qdeclarativeevents_p_p.h
} else {
    HEADERS += $$SK_GUI/declarative/WDeclarativeTexture.h \
               $$SK_GUI/declarative/WDeclarativeTexture_p.h \
               $$SK_GUI/declarative/WDeclarativeItemPaint.h \
               $$SK_GUI/declarative/WDeclarativeItemPaint_p.h
}

SOURCES += $$SK_GUI/declarative/WDeclarativeApplication.cpp \
           $$SK_GUI/declarative/WDeclarativeItem.cpp \
           $$SK_GUI/declarative/WDeclarativeMouseArea.cpp \
           $$SK_GUI/declarative/WDeclarativeMouseWatcher.cpp \
           $$SK_GUI/declarative/WDeclarativeBorders.cpp \
           $$SK_GUI/declarative/WDeclarativeImageBase.cpp \
           $$SK_GUI/declarative/WDeclarativeImage.cpp \
           $$SK_GUI/declarative/WDeclarativeImageSvg.cpp \
           $$SK_GUI/declarative/WDeclarativeBorderImage.cpp \
           #$$SK_GUI/declarative/WDeclarativeText.cpp \
           $$SK_GUI/declarative/WDeclarativeTextSvg.cpp \
           $$SK_GUI/declarative/WDeclarativeAnimated.cpp \
           $$SK_GUI/declarative/WDeclarativePlayer.cpp \
           $$SK_GUI/declarative/WDeclarativeAmbient.cpp \
           $$SK_GUI/declarative/WDeclarativeListView.cpp \
           $$SK_GUI/declarative/WDeclarativeContextualPage.cpp \
           $$SK_BARCODE/declarative/WDeclarativeScanner.cpp \
           $$SK_BARCODE/declarative/WDeclarativeScannerHover.cpp \

contains(QT_MAJOR_VERSION, 4) {
    SOURCES += $$SK_GUI/declarative/Qt/qdeclarativemousearea.cpp
} else {
    SOURCES += $$SK_GUI/declarative/WDeclarativeTexture.cpp \
               $$SK_GUI/declarative/WDeclarativeItemPaint.cpp
}
