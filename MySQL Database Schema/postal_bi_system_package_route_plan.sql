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
-- Table structure for table `package_route_plan`
--

DROP TABLE IF EXISTS `package_route_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `package_route_plan` (
  `package_id` binary(16) NOT NULL,
  `planned_origin_facility_id` int NOT NULL,
  `planned_destination_facility_id` int NOT NULL,
  `destination_purpose` varchar(30) NOT NULL,
  `selection_source` varchar(80) NOT NULL DEFAULT 'Procedure',
  `selected_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `route_note` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`package_id`),
  KEY `idx_package_route_plan_origin` (`planned_origin_facility_id`),
  KEY `idx_package_route_plan_destination` (`planned_destination_facility_id`),
  CONSTRAINT `fk_package_route_plan_destination_facility` FOREIGN KEY (`planned_destination_facility_id`) REFERENCES `facility` (`facility_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_package_route_plan_origin_facility` FOREIGN KEY (`planned_origin_facility_id`) REFERENCES `facility` (`facility_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_package_route_plan_package` FOREIGN KEY (`package_id`) REFERENCES `package` (`package_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_package_route_plan_distinct_facilities` CHECK (((`planned_origin_facility_id` <> `planned_destination_facility_id`) or (`destination_purpose` in (_utf8mb4'Delivery',_utf8mb4'Pickup',_utf8mb4'SmartLocker'))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `package_route_plan`
--

LOCK TABLES `package_route_plan` WRITE;
/*!40000 ALTER TABLE `package_route_plan` DISABLE KEYS */;
/*!40000 ALTER TABLE `package_route_plan` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-09 21:46:47
