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
-- Table structure for table `shippingdetails`
--

DROP TABLE IF EXISTS `shippingdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shippingdetails` (
  `package_id` binary(16) NOT NULL,
  `recipient_address` varchar(150) NOT NULL,
  `recipient_territory_id` int DEFAULT NULL,
  `sender_address` varchar(150) NOT NULL,
  `sender_territory_id` int DEFAULT NULL,
  `estimated_delivery_distance` decimal(10,2) DEFAULT NULL,
  `recipient_first_name` varchar(20) DEFAULT NULL,
  `recipient_middle_initial` char(1) DEFAULT NULL,
  `recipient_last_name` varchar(20) DEFAULT NULL,
  `expected_delivery_date` datetime DEFAULT NULL,
  `delivered_date` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`package_id`),
  KEY `idx_shippingdetails_sender_territory_id` (`sender_territory_id`),
  KEY `idx_shippingdetails_recipient_territory_id` (`recipient_territory_id`),
  CONSTRAINT `fk_AssociatedPackage` FOREIGN KEY (`package_id`) REFERENCES `package` (`package_id`),
  CONSTRAINT `fk_shippingdetails_recipient_territory` FOREIGN KEY (`recipient_territory_id`) REFERENCES `territory` (`territory_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_shippingdetails_sender_territory` FOREIGN KEY (`sender_territory_id`) REFERENCES `territory` (`territory_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_shippingdetails_estimated_delivery_distance_nonnegative` CHECK (((`estimated_delivery_distance` is null) or (`estimated_delivery_distance` >= 0)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shippingdetails`
--

LOCK TABLES `shippingdetails` WRITE;
/*!40000 ALTER TABLE `shippingdetails` DISABLE KEYS */;
/*!40000 ALTER TABLE `shippingdetails` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `beforeInsertShippingdetailsValidateBusinessRules` BEFORE INSERT ON `shippingdetails` FOR EACH ROW BEGIN
  DECLARE v_package_exists INT DEFAULT 0;
  DECLARE v_service_type_name VARCHAR(30);
  DECLARE v_sender_zip_code CHAR(5);
  DECLARE v_recipient_zip_code CHAR(5);
  DECLARE v_estimated_delivery_distance DECIMAL(10,2);

  SELECT COUNT(*), MAX(st.`service_type_name`)
  INTO v_package_exists, v_service_type_name
  FROM `package` p
  JOIN `service_type` st ON st.`service_type_id` = p.`service_type_id`
  WHERE p.`package_id` = NEW.`package_id`;

  IF v_package_exists = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'shippingdetails.package_id must reference an existing package.';
  END IF;

  IF v_service_type_name <> 'Delivery' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'shippingdetails rows are only valid for Delivery packages.';
  END IF;

  IF NEW.`sender_territory_id` IS NULL OR NEW.`recipient_territory_id` IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'shippingdetails sender and recipient territory IDs are required.';
  END IF;

  IF NEW.`estimated_delivery_distance` IS NULL THEN
    SELECT `zip_code` INTO v_sender_zip_code
    FROM `territory`
    WHERE `territory_id` = NEW.`sender_territory_id`
    LIMIT 1;

    SELECT `zip_code` INTO v_recipient_zip_code
    FROM `territory`
    WHERE `territory_id` = NEW.`recipient_territory_id`
    LIMIT 1;

    CALL `CalculatePointDifference`(
      v_sender_zip_code,
      v_recipient_zip_code,
      v_estimated_delivery_distance
    );

    SET NEW.`estimated_delivery_distance` = v_estimated_delivery_distance;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `beforeUpdateShippingdetailsValidateBusinessRules` BEFORE UPDATE ON `shippingdetails` FOR EACH ROW BEGIN
  DECLARE v_package_exists INT DEFAULT 0;
  DECLARE v_service_type_name VARCHAR(30);
  DECLARE v_sender_zip_code CHAR(5);
  DECLARE v_recipient_zip_code CHAR(5);
  DECLARE v_estimated_delivery_distance DECIMAL(10,2);

  SELECT COUNT(*), MAX(st.`service_type_name`)
  INTO v_package_exists, v_service_type_name
  FROM `package` p
  JOIN `service_type` st ON st.`service_type_id` = p.`service_type_id`
  WHERE p.`package_id` = NEW.`package_id`;

  IF v_package_exists = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'shippingdetails.package_id must reference an existing package.';
  END IF;

  IF v_service_type_name <> 'Delivery' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'shippingdetails rows are only valid for Delivery packages.';
  END IF;

  IF NEW.`sender_territory_id` IS NULL OR NEW.`recipient_territory_id` IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'shippingdetails sender and recipient territory IDs are required.';
  END IF;

  IF NEW.`estimated_delivery_distance` IS NULL
     OR NOT (OLD.`sender_territory_id` <=> NEW.`sender_territory_id`)
     OR NOT (OLD.`recipient_territory_id` <=> NEW.`recipient_territory_id`) THEN
    SELECT `zip_code` INTO v_sender_zip_code
    FROM `territory`
    WHERE `territory_id` = NEW.`sender_territory_id`
    LIMIT 1;

    SELECT `zip_code` INTO v_recipient_zip_code
    FROM `territory`
    WHERE `territory_id` = NEW.`recipient_territory_id`
    LIMIT 1;

    CALL `CalculatePointDifference`(
      v_sender_zip_code,
      v_recipient_zip_code,
      v_estimated_delivery_distance
    );

    SET NEW.`estimated_delivery_distance` = v_estimated_delivery_distance;
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

-- Dump completed on 2026-06-10 14:43:51
