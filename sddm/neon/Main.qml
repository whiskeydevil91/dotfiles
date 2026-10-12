// ─────────────────────────────────────────────────────────────────────────────
// Neon SDDM theme
//
// Layout (matches the background art):
//   • Top-left:  clock and date
//   • Top-right: session picker and power buttons
//   • Bottom:    username / password row, below the WELCOME sign
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#0b0014"

    readonly property color neonCyan:  config.accentCyan || "#00e5ff"
    readonly property color neonPink:  config.accentPink || "#ff2bd6"
    readonly property color panel:     config.panelColor || "#cc0b0014"
    readonly property color textColor: config.textColor  || "#f2e9ff"
    readonly property string fontName: config.font       || "IBM Plex Mono"

    property int sessionIndex: sessionModel.lastIndex
    property string loginError: ""

    function doLogin() {
        root.loginError = ""
        sddm.login(username.text, password.text, root.sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            root.loginError = "Wrong password, try again"
            password.forceActiveFocus()
        }
    }

    // ── Background ──────────────────────────────────────────────────────────
    Image {
        anchors.fill: parent
        source: config.background || "background.png"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // ── Reusable neon pieces ────────────────────────────────────────────────
    component NeonField: TextField {
        id: field
        Layout.preferredWidth: root.width * 0.17
        Layout.preferredHeight: 44
        color: root.textColor
        placeholderTextColor: Qt.rgba(0.9, 0.85, 1, 0.5)
        font.family: root.fontName
        font.pixelSize: 18
        horizontalAlignment: TextInput.AlignHCenter
        selectByMouse: true
        background: Rectangle {
            radius: 22
            color: root.panel
            border.width: 2
            border.color: field.activeFocus ? root.neonPink : root.neonCyan
            // Soft outer glow
            Rectangle {
                anchors.fill: parent
                anchors.margins: -4
                radius: parent.radius + 4
                color: "transparent"
                border.width: 2
                border.color: parent.border.color
                opacity: 0.35
            }
        }
    }

    component NeonButton: Button {
        id: btn
        property color accent: root.neonCyan
        font.family: root.fontName
        font.pixelSize: 16
        contentItem: Text {
            text: btn.text
            font: btn.font
            color: btn.hovered ? "#0b0014" : btn.accent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            implicitWidth: 44
            implicitHeight: 44
            radius: 22
            color: btn.hovered ? btn.accent : root.panel
            border.width: 2
            border.color: btn.accent
        }
    }

    // ── Clock (top-left) ────────────────────────────────────────────────────
    Column {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 40
        spacing: 4

        Text {
            id: clock
            color: root.neonCyan
            font.family: root.fontName
            font.pixelSize: 64
            font.bold: true
            text: Qt.formatTime(new Date(), "hh:mm")
        }
        Text {
            id: date
            color: root.neonPink
            font.family: root.fontName
            font.pixelSize: 20
            text: Qt.formatDate(new Date(), "dddd, MMMM d")
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                clock.text = Qt.formatTime(new Date(), "hh:mm")
                date.text = Qt.formatDate(new Date(), "dddd, MMMM d")
            }
        }
    }

    // ── Session picker and power buttons (top-right) ───────────────────────
    RowLayout {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 40
        spacing: 12

        ComboBox {
            id: session
            Layout.preferredWidth: 200
            Layout.preferredHeight: 44
            model: sessionModel
            textRole: "name"
            currentIndex: sessionModel.lastIndex
            onActivated: root.sessionIndex = currentIndex
            font.family: root.fontName
            font.pixelSize: 16
            contentItem: Text {
                leftPadding: 18
                text: session.displayText
                font: session.font
                color: root.textColor
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            background: Rectangle {
                radius: 22
                color: root.panel
                border.width: 2
                border.color: root.neonPink
            }
        }

        NeonButton {
            text: "⏾"
            visible: sddm.canSuspend
            onClicked: sddm.suspend()
        }
        NeonButton {
            text: "↻"
            visible: sddm.canReboot
            onClicked: sddm.reboot()
        }
        NeonButton {
            text: "⏻"
            accent: root.neonPink
            visible: sddm.canPowerOff
            onClicked: sddm.powerOff()
        }
    }

    // ── Login row (bottom, under the WELCOME sign) ──────────────────────────
    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.04
        spacing: 10

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 14

            NeonField {
                id: username
                text: userModel.lastUser
                placeholderText: "username"
                onAccepted: password.forceActiveFocus()
            }

            NeonField {
                id: password
                placeholderText: "password"
                echoMode: TextInput.Password
                passwordCharacter: "•"
                focus: true
                onAccepted: root.doLogin()
            }

            NeonButton {
                text: "→"
                accent: root.neonPink
                font.pixelSize: 22
                onClicked: root.doLogin()
            }
        }

        Text {
            id: errorText
            Layout.alignment: Qt.AlignHCenter
            color: root.neonPink
            font.family: root.fontName
            font.pixelSize: 16
            text: root.loginError !== "" ? root.loginError
                  : (keyboard.capsLock ? "Caps Lock is on" : "")
        }
    }

    Component.onCompleted: {
        if (username.text === "")
            username.forceActiveFocus()
        else
            password.forceActiveFocus()
    }
}
