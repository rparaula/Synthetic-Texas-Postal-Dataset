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
-- Table structure for table `pickupdetails`
--

DROP TABLE IF EXISTS `pickupdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pickupdetails` (
  `package_id` binary(16) NOT NULL,
  `sender_address` varchar(150) DEFAULT NULL,
  `sender_territory_id` int DEFAULT NULL,
  `recipient_address` varchar(150) DEFAULT NULL,
  `recipient_territory_id` int DEFAULT NULL,
  `recipient_first_name` varchar(20) DEFAULT NULL,
  `recipient_middle_initial` char(1) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `recipient_last_name` varchar(20) DEFAULT NULL,
  `sender_customer_id` binary(16) DEFAULT NULL,
  PRIMARY KEY (`package_id`),
  KEY `idx_pickupdetails_sender_territory_id` (`sender_territory_id`),
  KEY `idx_pickupdetails_recipient_territory_id` (`recipient_territory_id`),
  KEY `fk_pickupdetails_sender` (`sender_customer_id`),
  CONSTRAINT `fk_AssociatedPickup` FOREIGN KEY (`package_id`) REFERENCES `package` (`package_id`),
  CONSTRAINT `fk_pickupdetails_recipient_territory` FOREIGN KEY (`recipient_territory_id`) REFERENCES `territory` (`territory_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_pickupdetails_sender` FOREIGN KEY (`sender_customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_pickupdetails_sender_territory` FOREIGN KEY (`sender_territory_id`) REFERENCES `territory` (`territory_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pickupdetails`
--

LOCK TABLES `pickupdetails` WRITE;
/*!40000 ALTER TABLE `pickupdetails` DISABLE KEYS */;
/*!40000 ALTER TABLE `pickupdetails` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `bi_pickupdetails_business_rules` BEFORE INSERT ON `pickupdetails` FOR EACH ROW BEGIN
  DECLARE v_sender_customer_id BINARY(16);
  DECLARE v_service_type_name VARCHAR(50);

  SELECT p.`sender_customer_id`, st.`service_type_name`
  INTO v_sender_customer_id, v_service_type_name
  FROM `package` p
  JOIN `service_type` st ON st.`service_type_id` = p.`service_type_id`
  WHERE p.`package_id` = NEW.`package_id`;

  IF v_service_type_name <> 'Pickup' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'pickupdetails rows are only valid for Pickup packages.';
  END IF;

  IF NOT (NEW.`sender_customer_id` <=> v_sender_customer_id) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'pickupdetails.sender_customer_id must match package.sender_customer_id.';
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `bu_pickupdetails_business_rules` BEFORE UPDATE ON `pickupdetails` FOR EACH ROW BEGIN
  DECLARE v_sender_customer_id BINARY(16);
  DECLARE v_service_type_name VARCHAR(50);

  SELECT p.`sender_customer_id`, st.`service_type_name`
  INTO v_sender_customer_id, v_service_type_name
  FROM `package` p
  JOIN `service_type` st ON st.`service_type_id` = p.`service_type_id`
  WHERE p.`package_id` = NEW.`package_id`;

  IF v_service_type_name <> 'Pickup' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'pickupdetails rows are only valid for Pickup packages.';
  END IF;

  IF NOT (NEW.`sender_customer_id` <=> v_sender_customer_id) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'pickupdetails.sender_customer_id must match package.sender_customer_id.';
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

-- Dump completed on 2026-06-10 14:43:50
