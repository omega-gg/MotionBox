# Kernel module

HEADERS += $$SK_CORE/kernel/WCoreApplication.h \
           $$SK_CORE/kernel/WCrypter.h \
           $$SK_CORE/kernel/WListId.h \
           $$SK_CORE/kernel/WRegExp.h \
           $$SK_GUI/kernel/WApplication.h \
           $$SK_GUI/kernel/WAbstractTabs.h \
           $$SK_GUI/kernel/WAbstractTabs_p.h \
           $$SK_GUI/kernel/WAbstractTab.h \
           $$SK_GUI/kernel/WAbstractTab_p.h \
           $$SK_GUI/kernel/WActionCue.h \
           $$SK_GUI/kernel/WActionCue_p.h \
           $$SK_GUI/kernel/WInputCue.h \
           $$SK_GUI/kernel/WInputCue_p.h \

greaterThan(QT_MAJOR_VERSION, 5): HEADERS += $$SK_CORE/kernel/WList.h \

SOURCES += $$SK_CORE/kernel/WCoreApplication.cpp \
           $$SK_CORE/kernel/WCrypter.cpp \
           $$SK_CORE/kernel/WListId.cpp \
           $$SK_CORE/kernel/WRegExp.cpp \
           $$SK_GUI/kernel/WApplication.cpp \
           $$SK_GUI/kernel/WAbstractTabs.cpp \
           $$SK_GUI/kernel/WAbstractTab.cpp \
           $$SK_GUI/kernel/WActionCue.cpp \
           $$SK_GUI/kernel/WInputCue.cpp \
