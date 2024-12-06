//=================================================================================================
/*
    Copyright (C) 2015-2020 MotionBox authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of MotionBox.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.

    - Private License Usage:
    MotionBox licensees holding valid private licenses may use this file in accordance with the
    private license agreement provided with the Software or, alternatively, in accordance with the
    terms contained in written agreement between you and MotionBox authors. For further information
    contact us at contact@omega.gg.
*/
//=================================================================================================

#include "ControllerCore.h"

// Qt includes
#ifdef QT_4
#include <QCoreApplication>
#include <QDeclarativeEngine>
#else
#include <QQmlEngine>
#endif
//#include <QNetworkDiskCache>
#ifdef SK_DESKTOP
#include <QFileDialog>
#else
#include <QDir>
#if defined(Q_OS_ANDROID) && defined(QT_5) && QT_VERSION >= QT_VERSION_CHECK(5, 10, 0)
    #include <QtAndroid>
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
#include <WView>
#include <WViewResizer>
#include <WViewDrag>
#include <WWindow>
#include <WCache>
#include <WActionCue>
#include <WInputCue>
#include <WLoaderNetwork>
#include <WLoaderVbml>
#include <WLoaderBarcode>
//#include <WLoaderWeb>
#include <WLoaderTorrent>
#include <WLoaderSuggest>
#include <WLoaderRecent>
#include <WLoaderTracks>
#include <WHookOutputBarcode>
#include <WHookTorrent>
#include <WLibraryFolderRelated>
#include <WAbstractTabs>
#include <WAbstractTab>
#include <WTabsTrack>
#include <WTabTrack>
#include <WBackendVlc>
#include <WBackendSubtitle>
#include <WBackendIndex>
#include <WBackendTorrent>
#include <WBackendUniversal>
#ifndef QT_4
#include <WFilterBarcode>
#endif
#include <WModelRange>
#include <WModelList>
#include <WModelOutput>
#include <WModelLibraryFolder>
#include <WModelPlaylist>
#include <WModelCompletionGoogle>
#include <WModelContextual>
#include <WModelTabs>
#include <WImageFilterColor>
#include <WDeclarativeApplication>
#include <WDeclarativeMouseArea>
#include <WDeclarativeMouseWatcher>
#include <WDeclarativeListView>
#include <WDeclarativeContextualPage>
#include <WDeclarativeAnimated>
#include <WDeclarativeBorders>
#include <WDeclarativeImage>
#include <WDeclarativeImageSvg>
#include <WDeclarativeBorderImage>
#include <WDeclarativeTextSvg>
#include <WDeclarativeAmbient>
#include <WDeclarativeScanner>
#ifdef SK_DESKTOP
#include <WDeclarativeScannerHover>
#endif
#include <WBarcodeWriter>

// Application includes
#include "DataOnline.h"

W_INIT_CONTROLLER(ControllerCore)

//-------------------------------------------------------------------------------------------------
// Static variables

// NOTE: Also check DataLocal_patch, version_windows.
static const QString CORE_VERSION = "2.0.0-6";

static const int CORE_CACHE = 1048576 * 100; // 100 megabytes

#ifndef SK_DEPLOY
#ifdef Q_OS_MACX
static const QString PATH_STORAGE = "/../../../storage";
static const QString PATH_BACKEND = "../../../../../backend";
#else
static const QString PATH_STORAGE = "/storage";
static const QString PATH_BACKEND = "../../backend";
#endif
#endif

//-------------------------------------------------------------------------------------------------
// Ctor / dtor
//-------------------------------------------------------------------------------------------------

