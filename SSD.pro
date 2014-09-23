# figure out windows
win32 {
    contains(QMAKE_HOST.arch, x86_64) {
        message("x86_64 64-bit build")
        WINBITS = 64
    } else {
        message("x86 32-bit build")
        WINBITS = 32
    }
}
win32 {
   contains(WINBITS, 32) {
     MSYS = MinGW/msys/1.0
   } else {
     MSYS = mingw64/msys
   }
}

TEMPLATE = app
TARGET = "SonicScrewdriver Qt"
VERSION = 2.1.0.0
INCLUDEPATH += src src/json src/qt src/tor
QT += core gui network webkit
CONFIG += no_include_pwd
CONFIG += thread+

!macx:CONFIG += static

macx:INCLUDEPATH += /usr/local/BerkeleyDB.4.8/include # /usr/local/include

!macx:!win32 {
   # debian
   INCLUDEPATH += /usr/include/x86_64-linux-gnu
   # custom linux
   # INCLUDEPATH += /usr/include
   # INCLUDEPATH += /usr/local/include
   # INCLUDEPATH += /usr/local/ssl/include
   # INCLUDEPATH += /usr/local/boost
   # INCLUDEPATH += /usr/local/include/event2
   # custom linux for static
   INCLUDEPATH += /usr/local/BerkeleyDB.4.8/include
}

DEFINES += QT_GUI BOOST_THREAD_USE_LIB BOOST_SPIRIT_THREADSAFE \
           BOOST_THREAD_PROVIDES_GENERIC_SHARED_MUTEX_ON_WIN \
           __NO_SYSTEM_INCLUDES

win32 {
   contains(WINBITS, 32) {
      INCLUDEPATH += C:/$$MSYS/local/include/boost-1_55/
   } else {
      INCLUDEPATH += C:/$$MSYS/local/include/boost-1_55/
   }
}
win32:INCLUDEPATH += C:/$$MSYS/local/include
win32:INCLUDEPATH += C:/$$MSYS/local/ssl/include
win32:INCLUDEPATH += C:/$$MSYS/local

win32:contains(WINBITS, 64) {
   INCLUDEPATH += C:/$$MSYS/local/BerkeleyDB.4.8/include
}

win32:contains(WINBITS, 32) {
   # mingw 4.7
   HAVE_SSIZE_T = 1
}

# for boost 1.37, add -mt to the boost libraries
# use: qmake BOOST_LIB_SUFFIX=-mt
# for boost thread win32 with _win32 sufix
# use: BOOST_THREAD_LIB_SUFFIX=_win32-...
# or when linking against a specific BerkelyDB version: BDB_LIB_SUFFIX=-4.8

# Dependency library locations can be customized with:
#    BOOST_INCLUDE_PATH, BOOST_LIB_PATH, BDB_INCLUDE_PATH,
#    BDB_LIB_PATH, OPENSSL_INCLUDE_PATH and OPENSSL_LIB_PATH respectively

OBJECTS_DIR = build
MOC_DIR = build
UI_DIR = build

# use: qmake "RELEASE=1"
contains(RELEASE, 1) {
    # Mac: ensure compatibility with at least 10.7, 64 bit
    macx:XXFLAGS += -mmacosx-version-min=10.7 -arch x86_64 \
                    -isysroot /Developer/SDKs/MacOSX10.7.sdk
    !win32:!macx {
        # Linux: static link
        LIBS += -Bstatic
    }
}

# OS X is never static
# macx:mystaticconfig {
#   QMAKE_LIBS_QT =
#   QMAKE_LIBS_QT_THREAD =
#   LIBS += $(QTDIR)/lib/libqt.a -lz -framework Carbon
#   LIBS += /usr/local/lib/libqrencode.3.dylib
#   CONFIG += mystaticconfig
# }


# bug in gcc 4.4 breaks some pointer code
# QMAKE_CXXFLAGS += -fno-strict-aliasing
    win32:contains(WINBITS, 32) {
      # can have strict aliasing if opt is 0
      # QMAKE_CXXFLAGS_RELEASE -= -O2
      QMAKE_CXXFLAGS_RELEASE += -O0
}

