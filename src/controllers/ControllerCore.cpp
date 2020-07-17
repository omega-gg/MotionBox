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
#include <QProcess>
#include <QFileDialog>

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
//#include <WLoaderWeb>
#include <WLoaderTorrent>
#include <WHookTorrent>
#include <WLibraryFolderRelated>
#include <WAbstractTabs>
#include <WAbstractTab>
#include <WTabsTrack>
#include <WTabTrack>
#include <WBackendVlc>
#include <WBackendSubtitle>
#include <WBackendIndex>
#include <WBackendUniversal>
#include <WModelList>
#include <WModelLibraryFolder>
#include <WModelPlaylist>
#include <WModelRange>
#include <WModelCompletionGoogle>
#include <WModelContextual>
#include <WModelTabs>
#include <WImageColorFilter>
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
#include <WDeclarativePlayer>

// Application includes
#include "DataLocal.h"
#include "DataOnline.h"

W_INIT_CONTROLLER(ControllerCore)

//-------------------------------------------------------------------------------------------------
// Static variables

static const QString CORE_VERSION = "1.6.0-6";

static const int LOG_LENGTH = 4000;

#ifndef SK_DEPLOY
#ifdef Q_OS_MAC
static const QString PATH_STORAGE = "/../../../storage";
static const QString PATH_BACKEND = "../../../../../backend";
#else
static const QString PATH_STORAGE = "/storage";
static const QString PATH_BACKEND = "../../backend";
#endif
#endif

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
    QString path = WControllerFile::pathWritable();

    wControllerFile->setPathStorage(QDir::fromNativeSeparators(path));
#else
    QString path = QDir::currentPath() + PATH_STORAGE;

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
        clearStorage();
    }
    else if (_local->_splashWidth != -1)
    {
        _pathSplash = WControllerFile::fileUrl(path + "/splash.png");
    }

    //---------------------------------------------------------------------------------------------
    // QML
    //---------------------------------------------------------------------------------------------
    // Qt

    qmlRegisterUncreatableType<QAbstractItemModel>("Sky", 1,0, "QAbstractItemModel",
                                                   "QAbstractItemModel is abstract");

    //---------------------------------------------------------------------------------------------
    // Global

    qmlRegisterUncreatableType<WControllerDeclarative>("Sky", 1,0, "Sk", "Sk is not creatable");

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

    qmlRegisterType<WImageColorFilter>("Sky", 1,0, "ImageColorFilter");

    qmlRegisterType<WDeclarativeGradient>    ("Sky", 1,0, "ScaleGradient");
    qmlRegisterType<WDeclarativeGradientStop>("Sky", 1,0, "ScaleGradientStop");

    //---------------------------------------------------------------------------------------------
    // Declarative

    qmlRegisterType<WDeclarativeMouseArea>   ("Sky", 1,0, "MouseArea");
    qmlRegisterType<WDeclarativeMouseWatcher>("Sky", 1,0, "MouseWatcher");
    qmlRegisterType<WDeclarativeDrag>        ("Sky", 1,0, "Drag");

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

    qmlRegisterType<WDeclarativePlayer>("Sky", 1,0, "Player");

    //---------------------------------------------------------------------------------------------
    // Models

    qmlRegisterType<WModelList>("Sky", 1,0, "ModelList");

    qmlRegisterType<WModelLibraryFolder>        ("Sky", 1,0, "ModelLibraryFolder");
    qmlRegisterType<WModelLibraryFolderFiltered>("Sky", 1,0, "ModelLibraryFolderFiltered");

    qmlRegisterType<WModelPlaylist>("Sky", 1,0, "ModelPlaylist");

    qmlRegisterType<WModelRange>("Sky", 1,0, "ModelRange");

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

    qmlRegisterUncreatableType<WLocalObject>("Sky", 1,0, "LocalObject", "LocalObject is abstract");

    qmlRegisterUncreatableType<WLibraryItem>("Sky", 1,0, "LibraryItem", "LibraryItem is abstract");

    qmlRegisterType<WLibraryFolder>       ("Sky", 1,0, "LibraryFolder");
    qmlRegisterType<WLibraryFolderRelated>("Sky", 1,0, "LibraryFolderRelated");

    qmlRegisterType<WPlaylist>("Sky", 1,0, "Playlist");

    qmlRegisterType<WTabTrack> ("Sky", 1,0, "TabTrack");
    qmlRegisterType<WTabsTrack>("Sky", 1,0, "BaseTabsTrack");

    qmlRegisterType<WBackendVlc>     ("Sky", 1,0, "BackendVlc");
    qmlRegisterType<WBackendSubtitle>("Sky", 1,0, "BackendSubtitle");

    //---------------------------------------------------------------------------------------------
    // Events

    qmlRegisterUncreatableType<WDeclarativeMouseEvent>("Sky", 1,0, "DeclarativeMouseEvent",
                                                       "DeclarativeMouseEvent is not creatable");

    qmlRegisterUncreatableType<WDeclarativeDropEvent>("Sky", 1,0, "DeclarativeDropEvent",
                                                      "DeclarativeDropEvent is not creatable");

    qmlRegisterUncreatableType<WDeclarativeKeyEvent>("Sky", 1,0, "DeclarativeKeyEvent",
                                                     "DeclarativeKeyEvent is not creatable");

    //---------------------------------------------------------------------------------------------
    // MotionBox

    qmlRegisterType<DataLocal>("Sky", 1,0, "DataLocal");

    //---------------------------------------------------------------------------------------------
    // Context

    wControllerDeclarative->setContextProperty("sk",                sk);
    wControllerDeclarative->setContextProperty("controllerFile",    wControllerFile);
    wControllerDeclarative->setContextProperty("controllerNetwork", wControllerNetwork);

    wControllerDeclarative->setContextProperty("core",  this);
    wControllerDeclarative->setContextProperty("local", _local);
}

