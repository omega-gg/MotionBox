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

#include "ControllerCore.h"

// Qt includes
#include <QDeclarativeEngine>
#include <QNetworkDiskCache>
#include <QProcess>
#include <QFileDialog>
#ifdef SK_DEPLOY
#include <QDeclarativeComponent>
#include <QDir>
#ifdef QT_LATEST
#include <QStandardPaths>
#else
#include <QDesktopServices>
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
#include <WAbstractThreadAction>
#include <WWindow>
#include <WDeclarativeContextualPage>
#include <WCache>
#include <WLoaderNetwork>
#include <WLoaderWeb>
#include <WBackendTorrent>
#include <WBackendDuckDuckGo>
#include <WBackendYoutube>
#include <WBackendDailymotion>
#include <WBackendVimeo>
#include <WLibraryFolderRelated>
#include <WPlaylistNet>
#include <WTabsTrack>
#include <WTabTrack>

// App includes
#include "DataLocal.h"
#include "DataOnline.h"

W_INIT_CONTROLLER(ControllerCore)

//-------------------------------------------------------------------------------------------------
// Static variables

static const QString CORE_VERSION = "1.1.1-6";

static const QString PATH_SK = "../../Sky/src";

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

    _diskCache = NULL;

    _tabs = NULL;

    _library = NULL;
    _hubs    = NULL;
    _related = NULL;

    _loaderMedia = NULL;
    _loaderWeb   = NULL;

    //---------------------------------------------------------------------------------------------
    // Settings

    sk->setName("MotionBox");

#ifdef SK_DEPLOY
#ifdef QT_LATEST
    QString path = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
#else
    QString path = QDesktopServices::storageLocation(QDesktopServices::DataLocation);
#endif

    wControllerFile->setPathStorage(QDir::fromNativeSeparators(path));
#else
    QString path = "storage";

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

#ifndef SK_DEPLOY
    wControllerDeclarative->engine()->addImportPath(PATH_SK);
#endif
}

//-------------------------------------------------------------------------------------------------
// Interface
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::preload()
{
    if (_tabs) return;

    //---------------------------------------------------------------------------------------------
    // Controllers

    W_CREATE_CONTROLLER(WControllerMedia);
    W_CREATE_CONTROLLER(WControllerTorrent);

    //---------------------------------------------------------------------------------------------
    // DataOnline

    _online = new DataOnline(this);

    //---------------------------------------------------------------------------------------------
    // Tabs

    _tabs = new WTabsTrack(this);

    //---------------------------------------------------------------------------------------------
    // QML

    qmlRegisterType<DataOnline>("Sky", 1,0, "DataOnline");

    wControllerDeclarative->setContextProperty("online", _online);
}

