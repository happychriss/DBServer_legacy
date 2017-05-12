CREATE TABLE `connectors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) DEFAULT NULL,
  `service` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `prio` int(11) DEFAULT NULL,
  `uri` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `covers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `folder_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `counter` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `comment` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `first_page_only` tinyint(1) NOT NULL DEFAULT '0',
  `page_count` int(11) NOT NULL DEFAULT '0',
  `delete_at` date DEFAULT NULL,
  `no_delete` tinyint(1) DEFAULT NULL,
  `complete_pdf` tinyint(1) DEFAULT '0',
  `folder_id` int(11) DEFAULT NULL,
  `cover_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=886 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `folders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `cover_ind` tinyint(1) DEFAULT NULL,
  `short_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `message` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `messagetype` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `org_folder_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `original_filename` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source` int(11) DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `document_id` int(11) DEFAULT NULL,
  `position` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  `backup` tinyint(1) NOT NULL DEFAULT '0',
  `org_cover_id` int(11) DEFAULT NULL,
  `fid` int(11) DEFAULT NULL,
  `mime_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ocr` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3825 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `taggable_id` int(11) DEFAULT NULL,
  `taggable_type` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tagger_id` int(11) DEFAULT NULL,
  `tagger_type` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `context` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `index_taggings_on` (`taggable_id`,`taggable_type`,`context`)
) ENGINE=InnoDB AUTO_INCREMENT=879 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20130102204645');

INSERT INTO schema_migrations (version) VALUES ('20130130193932');

INSERT INTO schema_migrations (version) VALUES ('20130301220256');

INSERT INTO schema_migrations (version) VALUES ('20130312202714');

INSERT INTO schema_migrations (version) VALUES ('20130312203337');

INSERT INTO schema_migrations (version) VALUES ('20130324181724');

INSERT INTO schema_migrations (version) VALUES ('20130324215125');

INSERT INTO schema_migrations (version) VALUES ('20130324215517');

INSERT INTO schema_migrations (version) VALUES ('20130324215834');

INSERT INTO schema_migrations (version) VALUES ('20130406160533');

INSERT INTO schema_migrations (version) VALUES ('20130406160652');

INSERT INTO schema_migrations (version) VALUES ('20130409192243');

INSERT INTO schema_migrations (version) VALUES ('20130409192818');

INSERT INTO schema_migrations (version) VALUES ('20130409200043');

INSERT INTO schema_migrations (version) VALUES ('20130411183813');

INSERT INTO schema_migrations (version) VALUES ('20130416201758');

INSERT INTO schema_migrations (version) VALUES ('20130723200848');

INSERT INTO schema_migrations (version) VALUES ('20130726200328');

INSERT INTO schema_migrations (version) VALUES ('20130821194248');

INSERT INTO schema_migrations (version) VALUES ('20130821202953');

INSERT INTO schema_migrations (version) VALUES ('20130822185152');

INSERT INTO schema_migrations (version) VALUES ('20130903183640');

INSERT INTO schema_migrations (version) VALUES ('20130903201042');

INSERT INTO schema_migrations (version) VALUES ('20131001190517');

INSERT INTO schema_migrations (version) VALUES ('20131001191907');

INSERT INTO schema_migrations (version) VALUES ('20131010090651');

INSERT INTO schema_migrations (version) VALUES ('20141022194755');

INSERT INTO schema_migrations (version) VALUES ('20141102173725');

INSERT INTO schema_migrations (version) VALUES ('20141102174104');

INSERT INTO schema_migrations (version) VALUES ('20141206210928');

INSERT INTO schema_migrations (version) VALUES ('20141206212922');