ControllerCore::ControllerCore() : WController()
{
    _online = NULL;

    _cache = NULL;

    //_diskCache = NULL;

    _tabs = NULL;

    _library  = NULL;
    _feeds    = NULL;
    _backends = NULL;
    _related  = NULL;

    _playlist = NULL;

    _loaderMedia = NULL;
    //_loaderWeb   = NULL;

    _loaderSuggest     = NULL;
    _loaderRecent      = NULL;
    _loaderInteractive = NULL;

    _index = NULL;

    _output = NULL;

    //---------------------------------------------------------------------------------------------
    // Settings

    sk->setName("MotionBox");

    sk->setVersion(CORE_VERSION);

#ifdef Q_OS_LINUX
    sk->setIcon(":/pictures/icons/icon.svg");
#endif

#ifdef SK_DEPLOY
    _path = QDir::fromNativeSeparators(WControllerFile::pathWritable());
#else
    _path = QDir::currentPath() + PATH_STORAGE;
#endif

    wControllerFile->setPathStorage(_path);

    wControllerView->setLoadMode(WControllerView::LoadVisible);

    //---------------------------------------------------------------------------------------------
    // DataLocal

    _local.setSaveEnabled(true);

    _local.load(true);

    if (_local._maximized)
    {
        sk->setDefaultMode(Sk::Maximized);
    }

    sk->setDefaultScreen(_local._screen);

    sk->setDefaultWidth (_local._width);
    sk->setDefaultHeight(_local._height);

    if (_local._splashWidth != -1)
    {
        _pathSplash = WControllerFile::fileUrl(_path + "/splash.png");
    }

    //---------------------------------------------------------------------------------------------
    // QML
    //---------------------------------------------------------------------------------------------
    // Qt

    qmlRegisterUncreatableType<QAbstractItemModel>("Sky", 1,0, "QAbstractItemModel",
                                                   "QAbstractItemModel is abstract");

    //---------------------------------------------------------------------------------------------
    // Global

    qmlRegisterUncreatableType<WControllerApplication>("Sky", 1,0, "Sk", "Sk is not creatable");

    //---------------------------------------------------------------------------------------------
    // Application

    qmlRegisterType<WDeclarativeApplication>("Sky", 1,0, "Application");

    //---------------------------------------------------------------------------------------------
    // Kernel

    qmlRegisterUncreatableType<WAbstractTabs>("Sky", 1,0, "AbstractTabs",
                                              "AbstractTabs is abstract");

    qmlRegisterUncreatableType<WAbstractTab>("Sky", 1,0, "AbstractTab",
                                             "AbstractTab is abstract");

    qmlRegisterType<WActionCue>("Sky", 1,0, "ActionCue");
    qmlRegisterType<WInputCue> ("Sky", 1,0, "InputCue");

    //---------------------------------------------------------------------------------------------
    // View

    qmlRegisterUncreatableType<WView>("Sky", 1,0, "View", "View is abstract");

    qmlRegisterType<WViewResizer>("Sky", 1,0, "ViewResizer");
    qmlRegisterType<WViewDrag>   ("Sky", 1,0, "ViewDrag");

    qmlRegisterType<WWindow>("Sky", 1,0, "BaseWindow");

    //---------------------------------------------------------------------------------------------
    // Image

    qmlRegisterUncreatableType<WImageFilter>("Sky", 1,0, "ImageFilter", "ImageFilter is abstract");

    qmlRegisterType<WImageFilterColor>("Sky", 1,0, "ImageFilterColor");

    qmlRegisterType<WDeclarativeGradient>    ("Sky", 1,0, "ScaleGradient");
    qmlRegisterType<WDeclarativeGradientStop>("Sky", 1,0, "ScaleGradientStop");

    //---------------------------------------------------------------------------------------------
    // Declarative

    qmlRegisterType<WDeclarativeMouseArea>   ("Sky", 1,0, "MouseArea");
    qmlRegisterType<WDeclarativeMouseWatcher>("Sky", 1,0, "MouseWatcher");

    qmlRegisterType<WDeclarativeListHorizontal>("Sky", 1,0, "ListHorizontal");
    qmlRegisterType<WDeclarativeListVertical>  ("Sky", 1,0, "ListVertical");

    qmlRegisterType<WDeclarativeContextualPage>("Sky", 1,0, "ContextualPage");

    qmlRegisterType<WDeclarativeAnimated>("Sky", 1,0, "Animated");

    qmlRegisterType<WDeclarativeBorders>("Sky", 1,0, "Borders");

    qmlRegisterUncreatableType<WDeclarativeImageBase>("Sky", 1,0, "ImageBase",
                                                      "ImageBase is abstract");

    qmlRegisterType<WDeclarativeImage>     ("Sky", 1,0, "Image");
    qmlRegisterType<WDeclarativeImageScale>("Sky", 1,0, "ImageScale");
    qmlRegisterType<WDeclarativeImageSvg>  ("Sky", 1,0, "ImageSvg");

#ifdef QT_4
    qmlRegisterType<WDeclarativeImageSvgScale>("Sky", 1,0, "ImageSvgScale");
#endif

    qmlRegisterType<WDeclarativeBorderImage>     ("Sky", 1,0, "BorderImage");
    qmlRegisterType<WDeclarativeBorderImageScale>("Sky", 1,0, "BorderImageScale");
    qmlRegisterType<WDeclarativeBorderGrid>      ("Sky", 1,0, "BorderGrid");

    qmlRegisterType<WDeclarativeTextSvg>("Sky", 1,0, "TextSvg");

#ifdef QT_4
    qmlRegisterType<WDeclarativeTextSvgScale>("Sky", 1,0, "TextSvgScale");
#endif

    qmlRegisterType<WDeclarativePlayer> ("Sky", 1,0, "Player");
    qmlRegisterType<WDeclarativeAmbient>("Sky", 1,0, "Ambient");

    qmlRegisterType<WDeclarativeScanner>("Sky", 1,0, "Scanner");

#ifdef SK_DESKTOP
    qmlRegisterType<WDeclarativeScannerHover>("Sky", 1,0, "ScannerHover");
#endif

    //---------------------------------------------------------------------------------------------
    // Models

    qmlRegisterType<WModelRange>("Sky", 1,0, "ModelRange");

    qmlRegisterType<WModelList>("Sky", 1,0, "ModelList");

    qmlRegisterType<WModelOutput>("Sky", 1,0, "ModelOutput");

    qmlRegisterType<WModelLibraryFolder>        ("Sky", 1,0, "ModelLibraryFolder");
    qmlRegisterType<WModelLibraryFolderFiltered>("Sky", 1,0, "ModelLibraryFolderFiltered");

    qmlRegisterType<WModelPlaylist>        ("Sky", 1,0, "ModelPlaylist");
    qmlRegisterType<WModelPlaylistFiltered>("Sky", 1,0, "ModelPlaylistFiltered");

    qmlRegisterType<WModelCompletionGoogle>("Sky", 1,0, "ModelCompletionGoogle");

    qmlRegisterType<WModelContextual>("Sky", 1,0, "ModelContextual");

    qmlRegisterType<WModelTabs>("Sky", 1,0, "ModelTabs");

    //---------------------------------------------------------------------------------------------
    // Multimedia

    qmlRegisterUncreatableType<WBackendNet>("Sky", 1,0, "BackendNet", "BackendNet is abstract");

    qmlRegisterUncreatableType<WAbstractBackend>("Sky", 1,0, "AbstractBackend",
                                                 "AbstractBackend is abstract");

    qmlRegisterUncreatableType<WAbstractHook>("Sky", 1,0, "AbstractHook",
                                              "AbstractHook is abstract");

    qmlRegisterUncreatableType<WHookOutput>("Sky", 1,0, "HookOutput",
                                            "HookOutput is not creatable");

    qmlRegisterUncreatableType<WLocalObject>("Sky", 1,0, "LocalObject", "LocalObject is abstract");

    qmlRegisterUncreatableType<WLibraryItem>("Sky", 1,0, "LibraryItem", "LibraryItem is abstract");

    qmlRegisterType<WLibraryFolder>       ("Sky", 1,0, "LibraryFolder");
    qmlRegisterType<WLibraryFolderRelated>("Sky", 1,0, "LibraryFolderRelated");

    qmlRegisterType<WPlaylist>("Sky", 1,0, "Playlist");

    qmlRegisterType<WTabsTrack>("Sky", 1,0, "BaseTabsTrack");
    qmlRegisterType<WTabTrack> ("Sky", 1,0, "TabTrack");

    qmlRegisterUncreatableType<WBackendIndex>("Sky", 1,0, "BackendIndex",
                                              "BackendIndex is not creatable");

    qmlRegisterType<WBackendVlc>     ("Sky", 1,0, "BackendVlc");
    qmlRegisterType<WBackendSubtitle>("Sky", 1,0, "BackendSubtitle");

#ifndef QT_4
    qmlRegisterType<WFilterBarcode>("Sky", 1,0, "FilterBarcode");
#endif

    //---------------------------------------------------------------------------------------------
    // Events

    qmlRegisterUncreatableType<WDeclarativeDropEvent>("Sky", 1,0, "DeclarativeDropEvent",
                                                      "DeclarativeDropEvent is not creatable");

    qmlRegisterUncreatableType<WDeclarativeKeyEvent>("Sky", 1,0, "DeclarativeKeyEvent",
                                                     "DeclarativeKeyEvent is not creatable");

    //---------------------------------------------------------------------------------------------
    // MotionBox

    qmlRegisterType<DataLocal>("Sky", 1,0, "DataLocal");

    //---------------------------------------------------------------------------------------------
    // Context

    wControllerDeclarative->setContextProperty("sk", sk);

    wControllerDeclarative->setContextProperty("core",  this);
    wControllerDeclarative->setContextProperty("local", &_local);
}

