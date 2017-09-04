//=================================================================================================
/*
    Copyright (C) 2015-2017 MotionBox authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of MotionBox.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.
*/
//=================================================================================================

#include "DataLocal.h"

// Qt includes
#include <QXmlStreamWriter>
#include <QFile>

// Sk includes
#include <WControllerApplication>
#include <WControllerXml>
#include <WAbstractThreadAction>

//=================================================================================================
// DataLocalWrite and DataLocalWriteReply
//=================================================================================================

class DataLocalWrite : public WAbstractThreadAction
{
    Q_OBJECT

public:
    DataLocalWrite(DataLocal * data)
    {
        this->data = data;

        name    = sk->name   ();
        version = sk->version();
    }

protected: // WAbstractThreadAction reimplementation
    /* virtual */ WAbstractThreadReply * createReply() const;

protected: // WAbstractThreadAction implementation
    /* virtual */ bool run();

public: // Variables
    DataLocal * data;

    QString path;

    QString name;
    QString version;

    int screen;

    int width;
    int height;

    int miniX;
    int miniY;

    int splashWidth;
    int splashHeight;

    qreal scale;

    bool maximized;

    bool micro;

    bool expanded;
    bool macro;

    bool related;
    bool relatedExpanded;

    bool tracksExpanded;

    bool panelCoverVisible;

    bool browserVisible;

    bool typePlaylist;

    QString query;

    qreal speed;

    qreal volume;

    bool                       shuffle;
    WDeclarativePlayer::Repeat repeat;

    WAbstractBackend::Output  output;
    WAbstractBackend::Quality quality;

    int networkCache;

    bool cache;

    QString proxyHost;
    int     proxyPort;
    QString proxyPassword;

    bool proxyStream;
    bool proxyActive;

    int torrentConnections;

    int torrentUpload;
    int torrentDownload;

    bool torrentUploadActive;
    bool torrentDownloadActive;

    int torrentCache;
};

//=================================================================================================
// DataLocalWrite
//=================================================================================================

/* virtual */ WAbstractThreadReply * DataLocalWrite::createReply() const
{
    return new WLocalObjectReplySave(data);
}

/* virtual */ bool DataLocalWrite::run()
{
    QFile file(path);

    if (file.open(QIODevice::WriteOnly) == false)
    {
        qWarning("DataLocalWrite::run: Failed to open file %s.", path.C_STR);

        return false;
    }

    QXmlStreamWriter stream(&file);

    stream.setAutoFormatting(true);

    stream.writeStartDocument();

    stream.writeStartElement(name);

    stream.writeTextElement("version", version);

    stream.writeTextElement("screen", QString::number(screen));

    stream.writeTextElement("width",  QString::number(width));
    stream.writeTextElement("height", QString::number(height));

    stream.writeTextElement("miniX", QString::number(miniX));
    stream.writeTextElement("miniY", QString::number(miniY));

    stream.writeTextElement("splashWidth",  QString::number(splashWidth));
    stream.writeTextElement("splashHeight", QString::number(splashHeight));

    stream.writeTextElement("scale", QString::number(scale));

    stream.writeTextElement("maximized", QString::number(maximized));

    stream.writeTextElement("micro", QString::number(micro));

    stream.writeTextElement("expanded", QString::number(expanded));
    stream.writeTextElement("macro",    QString::number(macro));

    stream.writeTextElement("related",         QString::number(related));
    stream.writeTextElement("relatedExpanded", QString::number(relatedExpanded));

    stream.writeTextElement("tracksExpanded", QString::number(tracksExpanded));

    stream.writeTextElement("panelCoverVisible", QString::number(panelCoverVisible));

    stream.writeTextElement("browserVisible", QString::number(browserVisible));

    stream.writeTextElement("typePlaylist", QString::number(typePlaylist));

    stream.writeTextElement("query", query);

    stream.writeTextElement("speed", QString::number(speed));

    stream.writeTextElement("volume", QString::number(volume));

    stream.writeTextElement("shuffle", QString::number(shuffle));
    stream.writeTextElement("repeat",  QString::number(repeat));

    stream.writeTextElement("output",  QString::number(output));
    stream.writeTextElement("quality", QString::number(quality));

    stream.writeTextElement("networkCache", QString::number(networkCache));

    stream.writeTextElement("cache", QString::number(cache));

    stream.writeTextElement("proxyHost",     proxyHost);
    stream.writeTextElement("proxyPort",     QString::number(proxyPort));
    stream.writeTextElement("proxyPassword", proxyPassword);

    stream.writeTextElement("proxyStream", QString::number(proxyStream));
    stream.writeTextElement("proxyActive", QString::number(proxyActive));

    stream.writeTextElement("torrentConnections", QString::number(torrentConnections));

    stream.writeTextElement("torrentUpload",   QString::number(torrentUpload));
    stream.writeTextElement("torrentDownload", QString::number(torrentDownload));

    stream.writeTextElement("torrentUploadActive",   QString::number(torrentUploadActive));
    stream.writeTextElement("torrentDownloadActive", QString::number(torrentDownloadActive));

    stream.writeTextElement("torrentCache", QString::number(torrentCache));

    stream.writeEndElement(); // name

    stream.writeEndDocument();

    qDebug("DATA LOCAL SAVED");

    return true;
}

