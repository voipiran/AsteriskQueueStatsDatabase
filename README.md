# AsteriskQueueDatabase
Create Asterisk Queue Database and Insert Asterisk Queue Logs.

## Instalation (راهنمای نصب)
1) install issabel iso file with Asterisk 16 or 18 (نسخه 4 یا 5)
[Download Issabel4 Nightly](https://sourceforge.net/projects/issabelpbx/files/Issabel%204/issabel4-NIGHTLY-AST18-USB-DVD-x86_64-20211207.iso/download)
[Download Issabel5](https://voipiran.io/download/)

2) update issabel
```
yum update -y
```
3) Run This command on your Linux CLI:
```
curl -L https://github.com/voipiran/AsteriskQueueDatabase/archive/refs/heads/master.zip -o AsteriskQueueDatabase.zip && \
unzip -o -q AsteriskQueueDatabase.zip && \
mv VOIZ-main AsteriskQueueDatabase && \
cd AsteriskQueueDatabase && \
chmod 777 install.sh && \
./install.sh

```



## Give a Star! ⭐ یک ستاره با ما بدهید
If you like this project or plan to use it in the future, please give it a star. Thanks 🙏
