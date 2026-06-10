CREATE DATABASE  IF NOT EXISTS `postal_bi_system` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `postal_bi_system`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: post-office-mysql.mysql.database.azure.com    Database: postal_bi_system
-- ------------------------------------------------------
-- Server version	8.0.44-azure

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
-- Table structure for table `facility_type`
--

DROP TABLE IF EXISTS `facility_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `facility_type` (
  `facility_type_id` int NOT NULL AUTO_INCREMENT,
  `facility_type_code` varchar(10) DEFAULT NULL,
  `facility_type_name` varchar(80) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_customer_facing` tinyint(1) NOT NULL DEFAULT '0',
  `handles_retail` tinyint(1) NOT NULL DEFAULT '0',
  `handles_processing` tinyint(1) NOT NULL DEFAULT '0',
  `handles_distribution` tinyint(1) NOT NULL DEFAULT '0',
  `handles_local_delivery` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`facility_type_id`),
  UNIQUE KEY `uq_facility_type_name` (`facility_type_name`),
  UNIQUE KEY `uq_facility_type_code` (`facility_type_code`),
  CONSTRAINT `chk_facility_type_flags` CHECK (((`is_customer_facing` in (0,1)) and (`handles_retail` in (0,1)) and (`handles_processing` in (0,1)) and (`handles_distribution` in (0,1)) and (`handles_local_delivery` in (0,1)) and (`is_active` in (0,1))))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `facility_type`
--

LOCK TABLES `facility_type` WRITE;
/*!40000 ALTER TABLE `facility_type` DISABLE KEYS */;
INSERT INTO `facility_type` VALUES (1,'POST','Post Office','Customer-facing USPS post office or retail postal facility.',1,1,0,0,1,1,'2026-05-26 01:28:49','2026-06-06 21:52:43'),(2,'VMF','Vehicle Maintenance','Vehicle maintenance facility; treated as lower-priority operational flavor text for the demo.',0,0,0,0,0,1,'2026-06-06 21:52:43','2026-06-06 21:52:43'),(3,'ADMIN','Administrative Office','Administrative USPS facility; treated as lower-priority operational flavor text for the demo.',0,0,0,0,0,1,'2026-06-06 21:52:43','2026-06-06 21:52:43'),(4,'NETWORK','Network Facilities','Network facility used for package routing and distribution in the demo lifecycle.',0,0,0,1,1,1,'2026-06-06 21:52:43','2026-06-06 21:52:43'),(5,'MAIL_PROC','Mail Processing','Mail processing facility used as the primary processing node in the demo package lifecycle.',0,0,1,1,0,1,'2026-06-06 21:52:43','2026-06-06 21:52:43');
/*!40000 ALTER TABLE `facility_type` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-10 14:43:46
