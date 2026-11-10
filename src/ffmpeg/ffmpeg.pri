# FFmpeg module

HEADERS += $$SK_MEDIA/ffmpeg/WFfmpegPlayer.h \
           $$SK_MEDIA/ffmpeg/WFfmpegPlayer_p.h \
           $$SK_MEDIA/ffmpeg/WFfmpegDownload.h \
           $$SK_MEDIA/ffmpeg/WFfmpegDownload_p.h \
           $$SK_MEDIA/media/WMediaDownload.h \
           $$SK_MEDIA/media/WMediaDownload_p.h \
           $$SK_MEDIA/media/WBackendFfmpeg.h \
           $$SK_MEDIA/media/WBackendFfmpeg_p.h \

SOURCES += $$SK_MEDIA/ffmpeg/WFfmpegPlayer.cpp \
           $$SK_MEDIA/ffmpeg/WFfmpegDownload.cpp \
           $$SK_MEDIA/media/WMediaDownload.cpp \
           $$SK_MEDIA/media/WBackendFfmpeg.cpp \
