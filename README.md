DocumentBox - Never search for your documents again!
==================

Document management running on Cubietruck or any NAS
----------------------------

DocumentBox is a document management system for home use. Scan you documents with 1-Click on you scanner and store them 
centralized / searchable. Find documents in seconds with a sneak document preview.

DocumentBox is made for the paranoid, who dont want to sent any unencrpyted information to cloud, so you can reliable keep
you private infomratoin private.

DocumentBox provides a unique workflow I have developed to easy manage all my priate documents. 
It supports document you just scan and throwh away, and also documents you  should keep for tax reasons. Documents to be 
kept can be stored in a single folder, DocumentBox provides an easy way to find this documents later in the folder.

It has reduced the amount of paper I store at home significant, also the time I spent searching for documents. Comparing 
the my yearly heating costs is done in a second.

 
Including:
-----------

  * All documents stored as searchable PDF
  * Full Text Index Search
  * Also Upload Word, Excel, Pictures
  * Connect to multiple scanners
  * Use your mobile camera to direct upload to CleanDesk
  * Search from iPad or any laptop in you local Wifi network
  * upload encrypted data automatically to Amazon S3 or other cloud storages
  * Using Daemon running on your desktop to support the NAS/Cubietruck with computing power
    https://github.com/happychriss/CDDaemon

   

Requirements:
--------
  * abbyyocr (or any other OCR software)
  * pdftotext
  * using AWS3 for file backup via PGP, keys should be installed and configured in e.g. production.rb (see example.rb)
  * sphinx is compiled with using libstemmer_de
  * s3cmd for upload db backup to s3

  
  
  