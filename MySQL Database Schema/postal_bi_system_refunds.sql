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
-- Table structure for table `refunds`
--

DROP TABLE IF EXISTS `refunds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refunds` (
  `refund_id` int NOT NULL AUTO_INCREMENT,
  `package_id` binary(16) NOT NULL,
  `refund_amount` decimal(5,2) NOT NULL,
  `refund_reason` varchar(50) NOT NULL,
  `refund_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `refund_status` varchar(15) NOT NULL DEFAULT 'Pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `customer_id` binary(16) NOT NULL,
  PRIMARY KEY (`refund_id`),
  KEY `package_fk_idx` (`package_id`),
  KEY `customer_id_idx` (`customer_id`),
  CONSTRAINT `fk_CustomerRefund` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  CONSTRAINT `refunds_ibfk_1` FOREIGN KEY (`package_id`) REFERENCES `package` (`package_id`),
  CONSTRAINT `chk_refunds_amount_nonnegative` CHECK ((`refund_amount` >= 0)),
  CONSTRAINT `chk_refunds_reason_not_blank` CHECK ((trim(`refund_reason`) <> _utf8mb4'')),
  CONSTRAINT `chk_refunds_status_valid` CHECK ((`refund_status` in (_utf8mb4'Pending',_utf8mb4'Approved',_utf8mb4'Rejected',_utf8mb4'Paid',_utf8mb4'Cancelled')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refunds`
--

LOCK TABLES `refunds` WRITE;
/*!40000 ALTER TABLE `refunds` DISABLE KEYS */;
/*!40000 ALTER TABLE `refunds` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `bi_refunds_business_rules` BEFORE INSERT ON `refunds` FOR EACH ROW BEGIN
  DECLARE v_recipient_customer_id BINARY(16);
  DECLARE v_status_name VARCHAR(30);
  DECLARE v_charge_amount DECIMAL(8,2);
  DECLARE v_duplicate_count INT DEFAULT 0;

  SELECT p.`recipient_customer_id`, ps.`status_name`
  INTO v_recipient_customer_id, v_status_name
  FROM `package` p
  JOIN `package_status` ps ON ps.`package_status_id` = p.`package_status_id`
  WHERE p.`package_id` = NEW.`package_id`;

  SELECT MAX(`actual_shipping_charge`)
  INTO v_charge_amount
  FROM `shipping_cost`
  WHERE `package_id` = NEW.`package_id`;

  SELECT COUNT(*)
  INTO v_duplicate_count
  FROM `refunds`
  WHERE `package_id` = NEW.`package_id`;

  IF v_duplicate_count > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Only one refund is allowed per package unless the refund model is redesigned.';
  END IF;

  IF NEW.`customer_id` <> v_recipient_customer_id THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'refunds.customer_id must match package.recipient_customer_id.';
  END IF;

  IF v_status_name NOT IN ('Returned', 'Cancelled', 'Delivered') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Refunds are only allowed for returned, cancelled, or completed packages under review.';
  END IF;

  IF v_charge_amount IS NULL OR NEW.`refund_amount` > v_charge_amount THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Refund requires a charge basis and cannot exceed the recorded package charge.';
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `bu_refunds_business_rules` BEFORE UPDATE ON `refunds` FOR EACH ROW BEGIN
  DECLARE v_recipient_customer_id BINARY(16);
  DECLARE v_status_name VARCHAR(30);
  DECLARE v_charge_amount DECIMAL(8,2);
  DECLARE v_duplicate_count INT DEFAULT 0;

  SELECT p.`recipient_customer_id`, ps.`status_name`
  INTO v_recipient_customer_id, v_status_name
  FROM `package` p
  JOIN `package_status` ps ON ps.`package_status_id` = p.`package_status_id`
  WHERE p.`package_id` = NEW.`package_id`;

  SELECT MAX(`actual_shipping_charge`)
  INTO v_charge_amount
  FROM `shipping_cost`
  WHERE `package_id` = NEW.`package_id`;

  SELECT COUNT(*)
  INTO v_duplicate_count
  FROM `refunds`
  WHERE `package_id` = NEW.`package_id`
    AND `refund_id` <> OLD.`refund_id`;

  IF v_duplicate_count > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Only one refund is allowed per package unless the refund model is redesigned.';
  END IF;

  IF NEW.`customer_id` <> v_recipient_customer_id THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'refunds.customer_id must match package.recipient_customer_id.';
  END IF;

  IF v_status_name NOT IN ('Returned', 'Cancelled', 'Delivered') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Refunds are only allowed for returned, cancelled, or completed packages under review.';
  END IF;

  IF v_charge_amount IS NULL OR NEW.`refund_amount` > v_charge_amount THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Refund requires a charge basis and cannot exceed the recorded package charge.';
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

-- Dump completed on 2026-06-09 21:46:43
