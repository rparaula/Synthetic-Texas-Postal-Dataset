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
-- Table structure for table `department_type`
--

DROP TABLE IF EXISTS `department_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `department_type` (
  `department_type_id` int NOT NULL AUTO_INCREMENT,
  `department_type_code` varchar(20) NOT NULL,
  `department_type_name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`department_type_id`),
  UNIQUE KEY `uq_department_type_code` (`department_type_code`),
  UNIQUE KEY `uq_department_type_name` (`department_type_name`),
  CONSTRAINT `chk_department_type_is_active` CHECK ((`is_active` in (0,1)))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `department_type`
--

LOCK TABLES `department_type` WRITE;
/*!40000 ALTER TABLE `department_type` DISABLE KEYS */;
INSERT INTO `department_type` VALUES (1,'RETAIL','Retail Services','Customer-facing retail counter and service work.',1,'2026-06-07 21:56:15','2026-06-07 21:56:15'),(2,'DELIVERY','Delivery','Final-mile delivery and carrier work.',1,'2026-06-07 21:56:15','2026-06-07 21:56:15'),(3,'LOGISTICS','Logistics','Package routing, staging, and movement coordination.',1,'2026-06-07 21:56:15','2026-06-07 21:56:15'),(4,'OPERATIONS','Operations','Facility operations and processing supervision.',1,'2026-06-07 21:56:15','2026-06-07 21:56:15'),(5,'MAINTENANCE','Maintenance','Vehicle, equipment, and facility maintenance.',1,'2026-06-07 21:56:15','2026-06-07 21:56:15'),(6,'ADMIN','Administrative','Administrative and management support.',1,'2026-06-07 21:56:15','2026-06-07 21:56:15');
/*!40000 ALTER TABLE `department_type` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-10 14:43:27
