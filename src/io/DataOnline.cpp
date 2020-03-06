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
*/
//=================================================================================================

#include "DataOnline.h"

// Qt includes
#include <QXmlStreamReader>
#ifndef SK_DEPLOY
#include <QDir>
#endif

// Sk includes
#include <WControllerDownload>
#include <WControllerXml>

//-------------------------------------------------------------------------------------------------
// Static variables

#ifdef Q_OS_LINUX
#ifdef Q_PROCESSOR_X86_32
static const QString ONLINE_PATH = "http://omega.gg/get/MotionBox/1.0.0/linux32/";
#else
static const QString ONLINE_PATH = "http://omega.gg/get/MotionBox/1.0.0/linux64/";
#endif
#else
#ifdef Q_PROCESSOR_X86_32
static const QString ONLINE_PATH = "http://omega.gg/get/MotionBox/1.0.0/win32/";
#else
static const QString ONLINE_PATH = "http://omega.gg/get/MotionBox/1.0.0/win64/";
#endif
#endif

//-------------------------------------------------------------------------------------------------
// Ctor / dtor
//-------------------------------------------------------------------------------------------------

/* explicit */ DataOnline::DataOnline(QObject * parent) : QObject(parent) {}

//-------------------------------------------------------------------------------------------------
// Interface
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void DataOnline::load()
{
#ifdef SK_DEPLOY
    loadFile();

    startTimer(3600000); // 1 hour
#endif
}

/* Q_INVOKABLE */ void DataOnline::loadMessage()
{
    if (_messageText.isEmpty() || _message.isEmpty() == false) return;

    WRemoteData * data = wControllerDownload->getData(_messageText, this);

    connect(data, SIGNAL(loaded(WRemoteData *)), this, SLOT(onLoadedMessage(WRemoteData *)));
}

//-------------------------------------------------------------------------------------------------
// Events
//-------------------------------------------------------------------------------------------------

/* virtual */ void DataOnline::timerEvent(QTimerEvent *)
{
    loadFile();
}

//-------------------------------------------------------------------------------------------------
// Private functions
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void DataOnline::loadFile()
{
    WRemoteData * data = wControllerDownload->getData(generateUrl("data.xml"), this);

    connect(data, SIGNAL(loaded(WRemoteData *)), this, SLOT(onLoaded(WRemoteData *)));
}

//-------------------------------------------------------------------------------------------------

QString DataOnline::generateUrl(const QString & string) const
{
    if (QUrl(string).isRelative())
    {
         return ONLINE_PATH + string;
    }
    else return string;
}

//-------------------------------------------------------------------------------------------------
// Private slots
//-------------------------------------------------------------------------------------------------

void DataOnline::onLoaded(WRemoteData * data)
{
    _version    = QString();
    _messageUrl = QString();

    QXmlStreamReader stream(data->reply());

    while (stream.atEnd() == false)
    {
        QXmlStreamReader::TokenType type = stream.readNext();

        if (type != QXmlStreamReader::StartElement) continue;

        if (stream.name() == "version")
        {
            _version = WControllerXml::readNextString(&stream);
        }
        else if (stream.name() == "messageUrl")
        {
            _messageUrl = generateUrl(WControllerXml::readNextString(&stream));
        }
        else if (stream.name() == "messageIcon")
        {
            _messageIcon = generateUrl(WControllerXml::readNextString(&stream));
        }
        else if (stream.name() == "messageTitle")
        {
            _messageTitle = WControllerXml::readNextString(&stream);
        }
        else if (stream.name() == "messageCover")
        {
            _messageCover = generateUrl(WControllerXml::readNextString(&stream));
        }
        else if (stream.name() == "messageText")
        {
            _messageText = generateUrl(WControllerXml::readNextString(&stream));
        }
    }

    emit dataChanged();
}

void DataOnline::onLoadedMessage(WRemoteData * data)
{
    _message = data->readAll();

    emit messageChanged();
}

//-------------------------------------------------------------------------------------------------
// Properties
//-------------------------------------------------------------------------------------------------

QString DataOnline::version() const
{
    return _version;
}

//-------------------------------------------------------------------------------------------------

QString DataOnline::messageUrl() const
{
    return _messageUrl;
}

QString DataOnline::messageIcon() const
{
    return _messageIcon;
}

QString DataOnline::messageTitle() const
{
    return _messageTitle;
}

QString DataOnline::messageCover() const
{
    return _messageCover;
}

QString DataOnline::messageText() const
{
    return _messageText;
}

//-------------------------------------------------------------------------------------------------

QString DataOnline::message() const
{
    return _message;
}