//-------------------------------------------------------------------------------------------------
// Interface
//-------------------------------------------------------------------------------------------------

#ifdef SK_DESKTOP

/* Q_INVOKABLE */ void ControllerCore::applyArguments(int & argc, char ** argv)
{
    if (argc < 2) return;

    _argument = QString(argv[1]);
}

#endif

/* Q_INVOKABLE */ void ControllerCore::applyBackend(WDeclarativePlayer * player)
{
    Q_ASSERT(player);

#ifdef SK_NO_TORRENT
    WBackendManager * backend = new WBackendManager;
#else
    WBackendTorrent * backend = new WBackendTorrent;
#endif

    player->setBackend(backend);

    QList<WAbstractHook *> list;

    _output = new WHookOutputBarcode(backend);

    list.append(_output);

    player->setHooks(list);

    emit outputChanged();
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::load()
{
    if (_cache) return;

    //---------------------------------------------------------------------------------------------
    // DataLocal

    // NOTE: We make sure the storage folder is created.
    _local.createPath();

    //---------------------------------------------------------------------------------------------
    // Message handler

    // FIXME Qt4.8.7: qInstallMsgHandler breaks QML 'Keys' events.
#ifndef QT_4
    wControllerFile->initMessageHandler();
#endif

    //---------------------------------------------------------------------------------------------
    // Paths

    qDebug("MotionBox %s", sk->version().C_STR);

    qDebug("Path storage: %s", _path.C_STR);
    qDebug("Path log:     %s", wControllerFile->pathLog().C_STR);
    qDebug("Path config:  %s", _local.getFilePath().C_STR);

    //---------------------------------------------------------------------------------------------
    // Controllers

    W_CREATE_CONTROLLER(WControllerPlaylist);
    W_CREATE_CONTROLLER(WControllerMedia);

#ifndef SK_NO_TORRENT
    W_CREATE_CONTROLLER_2(WControllerTorrent, _path + "/torrents", _local._torrentPort);
#endif

    //---------------------------------------------------------------------------------------------
    // Cache

    _cache = new WCache(_path + "/cache", CORE_CACHE);

    wControllerFile->setCache(_cache);

    connect(_cache, SIGNAL(emptyChanged()), this, SIGNAL(cacheEmptyChanged()));

    //---------------------------------------------------------------------------------------------
    // DiskCache

    /*_diskCache = new QNetworkDiskCache(this);

    _diskCache->setCacheDirectory(_path + "/cache/web");*/

    //---------------------------------------------------------------------------------------------
    // LoaderWeb

    /*_loaderWeb = new WLoaderWeb(this);

    _loaderWeb->setCache(_diskCache);

    wControllerPlaylist->registerLoader(WBackendNetQuery::TypeWeb, _loaderWeb);*/

    //---------------------------------------------------------------------------------------------
    // LoaderVbml

    wControllerPlaylist->registerLoader(WBackendNetQuery::TypeVbml, new WLoaderVbml(this));

    //---------------------------------------------------------------------------------------------
    // LoaderBarcode

    wControllerPlaylist->registerLoader(WBackendNetQuery::TypeImage, new WLoaderBarcode(this));

#ifndef SK_NO_TORRENT
    //---------------------------------------------------------------------------------------------
    // LoaderTorrent

    WLoaderTorrent * loaderTorrent = new WLoaderTorrent(this);

    wControllerPlaylist->registerLoader(WBackendNetQuery::TypeTorrent, loaderTorrent);
    wControllerTorrent ->registerLoader(WBackendNetQuery::TypeTorrent, loaderTorrent);
#endif

    //---------------------------------------------------------------------------------------------
    // Proxy

    applyProxy(_local._proxyActive);

#ifndef SK_NO_TORRENT
    //---------------------------------------------------------------------------------------------
    // Torrents

    applyTorrentOptions(_local._torrentConnections,
                        _local._torrentUpload, _local._torrentDownload, _local._torrentCache);
#endif

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

    emit tabsChanged();

    //---------------------------------------------------------------------------------------------
    // Library

    _library = createLibrary(1);

    emit libraryChanged();

    //---------------------------------------------------------------------------------------------
    // Feeds

    _feeds = createLibrary(2);

    _feeds->setMaxCount(100);

    connect(_feeds, SIGNAL(currentIdChanged()), this, SLOT(onFeedChanged()));

    connect(_feeds, SIGNAL(itemsRemoved(const QList<int> &)), this, SLOT(onFeedUpdated()));
    connect(_feeds, SIGNAL(itemsCleared()),                   this, SLOT(onFeedUpdated()));

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

        _backends->setCurrentIndex(0);

        WControllerFileReply * reply = copyBackends(_path + "/backend/");

        connect(reply, SIGNAL(complete(bool)), this, SLOT(onLoaded()));
    }
    else createIndex();

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

    wControllerDeclarative->setContextProperty("controllerFile",     wControllerFile);
    wControllerDeclarative->setContextProperty("controllerNetwork",  wControllerNetwork);
    wControllerDeclarative->setContextProperty("controllerPlaylist", wControllerPlaylist);

    wControllerDeclarative->setContextProperty("online", _online);

    //---------------------------------------------------------------------------------------------

    startTimer(60000); // 1 minute

    _local.setSplashSize(-1, -1);

    _local.save();
}