//-------------------------------------------------------------------------------------------------
// Interface
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::load()
{
    if (_cache) return;

    _pathOpen = QDir::rootPath();

    //---------------------------------------------------------------------------------------------
    // Message handler

    // FIXME Qt4.8.7: qInstallMsgHandler breaks QML 'Keys' events.
#ifndef QT_4
    wControllerFile->initMessageHandler();
#endif

    //---------------------------------------------------------------------------------------------
    // Controllers

    QString path = pathStorage();

    W_CREATE_CONTROLLER(WControllerPlaylist);
    W_CREATE_CONTROLLER(WControllerMedia);

    W_CREATE_CONTROLLER_1(WControllerTorrent, path + "/torrents");

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

        _backends->setCurrentIndex(0);

        WControllerFileReply * reply = copyBackends(path + "/backend/");

        connect(reply, SIGNAL(actionComplete(bool)), this, SLOT(onLoaded()));
    }
    else createIndex(path + "/backend");

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

/* Q_INVOKABLE */ void ControllerCore::updateBackends() const
{
    if (_index == NULL) return;

    _index->update();
}

/* Q_INVOKABLE */ void ControllerCore::resetBackends() const
{
    WControllerFileReply * reply = copyBackends(pathStorage() + "/backend/");

    connect(reply, SIGNAL(actionComplete(bool)), this, SLOT(onReload()));
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
    QImage image = window->takeShot(0, 0, window->width(), window->height());

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
                                                 window->height() - border2x);
    }
    else image = window->takeShot(0, 0, window->width(), window->height());

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

/* Q_INVOKABLE */ void ControllerCore::clearCache()
{
    _related->clearItems();

    _backends->clearItems();

    createBrowse();

    _backends->setCurrentIndex(0);

    if (_index)
    {
        _index->createFolderItems(_backends);

        WBackendLoader::clearCache();
    }

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

    browse.label = "browser";

    _backends->addItem(browse);
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::createIndex(const QString & path)
{
    _index = new WBackendIndex(WControllerFile::fileUrl(path));

    connect(_index, SIGNAL(loaded()), this, SLOT(onIndexLoaded()));
}

//-------------------------------------------------------------------------------------------------

WControllerFileReply * ControllerCore::copyBackends(const QString & path) const
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

    if (QFile::exists(path))
    {
         wControllerFile->startDeleteFolderContent(path);
    }
    else wControllerFile->startCreateFolder(path);

    return wControllerFile->startCopyFiles(fileNames, newNames);
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::resetBrowse() const
{
    QString label = _backends->itemLabel(_backends->currentIndex());

    _backends->clearItems();

    createBrowse();

    _index->createFolderItems(_backends);

    int index = _backends->indexFromLabel(label);

    if (index == -1)
    {
         _backends->setCurrentIndex(0);
    }
    else _backends->setCurrentIndex(index);
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::clearStorage() const
{
    QString path = pathStorage();

    WControllerFile::deleteFolder(path + "/backend");
    WControllerFile::deleteFolder(path + "/cache");
    WControllerFile::deleteFolder(path + "/torrents");

    path.append("/playlists/");

    WControllerFile::deleteFolder(path + "3");
    WControllerFile::deleteFolder(path + "4");

    WControllerFile::deleteFile(path + "3.xml");
    WControllerFile::deleteFile(path + "4.xml");

    _local->setBrowserVisible(false);

    _local->setQuery(QString());

    _local->setCache(false);
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
    createIndex(pathStorage() + "/backend");
}

void ControllerCore::onIndexLoaded()
{
    disconnect(_index, SIGNAL(loaded()), this, SLOT(onIndexLoaded()));

    connect(_index, SIGNAL(updated()), this, SLOT(onUpdated()));

    connect(_index, SIGNAL(backendUpdated(QString)), this, SLOT(onBackendUpdated(QString)));

    if (_backends->count() == 1)
    {
        _index->createFolderItems(_backends);
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
    resetBrowse();
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::onReload()
{
    WBackendLoader::clearCache();

    if (_index) _index->reload();

    WBackendLoader::reloadBackends();
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::onBackendUpdated(const QString & id)
{
    int index = _backends->indexFromLabel(id);

    if (index == -1) return;

    WLibraryItem * item = _backends->createLibraryItemAt(index);

    item->reloadQuery();
}

//-------------------------------------------------------------------------------------------------
// Properties
//-------------------------------------------------------------------------------------------------

QString ControllerCore::argument() const
{
    return _argument;
}

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
