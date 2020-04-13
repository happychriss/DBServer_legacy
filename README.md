
![logo](https://github.com/happychriss/DocumentBox-Server/blob/master/app/assets/images/documentbox_pic.jpg)

DocumentBox for RPI 3/4 and TouchSwitch (new version)
===========

DocumentBox is a OpenSource „home use“ Document Management system that helps you to
easy scan, file and find your documents. Its running on a mini computer
as small as a Raspberry Pi 3 or 4. A scanner connected to the mini-computers
allows you to quickly scan your documents and file them directly from
your mobile phone or tablet.

**DocumentBox is made for the paranoid** 

All data is stored locally – only
sending your files fully encrypted for backup to the the cloud (Amazon
S3). The database and all configuration data is also automatically
encrypted and uploaded to S3.

**DocumentBox is made to save your time**

A unique work-flow keeps your desk clean and lets you find your documents in a second.

**DocumentBox is made to make fun**

Check out, how it looks and feels:
https://www.youtube.com/watch?v=xCD8ukdc4cc

**DocumentBox is flexible and mobile**

I have also developed a mobile-app that allows uploading documents using the camera of your mobile phone. 
The scanned files are stored on the phone and will be uploaded to the DocumentBox server only in your local
Wifi network to assure your data privacy. This mobile app is not part of this repository and may be published later.

Technical Overview
==================

DocumentBox is running as a Linux RoR Web Service on the Pi 3. All
documents are indexed in a DB and stored locally (e.g. on SD card) .
Also OCR and image processing needs some computer power, the PI 3 is
able to process the data. But the design also allows to “outsource” this
action to any PC via a daemon program (communicating with the PI). An
optional configurable hardware depending component allows to control the
scanner and some LEDs for the print process.

Installation
============

You will need at minimum a Raspberry PI3/4 with sufficient big SD card.

The below instruction is tested for the following image: 

```bash
Raspbian Stretch and Buster Lite
```

It is strongly recommend to use this image when following below installation.


Content
            
   * [General Installation](#installation)
      * [Prepare the PI](#prepare-the-pi)
      * [Install general SW Packages](#install-general-sw-packages)   
   * [Install DocumentBox Server](#install-documentbox-server)
   * [Setup MySQL Database](#setup-mysql-database)
   * [Configure Backup on Amazon S3](#configure-backup-on-amazon-s3)    
   * [Configure nginx](#configure-nginx)
   * [Install DocumentBox Daemons](#install-documentbox-daemons)      
   * [Configure Scanner](#configure-scanner)
   * [Run DocumentBox](#run-documentbox)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

Prepare the PI
--------------
### Fixed IP Address for the PI

You will need to configure the PI with a fixed IP address, to make it
possible for the SW services to work and to reach the DocumentBox from
your home network.

Update following file
```bash
File: //etc/dhcpcd.con  

# fixed IP address for PI  
interface wlan0  
static ip_address=192.168.1.105/24 #enter your IP address  
static routers=192.168.1.1 # enter your gateway IP address
```

### Setup the user ‘docbox’

The installation instructions is assuming a user ‘docbox’ and a folder
structure as //home/docbox for the file system.

```bash
sudo adduser docbox
sudo adduser docbox sudo
```

Little tip, when using ssh to connect to pi, run 
```bash
ssh-copy-id docbox@pi
```
to directly connect to the pi without repeating password and passphrase.

Install general SW Packages
---------------------------

```bash
# ruby components and the basics
sudo apt-get update  
sudo apt-get upgrade
sudo apt-get install ruby ruby-dev nodejs libavahi-compat-libdnssd-dev git nginx redis-server sphinxsearch
sudo gem install bundler

# database
sudo apt-get install mysql-server libmariadbclient-dev

# configure a user for mysql (MariaDB)
sudo su
mysql
# In mysql
           CREATE USER 'docbox'@'localhost' identified by 'docbox'
           GRANT ALL PRIVILEGES ON *.* TO 'docbox'@'localhost'
           flush privileges

# tools supporting scanning and OCR jobs
sudo apt-get install imagemagick poppler-utils unpaper tesseract-ocr tesseract-ocr-deu html2ps exactimage oracle-java8-jdk sane

```

Overview
========

!!! Now, please login with the new user docbox !!!!
Please check, you should not use "sudo" for any command, only if noted down


Install DocumentBox Server
==========================
Download Source-code
--------------------

DocumentBox is hosted on GitHub an written in Ruby On Rails. It consists
out of 2 repository: DocBox-Server and DocBox-Daemons. First the Server
is installed.

Ruby manages the SW packages in “gems” - to prepare for this, login with
user docbox – execute below commands:
```bash
echo "gem: --no-ri --no-rdoc" >> ~/.gemrc
echo "export RAILS_ENV=production" >> ~/.bashrc
source ~/.bashrc
```

To download the source code and automatically install all Ruby
dependencies (gems):

```bash
cd
git clone https://github.com/happychriss/DocumentBox-Server.git
mv DocumentBox-Server DBServer #just to give the folder a shorter  name - IMPORTANT
cd DBServer
bundle install
```

Configure Subnet
----------------

This is only needed when the IP address of the Pi does not start with
192.168.1.\*

Update below file with your subnet (last 3 group of your PI’s IP)

```bash
File: /home/docbox/DBServer/docbox.god.rb
SUBNET = “192.168.1”
```

### Create Root folder for mass data storage

All scanned files are stored in the file system as PDF and preview
images. This folder can be also located on an connected SD card . A link
from the DBServer folder to the data folder is also set-up.

```bash
sudo mkdir //data
sudo chown docbox //data
cd //data
mkdir docstore  #//data/docstore is folder for documents stored locally
cd /home/docbox/DBServer
ln -s //data/docstore/ docstore
```

Setup Postgres Database 
=====================

Ruby on Rails provides support to set-up and create a database. You will
need user-name and password as selected when installing Postgres and update
it in the file database.yml . Feel free to create a DB new user, the DB
user will need authorization to update data and create tables. For setting- up initial Postgres user, follow the standard instructions.

```bash
cd DBServer/config
cp database_example.yml database.yml #later you may change your db user or password
cp s3_example.yml s3.yml #later you wil update here your s3 credentials
rake db:create
rake db:schema:load
rake db:seed #will just create default values in the DB
```

Comnpile the static assets

```bash
rake assets:precompile
```

Configure Backup on Amazon S3
=============================

DocumentBox is configured to use Amazon S3 Service for the backup of
scanned files and the database. Depending on your scanner, 1 file is
between 500kB and 1MB.

SetUp Amazon S3 Bucket
----------------------

You need to create to buckets, one for the files and the second one for
DB. You will need to collect the s3\_access\_key and s3\_secret\_key to
enable DocumentBox to upload files.

The buckets should be named in the production section:
```text
production.docbox.com
production.docbox.db.com
```

### Update Config Files with Credentials 

The s3.yml file needs to be updated with above credentials:
```bash
DBServer/config/s3.yml
```

### Configure gpg encryption for file-upload and backup

All data uploaded to Amazon S3 will be encrypted using GPG Linux. Follow instructions by the program and accept the default values.
```bash
gpg --gen-key
```

Make sure to backup the key-pair, so you can encrypt your data when
downloading it from Amazon S3, the key is stored in the following folder
```bash
/home/docbox/.gnupg
```

The email address used for the key needs to be updated in the file  
```bash
/DBServer/config/s3.yml #field gpg_email_address
```

Configure nginx
===============

DocumentBox is using “thin” as Rails WebServer and Nginx as application
server and for assest management.

```bash
cd DBServer
sudo mv //etc/nginx/nginx.conf //etc/nginx/nginx.conf.bak
sudo mv app_support/nginx.conf //etc/nginx/nginx.conf
```

Configure Sphinx
===============
Sphinx is the search engine that creates an index and speeds it up when searching the documents.

```bash
cd DBServer
rake ts:rebuild
rake ts:index
```

Install DocumentBox Daemons
===========================

The daemons provide a modular system and can be configured to run on
different computers. Each daemon will use network discovery service to
find the DBServer and register it services. Therefore no IP
configuration is needed.

The following daemons are available:

**Scanner Daemon**

Connects the scanner and does prepare the scanned image for OCR
processing using UNPAPER.

**Converter Daemon**

Does all the heavy OCR work. Can run using abbyocr (for linux, no
freeware, but very fast and provides excellent OCR results) or
tesseract-ocr. Daemon is first checking for abbyocr and then for
tesseract-ocr.

**Hardware Daemon**

Not used in this version, allows to set LED or start&stop the scanning
process.

Download Software from GitHub
-----------------------------

```bash
cd
git clone https://github.com/happychriss/DocumentBox-Daemons.git
mv DocumentBox-Daemons/ DBDaemons # give it a short name
cd DBDaemons
bundle install
```

After completing the installation you should have the following folder
structure
```bash
home/docbox/DBServer #hosts the Web-server
home/docbox/DBDaemon # hosts the working processes
//data # host the scanned images
```

**Configure Scanner**
=====================

DocumentBox is using the Linux sane-library to communicate with the
scanner. I am using ScanSnap S1300 for scanning, as it support 2sided
pages and multiple pages scanning.

Only tested with ScanSnap S1300 – that requires some firmware download –
described here

[*https://www.josharcher.uk/code/install-scansnap-s1300-drivers-linux/*](https://www.josharcher.uk/code/install-scansnap-s1300-drivers-linux/)

### Instruction for S1300

```bash
cd
sudo mkdir /usr/share/sane/epjitsu
wget https://www.josharcher.uk/static/files/2016/10/1300_0C26.nal
sudo mv 1300_0C26.nal /usr/share/sane/epjitsu
sudo gpasswd -a docbox scanner
```

Check if it is working with:

```bash
scanimage -L
```

Output should be similar to „epjitsu:libusb:001:004' is a FUJITSU
ScanSnap S1300 scanner“
 
If scanimage only works with sudo user, create a file 55-libsane.rules in folder //etc/udev/rules.d with following content:
 ```bash
 ATTRS{idVendor}=="04c5", ATTRS{idProduct}=="11ed", GROUP="scanner", ENV{libsane_matched}="yes"
 ```
 

Run DocumentBox
===============

DocumentBox is using “god” as a framework to start and monitor the
application.

The file docbox.god.rb contains the startup configuration.

The following command will start the Server and Daemons in foreground to
check the start-up process.

```bash
cd DBServer
god start docbox -c docbox.god.rb -D

You can reach the server in your local network, e.g:
http://192.168.1.106:8082

# Other useful “god” commands

god start docbox -c docbox.god.rb #without -D will start in background (e.g. add to chron
god stop docbox      # will stop all services
god restart docbox   # will start all services
god restart scanner  # will restart a single services
```