USE_QRCODE=1
# use: qmake "USE_QRCODE=1"
# libqrencode (http://fukuchi.org/works/qrencode/index.en.html) must be installed for support
contains(USE_QRCODE, 1) {
    message(Building with QRCode support)
    DEFINES += USE_QRCODE
    win32:contains(WINBITS, 32) {
       INCLUDEPATH += C:/qrencode-3.4.3
       LIBS += -L"C:/qrencode-3.4.3"
    }
    macx:LIBS += /usr/local/lib/libqrencode.3.dylib
    LIBS += -lqrencode
} else {
    message(Building without QRCode support)
}

USE_UPNP=-
# use: qmake "USE_UPNP=1" ( enabled by default; default)
#  or: qmake "USE_UPNP=0" (disabled by default)
#  or: qmake "USE_UPNP=-" (not supported)
# miniupnpc (http://miniupnp.free.fr/files/) must be installed for support
contains(USE_UPNP, -) {
    message(Building without UPNP support)
} else {
    message(Building with UPNP support)
    count(USE_UPNP, 0) {
        USE_UPNP=1
    }
    DEFINES += USE_UPNP=$$USE_UPNP STATICLIB
    win32 {
       contains(WINBITS, 32) {
           INCLUDEPATH += C:/miniupnpc-1.9
           LIBS += -L"C:/miniupnpc-1.9/miniupnpc"
       } else {
           INCLUDEPATH += "C:/$$MSYS/local/miniupnpc-1.9"
           LIBS += -L"C:/$$MSYS/local/miniupnpc-1.9/miniupnpc"
       }
    }
    LIBS += -lminiupnpc
    win32:LIBS += -liphlpapi
}

# use: qmake "USE_DBUS=1"
contains(USE_DBUS, 1) {
    message(Building with DBUS (Freedesktop notifications) support)
    DEFINES += USE_DBUS
    QT += dbus
}

# use: qmake "FIRST_CLASS_MESSAGING=1"
contains(FIRST_CLASS_MESSAGING, 1) {
    message(Building with first-class messaging)
    DEFINES += FIRST_CLASS_MESSAGING
}

contains(BITCOIN_NEED_QT_PLUGINS, 1) {
    DEFINES += BITCOIN_NEED_QT_PLUGINS
    QTPLUGIN += qcncodecs qjpcodecs qtwcodecs qkrcodecs qtaccessiblewidgets
}

# LevelDB
DEFINES += USE_LEVELDB
INCLUDEPATH += $$PWD/src/leveldb/include $$PWD/src/leveldb/helpers
INCLUDEPATH += $$PWD/src/leveldb/include/leveldb $$PWD/src/leveldb/helpers/memenv
LIBS += $$PWD/src/leveldb/libleveldb.a $$PWD/src/leveldb/libmemenv.a
!win32 {
    # we use QMAKE_CXXFLAGS_RELEASE even without RELEASE=1 because we use RELEASE to indicate linking preferences not -O preferences
    # genleveldb.commands = cd $$PWD/src/leveldb && CC=$$QMAKE_CC CXX=$$QMAKE_CXX $(MAKE) OPT=\"$$QMAKE_CXXFLAGS $$QMAKE_CXXFLAGS_RELEASE\" libleveldb.a libmemenv.a
} else {
    # make an educated guess about what the ranlib command is called
    #isEmpty(QMAKE_RANLIB) {
    #    QMAKE_RANLIB = $$replace(QMAKE_STRIP, strip, ranlib)
    #}
    LIBS += -lshlwapi
    # genleveldb.commands = cd $$PWD/src/leveldb && CC=$$QMAKE_CC CXX=$$QMAKE_CXX TARGET_OS=OS_WINDOWS_CROSSCOMPILE $(MAKE) OPT=\"$$QMAKE_CXXFLAGS $$QMAKE_CXXFLAGS_RELEASE\" libleveldb.a libmemenv.a && $$QMAKE_RANLIB $$PWD/src/leveldb/libleveldb.a && $$QMAKE_RANLIB $$PWD/src/leveldb/libmemenv.a
}
genleveldb.target = $$PWD/src/leveldb/libleveldb.a
genleveldb.depends = FORCE
PRE_TARGETDEPS += $$PWD/src/leveldb/libleveldb.a
QMAKE_EXTRA_TARGETS += genleveldb
# Gross ugly hack that depends on qmake internals, unfortunately there is no other way to do it.
QMAKE_CLEAN += $$PWD/src/leveldb/libleveldb.a; cd $$PWD/src/leveldb ; $(MAKE) clean


