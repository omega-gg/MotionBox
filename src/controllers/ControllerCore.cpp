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

#include "ControllerCore.h"

// C++ includes
#include <iostream>

// Qt includes
#ifdef QT_4
#include <QCoreApplication>
#include <QDeclarativeEngine>
#else
#include <QQmlEngine>
#endif
//#include <QNetworkDiskCache>
#include <QProcess>
#include <QFileDialog>
#ifdef SK_DEPLOY
#include <QDir>
#ifdef QT_4
#include <QDesktopServices>
#else
#include <QStandardPaths>
#endif
#endif

// Sk includes
#include <WControllerApplication>
#include <WControllerDeclarative>
#include <WControllerView>
#include <WControllerFile>
#include <WControllerNetwork>
#include <WControllerDownload>
#include <WControllerPlaylist>
#include <WControllerMedia>
#include <WControllerTorrent>
#include <WWindow>
#include <WCache>
#include <WLoaderNetwork>
//#include <WLoaderWeb>
#include <WLoaderTorrent>
#include <WHookTorrent>
#include <WLibraryFolderRelated>
#include <WTabsTrack>
#include <WTabTrack>
#include <WBackendIndex>
#include <WBackendUniversal>
//#include <WBackendTorrent>
//#include <WBackendDuckDuckGo>
//#include <WBackendTmdb>
//#include <WBackendLastFm>
//#include <WBackendYoutube>
//#include <WBackendDailymotion>
//#include <WBackendVimeo>
//#include <WBackendSoundCloud>
//#include <WBackendOpenSubtitles>

// Application includes
#include "DataLocal.h"
#include "DataOnline.h"

W_INIT_CONTROLLER(ControllerCore)

//-------------------------------------------------------------------------------------------------
// Static variables

static const QString CORE_VERSION = "1.5.0-5";

static const int LOG_LENGTH = 4000;

#ifndef SK_DEPLOY
static const QString PATH_BACKEND = "../../backend";
#endif

//-------------------------------------------------------------------------------------------------
// Functions
//-------------------------------------------------------------------------------------------------

#ifdef QT_4
void messageOutput(QtMsgType, const char * message)
#else
void messageOutput(QtMsgType, const QMessageLogContext &, const QString & message)
#endif
{
    core->addLog(message);

#ifdef QT_4
    std::cout << message << std::endl;
#else
    std::cout << message.toLatin1().constData() << std::endl;
#endif
}

//=================================================================================================
// ShotWrite
//=================================================================================================

class ShotWrite : public WAbstractThreadAction
{
    Q_OBJECT

public:
    ShotWrite(const QImage & image, const QString & fileName)
    {
        this->image    = image;
        this->fileName = fileName;
    }

protected: // WAbstractThreadAction implementation
    /* virtual */ bool run();

public: // Variables
    QImage image;

    QString fileName;
};

/* virtual */ bool ShotWrite::run()
{
    return image.save(fileName, "png");
}

//=================================================================================================
// ControllerCore
//=================================================================================================
// Private ctor / dtor

