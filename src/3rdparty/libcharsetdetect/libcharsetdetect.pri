# libcharsetdetect module

INCLUDEPATH += $$SK_CORE/3rdparty/libcharsetdetect \
               $$SK_CORE/3rdparty/libcharsetdetect/base \
               $$SK_CORE/3rdparty/libcharsetdetect/nspr-emu \

HEADERS += $$SK_CORE/3rdparty/libcharsetdetect/charsetdetect.h \
           $$SK_CORE/3rdparty/libcharsetdetect/charsetdetectPriv.h \
           $$SK_CORE/3rdparty/libcharsetdetect/nscore.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/CharDistribution.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/JpCntx.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsBig5Prober.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsCharSetProber.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsCodingStateMachine.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsEscCharsetProber.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsEUCJPProber.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsEUCKRProber.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsEUCTWProber.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsGB2312Prober.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsHebrewProber.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsLatin1Prober.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsMBCSGroupProber.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsPkgInt.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsSBCharSetProber.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsSBCSGroupProber.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsSJISProber.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsUniversalDetector.h \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsUTF8Prober.h \
           $$SK_CORE/3rdparty/libcharsetdetect/nspr-emu/nsDebug.h \
           $$SK_CORE/3rdparty/libcharsetdetect/nspr-emu/prcpucfg.h \
           $$SK_CORE/3rdparty/libcharsetdetect/nspr-emu/prcpucfg_freebsd.h \
           $$SK_CORE/3rdparty/libcharsetdetect/nspr-emu/prcpucfg_linux.h \
           $$SK_CORE/3rdparty/libcharsetdetect/nspr-emu/prcpucfg_mac.h \
           $$SK_CORE/3rdparty/libcharsetdetect/nspr-emu/prcpucfg_openbsd.h \
           $$SK_CORE/3rdparty/libcharsetdetect/nspr-emu/prcpucfg_win.h \
           $$SK_CORE/3rdparty/libcharsetdetect/nspr-emu/prmem.h \
           $$SK_CORE/3rdparty/libcharsetdetect/nspr-emu/prtypes.h \
           $$SK_CORE/3rdparty/libcharsetdetect/nspr-emu/obsolete/protypes.h \

SOURCES += $$SK_CORE/3rdparty/libcharsetdetect/charsetdetect.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/CharDistribution.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/JpCntx.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/LangBulgarianModel.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/LangCyrillicModel.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/LangGreekModel.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/LangHebrewModel.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/LangHungarianModel.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/LangThaiModel.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsBig5Prober.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsCharSetProber.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsEscCharsetProber.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsEscSM.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsEUCJPProber.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsEUCKRProber.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsEUCTWProber.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsGB2312Prober.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsHebrewProber.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsLatin1Prober.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsMBCSGroupProber.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsMBCSSM.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsSBCharSetProber.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsSBCSGroupProber.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsSJISProber.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsUniversalDetector.cpp \
           $$SK_CORE/3rdparty/libcharsetdetect/base/nsUTF8Prober.cpp \
