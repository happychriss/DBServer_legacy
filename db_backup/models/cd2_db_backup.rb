# encoding: utf-8

##
# backup Generated: cd2_db_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t cd2_db_backup [-c <path_to_configuration_file>]
#
# yes

database_yml = File.expand_path('../../../config/database.yml',  __FILE__)
s3_yml = File.expand_path('../../../config/s3.yml',  __FILE__)
MY_RAILS_ENV = ENV['RAILS_ENV'] || 'development'

require 'yaml'
db_config = YAML.load_file(database_yml)
s3_config = YAML.load_file(s3_yml)

Backup::Model.new(:cd2_db_backup, 'DocBox Server Database backup') do
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 250 megabytes
  # if the backup file size exceeds 250 megabytes
  #
  split_into_chunks_of 250

  ##
  # MySQL [Database]
  #
  database MySQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = db_config[MY_RAILS_ENV]['database']

    db.username           = db_config[MY_RAILS_ENV]['username']
    db.password           = db_config[MY_RAILS_ENV]['password']
    db.host               = "localhost"
    db.port               = 3306
    db.socket             = db_config[MY_RAILS_ENV]['socket']
    # Note: when using `skip_tables` with the `db.name = :all` option,
    # table names should be prefixed with a database name.
    # e.g. ["db_name.table_to_skip", ...]
#    db.skip_tables        = ["skip", "these", "tables"]
#    db.only_tables        = ["only", "these", "tables"]
#    db.additional_options = ["--quick", "--single-transaction"]
  end

  encrypt_with GPG do |encryption|
    encryption.keys = {}
    encryption.keys['dev.cleandesk@googlemail.com'] = <<-KEY
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.11 (GNU/Linux)

mQENBE3zvMABCAC5T9P96kWqg6Kx8hJJ4n6aDgSDcKBk/XFpF2oSm3t/TUc9bIie
CfvcCEohTXDWU87QomGZDfyz1ktfidskE8/D97ct5dv7TfsSmVNKqfjxNXtn9ZoT
w5c3JoxBE4kpRFCqV+IgFHudfZzfcvAZiXKThPqO6bA13Vi6wPGYUVM6cs/GaK32
dfUo9+cO0b0qoOZo/QNOoYj8CJOyGnCtjNpHfZGq3bHgIivsSo4c4Yeosa0jsORE
INuRLYUJUsxjmuT4OlW8MXRfVi3C083Lt859kt4HujlIzQey1iNMxN/zI52UHc3r
vSpNVCySzFWP35dWs2oMiCKNzma9tabJcb4ZABEBAAG0U0NsZWFuZGVzayBEZXYg
KERldmVsb3BtZW50IEtleSAtIEVuY3J5cHRpb24gQ0QgQVdTMykgPGRldi5jbGVh
bmRlc2tAZ29vZ2xlbWFpbC5jb20+iQE4BBMBAgAiBQJN9fhWAhsDBgsJCAcDAgYV
CAIJCgsEFgIDAQIeAQIXgAAKCRBfxHORV9eZy0oZCACnOVHVY2uRArbtDMwk+CND
tnf2ch5VJl/EGHshh0ssFssaLaFbitZY+NnUMiZOLSA+lSQp+WJ+7qoysMVwRqSo
TyMjOALhmvLFgbPRIMSXrZBvbwzU+ugaUWCqrTxpGV3dBk61Rq6e9FjU7+PMmeJC
ZdzgBdQTs35/2S7CToGi2aevB/fU1GneUNUHk/1PptCNIBITfO2IxlkgT01fObZo
coGcSvwcGKSLEWIY5DetePjxBBxYEYR9a7SIe94auReWL5BL+qcGz8KJwKbMu/To
qFH4F8cGfCSaWjg29TfJnh/EiGvqIrI6O3+693TkqpUrdg61facM9CuMrAC1HtoN
uQENBE3zvMABCACpoxT2VVF/1QvfXsnFOjmgsbeWMU5VgK4hHnpSeP8P7lM75AdO
8ThbXE/GJyE7ZEWQ3rSDW/aDV4wpdZT7wS+Y6oox4ms3846nIOq6GUnUXH7syKLr
wJ7Es2qGYuJVlrIlxpLH/cM/02CuhvdO2ePaxfXvGd14RnKWOZlUvw6q+I31CUNr
gTx+inGqkETh/390R2NVbRXdJarrI/rB+btkW4o6JpAXq7NBWgA4Yl5uz/bXpYmx
K6U3Yk6bAI13+/+argqBMbi6XcxCYfPdpYKjn/WTBvtSSCRgMCA+OSkM40JKt1np
UxEIRF5BOJP97CFDqilp8LkMS8KLDOPPYVdzABEBAAGJAR8EGAECAAkFAk3zvMAC
GwwACgkQX8RzkVfXmctihgf/eTS2C0SAwu8+yWhllSgnHY4Yrb+Lf0JJyBZzSUGe
vMZS8vpCU6iOOYte0fdNTLMqU43ISRiCgclLWhhSK7fHnvRzN0A5SYEUAxsfvRti
g9B81Ns4YLr9RuEKa30W3RRZWLUagA8DwSpZwzHM0vzJHlZzdiTfo/F5VbmNpt4r
F9Z3aLW1+uJHA+PuOdNQwZZGjvFAxAFCHJaMFQvVc5JwEVHosngMpkZWg9qdtUv7
65U6CNGknrXlHLQ49mCUtV+2dkYrHCeOi2U3fH+r30FEBI1Y/ETXkOnGuyBeC+Vl
gqN0/W/Vou3uAQG+hqVd67D36az+BpXMiZWHNhDx5W9Dyw==
=TP/S
-----END PGP PUBLIC KEY BLOCK-----
    KEY
    encryption.recipients = 'dev.cleandesk@googlemail.com'
  end

  ##
  # Amazon Simple Storage Service [Storage]
  #
  # Available Regions:
  #
  #  - ap-northeast-1
  #  - ap-southeast-1
  #  - eu-west-1
  #  - us-east-1
  #  - us-west-1
  #
  store_with S3 do |s3|
    s3.access_key_id     = s3_config[MY_RAILS_ENV]['aws_s3_access_key']
    s3.secret_access_key = s3_config[MY_RAILS_ENV]['aws_s3_secret_key']
    s3.region            = "us-east-1"
    s3.bucket            = s3_config[MY_RAILS_ENV]['aws_s3_db_bucket']
#    s3.path              = "/path/to/my/backups"
    s3.keep              = 10
    s3.fog_options = { :path_style => true }        #https://github.com/meskyanichi/backup/issues/518
  end


  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the Wiki for other delivery options.
  # https://github.com/meskyanichi/backup/wiki/Notifiers
  #
  notify_by Mail do |mail|
    mail.on_success           = true
    mail.on_warning           = true
    mail.on_failure           = true

    mail.from                 = "pmsfriend@gmail.com"
    mail.to                   = "neuhaus.info@gmail.com"
    mail.address              = "smtp.gmail.com"
    mail.port                 = 587
    mail.domain               = "gmail.com"
    mail.user_name            = "pmsfriend@gmail.com"
    mail.password             = "atuyetxmu"
    mail.authentication       = "plain"
    mail.encryption           = :starttls
  end

end