/* Q_INVOKABLE */ void ControllerCore::loadTrack(WPlaylist * playlist, const QString & text)
{
    Q_ASSERT(playlist);

    if (WControllerNetwork::textIsUri(text))
    {
        playlist->insertSource(0, text, true);

        return;
    }

    QString id = wControllerPlaylist->backendIdFromText(text);

    if (id.isEmpty())
    {
        id = wControllerPlaylist->backendSearchId();

        if (id.isEmpty()) return;

        _query = text.trimmed();
    }
    else _query = WControllerPlaylist::queryFromText(text, id).trimmed();

    playlist->addDeleteLock();

    _playlistTrack = playlist;

    if (_playlist == NULL)
    {
        _playlist = new WPlaylist;

        _playlist->setParent(this);
    }
    else if (_playlist->queryIsLoading())
    {
        onQueryCompleted();
    }

    QString ssource = WControllerPlaylist::createSource(id, "search", "tracks", _query);

    WTrack track;

    track.setTitle(_query);

    _playlistTrack->insertTrack(0, track);

    connect(_playlist, SIGNAL(queryEnded    ()), this, SLOT(onQueryEnded    ()));
    connect(_playlist, SIGNAL(queryCompleted()), this, SLOT(onQueryCompleted()));

    _playlist->loadSource(ssource);
}

