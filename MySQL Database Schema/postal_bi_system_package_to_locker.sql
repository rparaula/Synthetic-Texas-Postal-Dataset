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
-- Table structure for table `package_to_locker`
--

DROP TABLE IF EXISTS `package_to_locker`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `package_to_locker` (
  `locker_assignment_id` int NOT NULL,
  `package_id` binary(16) NOT NULL,
  `assigned_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `customer_id` binary(16) NOT NULL,
  PRIMARY KEY (`package_id`),
  UNIQUE KEY `PackageID` (`package_id`),
  UNIQUE KEY `uq_package_to_locker_assignment` (`locker_assignment_id`),
  KEY `fk_associatedpackage_locker` (`locker_assignment_id`),
  KEY `fk_package_to_locker_customer` (`customer_id`),
  CONSTRAINT `fk_associatedpackage_locker` FOREIGN KEY (`locker_assignment_id`) REFERENCES `lockerassignment` (`locker_assignment_id`),
  CONSTRAINT `fk_package_to_locker_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_PackageGoingIntoLocker` FOREIGN KEY (`package_id`) REFERENCES `package` (`package_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `package_to_locker`
--

LOCK TABLES `package_to_locker` WRITE;
/*!40000 ALTER TABLE `package_to_locker` DISABLE KEYS */;
/*!40000 ALTER TABLE `package_to_locker` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `bi_package_to_locker_business_rules` BEFORE INSERT ON `package_to_locker` FOR EACH ROW BEGIN
  DECLARE v_recipient_customer_id BINARY(16);
  DECLARE v_service_type_name VARCHAR(50);
  DECLARE v_assignment_customer_id BINARY(16);
  DECLARE v_assignment_assigned_at DATETIME;

  SELECT p.`recipient_customer_id`, st.`service_type_name`
  INTO v_recipient_customer_id, v_service_type_name
  FROM `package` p
  JOIN `service_type` st ON st.`service_type_id` = p.`service_type_id`
  WHERE p.`package_id` = NEW.`package_id`;

  SELECT `customer_id`, `assigned_at`
  INTO v_assignment_customer_id, v_assignment_assigned_at
  FROM `lockerassignment`
  WHERE `locker_assignment_id` = NEW.`locker_assignment_id`;

  IF v_service_type_name <> 'SmartLocker' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'package_to_locker rows are only valid for SmartLocker packages.';
  END IF;

  IF NEW.`customer_id` <> v_recipient_customer_id
     OR NEW.`customer_id` <> v_assignment_customer_id THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'package_to_locker.customer_id must match package recipient and lockerassignment customer.';
  END IF;

  IF NOT (NEW.`assigned_at` <=> v_assignment_assigned_at) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'package_to_locker.assigned_at must match lockerassignment.assigned_at.';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `bu_package_to_locker_business_rules` BEFORE UPDATE ON `package_to_locker` FOR EACH ROW BEGIN
  DECLARE v_recipient_customer_id BINARY(16);
  DECLARE v_service_type_name VARCHAR(50);
  DECLARE v_assignment_customer_id BINARY(16);
  DECLARE v_assignment_assigned_at DATETIME;

  SELECT p.`recipient_customer_id`, st.`service_type_name`
  INTO v_recipient_customer_id, v_service_type_name
  FROM `package` p
  JOIN `service_type` st ON st.`service_type_id` = p.`service_type_id`
  WHERE p.`package_id` = NEW.`package_id`;

  SELECT `customer_id`, `assigned_at`
  INTO v_assignment_customer_id, v_assignment_assigned_at
  FROM `lockerassignment`
  WHERE `locker_assignment_id` = NEW.`locker_assignment_id`;

  IF v_service_type_name <> 'SmartLocker' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'package_to_locker rows are only valid for SmartLocker packages.';
  END IF;

  IF NEW.`customer_id` <> v_recipient_customer_id
     OR NEW.`customer_id` <> v_assignment_customer_id THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'package_to_locker.customer_id must match package recipient and lockerassignment customer.';
  END IF;

  IF NOT (NEW.`assigned_at` <=> v_assignment_assigned_at) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'package_to_locker.assigned_at must match lockerassignment.assigned_at.';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-09 21:46:48