/* Q_INVOKABLE */ void ControllerCore::load()
{
    if (_cache) return;

    //---------------------------------------------------------------------------------------------
    // Backends

    new WBackendTorrent;

    new WBackendDuckDuckGo;

    new WBackendYoutube;
    new WBackendDailymotion;
    new WBackendVimeo;

    //---------------------------------------------------------------------------------------------
    // Cache

    QString path = pathStorage();

    _cache = new WCache(path + "/cache");

    wControllerFile->setCache(_cache);

    connect(_cache, SIGNAL(emptyChanged()), this, SIGNAL(cacheEmptyChanged()));

    //---------------------------------------------------------------------------------------------
    // DiskCache

    _diskCache = new QNetworkDiskCache(this);

    _diskCache->setCacheDirectory(path + "/cache/web");

    //---------------------------------------------------------------------------------------------
    // LoaderWeb

    _loaderWeb = new WLoaderWeb(this);

    _loaderWeb->setCache(_diskCache);

    wControllerPlaylist->registerLoader(WBackendNetQuery::TypeWeb, _loaderWeb);

    //---------------------------------------------------------------------------------------------
    // Proxy

    applyProxy(_local->_proxyActive);

    //---------------------------------------------------------------------------------------------
    // Tabs

    _tabs->setId(1);

    _tabs->setMaxCount(8);

    _tabs->setSaveEnabled(true);

    _tabs->load();

    _tabs->addTab();

    //---------------------------------------------------------------------------------------------
    // Library

    _library = new WLibraryFolder;

    _library->setParent(this);

    _library->setId(1);

    _library->setSaveEnabled(true);

    _library->load();

    emit libraryChanged();

    //---------------------------------------------------------------------------------------------
    // Hubs

    _hubs = new WLibraryFolder;

    _hubs->setParent(this);

    _hubs->setId(2);

    _hubs->setSaveEnabled(true);

    wControllerPlaylist->setPathCover("pictures/icons/hub");

    if (_hubs->load() == false)
    {
        createBrowse();

        wControllerPlaylist->createBackendItems(_hubs);

        _hubs->setCurrentIndex(0);
    }

    emit hubsChanged();

    //---------------------------------------------------------------------------------------------
    // Related

    _related = new WLibraryFolderRelated;

    _related->setParent(this);

    _related->setId(3);

    _related->setSaveEnabled(true);

    _related->load();

    emit relatedChanged();

    //---------------------------------------------------------------------------------------------
    // Network

    wControllerNetwork->setCheckConnected(true);

    //---------------------------------------------------------------------------------------------

    _pathOpen = QDir::rootPath();

    startTimer(60000); // 1 minute

    _local->setSplashSize(-1, -1);

    _local->save();
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ bool ControllerCore::updateVersion()
{
    if (_online->_version.isEmpty()
        ||
        _online->_version == CORE_VERSION) return false;

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
    else if (Sk::runAdmin(path) == false)
    {
        return false;
    }

    _online->_version = QString();

    return true;
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ QString ControllerCore::openFile(const QString & title)
{
    QString path = QFileDialog::getOpenFileName(NULL, title, _pathOpen,
                                                WControllerPlaylist::getFileFilter());

    if (path.isEmpty()) return QString();

    QFileInfo info(path);

    _pathOpen = info.absolutePath();

    return WControllerFile::fileUrl(info.absoluteFilePath());
}

/* Q_INVOKABLE */ QString ControllerCore::openFolder(const QString & title)
{
    QString path = QFileDialog::getExistingDirectory(NULL, title, _pathOpen);

    if (path.isEmpty()) return QString();

    QFileInfo info(path);

    _pathOpen = info.absoluteFilePath();

    return WControllerFile::fileUrl(_pathOpen);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::saveShot(WWindow * window)
{
    QImage image = window->takeShot(0, 0, window->width(), window->height()).toImage();

    QString path = pathStorage() + "/screenshots";

    WControllerFile::createFolder(path);

    path.append("/MotionBox_" + Sk::currentDateString("yyyy-MM-dd_hhmmsszzz") + ".png");

    ShotWrite * action = new ShotWrite(image, path);

    wControllerFile->startWriteAction(action);
}

/* Q_INVOKABLE */ void ControllerCore::saveSplash(WWindow * window, int border)
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
            _loaderWeb->clearProxy();

            wControllerDownload->clearProxy();

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
            _loaderWeb->setProxy(_local->_proxyHost, _local->_proxyPort, _local->_proxyPassword);

            wControllerDownload->setProxy(_local->_proxyHost,
                                          _local->_proxyPort, _local->_proxyPassword);

            wControllerMedia->setLoader(NULL);
        }
    }
    else
    {
        _cache    ->clearProxy();
        _loaderWeb->clearProxy();

        wControllerDownload->clearProxy();

        wControllerMedia->setLoader(NULL);
    }
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ bool ControllerCore::checkUrl(const QString & text) const
{
    if (textIsUrl(text) || textIsPath(text))
    {
         return true;
    }
    else return false;
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ bool ControllerCore::textIsUrl(const QString & text) const
{
    if (WControllerNetwork::urlIsFile(text))
    {
        return true;
    }
    else if (WControllerNetwork::urlIsHttp(text) || text.startsWith("www."))
    {
        if (text.contains(' '))
        {
             return false;
        }
        else return true;
    }
    else return false;
}

/* Q_INVOKABLE */ bool ControllerCore::textIsPath(const QString & text) const
{
    if (text.length() > 1 && text.at(1) == ':')
    {
         return true;
    }
    else return false;
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ int ControllerCore::urlType(const QUrl & url) const
{
    return wControllerPlaylist->urlType(url);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ int ControllerCore::itemType(WLibraryFolder * folder, int index) const
{
    return folder->itemType(index);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ int ControllerCore::itemState(WLibraryFolder * folder, int index) const
{
    return folder->itemState(index);
}

/* Q_INVOKABLE */ int ControllerCore::itemStateQuery(WLibraryFolder * folder, int index) const
{
    return folder->itemStateQuery(index);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ int ControllerCore::getPlaylistType(WBackendNet * backend,
                                                      const QUrl  & url) const
{
    return backend->getPlaylistType(url);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ WLibraryFolder * ControllerCore::createFolder(int type) const
{
    return WLibraryFolder::create(static_cast<WLibraryItem::Type> (type));
}

/* Q_INVOKABLE */ WPlaylistNet * ControllerCore::createPlaylist(int type) const
{
    return WPlaylistNet::create(static_cast<WLibraryItem::Type> (type));
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ int ControllerCore::idFromTitle(WLibraryFolder * folder,
                                                  const QString  & title) const
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

/* Q_INVOKABLE */ void ControllerCore::updateCache(WPlaylistNet * playlist, int index) const
{
    if (playlist == NULL || index == -1) return;

    QList<QUrl> urls;

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

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::clearCache()
{
    _related->clearItems();

    restoreBrowse();

    wControllerPlaylist->restoreBackendItems(_hubs);

    _hubs->setCurrentIndex(0);

    _cache->clearFiles();

    _diskCache->clear();

    _local->setCache(false);
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

void ControllerCore::createBrowse()
{
    WLibraryFolderSearchable * browse = new WLibraryFolderSearchable;

    browse->setId(1);

    browse->setTitle(tr("Video Network"));

    browse->setLabel("Video Network");

    _hubs->addLibraryItem(browse);

    browse->tryDelete();
}

void ControllerCore::restoreBrowse()
{
    WLibraryFolder * browse = _hubs->createLibraryItemFromId(1)->toFolder();

    browse->clearItems();

    browse->tryDelete();
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::deleteBrowse()
{
    QString path = pathStorage() + "/playlists/";

    WControllerFile::deleteFolder(path + "2");
    WControllerFile::deleteFile  (path + "2.xml");

    _local->setBrowserVisible(false);

    _local->setQuery(QString());

    _local->setCache(false);
}

//-------------------------------------------------------------------------------------------------
// Properties
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

WLibraryFolder * ControllerCore::hubs() const
{
    return _hubs;
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
