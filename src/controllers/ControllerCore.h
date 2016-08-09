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

#ifndef CONTROLLERCORE_H
#define CONTROLLERCORE_H

// Qt includes
#include <QDateTime>

// Sk includes
#include <WController>
#include <WLibraryItem>

// Defines
#define core ControllerCore::instance()

// Forward declarations
class QNetworkDiskCache;
class QSize;
class WAbstractBackend;
class WAbstractHook;
class WWindow;
class WDeclarativeContextualPage;
class WCache;
class WLoaderNetwork;
class WLoaderWeb;
class WBackendNet;
class WTabsTrack;
class DataLocal;
class DataOnline;

class ControllerCore : public WController
{
    Q_OBJECT

    Q_PROPERTY(bool cacheIsEmpty READ cacheIsEmpty NOTIFY cacheEmptyChanged)

    Q_PROPERTY(QString version     READ version     CONSTANT)
    Q_PROPERTY(QString versionName READ versionName CONSTANT)

    Q_PROPERTY(WLibraryFolder        * library READ library NOTIFY libraryChanged)
    Q_PROPERTY(WLibraryFolder        * hubs    READ hubs    NOTIFY hubsChanged)
    Q_PROPERTY(WLibraryFolderRelated * related READ related NOTIFY relatedChanged)

    Q_PROPERTY(WTabsTrack * tabs READ tabs CONSTANT)

    Q_PROPERTY(QDateTime dateCover   READ dateCover   WRITE setDateCover NOTIFY dateCoverChanged)
    Q_PROPERTY(QDateTime datePreview READ datePreview WRITE setDatePreview
               NOTIFY datePreviewChanged)

    Q_PROPERTY(QString pathStorage READ pathStorage CONSTANT)
    Q_PROPERTY(QString pathSplash  READ pathSplash  CONSTANT)

private:
    ControllerCore();

public: // Interface
    Q_INVOKABLE void preload();
    Q_INVOKABLE void load   ();

    Q_INVOKABLE bool updateVersion();

    Q_INVOKABLE QString openFile  (const QString & title);
    Q_INVOKABLE QString openFolder(const QString & title);

    Q_INVOKABLE void saveShot  (WWindow * window);
    Q_INVOKABLE void saveSplash(WWindow * window, int border);

    Q_INVOKABLE void applyProxy(bool active);

    Q_INVOKABLE WAbstractHook * createHook(WAbstractBackend * backend) const;

    //---------------------------------------------------------------------------------------------

    Q_INVOKABLE bool checkUrl(const QString & text) const;

    Q_INVOKABLE bool textIsUrl (const QString & text) const;
    Q_INVOKABLE bool textIsPath(const QString & text) const;

    Q_INVOKABLE int urlType(const QUrl & url) const;

    //---------------------------------------------------------------------------------------------

    Q_INVOKABLE int itemType(WLibraryFolder * folder, int index) const;

    Q_INVOKABLE int itemState     (WLibraryFolder * folder, int index) const;
    Q_INVOKABLE int itemStateQuery(WLibraryFolder * folder, int index) const;

    Q_INVOKABLE int getPlaylistType(WBackendNet * backend, const QUrl & url) const;

    Q_INVOKABLE WLibraryFolder * createFolder  (int type = WLibraryItem::Folder)      const;
    Q_INVOKABLE WPlaylistNet   * createPlaylist(int type = WLibraryItem::PlaylistNet) const;

    Q_INVOKABLE int idFromTitle(WLibraryFolder * folder, const QString & title) const;

    //---------------------------------------------------------------------------------------------

    Q_INVOKABLE void updateCache(WPlaylistNet * playlist, int index) const;

    Q_INVOKABLE void clearCache();

protected: // Events
    /* virtual */ void timerEvent(QTimerEvent * event);

private: // Functions
    void createBrowse ();
    void restoreBrowse();

    void deleteBrowse();

signals:
    void cacheEmptyChanged();

    void libraryChanged();
    void hubsChanged   ();
    void relatedChanged();

    void dateCoverChanged  ();
    void datePreviewChanged();

public: // Properties
    bool cacheIsEmpty() const;

    QString version    () const;
    QString versionName() const;

    WTabsTrack * tabs() const;

    WLibraryFolder        * library() const;
    WLibraryFolder        * hubs   () const;
    WLibraryFolderRelated * related() const;

    QDateTime dateCover() const;
    void      setDateCover(const QDateTime & date);

    QDateTime datePreview() const;
    void      setDatePreview(const QDateTime & date);

    QString pathStorage() const;
    QString pathSplash () const;

private: // Variables
    WCache * _cache;

    QNetworkDiskCache * _diskCache;

    DataLocal  * _local;
    DataOnline * _online;

    WTabsTrack * _tabs;

    WLibraryFolder        * _library;
    WLibraryFolder        * _hubs;
    WLibraryFolderRelated * _related;

    WLoaderNetwork * _loaderMedia;
    WLoaderWeb     * _loaderWeb;

    QDateTime _dateCover;
    QDateTime _datePreview;

    QString _pathSplash;
    QString _pathOpen;

private:
    Q_DISABLE_COPY      (ControllerCore)
    W_DECLARE_CONTROLLER(ControllerCore)
};

#endif // CONTROLLERCORE_H
