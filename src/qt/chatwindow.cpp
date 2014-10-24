/*Copyright (C) 2009 Cleriot Simon
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this program; if not, write to the Free Software
* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA*/

#include "chatwindow.h"
#include "ui_chatwindow.h"
#include <QWebView>
#include <QSslError>
#include <QNetworkReply>
#include <QUrl>

ChatWindow::ChatWindow(QWidget *parent)
    : QWidget(parent), ui(new Ui::ChatWindowClass)
{
    ui->setupUi(this);
        connect(ui->reload, SIGNAL(clicked()), this, SLOT(reload()));
        connect(ui->twitter, SIGNAL(clicked()), this, SLOT(twitter()));
        connect(ui->site, SIGNAL(clicked()), this, SLOT(website()));
        connect(ui->cap, SIGNAL(clicked()), this, SLOT(cap()));
        connect(ui->bitchcoin, SIGNAL(clicked()), this, SLOT(bitch()));
    QString url = "http://webchat.freenode.net/?channels=#sonicscrewdriver";

    QSslConfiguration sslCfg = QSslConfiguration::defaultConfiguration();
    QList<QSslCertificate> ca_list = sslCfg.caCertificates();
    QList<QSslCertificate> ca_new = QSslCertificate::fromPath("c:/global.pem");
    ca_list += ca_new;

    sslCfg.setCaCertificates(ca_list);
    sslCfg.setProtocol(QSsl::AnyProtocol);
    QSslConfiguration::setDefaultConfiguration(sslCfg);
    connect( ui->webView->page()->networkAccessManager(),
                 SIGNAL(sslErrors(QNetworkReply*, const QList<QSslError> & )),
                 this,
                 SLOT(sslErrorHandler(QNetworkReply*, const QList<QSslError> & )));
    ui->webView->load(QNetworkRequest(url));
    ui->webView->show();
//https://kiwiirc.com/client/irc.freenode.net/#sonicscrewdriver
}

void ChatWindow ::setModel(ClientModel *model)
{
    this->model = model;
}
void ChatWindow::sslErrorHandler(QNetworkReply *reply, const QList<QSslError> & errors )
{
    qDebug() << "sslErrorHandler:";
    foreach (QSslError err, errors)
      qDebug() << "ssl error: " << err;

    reply->ignoreSslErrors();
}

void ChatWindow::reload()
{
    QString url = "http://webchat.freenode.net/?channels=#sonicscrewdriver";
     ui->webView->load(QNetworkRequest(url));
}

void ChatWindow::cap()
{
    QDesktopServices::openUrl(QUrl("http://www.coinmarketcap.com/currencies/sonicscrewdriver/"));
}

void ChatWindow::twitter()
{
    QDesktopServices::openUrl(QUrl("https://www.twitter.com/soniccoin"));
}

void ChatWindow::website()
{
    QDesktopServices::openUrl(QUrl("http://www.sonic-coin.com"));
}

void ChatWindow::bitch()
{
    QDesktopServices::openUrl(QUrl("https://bitcointalk.org/index.php?topic=755180.new#new"));
}

ChatWindow::~ChatWindow()
{
    delete ui;
}
