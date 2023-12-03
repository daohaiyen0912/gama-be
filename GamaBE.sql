-- MySQL dump 10.13  Distrib 8.0.24, for macos11 (x86_64)
--
-- Host: localhost    Database: gama_db
-- ------------------------------------------------------
-- Server version	8.0.27

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
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `includes`
--

DROP TABLE IF EXISTS `includes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `includes` (
  `id` varchar(45) NOT NULL,
  `project_id` int NOT NULL,
  `filename` varchar(45) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `includes`
--

LOCK TABLES `includes` WRITE;
/*!40000 ALTER TABLE `includes` DISABLE KEYS */;
/*!40000 ALTER TABLE `includes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'2014_10_12_000000_create_users_table',1),(2,'2014_10_12_100000_create_password_resets_table',1),(3,'2019_08_19_000000_create_failed_jobs_table',1),(4,'2019_12_14_000001_create_personal_access_tokens_table',1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `models`
--

DROP TABLE IF EXISTS `models`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `models` (
  `id` varchar(45) NOT NULL,
  `project_id` varchar(45) NOT NULL,
  `filename` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `models`
--

LOCK TABLES `models` WRITE;
/*!40000 ALTER TABLE `models` DISABLE KEYS */;
/*!40000 ALTER TABLE `models` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_resets` (
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  KEY `password_resets_email_index` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_resets`
--

LOCK TABLES `password_resets` WRITE;
/*!40000 ALTER TABLE `password_resets` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_resets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (5,'App\\Models\\User',1,'myapptoken','d539fc82a6b959e1267a1bf18070565e480450c673fb9d52f45bcf63d87a4dec','[\"*\"]','2022-03-13 14:07:36','2022-03-07 16:14:40','2022-03-13 14:07:36'),(6,'App\\Models\\User',3,'myapptoken','a21bff230c0b8c9f9f1a71c5f6d4cc95ae4f1bcb5fc3052042280e7235c66d6f','[\"*\"]',NULL,'2022-03-30 15:21:00','2022-03-30 15:21:00'),(7,'App\\Models\\User',3,'myapptoken','ad3e9f7af0d3eecc6b1b0bdf1d5c86f69a65cb0747b3323219f29c792cec5b29','[\"*\"]',NULL,'2022-03-30 15:36:08','2022-03-30 15:36:08'),(8,'App\\Models\\User',3,'myapptoken','33d9c8f3994f2e1ee8e9f78f3147c13db07faf9186ed29f693c1e95ef0b30f51','[\"*\"]',NULL,'2022-03-30 15:38:21','2022-03-30 15:38:21'),(9,'App\\Models\\User',3,'myapptoken','ddac5e414981b0c378450de8366346d573190ccd71d879412785bf8c697b5d9d','[\"*\"]',NULL,'2022-03-30 16:03:50','2022-03-30 16:03:50'),(10,'App\\Models\\User',3,'myapptoken','4c0f7ccc3c2ff70035f27d3cbc3f713aae4ce8219d9cfac15d5fdff0da333139','[\"*\"]',NULL,'2022-03-30 16:08:38','2022-03-30 16:08:38'),(11,'App\\Models\\User',3,'myapptoken','77a1a899870380521818010b3d56882029254d53297e52c152a76127f5933d08','[\"*\"]',NULL,'2022-03-30 16:09:18','2022-03-30 16:09:18'),(12,'App\\Models\\User',3,'myapptoken','4942cd394fe29349d0bf0c03f16484cf1181c70825ad0ec94cfaf6c8ab0eade3','[\"*\"]',NULL,'2022-03-30 16:09:46','2022-03-30 16:09:46'),(13,'App\\Models\\User',3,'myapptoken','5473d62ecb6add348f3fe26f5c091d91639b00a7d3c19bd15f25771c5d196d19','[\"*\"]',NULL,'2022-03-30 16:19:00','2022-03-30 16:19:00'),(14,'App\\Models\\User',3,'myapptoken','131767c0a4b0aedf09efe87da22919d29f27b7bdbe26b19a53e638456320ef10','[\"*\"]',NULL,'2022-03-30 16:31:04','2022-03-30 16:31:04'),(15,'App\\Models\\User',3,'myapptoken','a29c35be16a671410c6a58ea7d162157d9372024b9521ed62b82705ebe66fef5','[\"*\"]',NULL,'2022-03-30 16:31:26','2022-03-30 16:31:26'),(16,'App\\Models\\User',3,'myapptoken','da4442f88768d7263a1b5cda2b82680d83bb776fd40821f33bc66653d7ccf99e','[\"*\"]',NULL,'2022-03-31 01:35:50','2022-03-31 01:35:50'),(17,'App\\Models\\User',3,'myapptoken','4bf1991977fd49871ad6f07b69f8b9d8c07a155526eb1d903cdfe97869d14027','[\"*\"]',NULL,'2022-03-31 01:37:53','2022-03-31 01:37:53'),(18,'App\\Models\\User',3,'myapptoken','a2bc456bb30562126d455276d61cea786d9d985eb7bc7c33a14127e54116e145','[\"*\"]',NULL,'2022-03-31 01:41:42','2022-03-31 01:41:42'),(19,'App\\Models\\User',3,'myapptoken','a5f90bbac06be8e2c1b13dc021c16d50fbafc48be7e9aa3b27360a1dea6e708e','[\"*\"]',NULL,'2022-03-31 07:28:30','2022-03-31 07:28:30'),(20,'App\\Models\\User',3,'myapptoken','02605cad1a63a2b6eb8df2a539533a4432977b6eaf0c5ca9be17f72f8348c3c8','[\"*\"]',NULL,'2022-03-31 07:28:32','2022-03-31 07:28:32'),(21,'App\\Models\\User',3,'myapptoken','490c3985ca4af3f78aaed8540baad1e8563ad2a63d3c3d6b2d5075afb2c20f36','[\"*\"]',NULL,'2022-03-31 07:57:23','2022-03-31 07:57:23'),(22,'App\\Models\\User',3,'myapptoken','3c1adb2e9bd2defc555db537b0b6cc24d7415f3999e96c20d0f3fd2554f78696','[\"*\"]',NULL,'2022-03-31 12:49:21','2022-03-31 12:49:21'),(23,'App\\Models\\User',3,'myapptoken','677f1daaa9e8eff4610daaffebe739b9db640f8504467515a3116d1c65dd77cb','[\"*\"]',NULL,'2022-03-31 12:49:22','2022-03-31 12:49:22'),(24,'App\\Models\\User',3,'myapptoken','0b6efbef395794bcdb36f820a471bacb249e67f706df0b5a71ca15c0e76da0cf','[\"*\"]',NULL,'2022-03-31 14:03:02','2022-03-31 14:03:02'),(25,'App\\Models\\User',3,'myapptoken','156cb71af73888b568be8367b96da7de5c8071cd163763f64d1d754416c350c8','[\"*\"]',NULL,'2022-03-31 17:30:24','2022-03-31 17:30:24'),(26,'App\\Models\\User',3,'myapptoken','1d349a53138903219735a09e8b01cda1350e03cd32e39281423a5ba2362dd825','[\"*\"]',NULL,'2022-03-31 17:34:09','2022-03-31 17:34:09'),(27,'App\\Models\\User',3,'myapptoken','75ecb7e8b493143b624d52eb4d09d48f7341062e71b163bf36012ef5f1226bdb','[\"*\"]',NULL,'2022-03-31 17:36:35','2022-03-31 17:36:35'),(28,'App\\Models\\User',3,'myapptoken','5ed93d3165d746092a48dcba6af62d49a8d22d95b24c8c586570171c75e9a072','[\"*\"]',NULL,'2022-04-01 06:29:23','2022-04-01 06:29:23');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `projects` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `name` varchar(45) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projects`
--

LOCK TABLES `projects` WRITE;
/*!40000 ALTER TABLE `projects` DISABLE KEYS */;
/*!40000 ALTER TABLE `projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `snapshots`
--

DROP TABLE IF EXISTS `snapshots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `snapshots` (
  `id` int NOT NULL AUTO_INCREMENT,
  `simulation_id` int NOT NULL,
  `name` varchar(45) DEFAULT NULL,
  `url` text,
  `description` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `snapshots`
--

LOCK TABLES `snapshots` WRITE;
/*!40000 ALTER TABLE `snapshots` DISABLE KEYS */;
/*!40000 ALTER TABLE `snapshots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'namtnp','nam@gmail.com',NULL,'$2y$10$wdeDrTXPuy7H06Hu/8Mxq.7jcq975zIXp5PWOS/t4G91FY.BI5AiS',NULL,'2022-03-01 16:11:08','2022-03-01 16:11:08'),(2,'namtnp1','nam1@gmail.com',NULL,'$2y$10$XwM5v/E7KGjCfIPIsp4ykOYNrmfvSI4pNTlwLQUzbfJqgMmhiLx3S',NULL,'2022-03-07 14:30:50','2022-03-07 14:30:50'),(3,'namtran','namtran@gmail.com',NULL,'$2y$10$7xjUb8M0XcC3lyfSWJkMb.fBKPKJhriBwOm7eibvWm9BZfqKC/D5q',NULL,'2022-03-30 15:20:36','2022-03-30 15:20:36');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-04-01 13:46:21