!win32 {
    # for extra security against potential buffer overflows
    QMAKE_CXXFLAGS += -fstack-protector
    QMAKE_LFLAGS += -fstack-protector
    # do not enable this on windows, as it will result in a non-working executable!
}


# regenerate src/build.h
!windows|contains(USE_BUILD_INFO, 1) {
    genbuild.depends = FORCE
    genbuild.commands = cd $$PWD; /bin/sh share/genbuild.sh $$OUT_PWD/build/build.h
    genbuild.target = $$OUT_PWD/build/build.h
    PRE_TARGETDEPS += $$OUT_PWD/build/build.h
    QMAKE_EXTRA_TARGETS += genbuild
    DEFINES += HAVE_BUILD_INFO
}

QMAKE_CXXFLAGS += -msse2
QMAKE_CFLAGS += -msse2
QMAKE_CXXFLAGS_WARN_ON = -fdiagnostics-show-option -Wall -Wextra\
                         -Wformat -Wformat-security -Wno-unused-parameter


# Input
DEPENDPATH += src src/json src/qt
HEADERS += src/qt/bitcoingui.h \
    src/stealthaddress.h \
    src/qt/transactiontablemodel.h \
    src/qt/addresstablemodel.h \
    src/qt/optionsdialog.h \
    src/qt/coincontroldialog.h \
    src/qt/coincontroltreewidget.h \
    src/qt/sendcoinsdialog.h \
    src/qt/addressbookpage.h \
    src/qt/signverifymessagedialog.h \
    src/qt/aboutdialog.h \
    src/qt/editaddressdialog.h \
    src/qt/bitcoinaddressvalidator.h \
    src/alert.h \
    src/addrman.h \
    src/base58.h \
    src/bignum.h \
    src/checkpoints.h \
    src/compat.h \
    src/coincontrol.h \
    src/sync.h \
    src/util.h \
    src/uint256.h \
    src/kernel.h \
    src/scrypt_mine.h \
    src/pbkdf2.h \
    src/serialize.h \
    src/strlcpy.h \
    src/main.h \
    src/net.h \
    src/key.h \
    src/db.h \
    src/txdb.h \
    src/txdb-bdb.h \
    src/txdb-leveldb.h \
    src/walletdb.h \
    src/script.h \
    src/init.h \
    src/irc.h \
    src/mruset.h \
    src/json/json_spirit_writer_template.h \
    src/json/json_spirit_writer.h \
    src/json/json_spirit_value.h \
    src/json/json_spirit_utils.h \
    src/json/json_spirit_stream_reader.h \
    src/json/json_spirit_reader_template.h \
    src/json/json_spirit_reader.h \
    src/json/json_spirit_error_position.h \
    src/json/json_spirit.h \
    src/qt/clientmodel.h \
    src/qt/guiutil.h \
    src/qt/transactionrecord.h \
    src/qt/guiconstants.h \
    src/qt/optionsmodel.h \
    src/qt/monitoreddatamapper.h \
    src/qt/transactiondesc.h \
    src/qt/transactiondescdialog.h \
    src/qt/bitcoinamountfield.h \
    src/wallet.h \
    src/keystore.h \
    src/qt/transactionfilterproxy.h \
    src/qt/transactionview.h \
    src/qt/walletmodel.h \
    src/bitcoinrpc.h \
    src/qt/overviewpage.h \
    src/qt/csvmodelwriter.h \
    src/crypter.h \
    src/qt/sendcoinsentry.h \
    src/qt/qvalidatedlineedit.h \
    src/qt/bitcoinunits.h \
    src/qt/qvaluecombobox.h \
    src/qt/askpassphrasedialog.h \
    src/protocol.h \
    src/qt/notificator.h \
    src/qt/qtipcserver.h \
    src/allocators.h \
    src/ui_interface.h \
    src/qt/rpcconsole.h \
    src/version.h \
    src/netbase.h \
    src/clientversion.h \
    src/qt/httpsocket.h \
    src/qt/stealthsend.h \
        src/qt/chatwindow.h \
        src/qt/blockbrowser.h \
		src/qt/bittrex.h \
                src/qt/richlist.h