//=================================================================================================
// DataLocal
//=================================================================================================

/* explicit */ DataLocal::DataLocal(QObject * parent) : WLocalObject(parent)
{
    _screen = -1;

    _width  = -1;
    _height = -1;

    _miniX = -1;
    _miniY = -1;

    _splashWidth  = -1;
    _splashHeight = -1;

    _scale = 1.0;

    _maximized = false;

    _micro = false;

    _expanded = false;
    _macro    = false;

    _related         = false;
    _relatedExpanded = false;

    _tracksExpanded = false;

    _panelCoverVisible = false;

    _browserVisible = false;

    _typePlaylist = false;

    _speed = 1.0;

    _volume = 1.0;

    _shuffle = false;
    _repeat  = WDeclarativePlayer::RepeatNone;

    _output  = WAbstractBackend::OutputMedia;
    _quality = WAbstractBackend::QualityHigh;

    _networkCache = 1;

    _cache = false;

    _proxyPort = -1;

    _proxyStream = false;
    _proxyActive = false;

    _torrentConnections = 500;

    _torrentUpload   = 0;
    _torrentDownload = 0;

    _torrentUploadActive   = false;
    _torrentDownloadActive = false;

    _torrentCache = 1000;
}

//-------------------------------------------------------------------------------------------------
// Interface
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void DataLocal::setSize(int screen, int width, int height)
{
    _screen = screen;

    _width  = width;
    _height = height;
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void DataLocal::setMiniPos(int x, int y)
{
    _miniX = x;
    _miniY = y;
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void DataLocal::setSplashSize(int width, int height)
{
    _splashWidth  = width;
    _splashHeight = height;
}

//-------------------------------------------------------------------------------------------------
// WLocalObject reimplementation
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE virtual */ bool DataLocal::load(bool)
{
    QString path = getFilePath();

    QFile file(path);

    if (file.exists() == false) return false;

    if (file.open(QIODevice::ReadOnly) == false)
    {
        qWarning("DataLocal::load: Failed to open file %s.", path.C_STR);

        return false;
    }

    QXmlStreamReader stream(&file);

    //---------------------------------------------------------------------------------------------
    // version

    if (wControllerXml->readNextStartElement(&stream, "version") == false) return false;

    _version = wControllerXml->readNextString(&stream);

    //---------------------------------------------------------------------------------------------
    // screen

    if (wControllerXml->readNextStartElement(&stream, "screen") == false) return false;

    _screen = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // width

    if (wControllerXml->readNextStartElement(&stream, "width") == false) return false;

    _width = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // height

    if (wControllerXml->readNextStartElement(&stream, "height") == false) return false;

    _height = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // miniX

    if (wControllerXml->readNextStartElement(&stream, "miniX") == false) return false;

    _miniX = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // miniY

    if (wControllerXml->readNextStartElement(&stream, "miniY") == false) return false;

    _miniY = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // splashWidth

    if (wControllerXml->readNextStartElement(&stream, "splashWidth") == false) return false;

    _splashWidth = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // splashHeight

    if (wControllerXml->readNextStartElement(&stream, "splashHeight") == false) return false;

    _splashHeight = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // scale

    if (wControllerXml->readNextStartElement(&stream, "scale") == false) return false;

    _scale = wControllerXml->readNextFloat(&stream);

    //---------------------------------------------------------------------------------------------
    // maximized

    if (wControllerXml->readNextStartElement(&stream, "maximized") == false) return false;

    _maximized = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // micro

    if (wControllerXml->readNextStartElement(&stream, "micro") == false) return false;

    _micro = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // expanded

    if (wControllerXml->readNextStartElement(&stream, "expanded") == false) return false;

    _expanded = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // macro

    if (wControllerXml->readNextStartElement(&stream, "macro") == false) return false;

    _macro = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // related

    if (wControllerXml->readNextStartElement(&stream, "related") == false) return false;

    _related = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // relatedExpanded

    if (wControllerXml->readNextStartElement(&stream, "relatedExpanded") == false) return false;

    _relatedExpanded = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // tracksExpanded

    if (wControllerXml->readNextStartElement(&stream, "tracksExpanded") == false) return false;

    _tracksExpanded = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // panelCoverVisible

    if (wControllerXml->readNextStartElement(&stream, "panelCoverVisible") == false) return false;

    _panelCoverVisible = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // browserVisible

    if (wControllerXml->readNextStartElement(&stream, "browserVisible") == false) return false;

    _browserVisible = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // typePlaylist

    if (wControllerXml->readNextStartElement(&stream, "typePlaylist") == false) return false;

    _typePlaylist = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // query

    if (wControllerXml->readNextStartElement(&stream, "query") == false) return false;

    _query = wControllerXml->readNextString(&stream);

    //---------------------------------------------------------------------------------------------
    // speed

    if (wControllerXml->readNextStartElement(&stream, "speed") == false) return false;

    _speed = wControllerXml->readNextFloat(&stream);

    //---------------------------------------------------------------------------------------------
    // volume

    if (wControllerXml->readNextStartElement(&stream, "volume") == false) return false;

    _volume = wControllerXml->readNextFloat(&stream);

    //---------------------------------------------------------------------------------------------
    // shuffle

    if (wControllerXml->readNextStartElement(&stream, "shuffle") == false) return false;

    _shuffle = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // repeat

    if (wControllerXml->readNextStartElement(&stream, "repeat") == false) return false;

    _repeat = static_cast<WDeclarativePlayer::Repeat> (wControllerXml->readNextInt(&stream));

    //---------------------------------------------------------------------------------------------
    // output

    if (wControllerXml->readNextStartElement(&stream, "output") == false) return false;

    _output = static_cast<WAbstractBackend::Output> (wControllerXml->readNextInt(&stream));

    //---------------------------------------------------------------------------------------------
    // quality

    if (wControllerXml->readNextStartElement(&stream, "quality") == false) return false;

    _quality = static_cast<WAbstractBackend::Quality> (wControllerXml->readNextInt(&stream));

    //---------------------------------------------------------------------------------------------
    // networkCache

    if (wControllerXml->readNextStartElement(&stream, "networkCache") == false) return false;

    _networkCache = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // cache

    if (wControllerXml->readNextStartElement(&stream, "cache") == false) return false;

    _cache = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // proxyHost

    if (wControllerXml->readNextStartElement(&stream, "proxyHost") == false) return false;

    _proxyHost = wControllerXml->readNextString(&stream);

    //---------------------------------------------------------------------------------------------
    // proxyPort

    if (wControllerXml->readNextStartElement(&stream, "proxyPort") == false) return false;

    _proxyPort = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // proxyPassword

    if (wControllerXml->readNextStartElement(&stream, "proxyPassword") == false) return false;

    _proxyPassword = wControllerXml->readNextString(&stream);

    //---------------------------------------------------------------------------------------------
    // proxyStream

    if (wControllerXml->readNextStartElement(&stream, "proxyStream") == false) return false;

    _proxyStream = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // proxyActive

    if (wControllerXml->readNextStartElement(&stream, "proxyActive") == false) return false;

    _proxyActive = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // torrentConnections

    if (wControllerXml->readNextStartElement(&stream, "torrentConnections") == false) return false;

    _torrentConnections = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // torrentUpload

    if (wControllerXml->readNextStartElement(&stream, "torrentUpload") == false) return false;

    _torrentUpload = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // torrentDownload

    if (wControllerXml->readNextStartElement(&stream, "torrentDownload") == false) return false;

    _torrentDownload = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // torrentUploadActive

    if (wControllerXml->readNextStartElement(&stream, "torrentUploadActive") == false)
    {
        return false;
    }

    _torrentUploadActive = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // torrentDownloadActive

    if (wControllerXml->readNextStartElement(&stream, "torrentDownloadActive") == false)
    {
        return false;
    }

    _torrentDownloadActive = wControllerXml->readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // torrentCache

    if (wControllerXml->readNextStartElement(&stream, "torrentCache") == false) return false;

    _torrentCache = wControllerXml->readNextInt(&stream);

    qDebug("DATA LOCAL LOADED");

    return true;
}

/* Q_INVOKABLE virtual */ QString DataLocal::getFilePath() const
{
    return getParentPath() + "/data.xml";
}

//-------------------------------------------------------------------------------------------------
// Protected WLocalObject reimplementation
//-------------------------------------------------------------------------------------------------

/* virtual */ WAbstractThreadAction * DataLocal::onSave(const QString & path)
{
    DataLocalWrite * action = new DataLocalWrite(this);

    action->path = path;

    action->screen = _screen;

    action->width  = _width;
    action->height = _height;

    action->miniX = _miniX;
    action->miniY = _miniY;

    action->splashWidth  = _splashWidth;
    action->splashHeight = _splashHeight;

    action->scale = _scale;

    action->maximized = _maximized;

    action->micro = _micro;

    action->expanded = _expanded;
    action->macro    = _macro;

    action->related         = _related;
    action->relatedExpanded = _relatedExpanded;

    action->tracksExpanded = _tracksExpanded;

    action->panelCoverVisible = _panelCoverVisible;

    action->browserVisible = _browserVisible;

    action->typePlaylist = _typePlaylist;

    action->query = _query;

    action->speed = _speed;

    action->volume = _volume;

    action->shuffle = _shuffle;
    action->repeat  = _repeat;

    action->output  = _output;
    action->quality = _quality;

    action->networkCache = _networkCache;

    action->cache = _cache;

    action->proxyHost     = _proxyHost;
    action->proxyPort     = _proxyPort;
    action->proxyPassword = _proxyPassword;

    action->proxyStream = _proxyStream;
    action->proxyActive = _proxyActive;

    action->torrentConnections = _torrentConnections;

    action->torrentUpload   = _torrentUpload;
    action->torrentDownload = _torrentDownload;

    action->torrentUploadActive   = _torrentUploadActive;
    action->torrentDownloadActive = _torrentDownloadActive;

    action->torrentCache = _torrentCache;

    return action;
}

//-------------------------------------------------------------------------------------------------
// Properties
//-------------------------------------------------------------------------------------------------

QString DataLocal::version() const
{
    return _version;
}

//-------------------------------------------------------------------------------------------------

int DataLocal::screen() const
{
    return _screen;
}

//-------------------------------------------------------------------------------------------------

int DataLocal::width() const
{
    return _width;
}

int DataLocal::height() const
{
    return _height;
}

//-------------------------------------------------------------------------------------------------

int DataLocal::miniX() const
{
    return _miniX;
}

int DataLocal::miniY() const
{
    return _miniY;
}

//-------------------------------------------------------------------------------------------------

int DataLocal::splashWidth() const
{
    return _splashWidth;
}

int DataLocal::splashHeight() const
{
    return _splashHeight;
}

//-------------------------------------------------------------------------------------------------

qreal DataLocal::scale() const
{
    return _scale;
}

void DataLocal::setScale(qreal scale)
{
    _scale = scale;

    emit scaleChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

bool DataLocal::maximized() const
{
    return _maximized;
}

void DataLocal::setMaximized(bool maximized)
{
    if (_maximized == maximized) return;

    _maximized = maximized;

    emit maximizedChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

bool DataLocal::micro() const
{
    return _micro;
}

void DataLocal::setMicro(bool micro)
{
    if (_micro == micro) return;

    _micro = micro;

    emit microChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

bool DataLocal::expanded() const
{
    return _expanded;
}

void DataLocal::setExpanded(bool expanded)
{
    if (_expanded == expanded) return;

    _expanded = expanded;

    emit expandedChanged();

    save();
}

bool DataLocal::macro() const
{
    return _macro;
}

void DataLocal::setMacro(bool macro)
{
    if (_macro == macro) return;

    _macro = macro;

    emit macroChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

bool DataLocal::related() const
{
    return _related;
}

void DataLocal::setRelated(bool related)
{
    if (_related == related) return;

    _related = related;

    emit relatedChanged();

    save();
}

bool DataLocal::relatedExpanded() const
{
    return _relatedExpanded;
}

void DataLocal::setRelatedExpanded(bool expanded)
{
    if (_relatedExpanded == expanded) return;

    _relatedExpanded = expanded;

    emit relatedExpandedChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

bool DataLocal::tracksExpanded() const
{
    return _tracksExpanded;
}

void DataLocal::setTracksExpanded(bool expanded)
{
    if (_tracksExpanded == expanded) return;

    _tracksExpanded = expanded;

    emit tracksExpandedChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

bool DataLocal::panelCoverVisible() const
{
    return _panelCoverVisible;
}

void DataLocal::setPanelCoverVisible(bool visible)
{
    if (_panelCoverVisible == visible) return;

    _panelCoverVisible = visible;

    emit panelCoverVisibleChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

bool DataLocal::browserVisible() const
{
    return _browserVisible;
}

void DataLocal::setBrowserVisible(bool visible)
{
    if (_browserVisible == visible) return;

    _browserVisible = visible;

    emit browserVisibleChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

bool DataLocal::typePlaylist() const
{
    return _typePlaylist;
}

void DataLocal::setTypePlaylist(bool type)
{
    if (_typePlaylist == type) return;

    _typePlaylist = type;

    emit typePlaylistChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

QString DataLocal::query() const
{
    return _query;
}

void DataLocal::setQuery(const QString & query)
{
    QString string = query.simplified();

    if (_query == string) return;

    _query = string;

    emit queryChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

qreal DataLocal::speed() const
{
    return _speed;
}

void DataLocal::setSpeed(qreal speed)
{
    if (_speed == speed) return;

    _speed = speed;

    emit speedChanged();
}

//-------------------------------------------------------------------------------------------------

qreal DataLocal::volume() const
{
    return _volume;
}

void DataLocal::setVolume(qreal volume)
{
    if (_volume == volume) return;

    _volume = volume;

    emit volumeChanged();
}

//-------------------------------------------------------------------------------------------------

bool DataLocal::shuffle() const
{
    return _shuffle;
}

void DataLocal::setShuffle(bool shuffle)
{
    if (_shuffle == shuffle) return;

    _shuffle = shuffle;

    emit shuffleChanged();

    save();
}

WDeclarativePlayer::Repeat DataLocal::repeat() const
{
    return _repeat;
}

void DataLocal::setRepeat(WDeclarativePlayer::Repeat repeat)
{
    if (_repeat == repeat) return;

    _repeat = repeat;

    emit repeatChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

WAbstractBackend::Output DataLocal::output() const
{
    return _output;
}

void DataLocal::setOutput(WAbstractBackend::Output output)
{
    if (_output == output) return;

    _output = output;

    emit outputChanged();

    save();
}

WAbstractBackend::Quality DataLocal::quality() const
{
    return _quality;
}

void DataLocal::setQuality(WAbstractBackend::Quality quality)
{
    if (_quality == quality) return;

    _quality = quality;

    emit qualityChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

int DataLocal::networkCache() const
{
    return _networkCache;
}

void DataLocal::setNetworkCache(int index)
{
    _networkCache = index;

    emit networkCacheChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

bool DataLocal::cache() const
{
    return _cache;
}

void DataLocal::setCache(bool cache)
{
    if (_cache == cache) return;

    _cache = cache;

    emit cacheChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

QString DataLocal::proxyHost() const
{
    return _proxyHost;
}

void DataLocal::setProxyHost(const QString & host)
{
    if (_proxyHost == host) return;

    _proxyHost = host;

    emit proxyHostChanged();

    save();
}

int DataLocal::proxyPort() const
{
    return _proxyPort;
}

void DataLocal::setProxyPort(int port)
{
    if (_proxyPort == port) return;

    _proxyPort = port;

    emit proxyPortChanged();

    save();
}

QString DataLocal::proxyPassword() const
{
    return _proxyPassword;
}

void DataLocal::setProxyPassword(const QString & password)
{
    if (_proxyPassword == password) return;

    _proxyPassword = password;

    emit proxyPasswordChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

bool DataLocal::proxyStream() const
{
    return _proxyStream;
}

void DataLocal::setProxyStream(bool stream)
{
    if (_proxyStream == stream) return;

    _proxyStream = stream;

    emit proxyStreamChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

bool DataLocal::proxyActive() const
{
    return _proxyActive;
}

void DataLocal::setProxyActive(bool active)
{
    if (_proxyActive == active) return;

    _proxyActive = active;

    emit proxyActiveChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

int DataLocal::torrentConnections() const
{
    return _torrentConnections;
}

void DataLocal::setTorrentConnections(int connections)
{
    if (_torrentConnections == connections) return;

    _torrentConnections = connections;

    emit torrentConnectionsChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

int DataLocal::torrentUpload() const
{
    return _torrentUpload;
}

void DataLocal::setTorrentUpload(int upload)
{
    if (_torrentUpload == upload) return;

    _torrentUpload = upload;

    emit torrentUploadChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

int DataLocal::torrentDownload() const
{
    return _torrentDownload;
}

void DataLocal::setTorrentDownload(int download)
{
    if (_torrentDownload == download) return;

    _torrentDownload = download;

    emit torrentDownloadChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

bool DataLocal::torrentUploadActive() const
{
    return _torrentUploadActive;
}

void DataLocal::setTorrentUploadActive(bool active)
{
    if (_torrentUploadActive == active) return;

    _torrentUploadActive = active;

    emit torrentUploadActiveChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

bool DataLocal::torrentDownloadActive() const
{
    return _torrentDownloadActive;
}

void DataLocal::setTorrentDownloadActive(bool active)
{
    if (_torrentDownloadActive == active) return;

    _torrentDownloadActive = active;

    emit torrentDownloadActiveChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

int DataLocal::torrentCache() const
{
    return _torrentCache;
}

void DataLocal::setTorrentCache(int cache)
{
    if (_torrentCache == cache) return;

    _torrentCache = cache;

    emit torrentCacheChanged();

    save();
}

#include "DataLocal.moc"
