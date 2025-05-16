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

import QtQuick      1.0
import QtMultimedia 1.0

import Sky 1.0

VideoOutput
{
//#QT_6
    id: pageCamera
//#END

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property int size: Math.min(parent.width, parent.height) / 2

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.fill: parent

    opacity: 0.0

//#QT_5
    autoOrientation: true

    // NOTE macOS/Qt5: We have to ensure the camera is valid, otherwise we crash.
    source: (camera.deviceId) ? camera : null

    filters: (imageTarget.visible) ? [ filter ] : null
//#END

    fillMode: VideoOutput.PreserveAspectCrop

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
        pApplyCamera();

//#QT_6
        // NOTE Qt6: We need to start the camera manually.
        camera.start();
//#END

        opacity = 1.0;
    }

    onSizeChanged: pUpdateTarget()

    // NOTE: It's important to handle these two to get the proper target. The contentRect might
    //       change fairly often and be incorrect at first.
    onSourceRectChanged : pUpdateTarget()
    onContentRectChanged: pUpdateTarget()

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Private

    function pApplyCamera()
    {
//#QT_5
        // NOTE: Apparently availableCameras does not update itself.
        if (core.applyCameras(QtMultimedia.availableCameras))
//#ELSE
        var ids = new Array;

        for (var i = 0; i < devices.videoInputs.length; i++)
        {
            ids.push({ "deviceId": devices.videoInputs[i].id });
        }

        if (core.applyCameras(ids))
//#END
        {
             buttonCamera.enabled = true;
        }
        else buttonCamera.enabled = false;
    }

    function pUpdateTarget()
    {
        var size = gui.size;

        var x = (width  - size) / 2;
        var y = (height - size) / 2;

//#QT_OLD
        filter.target = filter.mapRectToSource(sourceRect, contentRect, Qt.rect(x, y, size, size),
                                               0, orientation);
//#ELSE
        filter.target = filter.mapRectToSource(sourceRect, contentRect, Qt.rect(x, y, size, size),
                                               filter.orientation, 0);
//#END
    }

//#QT_6
    function pGetCamera(id)
    {
        for (var i = 0; i < devices.videoInputs.length; i++)
        {
            var input = devices.videoInputs[i];

            if (input.id == id) return input;
        }

        return null;
    }
//#END

    //---------------------------------------------------------------------------------------------
    // Animations
    //---------------------------------------------------------------------------------------------

    Behavior on opacity
    {
        PropertyAnimation
        {
            duration: st.duration_normal

            easing.type: st.easing
        }
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Rectangle
    {
        anchors.fill: parent

        z: -1

        color: "black"
    }

    BorderHorizontal
    {
        size: st.dp8

        color: st.border_colorFocus
    }

//#QT_6
    CaptureSession
    {
        videoOutput: pageCamera

        camera: (camera.cameraDevice) ? camera : null
    }

    MediaDevices
    {
        id: devices

        onVideoInputsChanged: pApplyCamera()
    }
//#END

    Camera
    {
        id: camera

//#QT_5
        deviceId: (core.cameraId) ? core.cameraId
                                  : QtMultimedia.defaultCamera.deviceId

        focus.focusMode: CameraFocus.FocusContinuous

        // NOTE: It seems preferrable to focus the center when scanning a tag.
        focus.focusPointMode: CameraFocus.FocusPointCenter
//#ELSE
        cameraDevice: (core.cameraId) ? pGetCamera(core.cameraId)
                                      : devices.defaultVideoInput
//#END
    }

    FilterBarcode
    {
        id: filter

//#QT_6
        videoSink: (imageTarget.visible) ? pageCamera.videoSink : null
//#END

        /* QML_EVENT */ onLoaded: function(text)
        {
            // NOTE: Making sure 'imageTarget' is still visible before browsing. Also checking the
            //       tag validity.
            if (imageTarget.visible && core.checkTag(text) == false) return;

            sk.vibrate(200);

            panelBrowse.browse(text);
        }

//#QT_6
        onOrientationChanged: pUpdateTarget()
//#END
    }

    ImageScale
    {
        id: imageTarget

        anchors.centerIn: parent

        width : size
        height: width

        opacity: 0.9

        source: st.picture_camera

        asynchronous: gui.asynchronous
    }

    ButtonRound
    {
        id: buttonCamera

        anchors.bottom: parent.bottom

        anchors.bottomMargin: st.dp64

        anchors.horizontalCenter: parent.horizontalCenter

        width : st.dp44
        height: width

        icon          : st.icon16x16_rotate
        iconSourceSize: st.size16x16

        onClicked: core.setNextCamera()
    }

    ButtonPianoIcon
    {
        anchors.right : bar.left
        anchors.top   : bar.top
        anchors.bottom: bar.bottom

        borderLeft  : borderSize
        borderBottom: borderSize

        icon          : st.icon12x12_close
        iconSourceSize: st.size12x12

        onClicked: panelTag.collapse()
    }

    Rectangle
    {
        id: bar

        anchors.right: parent.right

        width : st.dp16
        height: st.dp32 + st.border_size

        gradient: Gradient
        {
            GradientStop { position: 0.0; color: st.barTitle_colorA }
            GradientStop { position: 1.0; color: st.barTitle_colorB }
        }
    }

    BorderHorizontal
    {
        anchors.left  : bar.left
        anchors.right : bar.right
        anchors.bottom: bar.bottom
    }
}