SOURCES += src/qt/bitcoin.cpp src/qt/bitcoingui.cpp \
    src/qt/transactiontablemodel.cpp \
    src/qt/addresstablemodel.cpp \
    src/qt/optionsdialog.cpp \
    src/qt/sendcoinsdialog.cpp \
    src/qt/coincontroldialog.cpp \
    src/qt/coincontroltreewidget.cpp \
    src/qt/addressbookpage.cpp \
    src/qt/signverifymessagedialog.cpp \
    src/qt/aboutdialog.cpp \
    src/qt/editaddressdialog.cpp \
    src/qt/bitcoinaddressvalidator.cpp \
    src/qt/chatwindow.cpp \
	src/qt/bittrex.cpp \
        src/qt/richlist.cpp \
    src/tor/address.c \
    src/tor/addressmap.c \
    src/tor/aes.c \
    src/tor/backtrace.c \
    src/tor/buffers.c \
    src/tor/channel.c \
    src/tor/channeltls.c \
    src/tor/circpathbias.c \
    src/tor/circuitbuild.c \
    src/tor/circuitlist.c \
    src/tor/circuitmux.c \
    src/tor/circuitmux_ewma.c \
    src/tor/circuitstats.c \
    src/tor/circuituse.c \
    src/tor/command.c \
    src/tor/compat.c \
    src/tor/compat_libevent.c \
    src/tor/config.c \
    src/tor/config_codedigest.c \
    src/tor/confparse.c \
    src/tor/connection.c \
    src/tor/connection_edge.c \
    src/tor/connection_or.c \
    src/tor/container.c \
    src/tor/control.c \
    src/tor/cpuworker.c \
    src/tor/crypto.c \
    src/tor/crypto_curve25519.c \
    src/tor/crypto_format.c \
    src/tor/curve25519-donna.c \
    src/tor/di_ops.c \
    src/tor/directory.c \
    src/tor/dirserv.c \
    src/tor/dirvote.c \
    src/tor/dns.c \
    src/tor/dnsserv.c \
    src/tor/entrynodes.c \
    src/tor/ext_orport.c \
    src/tor/fp_pair.c \
    src/tor/geoip.c \
    src/tor/hibernate.c \
    src/tor/log.c \
    src/tor/memarea.c \
    src/tor/mempool.c \
    src/tor/microdesc.c \
    src/tor/networkstatus.c \
    src/tor/nodelist.c \
    src/tor/onion.c \
    src/tor/onion_fast.c \
    src/tor/onion_main.c \
    src/tor/onion_ntor.c \
    src/tor/onion_tap.c \
    src/tor/policies.c \
    src/tor/stealth.cpp \
    src/tor/procmon.c \
    src/tor/reasons.c \
    src/tor/relay.c \
    src/tor/rendclient.c \
    src/tor/rendcommon.c \
    src/tor/rendmid.c \
    src/tor/rendservice.c \
    src/tor/rephist.c \
    src/tor/replaycache.c \
    src/tor/router.c \
    src/tor/routerlist.c \
    src/tor/routerparse.c \
    src/tor/routerset.c \
    src/tor/sandbox.c \
    src/tor/statefile.c \
    src/tor/status.c \
    src/tor/strlcat.c \
    src/tor/strlcpy.c \
    src/tor/tor_util.c \
    src/tor/torgzip.c \
    src/tor/tortls.c \
    src/tor/transports.c \
    src/tor/util_codedigest.c \
    src/alert.cpp \
    src/version.cpp \
    src/sync.cpp \
    src/util.cpp \
    src/netbase.cpp \
    src/key.cpp \
    src/script.cpp \
    src/main.cpp \
    src/init.cpp \
    src/net.cpp \
    src/irc.cpp \
    src/checkpoints.cpp \
    src/addrman.cpp \
    src/db.cpp \
    src/txdb-leveldb.cpp \
    src/walletdb.cpp \
    src/qt/clientmodel.cpp \
    src/qt/guiutil.cpp \
    src/qt/transactionrecord.cpp \
    src/qt/optionsmodel.cpp \
    src/qt/monitoreddatamapper.cpp \
    src/qt/transactiondesc.cpp \
    src/qt/transactiondescdialog.cpp \
    src/qt/bitcoinstrings.cpp \
    src/qt/bitcoinamountfield.cpp \
    src/wallet.cpp \
    src/keystore.cpp \
    src/qt/blockbrowser.cpp \
    src/qt/transactionfilterproxy.cpp \
    src/qt/transactionview.cpp \
    src/qt/walletmodel.cpp \
    src/bitcoinrpc.cpp \
    src/rpcdump.cpp \
    src/rpcnet.cpp \
    src/rpcmining.cpp \
    src/rpcwallet.cpp \
    src/rpcblockchain.cpp \
    src/rpcrawtransaction.cpp \
    src/qt/overviewpage.cpp \
    src/qt/csvmodelwriter.cpp \
    src/crypter.cpp \
    src/qt/sendcoinsentry.cpp \
    src/qt/qvalidatedlineedit.cpp \
    src/qt/bitcoinunits.cpp \
    src/qt/qvaluecombobox.cpp \
    src/qt/askpassphrasedialog.cpp \
    src/protocol.cpp \
    src/qt/notificator.cpp \
    src/qt/qtipcserver.cpp \
    src/qt/rpcconsole.cpp \
    src/noui.cpp \
    src/kernel.cpp \
    src/scrypt-x86.S \
    src/scrypt-x86_64.S \
    src/scrypt_mine.cpp \
    src/pbkdf2.cpp \
    src/scrypt.cpp \
    src/sonicvortex.cpp \
    src/qt/httpsocket.cpp \
    src/qt/stealthsend.cpp \

