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

#ifndef RICHLIST_H
#define RICHLIST_H

#include <QtGui>
#include <QtNetwork>
#include <QtWidgets>
#include "clientmodel.h"




namespace Ui
{
    class richlistClass;
}

class RichlistWindow : public QWidget
{
    Q_OBJECT

public:
    RichlistWindow(QWidget *parent = 0);
    ~RichlistWindow();
    void setModel(ClientModel *model);



private:
    Ui::richlistClass *ui;
    ClientModel *model;

private slots:
    void reloadRich();
    void sslErrorHandler(QNetworkReply *reply, const QList<QSslError> & errors);
};

#endif // Richlist_H