ControllerCore::ControllerCore() : WController()
{
    _cache = NULL;

    //_diskCache = NULL;

    _tabs = NULL;

    _library  = NULL;
    _feeds    = NULL;
    _backends = NULL;
    _related  = NULL;

    _loaderMedia = NULL;
    //_loaderWeb   = NULL;

    _index = NULL;

    //---------------------------------------------------------------------------------------------
    // Settings

    sk->setName("MotionBox");

#ifdef Q_OS_LINUX
    sk->setIcon(":/qrc/pictures/icons/icon.svg");
#endif

#ifdef SK_DEPLOY
#ifdef QT_4
    QString path = QDesktopServices::storageLocation(QDesktopServices::DataLocation);
#else
    QString path = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
#endif

    wControllerFile->setPathStorage(QDir::fromNativeSeparators(path));
#else
    QString path = QDir::currentPath() + "/storage";

    wControllerFile->setPathStorage(path);
#endif

    wControllerView->setLoadMode(WControllerView::LoadVisible);

    //---------------------------------------------------------------------------------------------
    // DataLocal

    _local = new DataLocal(this);

    _local->setSaveEnabled(true);

    _local->load(true);

    sk->setVersion(CORE_VERSION);

    if (_local->_maximized)
    {
        sk->setDefaultMode(Sk::Maximized);
    }

    sk->setDefaultScreen(_local->_screen);

    sk->setDefaultWidth (_local->_width);
    sk->setDefaultHeight(_local->_height);

    if (_local->_version != CORE_VERSION)
    {
        deleteBrowse();
    }
    else if (_local->_splashWidth != -1)
    {
        _pathSplash = WControllerFile::fileUrl(path + "/splash.png");
    }

    //---------------------------------------------------------------------------------------------
    // QML

    qmlRegisterType<DataLocal>("Sky", 1,0, "DataLocal");

    wControllerDeclarative->setContextProperty("core", this);

    wControllerDeclarative->setContextProperty("local", _local);
}

/* virtual */ ControllerCore::~ControllerCore()
{
#ifdef QT_4
    qInstallMsgHandler(NULL);
#else
    qInstallMessageHandler(NULL);
#endif
}