RESOURCES += \
    src/qt/bitcoin.qrc

FORMS += \
    src/qt/forms/coincontroldialog.ui \
    src/qt/forms/sendcoinsdialog.ui \
    src/qt/forms/addressbookpage.ui \
    src/qt/forms/signverifymessagedialog.ui \
    src/qt/forms/aboutdialog.ui \
    src/qt/forms/editaddressdialog.ui \
    src/qt/forms/transactiondescdialog.ui \
    src/qt/forms/overviewpage.ui \
    src/qt/forms/sendcoinsentry.ui \
    src/qt/forms/askpassphrasedialog.ui \
    src/qt/forms/rpcconsole.ui \
    src/qt/forms/optionsdialog.ui \
    src/qt/forms/blockbrowser.ui \
    src/qt/forms/chatwindow.ui \
    src/qt/forms/bittrex.ui \
    src/qt/forms/richlist.ui

contains(USE_QRCODE, 1) {
HEADERS += src/qt/qrcodedialog.h
SOURCES += src/qt/qrcodedialog.cpp
FORMS += src/qt/forms/qrcodedialog.ui
}

contains(BITCOIN_QT_TEST, 1) {
SOURCES += src/qt/test/test_main.cpp \
    src/qt/test/uritests.cpp
HEADERS += src/qt/test/uritests.h
DEPENDPATH += src/qt/test
QT += testlib
TARGET = sonic-qt_test
DEFINES += BITCOIN_QT_TEST
}