/* Q_INVOKABLE */ void ControllerCore::loadLinks(const QString & source, bool safe)
{
    WMediaReply * reply;

    int currentTime = WControllerPlaylist::extractTime(source);

    if (safe)
    {
         reply = wControllerMedia->getMedia(source, WAbstractBackend::SourceSafe, currentTime);
    }
    else reply = wControllerMedia->getMedia(source, WAbstractBackend::SourceDefault, currentTime);

    if (reply->isLoaded())
    {
        onMediaLoaded(reply);
    }
    else connect(reply, SIGNAL(loaded(WMediaReply *)), this, SLOT(onMediaLoaded(WMediaReply *)));
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ bool ControllerCore::updateVersion()
{
    if (_online->_version.isEmpty() || _online->_version == CORE_VERSION) return false;

    if (Sk::runUpdate())
    {
        _online->_version = QString();

        return true;
    }
    else return false;
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::updateBackends() const
{
    if (_index == NULL) return;

    _index->update();
}

/* Q_INVOKABLE */ void ControllerCore::resetBackends() const
{
    WControllerFileReply * reply = copyBackends(_path + "/backend/");

    connect(reply, SIGNAL(complete(bool)), this, SLOT(onReload()));
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::connectToHost(const QString & url)
{
    if (_output) _output->connectToHost(url);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ QString ControllerCore::openFile(const QString & title)
{
    return getFile(title, WControllerPlaylist::getFilterFile());
}

/* Q_INVOKABLE */ QString ControllerCore::openFolder(const QString & title)
{
#ifdef SK_DESKTOP
    if (_pathOpen.isEmpty()) _pathOpen = QDir::rootPath();

    QString path = QFileDialog::getExistingDirectory(NULL, title, _pathOpen);

    if (path.isEmpty()) return QString();

    QFileInfo info(path);

    _pathOpen = info.absoluteFilePath();

    return WControllerFile::fileUrl(_pathOpen);
#else
    Q_UNUSED(title);

    return QString();
#endif
}

/* Q_INVOKABLE */ QString ControllerCore::openSubtitle(const QString & title)
{
    return getFile(title, WControllerPlaylist::getFilterSubtitle());
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::generateTag(const QString & vbml, const QString & prefix)
{
    if (vbml.isEmpty()) return;

    WBarcodeWriter::startWrite(vbml, this, SIGNAL(tagUpdated(const QImage &, const QString &)),
                               WBarcodeWriter::Vbml, prefix);
}

/* Q_INVOKABLE */ void ControllerCore::copyLink(const QString & vbml, const QString & prefix)
{
    if (vbml.isEmpty()) return;

    WBarcodeWriter::startEncode(vbml, this, SIGNAL(linkReady(const QString &)),
                                WBarcodeWriter::Vbml, prefix);
}

/* Q_INVOKABLE */ void ControllerCore::saveVbml(const QString & title, const QString & vbml)
{
#if defined(Q_OS_ANDROID) && defined(QT_5) && QT_VERSION >= QT_VERSION_CHECK(5, 10, 0)
    QString permission = "android.permission.WRITE_EXTERNAL_STORAGE";

    if (QtAndroid::checkPermission(permission) == QtAndroid::PermissionResult::Denied)
    {
        QtAndroid::requestPermissions(QStringList(permission),
                                      [this, permission, title, vbml]
                                      (QtAndroid::PermissionResultMap hash)
                                      {
                                          if (hash.value(permission) != QtAndroid::PermissionResult::Granted) return;

                                          this->writeVbml(title, vbml);
                                      });

        return;
    }
#endif

    writeVbml(title, vbml);
}

/* Q_INVOKABLE */ void ControllerCore::saveTag(const QString & title,
                                               const QString & vbml,
                                               const QString & background,
                                               const QString & cover,
                                               const QString & prefix, int padding)
{
#if defined(Q_OS_ANDROID) && defined(QT_5) && QT_VERSION >= QT_VERSION_CHECK(5, 10, 0)
    QString permission = "android.permission.WRITE_EXTERNAL_STORAGE";

    if (QtAndroid::checkPermission(permission) == QtAndroid::PermissionResult::Denied)
    {
        QtAndroid::requestPermissions(QStringList(permission),
                                      [this,
                                       permission, title, vbml, background, cover, prefix, padding]
                                      (QtAndroid::PermissionResultMap hash)
        {
            if (hash.value(permission) != QtAndroid::PermissionResult::Granted) return;

            this->writeTag(title, vbml, background, cover, prefix, padding);
        });

        return;
    }
#endif

    writeTag(title, vbml, background, cover, prefix, padding);
}

/* Q_INVOKABLE */ void ControllerCore::saveSplash(WWindow * window, int border)
{
    QImage image;

    if (window->isMaximized() == false)
    {
        int border2x = border * 2;

        image = window->takeShot(border, border, window->width () - border2x,
                                                 window->height() - border2x);
    }
    else image = window->takeShot(0, 0, window->width(), window->height());

    image = WControllerView::desaturate(image);

    image.save(_path + "/splash.png", "png");

    _local.setSplashSize(image.width(), image.height());
}

//-------------------------------------------------------------------------------------------------

#ifdef QT_NEW

/* Q_INVOKABLE */ bool ControllerCore::applyCameras(const QVariantList & cameras)
{
    _cameras.clear();

    foreach (const QVariant & variant, cameras)
    {
        QMap<QString, QVariant> map = variant.toMap();

        QString id = map.value("deviceId").toString();

        // NOTE: Sometimes the same id comes up twice.
        if (_cameras.contains(id)) continue;

        _cameras.append(map.value("deviceId").toString());
    }

    if (_cameras.isEmpty())
    {
        if (_cameraId.isEmpty() == false)
        {
            _cameraId = QString();

            emit cameraIdChanged();
        }

        return false;
    }
    else
    {
        if (_cameras.contains(_cameraId) == false)
        {
            _cameraId = _cameras.first();

            emit cameraIdChanged();
        }

        return (_cameras.count() > 1);
    }
}

/* Q_INVOKABLE */ void ControllerCore::setNextCamera()
{
    int count = _cameras.count();

    for (int i = 0; i < count; i++)
    {
        if (_cameras.at(i) == _cameraId)
        {
            if (i == count - 1)
            {
                 _cameraId = _cameras.first();
            }
            else _cameraId = _cameras.at(i + 1);

            emit cameraIdChanged();

            return;
        }
    }

    if (count == 0) return;

    _cameraId = _cameras.first();

    emit cameraIdChanged();
}

#endif

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::applyProxy(bool active)
{
    wControllerMedia->clearMedias();

    if (active)
    {
        if (_local._proxyStream)
        {
            _cache    ->clearProxy();
            //_loaderWeb->clearProxy();

            wControllerDownload->clearProxy();

            wControllerTorrent->setProxy(_local._proxyHost,
                                         _local._proxyPort, _local._proxyPassword);

            if (_loaderMedia == NULL)
            {
                _loaderMedia = new WLoaderNetwork(this);
            }

            _loaderMedia->setProxy(_local._proxyHost, _local._proxyPort, _local._proxyPassword);

            wControllerMedia->setLoader(_loaderMedia);
        }
        else
        {
            _cache    ->setProxy(_local._proxyHost, _local._proxyPort, _local._proxyPassword);
            //_loaderWeb->setProxy(_local._proxyHost, _local._proxyPort, _local._proxyPassword);

            wControllerDownload->setProxy(_local._proxyHost,
                                          _local._proxyPort, _local._proxyPassword);

            wControllerTorrent->setProxy(_local._proxyHost,
                                         _local._proxyPort, _local._proxyPassword);

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

/* Q_INVOKABLE */ void ControllerCore::clearMedia(WDeclarativePlayer * player) const
{
    Q_ASSERT(player);

    wControllerMedia->clearMedia(player->source ());
    wControllerMedia->clearMedia(player->ambient());
}

/* Q_INVOKABLE */ void ControllerCore::clearCache()
{
    _related->clearItems();

    _backends->clearItems();

    createBrowse();

    _backends->setCurrentIndex(0);

    if (_index)
    {
        _index->createFolderItems(_backends, WLibraryItem::FolderSearchable);

        _index->clearCache();
    }

    _cache->clearFiles();

    //_diskCache->clear();

#ifndef SK_NO_TORRENT
    wControllerTorrent->clearTorrents();
#endif

    // NOTE: It's important to reset backends in case they got corrupted.
    resetBackends();

    _local.setCache(false);
}

//-------------------------------------------------------------------------------------------------
// Static functions
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ void ControllerCore::applyTorrentOptions(int connections,
                                                                  int upload, int download,
                                                                  int cache)
{
#ifdef SK_NO_TORRENT
    Q_UNUSED(connections); Q_UNUSED(upload); Q_UNUSED(download); Q_UNUSED(cache);
#else
    wControllerTorrent->setOptions(connections, upload * 1024, download * 1024);

    wControllerTorrent->setSizeMax(qint64(cache) * 1048576);
#endif
}

/* Q_INVOKABLE static */ void ControllerCore::applyCover(WDeclarativeImage * item)
{
    Q_ASSERT(item);

    QImage image = WBarcodeWriter::generateCover(item->toImage());

    item->applyImage(image);
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ bool ControllerCore::checkUrl(const QString & text)
{
    return WControllerNetwork::textIsUri(text);
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

/* Q_INVOKABLE static */ void ControllerCore::updateCache(WPlaylist * playlist, int index)
{
    if (playlist == NULL || index == -1) return;

    QStringList urls;

    int count = 3;

    for (int i = index - 1; count && i > -1; i--)
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

    browse.label = "browser";

    _backends->addItem(browse);
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::createIndex()
{
#ifdef SK_NO_TORRENT
    _index = new WBackendIndex(WControllerFile::fileUrl(_path + "/backend/indexLite.vbml"));
#else
    _index = new WBackendIndex(WControllerFile::fileUrl(_path + "/backend/index.vbml"));
#endif

    connect(_index, SIGNAL(loaded()), this, SLOT(onIndexLoaded()));

    emit indexChanged();
}

//-------------------------------------------------------------------------------------------------

WControllerFileReply * ControllerCore::copyBackends(const QString & path) const
{
#ifdef SK_DEPLOY
#ifdef Q_OS_ANDROID
    return WControllerPlaylist::copyBackends("assets:/backend", path);
#else
    return WControllerPlaylist::copyBackends(WControllerFile::applicationPath("backend"), path);
#endif
#else
    return WControllerPlaylist::copyBackends(WControllerFile::applicationPath(PATH_BACKEND), path);
#endif
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::writeVbml(const QString & title, const QString & vbml)
{
    if (_pathDocuments.isNull())
    {
        _pathDocuments = WControllerFile::pathDocuments() + '/' + sk->name();

        // NOTE: We create the path when saving our first file.
        wControllerFile->startCreatePath(_pathDocuments);
    }

#ifdef Q_OS_ANDROID
    _fileVbml = _pathDocuments + '/'
                +
                WBarcodeWriter::getTagName(title, QString()) + ".vbml";

    writeVbmlFile(_fileVbml, vbml);
#else
    QString fileName = _pathDocuments + '/'
                       +
                       WBarcodeWriter::getTagName(title, QString()) + ".vbml";

    writeVbmlFile(fileName, vbml);
#endif
}

void ControllerCore::writeVbmlFile(const QString & title, const QString & vbml)
{
    WControllerFileReply * reply = wControllerFile->startWriteFile(title, vbml.toUtf8());

    connect(reply, SIGNAL(complete(bool)), this, SLOT(onVbmlSaved(bool)));
}

void ControllerCore::writeTag(const QString & title,      const QString & vbml,
                              const QString & background, const QString & cover,
                              const QString & prefix,     int             padding)
{
    if (_pathPictures.isNull())
    {
        _pathPictures = WControllerFile::pathPictures() + '/' + sk->name();

        // NOTE: We create the path when saving our first file.
        wControllerFile->startCreatePath(_pathPictures);
    }

#ifdef Q_OS_ANDROID
    _fileTag = _pathPictures + '/' + WBarcodeWriter::getTagName(title) + ".png";

    writeTagFile(_fileTag, vbml, background, cover, prefix, padding, SLOT(onTagSaved(bool)));
#else
    QString fileName = _pathPictures + '/' + WBarcodeWriter::getTagName(title) + ".png";

    writeTagFile(fileName, vbml, background, cover, prefix, padding, SLOT(onTagSaved(bool)));
#endif
}

void ControllerCore::writeTagFile(const QString & fileName,   const QString & vbml,
                                  const QString & background, const QString & cover,
                                  const QString & prefix,     int             padding,
                                  const char    * method)
{
    WBarcodeTag parameters;

    if (cover.isEmpty() == false)
    {
        parameters.cover = wControllerFile->getFileUrl(cover);
    }

    parameters.prefix  = prefix;
    parameters.padding = padding;

    WBarcodeWriter::startWriteTagFile(fileName, vbml, background, this, method, parameters);
}

//-------------------------------------------------------------------------------------------------

QString ControllerCore::getFile(const QString & title, const QString & filter)
{
#ifdef SK_DESKTOP
    if (_pathOpen.isEmpty()) _pathOpen = QDir::rootPath();

    QString path = QFileDialog::getOpenFileName(NULL, title, _pathOpen, filter);

    if (path.isEmpty()) return QString();

    QFileInfo info(path);

    _pathOpen = info.absolutePath();

    return WControllerFile::fileUrl(info.absoluteFilePath());
#else
    Q_UNUSED(title); Q_UNUSED(filter);

    return QString();
#endif
}

//-------------------------------------------------------------------------------------------------
// Private slots
//-------------------------------------------------------------------------------------------------

void ControllerCore::onLoaded()
{
    createIndex();
}

void ControllerCore::onIndexLoaded()
{
    disconnect(_index, SIGNAL(loaded()), this, SLOT(onIndexLoaded()));

    connect(_index, SIGNAL(updated()), this, SLOT(onUpdated()));

    connect(_index, SIGNAL(backendUpdated(const QString &)),
            this,   SLOT(onBackendUpdated(const QString &)));

    if (_backends->count() == 1)
    {
        _index->createFolderItems(_backends, WLibraryItem::FolderSearchable);
    }

#if defined(SK_BACKEND_LOCAL) && defined(SK_DEPLOY) == false
    // NOTE: This makes sure that we have the latest local vbml loaded.
    resetBackends();

    // NOTE: We want to reload backends when the folder changes.
    _watcher.addFolder(WControllerFile::applicationPath(PATH_BACKEND));

    connect(&_watcher, SIGNAL(foldersModified(const QString &, const QStringList &)),
            this,      SLOT(resetBackends()));
#else
    _index->update();
#endif
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::onUpdated()
{
    QString label = _backends->itemLabel(_backends->currentIndex());

    _backends->clearItems();

    createBrowse();

    _index->createFolderItems(_backends, WLibraryItem::FolderSearchable);

    // NOTE: We restore the previous selection based on the label.
    int index = _backends->indexFromLabel(label);

    if (index == -1)
    {
         _backends->setCurrentIndex(0);
    }
    else _backends->setCurrentIndex(index);
}

void ControllerCore::onReload()
{
    if (_index == NULL) return;

    _index->clearCache();

    _index->reload();

    _index->reloadBackends();

    WBackendUniversal::clearCache();
}

void ControllerCore::onBackendUpdated(const QString & id)
{
    int index = _backends->indexFromLabel(id);

    if (index == -1) return;

    WLibraryItem * item = _backends->createLibraryItemAt(index);

    item->reloadQuery();
}

void ControllerCore::onFeedChanged()
{
    QString label = _feeds->itemLabel(_feeds->currentIndex());

    if (label == "suggest" && _loaderSuggest == NULL)
    {
        if (_feeds->itemLabel(0) != "tracks") return;

        _loaderSuggest = new WLoaderSuggest(_feeds, _feeds->currentId());

        WPlaylist * history = _feeds->createLibraryItemAt(0, true)->toPlaylist();

        _loaderSuggest->setHistory(history);

        _loaderSuggest->start();
    }
    else if (label == "recent" && _loaderRecent == NULL)
    {
        _loaderRecent = new WLoaderRecent(_feeds, _feeds->currentId());

        _loaderRecent->setFeeds(_feeds);

        _loaderRecent->start();
    }
    else if (label == "interactive" && _loaderInteractive == NULL)
    {
        if (_feeds->itemLabel(0) != "tracks") return;

        _loaderInteractive = new WLoaderTracks(_feeds, _feeds->currentId());

        _loaderInteractive->addType(WTrack::Hub);
        _loaderInteractive->addType(WTrack::Channel);
        _loaderInteractive->addType(WTrack::Interactive);

        WPlaylist * history = _feeds->createLibraryItemAt(0, true)->toPlaylist();

        _loaderInteractive->setHistory(history);

        QStringList hubs;

        hubs.append("https://omega.gg/vox");
        hubs.append("https://vox.omega.gg/w/9d5fYXTcjLHReVUQabKRwB"); // tmdb
        hubs.append("https://vox.omega.gg/w/1bygNVLjD7P5Ande3BKktN"); // twitch
        hubs.append("https://vox.omega.gg/w/azQbNtC41sMW7RYge9qBrV"); // netflix
        hubs.append("https://vox.omega.gg/w/u7LcNmoaU3AU82PBjFHG72"); // disney
        hubs.append("https://vox.omega.gg/w/pAtEEiZ13ezKCcgEHnnXY1"); // apple
        hubs.append("https://vox.omega.gg/w/aHy9qfys6ZHzWHVANxX7fp"); // max
        hubs.append("https://vox.omega.gg/w/cZwGXA9WztBQX1npkRCnd3"); // blender

        _loaderInteractive->setBaseUrls(hubs);

        _loaderInteractive->start();
    }
}

void ControllerCore::onFeedUpdated()
{
    if (_feeds->itemLabel(1) != "suggest" && _loaderSuggest)
    {
        WPlaylist * history = _loaderSuggest->history();

        if (history) history->tryDelete();

        delete _loaderSuggest;

        _loaderSuggest = NULL;
    }

    if (_feeds->itemLabel(2) == "recent" && _loaderRecent)
    {
        delete _loaderRecent;

        _loaderRecent = NULL;
    }

    if (_feeds->itemLabel(3) == "interactive" && _loaderInteractive)
    {
        WPlaylist * history = _loaderInteractive->history();

        if (history) history->tryDelete();

        delete _loaderInteractive;

        _loaderInteractive = NULL;
    }
}

void ControllerCore::onMediaLoaded(WMediaReply * reply)
{
    QStringList listA;
    QStringList listB;

    QHash<WAbstractBackend::Quality, QString> medias = reply->medias();
    QHash<WAbstractBackend::Quality, QString> audios = reply->audios();

    for (int i = 0; i <= WAbstractBackend::Quality2160; i++)
    {
        WAbstractBackend::Quality quality = static_cast<WAbstractBackend::Quality> (i);

        listA.append(medias.value(quality));

        QString source = audios.value(quality);

        if (listB.contains(source))
        {
             listB.append(QString());
        }
        else listB.append(source);

    }

    emit linksLoaded(listA, listB);
}

void ControllerCore::onQueryEnded()
{
    if (_playlist->isEmpty()) return;

    disconnect(_playlist, 0, this, 0);

    WTrack track = _playlist->getTrackAt(0);

    _playlist->clearTracks();

    if (_playlistTrack->trackTitle(0) == _query)
    {
        _playlistTrack->removeTrack(0);

        _playlistTrack->insertTrack(0, track);

        _playlistTrack->loadTrack(0);
    }

    _playlistTrack->tryDelete();
}

void ControllerCore::onQueryCompleted()
{
    disconnect(_playlist, 0, this, 0);

    _playlist->clearTracks();

    _playlistTrack->tryDelete();
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::onVbmlSaved(bool ok)
{
#ifdef Q_OS_ANDROID
    // NOTE android: We have to trigger a scan on the file. Otherwise it won't show up in other
    //               applications. Yes, that's messed up.
    if (ok) Sk::scanFile(_fileVbml);
#endif

    emit vbmlSaved(ok, _pathDocuments);
}

void ControllerCore::onTagSaved(bool ok)
{
#ifdef Q_OS_ANDROID
    // NOTE android: We have to trigger a scan on the file. Otherwise it won't show up in other
    //               applications. Yes, that's messed up.
    if (ok) Sk::scanFile(_fileTag);
#endif

    emit tagSaved(ok, _pathPictures);
}

//-------------------------------------------------------------------------------------------------
// Properties
//-------------------------------------------------------------------------------------------------

#ifdef SK_DESKTOP

QString ControllerCore::argument() const
{
    return _argument;
}

#endif

//-------------------------------------------------------------------------------------------------

bool ControllerCore::cacheIsEmpty() const
{
    return _cache->isEmpty();
}

//-------------------------------------------------------------------------------------------------

QString ControllerCore::version() const
{
    return CORE_VERSION;
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

WBackendIndex * ControllerCore::index() const
{
    return _index;
}

//-------------------------------------------------------------------------------------------------

WHookOutput * ControllerCore::output() const
{
    return _output;
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

#ifdef QT_NEW

QString ControllerCore::cameraId() const
{
    return _cameraId;
}

#endif

//-------------------------------------------------------------------------------------------------

QString ControllerCore::pathStorage() const
{
    return _path;
}

QString ControllerCore::pathSplash() const
{
    return _pathSplash;
}

QString ControllerCore::pathShots() const
{
    return _path + "/screenshots";
}
