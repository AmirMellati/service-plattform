-- MySQL dump 10.13  Distrib 8.0.46, for macos15 (arm64)
--
-- Host: 127.0.0.1    Database: comgatus
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `anfragen`
--

DROP TABLE IF EXISTS `anfragen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `anfragen` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `auftraggeber_id` bigint unsigned NOT NULL,
  `handwerker_id` bigint unsigned NOT NULL,
  `messestand_id` bigint unsigned NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_anfragen_auftraggeber` (`auftraggeber_id`),
  KEY `fk_anfragen_handwerker` (`handwerker_id`),
  KEY `fk_anfragen_messestand` (`messestand_id`),
  CONSTRAINT `fk_anfragen_auftraggeber` FOREIGN KEY (`auftraggeber_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_anfragen_handwerker` FOREIGN KEY (`handwerker_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_anfragen_messestand` FOREIGN KEY (`messestand_id`) REFERENCES `messestaende` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `anfragen`
--

LOCK TABLES `anfragen` WRITE;
/*!40000 ALTER TABLE `anfragen` DISABLE KEYS */;
INSERT INTO `anfragen` VALUES (1,1,2,1,'OFFEN','Hamburg',NULL,NULL);
/*!40000 ALTER TABLE `anfragen` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `aktion` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `objekt_typ` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `objekt_id` bigint unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_audit_logs_user` (`user_id`),
  CONSTRAINT `fk_audit_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,2,'STREITFALL_GEOEFFNET','STREITFALL',1,'2026-08-10 15:38:57');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buchungen`
--

DROP TABLE IF EXISTS `buchungen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `buchungen` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `anfrage_id` bigint unsigned NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `termin` timestamp NULL DEFAULT NULL,
  `preis` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `anfrage_id` (`anfrage_id`),
  CONSTRAINT `fk_buchungen_anfrage` FOREIGN KEY (`anfrage_id`) REFERENCES `anfragen` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buchungen`
--

LOCK TABLES `buchungen` WRITE;
/*!40000 ALTER TABLE `buchungen` DISABLE KEYS */;
INSERT INTO `buchungen` VALUES (1,1,'BESTAETIGT','2026-08-20 08:00:00',80.00,NULL,NULL);
/*!40000 ALTER TABLE `buchungen` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `einsatzgebiete`
--

DROP TABLE IF EXISTS `einsatzgebiete`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `einsatzgebiete` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `messestand_id` bigint unsigned NOT NULL,
  `gebiet` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `messestand_id` (`messestand_id`),
  CONSTRAINT `fk_einsatzgebiete_messestand` FOREIGN KEY (`messestand_id`) REFERENCES `messestaende` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `einsatzgebiete`
--

LOCK TABLES `einsatzgebiete` WRITE;
/*!40000 ALTER TABLE `einsatzgebiete` DISABLE KEYS */;
INSERT INTO `einsatzgebiete` VALUES (1,1,'Hamburg',NULL,NULL);
/*!40000 ALTER TABLE `einsatzgebiete` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mediation_logs`
--

DROP TABLE IF EXISTS `mediation_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mediation_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `streitfall_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `aktion` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `notiz` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_mediation_logs_streitfall` (`streitfall_id`),
  KEY `fk_mediation_logs_user` (`user_id`),
  CONSTRAINT `fk_mediation_logs_streitfall` FOREIGN KEY (`streitfall_id`) REFERENCES `streitfaelle` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_mediation_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mediation_logs`
--

LOCK TABLES `mediation_logs` WRITE;
/*!40000 ALTER TABLE `mediation_logs` DISABLE KEYS */;
INSERT INTO `mediation_logs` VALUES (1,1,2,'KONTAKT_AUFGENOMMEN','Handwerker wurde zur Stellungnahme kontaktiert.','2026-08-10 15:38:08');
/*!40000 ALTER TABLE `mediation_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messestaende`
--

DROP TABLE IF EXISTS `messestaende`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messestaende` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `price_from` decimal(10,2) DEFAULT NULL,
  `price_to` decimal(10,2) DEFAULT NULL,
  `featured` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_messestaende_user` (`user_id`),
  CONSTRAINT `fk_messestaende_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messestaende`
--

LOCK TABLES `messestaende` WRITE;
/*!40000 ALTER TABLE `messestaende` DISABLE KEYS */;
INSERT INTO `messestaende` VALUES (1,2,'Elektroinstallation','Professionelle Elektroarbeiten für Wohnungen und Häuser.',50.00,120.00,1,NULL,NULL);
/*!40000 ALTER TABLE `messestaende` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messestand_bilder`
--

DROP TABLE IF EXISTS `messestand_bilder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messestand_bilder` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `messestand_id` bigint unsigned NOT NULL,
  `bild` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_messestand_bilder_messestand` (`messestand_id`),
  CONSTRAINT `fk_messestand_bilder_messestand` FOREIGN KEY (`messestand_id`) REFERENCES `messestaende` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messestand_bilder`
--

LOCK TABLES `messestand_bilder` WRITE;
/*!40000 ALTER TABLE `messestand_bilder` DISABLE KEYS */;
/*!40000 ALTER TABLE `messestand_bilder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messestand_skill_beziehung`
--

DROP TABLE IF EXISTS `messestand_skill_beziehung`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messestand_skill_beziehung` (
  `messestand_id` bigint unsigned NOT NULL,
  `skill_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`messestand_id`,`skill_id`),
  KEY `fk_msb_skill` (`skill_id`),
  CONSTRAINT `fk_msb_messestand` FOREIGN KEY (`messestand_id`) REFERENCES `messestaende` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_msb_skill` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messestand_skill_beziehung`
--

LOCK TABLES `messestand_skill_beziehung` WRITE;
/*!40000 ALTER TABLE `messestand_skill_beziehung` DISABLE KEYS */;
INSERT INTO `messestand_skill_beziehung` VALUES (1,3);
/*!40000 ALTER TABLE `messestand_skill_beziehung` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nachrichten`
--

DROP TABLE IF EXISTS `nachrichten`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nachrichten` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `anfrage_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `nachricht` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `gesendet_am` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_nachrichten_anfrage` (`anfrage_id`),
  KEY `fk_nachrichten_user` (`user_id`),
  CONSTRAINT `fk_nachrichten_anfrage` FOREIGN KEY (`anfrage_id`) REFERENCES `anfragen` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_nachrichten_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nachrichten`
--

LOCK TABLES `nachrichten` WRITE;
/*!40000 ALTER TABLE `nachrichten` DISABLE KEYS */;
INSERT INTO `nachrichten` VALUES (1,1,1,'Hallo, ich habe eine Anfrage zu Ihrem Angebot.','2026-08-10 15:35:31');
/*!40000 ALTER TABLE `nachrichten` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profiles`
--

DROP TABLE IF EXISTS `profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `profiles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `bio` text COLLATE utf8mb4_unicode_ci,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `fk_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profiles`
--

LOCK TABLES `profiles` WRITE;
/*!40000 ALTER TABLE `profiles` DISABLE KEYS */;
INSERT INTO `profiles` VALUES (1,1,'Testprofil Auftraggeber','profile1.jpg',NULL,NULL);
/*!40000 ALTER TABLE `profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rechnungen`
--

DROP TABLE IF EXISTS `rechnungen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rechnungen` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `buchung_id` bigint unsigned NOT NULL,
  `rechnungsnummer` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `betrag` decimal(10,2) NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ausgestellt_am` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `buchung_id` (`buchung_id`),
  UNIQUE KEY `rechnungsnummer` (`rechnungsnummer`),
  CONSTRAINT `fk_rechnungen_buchung` FOREIGN KEY (`buchung_id`) REFERENCES `buchungen` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rechnungen`
--

LOCK TABLES `rechnungen` WRITE;
/*!40000 ALTER TABLE `rechnungen` DISABLE KEYS */;
INSERT INTO `rechnungen` VALUES (1,1,'RE-2026-0001',80.00,'ERSTELLT','2026-08-10 15:34:57',NULL,NULL);
/*!40000 ALTER TABLE `rechnungen` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `skills`
--

DROP TABLE IF EXISTS `skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `skills` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skills`
--

LOCK TABLES `skills` WRITE;
/*!40000 ALTER TABLE `skills` DISABLE KEYS */;
INSERT INTO `skills` VALUES (2,'Beleuchtung'),(1,'Elektroinstallation'),(3,'Reparatur');
/*!40000 ALTER TABLE `skills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `streitfaelle`
--

DROP TABLE IF EXISTS `streitfaelle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `streitfaelle` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `buchung_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `grund` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `buchung_id` (`buchung_id`),
  KEY `fk_streitfaelle_user` (`user_id`),
  CONSTRAINT `fk_streitfaelle_buchung` FOREIGN KEY (`buchung_id`) REFERENCES `buchungen` (`id`),
  CONSTRAINT `fk_streitfaelle_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `streitfaelle`
--

LOCK TABLES `streitfaelle` WRITE;
/*!40000 ALTER TABLE `streitfaelle` DISABLE KEYS */;
INSERT INTO `streitfaelle` VALUES (1,1,1,'Die vereinbarte Leistung wurde nicht vollständig erbracht.','OFFEN',NULL,NULL);
/*!40000 ALTER TABLE `streitfaelle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trust_events`
--

DROP TABLE IF EXISTS `trust_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trust_events` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `event` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `points` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_trust_events_user` (`user_id`),
  CONSTRAINT `fk_trust_events_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trust_events`
--

LOCK TABLES `trust_events` WRITE;
/*!40000 ALTER TABLE `trust_events` DISABLE KEYS */;
INSERT INTO `trust_events` VALUES (1,2,'BOOKING_COMPLETED',10,'2026-08-10 15:36:07');
/*!40000 ALTER TABLE `trust_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Auftraggeber Test','auftraggeber@test.de','test123','auftraggeber','aktiv',NULL,NULL),(2,'Handwerker Test','handwerker@test.de','test123','handwerker','aktiv',NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `zahlungen`
--

DROP TABLE IF EXISTS `zahlungen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `zahlungen` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `buchung_id` bigint unsigned NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `betrag` decimal(10,2) NOT NULL,
  `bezahlt_am` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `buchung_id` (`buchung_id`),
  CONSTRAINT `fk_zahlungen_buchung` FOREIGN KEY (`buchung_id`) REFERENCES `buchungen` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `zahlungen`
--

LOCK TABLES `zahlungen` WRITE;
/*!40000 ALTER TABLE `zahlungen` DISABLE KEYS */;
INSERT INTO `zahlungen` VALUES (1,1,'BEZAHLT',80.00,'2026-08-10 15:33:36',NULL,NULL);
/*!40000 ALTER TABLE `zahlungen` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-10 18:32:19
