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

#ifndef CONTROLLERCORE_H
#define CONTROLLERCORE_H

// Qt includes
#include <QDateTime>

// Sk includes
#include <WController>
#include <WLibraryItem>
#ifndef SK_DEPLOY
#include <WFileWatcher>
#endif

// Defines
#define core ControllerCore::instance()

// Forward declarations
//class QNetworkDiskCache;
class WControllerFileReply;
class WAbstractBackend;
class WAbstractHook;
class WWindow;
class WCache;
class WLoaderNetwork;
class WLoaderWeb;
class WBackendIndex;
class WBackendNet;
class WLibraryFolderRelated;
class WTabsTrack;
class DataLocal;
class DataOnline;

class ControllerCore : public WController
{
    Q_OBJECT

    Q_PROPERTY(QString argument READ argument CONSTANT)

    Q_PROPERTY(QString log READ log NOTIFY logChanged)

    Q_PROPERTY(bool cacheIsEmpty READ cacheIsEmpty NOTIFY cacheEmptyChanged)

    Q_PROPERTY(QString version     READ version     CONSTANT)
    Q_PROPERTY(QString versionName READ versionName CONSTANT)

    Q_PROPERTY(WLibraryFolder        * library  READ library  NOTIFY libraryChanged)
    Q_PROPERTY(WLibraryFolder        * feeds    READ feeds    NOTIFY feedsChanged)
    Q_PROPERTY(WLibraryFolder        * backends READ backends NOTIFY backendsChanged)
    Q_PROPERTY(WLibraryFolderRelated * related  READ related  NOTIFY relatedChanged)

    Q_PROPERTY(WTabsTrack * tabs READ tabs CONSTANT)

    Q_PROPERTY(QDateTime dateCover   READ dateCover   WRITE setDateCover NOTIFY dateCoverChanged)
    Q_PROPERTY(QDateTime datePreview READ datePreview WRITE setDatePreview
               NOTIFY datePreviewChanged)

    Q_PROPERTY(QString pathStorage READ pathStorage CONSTANT)
    Q_PROPERTY(QString pathSplash  READ pathSplash  CONSTANT)

private:
    ControllerCore();

    /* virtual */ ~ControllerCore();

public: // Interface
    Q_INVOKABLE void load();

    Q_INVOKABLE bool updateVersion();

    Q_INVOKABLE void resetBackends() const;

    Q_INVOKABLE QString openFile    (const QString & title);
    Q_INVOKABLE QString openFolder  (const QString & title);
    Q_INVOKABLE QString openSubtitle(const QString & title);

    Q_INVOKABLE void saveShot  (WWindow * window)             const;
    Q_INVOKABLE void saveSplash(WWindow * window, int border) const;

    Q_INVOKABLE void applyProxy(bool active);

    Q_INVOKABLE void applyArguments(int & argc, char ** argv);

    Q_INVOKABLE void addLog(const QString & message);

    Q_INVOKABLE void clearCache();

public: // Static functions
    Q_INVOKABLE static void applyTorrentOptions(int connections, int upload, int download,
                                                                             int cache);

    Q_INVOKABLE static WAbstractHook * createHook(WAbstractBackend * backend);

    //---------------------------------------------------------------------------------------------

    Q_INVOKABLE static QString extractArgument(const QString & message);

    //---------------------------------------------------------------------------------------------

    Q_INVOKABLE static bool checkUrl(const QString & text);

    Q_INVOKABLE static int urlType(const QString & url);

    //---------------------------------------------------------------------------------------------

    Q_INVOKABLE static int itemType(WLibraryFolder * folder, int index);

    Q_INVOKABLE static int itemState     (WLibraryFolder * folder, int index);
    Q_INVOKABLE static int itemStateQuery(WLibraryFolder * folder, int index);

    Q_INVOKABLE static int getPlaylistType(WBackendNet * backend, const QString & url);

    Q_INVOKABLE static WLibraryFolder * createFolder  (int type = WLibraryItem::Folder);
    Q_INVOKABLE static WPlaylist      * createPlaylist(int type = WLibraryItem::Playlist);

    Q_INVOKABLE static void addFolderSearch(WLibraryFolder * folder, const QString & title);

    Q_INVOKABLE static int idFromTitle(WLibraryFolder * folder, const QString & title);

    Q_INVOKABLE static QString getQuery(const QString & title);

    //---------------------------------------------------------------------------------------------

    Q_INVOKABLE static void updateCache(WPlaylist * playlist, int index);

    Q_INVOKABLE static void clearTorrentCache();

protected: // Events
    /* virtual */ void timerEvent(QTimerEvent * event);

private: // Functions
    WLibraryFolder * createLibrary(int id);

    void createBrowse() const;
    void deleteBrowse() const;

    WControllerFileReply * copyBackends(const QString & path) const;

#ifndef SK_DEPLOY
    void applyWatcher();
#endif

    QString getFile(const QString & title, const QString & filter);

private slots:
    void onLoaded();

    void onIndexLoaded();

    void onReload();

signals:
    void logChanged();

    void cacheEmptyChanged();

    void libraryChanged ();
    void feedsChanged   ();
    void backendsChanged();
    void relatedChanged ();

    void dateCoverChanged  ();
    void datePreviewChanged();

public: // Properties
    QString argument() const;

    QString log() const;

    bool cacheIsEmpty() const;

    QString version    () const;
    QString versionName() const;

    WTabsTrack * tabs() const;

    WLibraryFolder        * library () const;
    WLibraryFolder        * feeds   () const;
    WLibraryFolder        * backends() const;
    WLibraryFolderRelated * related () const;

    QDateTime dateCover() const;
    void      setDateCover(const QDateTime & date);

    QDateTime datePreview() const;
    void      setDatePreview(const QDateTime & date);

    QString pathStorage() const;
    QString pathSplash () const;

private: // Variables
    QString _argument;

    QString _log;

    WCache * _cache;

    //QNetworkDiskCache * _diskCache;

    DataLocal  * _local;
    DataOnline * _online;

    WTabsTrack * _tabs;

    WLibraryFolder        * _library;
    WLibraryFolder        * _feeds;
    WLibraryFolder        * _backends;
    WLibraryFolderRelated * _related;

    WLoaderNetwork * _loaderMedia;
    //WLoaderWeb     * _loaderWeb;

    WBackendIndex * _index;

    QDateTime _dateCover;
    QDateTime _datePreview;

    QString _pathSplash;
    QString _pathOpen;

#ifndef SK_DEPLOY
    WFileWatcher _watcher;
#endif

private:
    Q_DISABLE_COPY      (ControllerCore)
    W_DECLARE_CONTROLLER(ControllerCore)
};

#endif // CONTROLLERCORE_H