//-------------------------------------------------------------------------------------------------
// Interface
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::load()
{
    if (_cache) return;

    _pathOpen = QDir::rootPath();

    //---------------------------------------------------------------------------------------------
    // Controllers

    QString path = pathStorage();

    W_CREATE_CONTROLLER(WControllerPlaylist);
    W_CREATE_CONTROLLER(WControllerMedia);

    W_CREATE_CONTROLLER_1(WControllerTorrent, path + "/torrents");

    //---------------------------------------------------------------------------------------------
    // Backends

    //new WBackendTorrent;

    //new WBackendDuckDuckGo;
    //new WBackendTmdb;
    //new WBackendLastFm;

    //new WBackendYoutube;
    //new WBackendDailymotion;
    //new WBackendVimeo;
    //new WBackendSoundCloud;

    //new WBackendOpenSubtitles;

    //---------------------------------------------------------------------------------------------
    // Cache

    _cache = new WCache(path + "/cache", 1048576 * 100); // 100 megabytes

    wControllerFile->setCache(_cache);

    connect(_cache, SIGNAL(emptyChanged()), this, SIGNAL(cacheEmptyChanged()));

    //---------------------------------------------------------------------------------------------
    // DiskCache

    /*_diskCache = new QNetworkDiskCache(this);

    _diskCache->setCacheDirectory(path + "/cache/web");*/

    //---------------------------------------------------------------------------------------------
    // LoaderWeb

    /*_loaderWeb = new WLoaderWeb(this);

    _loaderWeb->setCache(_diskCache);

    wControllerPlaylist->registerLoader(WBackendNetQuery::TypeWeb, _loaderWeb);*/

    //---------------------------------------------------------------------------------------------
    // LoaderTorrent

    WLoaderTorrent * loaderTorrent = new WLoaderTorrent(this);

    wControllerPlaylist->registerLoader(WBackendNetQuery::TypeTorrent, loaderTorrent);
    wControllerTorrent ->registerLoader(WBackendNetQuery::TypeTorrent, loaderTorrent);

    //---------------------------------------------------------------------------------------------
    // Proxy

    applyProxy(_local->_proxyActive);

    //---------------------------------------------------------------------------------------------
    // Torrents

    applyTorrentOptions(_local->_torrentConnections,
                        _local->_torrentUpload, _local->_torrentDownload, _local->_torrentCache);

    //---------------------------------------------------------------------------------------------
    // Tabs

    _tabs = new WTabsTrack(this);

    _tabs->setId(1);

    _tabs->setMaxCount(32);

    _tabs->addTab();

    _tabs->setSaveEnabled(true);

    if (_tabs->load() == false)
    {
        _tabs->save();
    }

    //---------------------------------------------------------------------------------------------
    // Library

    _library = createLibrary(1);

    emit libraryChanged();

    //---------------------------------------------------------------------------------------------
    // Feeds

    _feeds = createLibrary(2);

    _feeds->setMaxCount(100);

    emit feedsChanged();

    //---------------------------------------------------------------------------------------------
    // Backends

    _backends = new WLibraryFolder;

    _backends->setParent(this);

    _backends->setId(3);

    _backends->setSaveEnabled(true);

    if (_backends->load() == false)
    {
        createBrowse();

        copyBackends(path + "/backend/");
    }
    else _index = new WBackendIndex(WControllerFile::fileUrl(path + "/backend"));

    emit backendsChanged();

    //---------------------------------------------------------------------------------------------
    // Related

    _related = new WLibraryFolderRelated;

    _related->setParent(this);

    _related->setId(4);

    _related->setSaveEnabled(true);

    _related->load();

    emit relatedChanged();

    //---------------------------------------------------------------------------------------------
    // Network

    wControllerNetwork->setCheckConnected(true);

    //---------------------------------------------------------------------------------------------
    // DataOnline

    _online = new DataOnline(this);

    //---------------------------------------------------------------------------------------------
    // QML

    qmlRegisterType<DataOnline>("Sky", 1,0, "DataOnline");

    wControllerDeclarative->setContextProperty("controllerPlaylist", wControllerPlaylist);

    wControllerDeclarative->setContextProperty("online", _online);

    //---------------------------------------------------------------------------------------------
    // Message handler

#ifdef QT_4
    qInstallMsgHandler(messageOutput);
#else
    qInstallMessageHandler(messageOutput);
#endif

    //---------------------------------------------------------------------------------------------

    startTimer(60000); // 1 minute

    _local->setSplashSize(-1, -1);

    _local->save();
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ bool ControllerCore::updateVersion()
{
    if (_online->_version.isEmpty() || _online->_version == CORE_VERSION) return false;

#ifdef Q_OS_WIN
    QString path = QCoreApplication::applicationDirPath() + "/setup.exe";
#else
    QString path = QCoreApplication::applicationDirPath() + "/setup";
#endif

    if (WControllerFile::tryAppend(WControllerFile::fileUrl(path)))
    {
        if (QProcess::startDetached(Sk::quote(path), QStringList("--updater")) == false)
        {
            return false;
        }
    }
    else if (Sk::runAdmin(path, "--updater") == false)
    {
        return false;
    }

    _online->_version = QString();

    return true;
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::reloadBackends() const
{
    WBackendLoader::reloadBackends();
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ QString ControllerCore::openFile(const QString & title)
{
    return getFile(title, WControllerPlaylist::getFilterFile());
}

/* Q_INVOKABLE */ QString ControllerCore::openFolder(const QString & title)
{
    QString path = QFileDialog::getExistingDirectory(NULL, title, _pathOpen);

    if (path.isEmpty()) return QString();

    QFileInfo info(path);

    _pathOpen = info.absoluteFilePath();

    return WControllerFile::fileUrl(_pathOpen);
}

/* Q_INVOKABLE */ QString ControllerCore::openSubtitle(const QString & title)
{
    return getFile(title, WControllerPlaylist::getFilterSubtitle());
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::saveShot(WWindow * window) const
{
    QImage image = window->takeShot(0, 0, window->width(), window->height()).toImage();

    QString path = pathStorage() + "/screenshots";

    WControllerFile::createFolder(path);

    path.append("/MotionBox_" + Sk::currentDateString("yyyy-MM-dd_hh-mm-ss-zzz") + ".png");

    ShotWrite * action = new ShotWrite(image, path);

    wControllerFile->startWriteAction(action);
}

/* Q_INVOKABLE */ void ControllerCore::saveSplash(WWindow * window, int border) const
{
    QImage image;

    if (window->isMaximized() == false)
    {
        int border2x = border * 2;

        image = window->takeShot(border, border, window->width () - border2x,
                                                 window->height() - border2x).toImage();
    }
    else image = window->takeShot(0, 0, window->width(), window->height()).toImage();

    image = WControllerView::desaturate(image);

    image.save(pathStorage() + "/splash.png", "png");

    _local->setSplashSize(image.width(), image.height());
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::applyProxy(bool active)
{
    wControllerMedia->clearMedias();

    if (active)
    {
        if (_local->_proxyStream)
        {
            _cache    ->clearProxy();
            //_loaderWeb->clearProxy();

            wControllerDownload->clearProxy();

            wControllerTorrent->setProxy(_local->_proxyHost,
                                         _local->_proxyPort, _local->_proxyPassword);

            if (_loaderMedia == NULL)
            {
                _loaderMedia = new WLoaderNetwork(this);
            }

            _loaderMedia->setProxy(_local->_proxyHost, _local->_proxyPort, _local->_proxyPassword);

            wControllerMedia->setLoader(_loaderMedia);
        }
        else
        {
            _cache    ->setProxy(_local->_proxyHost, _local->_proxyPort, _local->_proxyPassword);
            //_loaderWeb->setProxy(_local->_proxyHost, _local->_proxyPort, _local->_proxyPassword);

            wControllerDownload->setProxy(_local->_proxyHost,
                                          _local->_proxyPort, _local->_proxyPassword);

            wControllerTorrent->setProxy(_local->_proxyHost,
                                         _local->_proxyPort, _local->_proxyPassword);

            wControllerMedia->setLoader(NULL);
        }
    }
    else
    {
        _cache    ->clearProxy();
        //_loaderWeb->clearProxy();

        wControllerDownload->clearProxy();
        wControllerTorrent ->clearProxy();

        wControllerMedia->setLoader(NULL);
    }
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::applyArguments(int & argc, char ** argv)
{
    if (argc < 2) return;

    _argument = QString(argv[1]);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::addLog(const QString & message)
{
    if (_log.isEmpty())
    {
         _log.append(message);
    }
    else _log.append('\n' + message);

    int length = _log.length();

    if (length > LOG_LENGTH)
    {
        _log.remove(0, length - LOG_LENGTH);
    }

    emit logChanged();
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::clearCache()
{
    _related->clearItems();

    _backends->clearItems();

    createBrowse();

    if (_index) _index->createFolderItems(_backends);

    _cache->clearFiles();

    //_diskCache->clear();

    wControllerTorrent->clearTorrents();

    _local->setCache(false);
}

//-------------------------------------------------------------------------------------------------
// Static functions
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ void ControllerCore::applyTorrentOptions(int connections, int upload,
                                                                                   int download,
                                                                                   int cache)
{
    wControllerTorrent->setOptions(connections, upload * 1024, download * 1024);

    wControllerTorrent->setSizeMax(qint64(cache) * 1048576);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ WAbstractHook * ControllerCore::createHook(WAbstractBackend * backend)
{
    return new WHookTorrent(backend);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ QString ControllerCore::extractArgument(const QString & message)
{
    int indexA = message.indexOf(' ');

    if (indexA == -1) return QString();

    indexA++;

    int indexB = message.indexOf(' ', indexA);

    if (indexB == -1)
    {
         return message.mid(indexA, indexB);
    }
    else return message.mid(indexA, indexB - indexA);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ bool ControllerCore::checkUrl(const QString & text)
{
#ifdef Q_OS_WIN
    if (WControllerNetwork::textIsUrl(text) || text.startsWith('/') || text.startsWith('\\'))
#else
    if (WControllerNetwork::textIsUrl(text) || text.startsWith('/'))
#endif
    {
        return true;
    }
    else if (text.contains(':'))
    {
        if (text.length() > 1)
        {
            if (text.at(0).isLetter() || text.contains(' ') == false)
            {
                return true;
            }
        }

        return false;
    }
    else if (text.contains('.') && text.contains(' ') == false)
    {
        return true;
    }
    else return false;
}

/* Q_INVOKABLE static */ int ControllerCore::urlType(const QString & url)
{
    return wControllerPlaylist->urlType(url);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ int ControllerCore::itemType(WLibraryFolder * folder, int index)
{
    return folder->itemType(index);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ int ControllerCore::itemState(WLibraryFolder * folder, int index)
{
    return folder->itemState(index);
}

/* Q_INVOKABLE static */ int ControllerCore::itemStateQuery(WLibraryFolder * folder, int index)
{
    return folder->itemStateQuery(index);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ int ControllerCore::getPlaylistType(WBackendNet   * backend,
                                                             const QString & url)
{
    return backend->getPlaylistType(url);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ WLibraryFolder * ControllerCore::createFolder(int type)
{
    return WLibraryFolder::create(static_cast<WLibraryItem::Type> (type));
}

/* Q_INVOKABLE static */ WPlaylist * ControllerCore::createPlaylist(int type)
{
    return WPlaylist::create(static_cast<WLibraryItem::Type> (type));
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ void ControllerCore::addFolderSearch(WLibraryFolder * folder,
                                                              const QString  & title)
{
    WLibraryFolderItem item(WLibraryItem::FolderSearch);

    item.title = title;

    folder->addItem(item);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ int ControllerCore::idFromTitle(WLibraryFolder * folder,
                                                         const QString  & title)
{
    for (int i = 0; i < folder->count(); i++)
    {
        const WLibraryFolderItem * item = folder->itemAt(i);

        if (item->title == title)
        {
            return item->id;
        }
    }

    return -1;
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ QString ControllerCore::getQuery(const QString & title)
{
    QString result = title;

    result.replace(QRegExp("[.:]"), " ");

    return result.simplified();
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ void ControllerCore::updateCache(WPlaylist * playlist, int index)
{
    if (playlist == NULL || index == -1) return;

    QStringList urls;

    int count = 3;

    for (int i = index - 1; count && i >= 0; i--)
    {
        urls.append(playlist->trackCover(i));

        count--;
    }

    count = 3;

    for (int i = index + 1; count && i < playlist->count(); i++)
    {
        urls.append(playlist->trackCover(i));

        count--;
    }

    wControllerFile->cache()->load(urls);
}

/* Q_INVOKABLE static */ void ControllerCore::clearTorrentCache()
{
    wControllerTorrent->clearCache();
}

//-------------------------------------------------------------------------------------------------
// Events
//-------------------------------------------------------------------------------------------------

/* virtual */ void ControllerCore::timerEvent(QTimerEvent *)
{
    _tabs->currentTab()->toTabTrack()->updateBookmark();

    emit dateCoverChanged  ();
    emit datePreviewChanged();
}

//-------------------------------------------------------------------------------------------------
// Private functions
//-------------------------------------------------------------------------------------------------

WLibraryFolder * ControllerCore::createLibrary(int id)
{
    WLibraryFolder * folder = new WLibraryFolder;

    folder->setParent(this);

    folder->setId(id);

    folder->setSaveEnabled(true);

    folder->load();

    return folder;
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::createBrowse() const
{
    WLibraryFolderItem browse(WLibraryItem::FolderSearchable);

    browse.id = 1;

    browse.title = tr("Browser");

    browse.label = "Browser";

    _backends->addItem(browse);

    _backends->setCurrentIndex(0);
}

void ControllerCore::deleteBrowse() const
{
    QString path = pathStorage() + "/playlists/";

    WControllerFile::deleteFolder(path + "3");
    WControllerFile::deleteFolder(path + "4");

    WControllerFile::deleteFile(path + "3.xml");
    WControllerFile::deleteFile(path + "4.xml");

    _local->setBrowserVisible(false);

    _local->setQuery(QString());

    _local->setCache(false);
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::copyBackends(const QString & path) const
{
#ifdef SK_DEPLOY
    QDir dir(WControllerFile::applicationPath("backend"));
#else
    QDir dir(WControllerFile::applicationPath(PATH_BACKEND));
#endif

    QStringList fileNames;
    QStringList newNames;

    QFileInfoList list = dir.entryInfoList(QDir::Files);

    foreach (QFileInfo info, list)
    {
        if (info.suffix().toLower() != "vbml") continue;

        fileNames.append(info.filePath());

        newNames.append(path + info.fileName());
    }

    wControllerFile->startDeleteFolder(path);
    wControllerFile->startCreateFolder(path);

    WControllerFileReply * reply = wControllerFile->startCopyFiles(fileNames, newNames);

    connect(reply, SIGNAL(actionComplete(bool)), this, SLOT(onLoaded()));
}

//-------------------------------------------------------------------------------------------------

QString ControllerCore::getFile(const QString & title, const QString & filter)
{
    QString path = QFileDialog::getOpenFileName(NULL, title, _pathOpen, filter);

    if (path.isEmpty()) return QString();

    QFileInfo info(path);

    _pathOpen = info.absoluteFilePath();

    return WControllerFile::fileUrl(info.absoluteFilePath());
}

//-------------------------------------------------------------------------------------------------
// Private slots
//-------------------------------------------------------------------------------------------------

void ControllerCore::onLoaded()
{
    _index = new WBackendIndex(WControllerFile::fileUrl(pathStorage() + "/backend"));

    connect(_index, SIGNAL(loaded()), this, SLOT(onIndexLoaded()));
}

void ControllerCore::onIndexLoaded()
{
    disconnect(_index, SIGNAL(loaded()), this, SLOT(onIndexLoaded()));

    _index->createFolderItems(_backends);
}

//-------------------------------------------------------------------------------------------------
// Properties
//-------------------------------------------------------------------------------------------------

QString ControllerCore::argument() const
{
    return _argument;
}

//-------------------------------------------------------------------------------------------------

QString ControllerCore::log() const
{
    return _log;
}

//-------------------------------------------------------------------------------------------------

bool ControllerCore::cacheIsEmpty() const
{
    return _cache->isEmpty();
}

//-------------------------------------------------------------------------------------------------

QString ControllerCore::version() const
{
    return sk->getVersionLite(CORE_VERSION);
}

QString ControllerCore::versionName() const
{
    return "alpha " + version();
}

//-------------------------------------------------------------------------------------------------

WTabsTrack * ControllerCore::tabs() const
{
    return _tabs;
}

//-------------------------------------------------------------------------------------------------

WLibraryFolder * ControllerCore::library() const
{
    return _library;
}

WLibraryFolder * ControllerCore::feeds() const
{
    return _feeds;
}

WLibraryFolder * ControllerCore::backends() const
{
    return _backends;
}

WLibraryFolderRelated * ControllerCore::related() const
{
    return _related;
}

//-------------------------------------------------------------------------------------------------

QDateTime ControllerCore::dateCover() const
{
    return _dateCover;
}

void ControllerCore::setDateCover(const QDateTime & date)
{
    if (_dateCover == date) return;

    _dateCover = date;

    emit dateCoverChanged();
}

//-------------------------------------------------------------------------------------------------

QDateTime ControllerCore::datePreview() const
{
    return _datePreview;
}

void ControllerCore::setDatePreview(const QDateTime & date)
{
    if (_datePreview == date) return;

    _datePreview = date;

    emit datePreviewChanged();
}

//-------------------------------------------------------------------------------------------------

QString ControllerCore::pathStorage() const
{
    return wControllerFile->pathStorage();
}

QString ControllerCore::pathSplash() const
{
    return _pathSplash;
}

#include "ControllerCore.moc"
