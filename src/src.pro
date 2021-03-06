TEMPLATE = aux
TARGET = fullcircle

RESOURCES += fullcircle.qrc

QML_FILES += $$files(*.qml,true) \
             $$files(*.js,true)

CONF_FILES +=  ../click/fullcircle.apparmor \
               ../click/fullcircle.desktop \
               ../images/logo.png \
               ../click/fullcircle.content-hub

OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               $${AP_TEST_FILES}

#specify where the qml/js files are installed to
qml_files.path = /fullcircle
qml_files.files += $${QML_FILES}

#specify where the config files are installed to
config_files.path = /fullcircle
config_files.files += $${CONF_FILES}

INSTALLS+=config_files qml_files
