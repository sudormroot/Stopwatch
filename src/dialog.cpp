#include "dialog.h"
#include "ui_dialog.h"

#include <QApplication>

Dialog::Dialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Dialog)
{
    ui->setupUi(this);

    //this->setWindowFlags(Qt::WindowMinimizeButtonHint | Qt::WindowStaysOnTopHint);

    //this->setWindowFlags(Qt::WindowCloseButtonHint | Qt::WindowStaysOnTopHint);

    Qt::WindowFlags wflags = 0;


    wflags |= Qt::Dialog;
    //wflags |= Qt::WindowTitleHint;

    wflags |= Qt::WindowStaysOnTopHint;

    //wflags |= Qt::WindowCloseButtonHint;
    //wflags |= Qt::CustomizeWindowHint;



    this->setWindowFlags(wflags);

    this->setWindowOpacity(0.7);



    this->setAutoFillBackground(true);

    this->setWindowTitle(   QString(STOPWATCH_WINDOW_TITLE) +
                            QString(" (") +
                            QString(STOPWATCH_VERSION) +
                            QString(")") );


    this->setFixedSize(this->size());


    ui->pushButtonStartStop->setText(tr("Start"));
    ui->lineEdit->setText("000:00:00.000");
    ui->lineEdit->setMaxLength(ui->lineEdit->text().length());
    ui->lineEdit->setAlignment(Qt::AlignCenter);

    QPalette pal;
    pal.setColor(QPalette::Base, Qt::gray);
    pal.setColor(QPalette::Text, Qt::white);


    ui->lineEdit->setPalette(pal);

    ui->lineEdit->setFont(QFont("Timers", 32, QFont::Bold));

    ui->lineEdit->setAutoFillBackground(true);


    trayIcon = new QSystemTrayIcon(this);

    trayIcon ->setToolTip(this->windowTitle() + " " + tr("Stopped"));
    trayIcon ->setIcon(QIcon(":/images/stopwatch.icns"));

    connect(    trayIcon , SIGNAL(activated(QSystemTrayIcon::ActivationReason)),
                this, SLOT(trayIconActived(QSystemTrayIcon::ActivationReason)));

    trayIcon->show();

    //trayIcon->showMessage(this->windowTitle(), QString(tr("Timer")));



}

Dialog::~Dialog()
{
    if(ui->pushButtonStartStop->text() == tr("Stop")) {
        stop();
    }

    disconnect(    trayIcon , SIGNAL(activated(QSystemTrayIcon::ActivationReason)),
                this, SLOT(trayIconActived(QSystemTrayIcon::ActivationReason)));

    trayIcon->hide();

    delete trayIcon;

    delete ui;
}




void Dialog::trayIconActived(QSystemTrayIcon::ActivationReason reason)
{
    switch(reason) {

        //single click
        case QSystemTrayIcon::Trigger:

            if(this->isHidden()) {
                this->move(rect.left(), rect.top());
                this->show();
            } else if(!this->isHidden()) {

                rect = this->geometry();



                this->hide();
            }

            break;

        //double click
        case QSystemTrayIcon::DoubleClick:
            this->show();
            break;

        default:
            break;
    }
}

void Dialog::oneTick(void)
{
    ticks++;

    int diff = baseTime.elapsed();

    int msecs = diff % 1000;

    int secs = (diff / 1000) % 60;

    int mins = (diff / 1000 / 60) % 60;

    int hrs = diff / 1000 / 60 / 60;

    //000:00:00.000
    QString text = QString("%1:%2:%3.%4").
                arg(hrs, 3, 10, QChar('0')).
                arg(mins, 2, 10, QChar('0')).
                arg(secs, 2, 10, QChar('0')).
                arg(msecs, 3, 10, QChar('0'));


    ui->lineEdit->setText(text);




}

void Dialog::start(void)
{

    timer = new QTimer(this);

    timer->setInterval(STOPWATCH_TIMER_INTERVAL);

    connect(timer, SIGNAL(timeout()), this, SLOT(oneTick()));

    ticks = 0;



    ui->pushButtonStartStop->setText(tr("Stop"));

    baseTime = QTime::currentTime();


    baseTime.start();
    timer->start();

    trayIcon ->setToolTip(this->windowTitle() + " " + tr("Started"));
}

void Dialog::stop(void)
{



    timer->stop();

    disconnect(timer, SIGNAL(timeout()), this, SLOT(oneTick()));

    ui->pushButtonStartStop->setText(tr("Start"));


    delete timer;

    trayIcon ->setToolTip(this->windowTitle() + " " + tr("Stopped"));
}


void Dialog::on_pushButtonStartStop_clicked()
{
    if(ui->pushButtonStartStop->text() == tr("Start")) {
        start();
    } else {
        stop();
    }
}

void Dialog::on_pushButtonHide_clicked()
{


    rect = this->geometry();

    this->hide();
}
