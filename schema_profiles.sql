CREATE TABLE `profile_operations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `startTimestamp` bigint(20) unsigned NOT NULL,
  `correlation_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `actor` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `employee_id` bigint(20) DEFAULT NULL,
  `interface` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `details` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `app_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2187 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `profile_update_request_logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `business_id` bigint(20) NOT NULL,
  `endpoint` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `request_data` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `response_data` longtext COLLATE utf8mb4_unicode_ci,
  `timestamp` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `timestamp` (`timestamp`),
  KEY `business_id` (`business_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1932 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `profile_versions_latest` (
  `profile_id` bigint(20) unsigned NOT NULL,
  `profileOperation_id` bigint(20) unsigned NOT NULL,
  `timestamp` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `profiles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `base_id` bigint(20) DEFAULT NULL,
  `business_id` bigint(20) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `base_id` (`base_id`),
  KEY `business_id` (`business_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3306307 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `entity_active_profiles` (
  `profile_id` bigint(20) unsigned NOT NULL,
  `entity_id` bigint(20) unsigned NOT NULL,
  `locale_code` varchar(10) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  PRIMARY KEY (`entity_id`,`locale_code`),
  KEY `profile_id` (`profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `entity_primary_profiles` (
  `entity_id` bigint(20) unsigned NOT NULL,
  `profile_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`entity_id`),
  KEY `profile_id` (`profile_id`),
  CONSTRAINT `entity_primary_profiles_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `entity_profiles` (
  `profile_id` bigint(20) unsigned NOT NULL,
  `entity_id` bigint(20) unsigned NOT NULL,
  `locale_code` varchar(10) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  PRIMARY KEY (`profile_id`),
  KEY `entity_id` (`entity_id`),
  CONSTRAINT `entity_profiles_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `profile_field_data` (
  `profile_id` bigint(20) unsigned NOT NULL,
  `field_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `updateTimestamp` bigint(20) unsigned NOT NULL,
  `data` mediumblob NOT NULL,
  `profileOperation_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`profile_id`,`field_id`,`updateTimestamp`),
  KEY `profileOperation_id` (`profileOperation_id`),
  CONSTRAINT `profile_field_data_ibfk_1` FOREIGN KEY (`profileOperation_id`) REFERENCES `profile_operations` (`id`),
  CONSTRAINT `profile_field_data_ibfk_2` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `profile_field_data_latest` (
  `profile_id` bigint(20) unsigned NOT NULL,
  `field_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `updateTimestamp` bigint(20) unsigned NOT NULL,
  `data` mediumblob NOT NULL,
  `profileOperation_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`profile_id`,`field_id`),
  KEY `profileOperation_id` (`profileOperation_id`),
  CONSTRAINT `_profile_field_data_latest_ibfk_1` FOREIGN KEY (`profileOperation_id`) REFERENCES `profile_operations` (`id`),
  CONSTRAINT `_profile_field_data_latest_ibfk_2` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `profile_locks` (
  `id` bigint(20) unsigned NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timestamp` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `profile_updates` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `profileOperation_id` bigint(20) unsigned NOT NULL,
  `profile_id` bigint(20) unsigned DEFAULT NULL,
  `timestamp` bigint(20) unsigned NOT NULL,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `details` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `profileOperation_id` (`profileOperation_id`),
  KEY `profile_id` (`profile_id`),
  CONSTRAINT `_profile_updates_ibfk_1` FOREIGN KEY (`profileOperation_id`) REFERENCES `profile_operations` (`id`),
  CONSTRAINT `_profile_updates_ibfk_2` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5152 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `profile_versions` (
  `profile_id` bigint(20) unsigned NOT NULL,
  `profileOperation_id` bigint(20) unsigned NOT NULL,
  `timestamp` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`profile_id`,`timestamp`),
  KEY `profileOperation_id` (`profileOperation_id`),
  KEY `timestamp` (`timestamp`),
  CONSTRAINT `__profile_versions_ibfk_1` FOREIGN KEY (`profileOperation_id`) REFERENCES `profile_operations` (`id`),
  CONSTRAINT `__profile_versions_ibfk_2` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
