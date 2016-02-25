//=================================================================================================
/*
    Copyright (C) 2015-2016 MotionBox authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of MotionBox.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.
*/
//=================================================================================================

#ifndef DATALOCAL_H
#define DATALOCAL_H

// Sk includes
#include <WLocalObject>
#include <WAbstractBackend>
#include <WDeclarativePlayer>

class DataLocal : public WLocalObject
{
    Q_OBJECT

    Q_PROPERTY(QString version READ version CONSTANT)

    Q_PROPERTY(int screen READ screen CONSTANT)

    Q_PROPERTY(int width  READ width  CONSTANT)
    Q_PROPERTY(int height READ height CONSTANT)

    Q_PROPERTY(int miniX READ miniX CONSTANT)
    Q_PROPERTY(int miniY READ miniY CONSTANT)

    Q_PROPERTY(int miniWidth  READ miniWidth  CONSTANT)
    Q_PROPERTY(int miniHeight READ miniHeight CONSTANT)

    Q_PROPERTY(int splashWidth  READ splashWidth  CONSTANT)
    Q_PROPERTY(int splashHeight READ splashHeight CONSTANT)

    Q_PROPERTY(qreal scale READ scale WRITE setScale NOTIFY scaleChanged)

    Q_PROPERTY(bool maximized READ maximized WRITE setMaximized NOTIFY maximizedChanged)

    Q_PROPERTY(bool micro READ micro WRITE setMicro NOTIFY microChanged)

    Q_PROPERTY(bool expanded READ expanded WRITE setExpanded NOTIFY expandedChanged)
    Q_PROPERTY(bool macro    READ macro    WRITE setMacro    NOTIFY macroChanged)

    Q_PROPERTY(bool related READ related WRITE setRelated NOTIFY relatedChanged)

    Q_PROPERTY(bool relatedExpanded READ relatedExpanded WRITE setRelatedExpanded
               NOTIFY relatedExpandedChanged)

    Q_PROPERTY(bool tracksExpanded READ tracksExpanded WRITE setTracksExpanded
               NOTIFY tracksExpandedChanged)

    Q_PROPERTY(bool panelCoverVisible READ panelCoverVisible WRITE setPanelCoverVisible
               NOTIFY panelCoverVisibleChanged)

    Q_PROPERTY(bool browserVisible READ browserVisible WRITE setBrowserVisible
               NOTIFY browserVisibleChanged)

    Q_PROPERTY(bool typePlaylist READ typePlaylist WRITE setTypePlaylist
               NOTIFY typePlaylistChanged)

    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)

    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)

    Q_PROPERTY(bool shuffle READ shuffle WRITE setShuffle NOTIFY shuffleChanged)

    Q_PROPERTY(WDeclarativePlayer::Repeat repeat READ repeat WRITE setRepeat
               NOTIFY repeatChanged)

    Q_PROPERTY(WAbstractBackend::Quality quality READ quality WRITE setQuality
               NOTIFY qualityChanged)

    Q_PROPERTY(int networkCache READ networkCache WRITE setNetworkCache
               NOTIFY networkCacheChanged)

    Q_PROPERTY(bool cache READ cache WRITE setCache NOTIFY cacheChanged)

    Q_PROPERTY(QString proxyHost READ proxyHost WRITE setProxyHost NOTIFY proxyHostChanged)
    Q_PROPERTY(int     proxyPort READ proxyPort WRITE setProxyPort NOTIFY proxyPortChanged)

    Q_PROPERTY(QString proxyPassword READ proxyPassword WRITE setProxyPassword
               NOTIFY proxyPasswordChanged)

    Q_PROPERTY(bool proxyStream READ proxyStream WRITE setProxyStream NOTIFY proxyStreamChanged)
    Q_PROPERTY(bool proxyActive READ proxyActive WRITE setProxyActive NOTIFY proxyActiveChanged)

public:
    explicit DataLocal(QObject * parent = NULL);

public: // Interface
    Q_INVOKABLE void setSize(int screen, int width, int height);

    Q_INVOKABLE void setMiniPos (int x,     int y);
    Q_INVOKABLE void setMiniSize(int width, int height);

    Q_INVOKABLE void setSplashSize(int width, int height);

