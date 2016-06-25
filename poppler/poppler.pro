TEMPLATE = lib
TARGET = popplerPlugin
QT += qml quick xml core-private quick-private qml-private gui-private
CONFIG += qt plugin

load(ubuntu-click)

TARGET = $$qtLibraryTarget($$TARGET)
LIBS += -lpoppler-qt5
QMAKE_CXXFLAGS += -std=c++0x

uri = Poppler

SOURCES += \
    pdfdocument.cpp \
    pdfimageprovider.cpp \
    pdfitem.cpp \
    pdftocmodel.cpp \
    plugin.cpp \
    verticalview.cpp

HEADERS += \
    pdfdocument.h \
    pdfimageprovider.h \
    pdfitem.h \
    pdftocmodel.h \
    plugin.h \
    verticalview.h

OTHER_FILES = qmldir
QML_FILES += $$files(*.qml,true)

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$OUT_PWD/qmldir
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(COPY_FILE) \"$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)\"
    QMAKE_EXTRA_TARGETS += copy_qmldir
    PRE_TARGETDEPS += $$copy_qmldir.target
}

qmldir.files = qmldir
installPath = $${UBUNTU_CLICK_PLUGIN_PATH}/Poppler
qmldir.path = $$installPath
target.path = $$installPath
qml_files.path = $$installPath
qml_files.files += $${QML_FILES}

INSTALLS += target qmldir qml_files