CODECFORTR = UTF-8

# for lrelease/lupdate
# also add new translations to src/qt/bitcoin.qrc under translations/
TRANSLATIONS = $$files(src/qt/locale/bitcoin_*.ts)

isEmpty(QMAKE_LRELEASE) {
    win32:QMAKE_LRELEASE = $$[QT_INSTALL_BINS]\\lrelease.exe
    else:QMAKE_LRELEASE = $$[QT_INSTALL_BINS]/lrelease
}
isEmpty(QM_DIR):QM_DIR = $$PWD/src/qt/locale
# automatically build translations, so they can be included in resource file
TSQM.name = lrelease ${QMAKE_FILE_IN}
TSQM.input = TRANSLATIONS
TSQM.output = $$QM_DIR/${QMAKE_FILE_BASE}.qm
TSQM.commands = $$QMAKE_LRELEASE ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_OUT}
TSQM.CONFIG = no_link
QMAKE_EXTRA_COMPILERS += TSQM

# "Other files" to show in Qt Creator
OTHER_FILES += \
    contrib/gitian-descriptors/* doc/*.rst doc/*.txt doc/README README.md res/bitcoin-qt.rc \
    share/setup.nsi

# platform specific defaults, if not overridden on command line
isEmpty(BOOST_LIB_SUFFIX) {
    macx:BOOST_LIB_SUFFIX = -mt
    win32 {
      contains(WINBITS, 32) {
         BOOST_LIB_SUFFIX = -mgw44-mt-d-1_55
      } else {
         BOOST_LIB_SUFFIX = -mgw47-mt-d-1_55
      }
    }
}

isEmpty(BOOST_THREAD_LIB_SUFFIX) {
    BOOST_THREAD_LIB_SUFFIX = $$BOOST_LIB_SUFFIX
}

isEmpty(BDB_LIB_PATH) {
    macx:BDB_LIB_PATH = /usr/local/BerkeleyDB.4.8/lib
}

isEmpty(BDB_LIB_SUFFIX) {
    macx:BDB_LIB_SUFFIX = -4.8
}

isEmpty(BDB_INCLUDE_PATH) {
    macx:BDB_INCLUDE_PATH = /usr/local/BerkeleyDB.4.8/include
}

isEmpty(BOOST_LIB_PATH) {
    macx:BOOST_LIB_PATH = /opt/local/lib
    # custom linux
    # !macx:!win32:BOOST_LIB_PATH = /usr/local/boost/stage/lib
}

isEmpty(BOOST_INCLUDE_PATH) {
    macx:BOOST_INCLUDE_PATH = /opt/local/include
}

win32:DEFINES += WIN32
win32:RC_FILE = src/qt/res/bitcoin-qt.rc

win32:!contains(MINGW_THREAD_BUGFIX, 0) {
    # At least qmake's win32-g++-cross profile is missing the -lmingwthrd
    # thread-safety flag. GCC has -mthreads to enable this, but it doesn't
    # work with static linking. -lmingwthrd must come BEFORE -lmingw, so
    # it is prepended to QMAKE_LIBS_QT_ENTRY.
    # It can be turned off with MINGW_THREAD_BUGFIX=0, just in case it causes
    # any problems on some untested qmake profile now or in the future.
    DEFINES += _MT
    QMAKE_LIBS_QT_ENTRY = -lmingwthrd $$QMAKE_LIBS_QT_ENTRY
}

macx {
   HEADERS += src/qt/macdockiconhandler.h
   OBJECTIVE_SOURCES += src/qt/macdockiconhandler.mm
   LIBS += -framework Foundation -framework ApplicationServices \
           -framework AppKit
   DEFINES += MAC_OSX MSG_NOSIGNAL=0
   ICON = src/qt/res/icons/bitcoin.icns
   TARGET = "SonicScrewdriver Qt"
   QMAKE_CFLAGS_THREAD += -pthread
   QMAKE_LFLAGS_THREAD += -pthread
   QMAKE_CXXFLAGS_THREAD += -pthread
}


# Set libraries and includes at end, to use platform-defined defaults if not overridden
INCLUDEPATH += $$BOOST_INCLUDE_PATH $$BDB_INCLUDE_PATH $$OPENSSL_INCLUDE_PATH $$QRENCODE_INCLUDE_PATH
win32:LIBS += -L"C:/$$MSYS/local/ssl/lib"
win32:contains(WINBITS, 64) {
    LIBS += -L"C:/$$MSYS/local/BerkeleyDB.4.8/lib"
    LIBS += "C:/mingw64/bin/libwinpthread-1.dll"
    LIBS += "C:/$$MSYS/local/lib/libboost_filesystem-mgw47-mt-d-1_55.dll"
    LIBS += -static
}
win32:LIBS += -L"C:/$$MSYS/local/lib"
win32:LIBS += -L"C:/$$MSYS/local/cryptopp562"
# win32:LIBS += "C:/mingw64/x86_64-w64-mingw32/lib/libgcc_s_sjlj-1.dll"
# win32:LIBS += "C:/mingw64/x86_64-w64-mingw32/lib/libstdc++-6.dll"
macx|win32 {
LIBS += $$join(BOOST_LIB_PATH,,-L,) $$join(BDB_LIB_PATH,,-L,) \
        $$join(OPENSSL_LIB_PATH,,-L,) $$join(QRENCODE_LIB_PATH,,-L,)
}

LIBS += -lssl -lcrypto -levent -lz -lcryptopp


!win32:!macx {
    DEFINES += LINUX
    # debian
    LIBS += -L/usr/lib/x86_64-linux-gnu
    # custom linux
    # LIBS += -L/usr/local/ssl/lib
}

!macx:!win32 {
    LIBS += -lrt
    LIBS += -ldl
}

macx|win32 {
    LIBS += -ldb_cxx$$BDB_LIB_SUFFIX
}

!macx:!win32 {
    # debian
    LIBS += /usr/lib/x86_64-linux-gnu/libssl.a
    LIBS += /usr/lib/x86_64-linux-gnu/libcrypto.a
    LIBS += /usr/lib/x86_64-linux-gnu/libboost_system.a
    LIBS += /usr/lib/x86_64-linux-gnu/libboost_filesystem.a
    LIBS += /usr/lib/x86_64-linux-gnu/libboost_thread.a
    LIBS += /usr/lib/x86_64-linux-gnu/libboost_program_options.a
    # custom linux
    # LIBS += /usr/local/ssl/lib/libssl.a
    # LIBS += /usr/local/ssl/lib/libcrypto.a
    # LIBS += /usr/local/boost/stage/lib/libboost_system.a
    # LIBS += /usr/local/boost/stage/lib/libboost_filesystem.a
    # LIBS += /usr/local/boost/stage/lib/libboost_thread.a
    # LIBS += /usr/local/boost/stage/lib/libboost_program_options.a
    # custom linux for static
    LIBS += /usr/local/BerkeleyDB.4.8/lib/libdb_cxx-4.8.a
    LIBS += /usr/lib/libcryptopp.a
}

# -lgdi32 has to happen after -lcrypto (see  #681)
win32:LIBS += -lws2_32 -lshlwapi -lmswsock -lole32 -loleaut32 -luuid -lgdi32

win32|macx {
    LIBS += -lboost_system$$BOOST_LIB_SUFFIX \
            -lboost_filesystem$$BOOST_LIB_SUFFIX \
            -lboost_program_options$$BOOST_LIB_SUFFIX \
            -lboost_thread$$BOOST_THREAD_LIB_SUFFIX
}

win32:LIBS += -lboost_chrono$$BOOST_LIB_SUFFIX

win32:contains(WINBITS, 64) {
       LIBS += -pthread
}

!win32:!macx {
        # Linux: turn dynamic linking back on for c/c++ runtime libraries
        LIBS += -Wl,-Bdynamic,-rpath,.
}

system($$QMAKE_LRELEASE -silent $$_PRO_FILE_)
