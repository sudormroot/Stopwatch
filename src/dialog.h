#ifndef DIALOG_H
#define DIALOG_H

#include <QDialog>
#include <QTimer>
#include <QTime>
#include <QSystemTrayIcon>
#include <QRect>

//#include <QCloseEvent>


//100mS
#define STOPWATCH_TIMER_INTERVAL    10

#define STOPWATCH_WINDOW_TITLE  "Stopwatch"
#define STOPWATCH_VERSION       "v1.0.0.6"

//#define STOPWATCH_URL           "https://"

namespace Ui {
class Dialog;
}

class Dialog : public QDialog
{
    Q_OBJECT

public:
    explicit Dialog(QWidget *parent = 0);
    ~Dialog();



private slots:
    void oneTick(void);


    void trayIconActived(QSystemTrayIcon::ActivationReason reason);



    void on_pushButtonStartStop_clicked();

    void on_pushButtonHide_clicked();

private:
    Ui::Dialog *ui;

    void start(void);
    void stop(void);
    //void pause(void);

    unsigned long long ticks;

    QTimer  *timer;

    QTime   baseTime;

    QSystemTrayIcon *trayIcon;

    QRect   rect;


};

#endif // DIALOG_H