public: // WLocalObject reimplementation
    /* Q_INVOKABLE virtual */ bool load(bool instant = false);

    /* Q_INVOKABLE virtual */ QString getFilePath() const;

signals:
    void scaleChanged();

    void maximizedChanged();

    void microChanged();

    void expandedChanged();
    void macroChanged   ();

    void relatedChanged        ();
    void relatedExpandedChanged();

    void tracksExpandedChanged();

    void panelCoverVisibleChanged();

    void browserVisibleChanged();

    void typePlaylistChanged();

    void queryChanged();

    void volumeChanged();

    void shuffleChanged();
    void repeatChanged ();
    void qualityChanged();

    void networkCacheChanged();

    void cacheChanged();

    void proxyHostChanged    ();
    void proxyPortChanged    ();
    void proxyPasswordChanged();

    void proxyStreamChanged();
    void proxyActiveChanged();

protected: // WLocalObject reimplementation
    /* virtual */ WAbstractThreadAction * onSave(const QString & path);

public: // Properties
    QString version() const;

    int screen() const;

    int width () const;
    int height() const;

    int miniX() const;
    int miniY() const;

    int miniWidth () const;
    int miniHeight() const;

    int splashWidth () const;
    int splashHeight() const;

    qreal scale() const;
    void  setScale(qreal scale);

    bool maximized() const;
    void setMaximized(bool maximized);

    bool micro() const;
    void setMicro(bool micro);

    bool expanded() const;
    void setExpanded(bool expanded);

    bool macro() const;
    void setMacro(bool macro);

    bool related() const;
    void setRelated(bool related);

    bool relatedExpanded() const;
    void setRelatedExpanded(bool expanded);

    bool tracksExpanded() const;
    void setTracksExpanded(bool expanded);

    bool panelCoverVisible() const;
    void setPanelCoverVisible(bool visible);

    bool browserVisible() const;
    void setBrowserVisible(bool visible);

    bool typePlaylist() const;
    void setTypePlaylist(bool type);

    QString query() const;
    void    setQuery(const QString & query);

    bool shuffle() const;
    void setShuffle(bool shuffle);

    WDeclarativePlayer::Repeat repeat() const;
    void                       setRepeat(WDeclarativePlayer::Repeat repeat);

    int  volume() const;
    void setVolume(int volume);

    WAbstractBackend::Quality quality() const;
    void                      setQuality(WAbstractBackend::Quality quality);

    int  networkCache() const;
    void setNetworkCache(int index);

    bool cache() const;
    void setCache(bool cache);

    QString proxyHost() const;
    void    setProxyHost(const QString & host);

    int  proxyPort() const;
    void setProxyPort(int port);

    QString proxyPassword() const;
    void    setProxyPassword(const QString & password);

    bool proxyStream() const;
    void setProxyStream(bool stream);

    bool proxyActive() const;
    void setProxyActive(bool active);

private: // Variables
    QString _version;

    int _screen;

    int _width;
    int _height;

    int _miniX;
    int _miniY;

    int _miniWidth;
    int _miniHeight;

    int _splashWidth;
    int _splashHeight;

    qreal _scale;

    bool _maximized;

    bool _micro;

    bool _expanded;
    bool _macro;

    bool _related;
    bool _relatedExpanded;

    bool _tracksExpanded;

    bool _panelCoverVisible;

    bool _browserVisible;

    bool _typePlaylist;

    QString _query;

    int _volume;

    bool                       _shuffle;
    WDeclarativePlayer::Repeat _repeat;
    WAbstractBackend::Quality  _quality;

    int _networkCache;

    bool _cache;

    QString _proxyHost;
    int     _proxyPort;
    QString _proxyPassword;

    bool _proxyStream;
    bool _proxyActive;

private:
    Q_DISABLE_COPY(DataLocal)

    friend class DataLocalWriteReply;
    friend class DataLocalReadReply;
    friend class ControllerCore;
};

#endif // DATALOCAL_H
