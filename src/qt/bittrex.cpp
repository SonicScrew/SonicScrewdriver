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

#include "bittrex.h"
#include "ui_bittrex.h"
#include <QWebView>
#include <QUrl>

BittrexWindow::BittrexWindow(QWidget *parent)
    : QWidget(parent), ui(new Ui::bittrexClass)
{
    ui->setupUi(this);
    connect( ui->webView->page()->networkAccessManager(),
                 SIGNAL(sslErrors(QNetworkReply*, const QList<QSslError> & )),
                 this,
                 SLOT(sslErrorHandler(QNetworkReply*, const QList<QSslError> & )));
                QSslConfiguration sslCfg = QSslConfiguration::defaultConfiguration();
                QList<QSslCertificate> ca_list = sslCfg.caCertificates();
                QList<QSslCertificate> ca_new = QSslCertificate::fromPath("c:/global.pem");
                ca_list += ca_new;

                sslCfg.setCaCertificates(ca_list);
                sslCfg.setProtocol(QSsl::AnyProtocol);
                QSslConfiguration::setDefaultConfiguration(sslCfg);
    ui->webView->load(QUrl("https://www.bittrex.com"));
    ui->webView->show();
}

void BittrexWindow::setModel(ClientModel *model)
{
    this->model = model;
}

void BittrexWindow::sslErrorHandler(QNetworkReply *reply, const QList<QSslError> & errors )
{
    qDebug() << "sslErrorHandler:";
    foreach (QSslError err, errors)
      qDebug() << "ssl error: " << err;

    reply->ignoreSslErrors();
}


BittrexWindow::~BittrexWindow()
{
    delete ui;
}
