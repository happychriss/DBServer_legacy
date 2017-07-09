# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
f=Folder.create(name: '1 - Nur Scannen', short_name: 'ScanOnly', cover_ind: false);
f.save
f=Folder.create(name: '2 - Ablegen in Ordner', short_name: 'Ablage', cover_ind: true);
f.save

