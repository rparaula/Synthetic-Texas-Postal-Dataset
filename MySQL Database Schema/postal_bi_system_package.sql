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
-- Table structure for table `package`
--

DROP TABLE IF EXISTS `package`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `package` (
  `package_id` binary(16) NOT NULL,
  `package_status_id` int NOT NULL,
  `service_type_id` int DEFAULT NULL,
  `received_date` datetime NOT NULL,
  `contents` varchar(30) DEFAULT 'Unknown',
  `weight_lbs` decimal(8,2) DEFAULT NULL,
  `length_in` decimal(8,2) DEFAULT NULL,
  `width_in` decimal(8,2) DEFAULT NULL,
  `height_in` decimal(8,2) DEFAULT NULL,
  `employee_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `recipient_customer_id` binary(16) NOT NULL,
  `package_flow_type_id` int NOT NULL,
  `sender_customer_id` binary(16) DEFAULT NULL,
  `sender_business_id` binary(16) DEFAULT NULL,
  PRIMARY KEY (`package_id`),
  KEY `EmployeeID` (`employee_id`),
  KEY `fk_package_status` (`package_status_id`),
  KEY `fk_package_service_type` (`service_type_id`),
  KEY `idx_package_recipient_customer_id` (`recipient_customer_id`),
  KEY `idx_package_package_flow_type_id` (`package_flow_type_id`),
  KEY `idx_package_sender_customer_id` (`sender_customer_id`),
  KEY `idx_package_sender_business_id` (`sender_business_id`),
  KEY `idx_package_recipient_service_status` (`recipient_customer_id`,`service_type_id`,`package_status_id`),
  CONSTRAINT `fk_package_employee` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_package_package_flow_type` FOREIGN KEY (`package_flow_type_id`) REFERENCES `package_flow_type` (`package_flow_type_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_package_recipient_customer` FOREIGN KEY (`recipient_customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_package_sender_business` FOREIGN KEY (`sender_business_id`) REFERENCES `business` (`business_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_package_sender_customer` FOREIGN KEY (`sender_customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_package_service_type` FOREIGN KEY (`service_type_id`) REFERENCES `service_type` (`service_type_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_package_status` FOREIGN KEY (`package_status_id`) REFERENCES `package_status` (`package_status_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_package_dimensions` CHECK ((((`length_in` is null) or (`length_in` > 0)) and ((`width_in` is null) or (`width_in` > 0)) and ((`height_in` is null) or (`height_in` > 0)))),
  CONSTRAINT `chk_package_not_both_sender_entities` CHECK (((`sender_customer_id` is null) or (`sender_business_id` is null))),
  CONSTRAINT `chk_package_weight` CHECK (((`weight_lbs` is not null) and (`weight_lbs` > 0)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `package`
--

LOCK TABLES `package` WRITE;
/*!40000 ALTER TABLE `package` DISABLE KEYS */;
/*!40000 ALTER TABLE `package` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `beforeInsertPackageValidateBusinessRules` BEFORE INSERT ON `package` FOR EACH ROW BEGIN
    IF NEW.weight_lbs IS NULL OR NEW.weight_lbs <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package.weight_lbs must be greater than 0.';
    END IF;

    IF NEW.length_in IS NULL OR NEW.length_in <= 0
       OR NEW.width_in IS NULL OR NEW.width_in <= 0
       OR NEW.height_in IS NULL OR NEW.height_in <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package dimensions must all be greater than 0.';
    END IF;

    IF NEW.service_type_id IS NULL
       OR NOT EXISTS (
           SELECT 1
           FROM `service_type` st
           WHERE st.service_type_id = NEW.service_type_id
             AND st.is_active = 1
       ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package.service_type_id must reference an active service_type.';
    END IF;

    IF NEW.package_status_id IS NULL
       OR NOT EXISTS (
           SELECT 1
           FROM `package_status` ps
           WHERE ps.package_status_id = NEW.package_status_id
             AND ps.is_active = 1
       ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package.package_status_id must reference an active package_status.';
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `bi_package_flow_sender_rules` BEFORE INSERT ON `package` FOR EACH ROW BEGIN
  DECLARE v_flow_type_name VARCHAR(30);

  SELECT MAX(`package_flow_type_name`)
  INTO v_flow_type_name
  FROM `package_flow_type`
  WHERE `package_flow_type_id` = NEW.`package_flow_type_id`
    AND `is_active` = 1;

  IF NEW.`recipient_customer_id` IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'package.recipient_customer_id is required.';
  END IF;

  IF v_flow_type_name IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'package.package_flow_type_id must reference an active package_flow_type.';
  END IF;

  IF v_flow_type_name = 'P2P'
     AND NOT (NEW.`sender_customer_id` IS NOT NULL AND NEW.`sender_business_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'P2P packages require sender_customer_id and no sender_business_id.';
  END IF;

  IF v_flow_type_name = 'B2C'
     AND NOT (NEW.`sender_business_id` IS NOT NULL AND NEW.`sender_customer_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'B2C packages require sender_business_id and no sender_customer_id.';
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `afterInsertPackageRecalculateCharges` AFTER INSERT ON `package` FOR EACH ROW BEGIN
    DECLARE v_has_shipping_cost INT DEFAULT 0;
    DECLARE v_has_shippingdetails INT DEFAULT 0;
    DECLARE v_material_cost DECIMAL(12,2);
    DECLARE v_actual_shipping_charge DECIMAL(8,2);

    SELECT COUNT(*)
    INTO v_has_shipping_cost
    FROM `shipping_cost` sc
    WHERE sc.package_id = NEW.package_id;

    SELECT COUNT(*)
    INTO v_has_shippingdetails
    FROM `shippingdetails` sd
    WHERE sd.package_id = NEW.package_id;

    IF v_has_shipping_cost > 0 THEN
        CALL `CalculateMaterialCost`(NEW.package_id, v_material_cost);
    END IF;

    IF v_has_shipping_cost > 0 AND v_has_shippingdetails > 0 THEN
        CALL `CustomerDeliveryCharge`(NEW.package_id, v_actual_shipping_charge);
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `beforeUpdatePackageValidateBusinessRules` BEFORE UPDATE ON `package` FOR EACH ROW BEGIN
    IF NEW.weight_lbs IS NULL OR NEW.weight_lbs <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package.weight_lbs must be greater than 0.';
    END IF;

    IF NEW.length_in IS NULL OR NEW.length_in <= 0
       OR NEW.width_in IS NULL OR NEW.width_in <= 0
       OR NEW.height_in IS NULL OR NEW.height_in <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package dimensions must all be greater than 0.';
    END IF;

    IF NEW.service_type_id IS NULL
       OR NOT EXISTS (
           SELECT 1
           FROM `service_type` st
           WHERE st.service_type_id = NEW.service_type_id
             AND st.is_active = 1
       ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package.service_type_id must reference an active service_type.';
    END IF;

    IF NEW.package_status_id IS NULL
       OR NOT EXISTS (
           SELECT 1
           FROM `package_status` ps
           WHERE ps.package_status_id = NEW.package_status_id
             AND ps.is_active = 1
       ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package.package_status_id must reference an active package_status.';
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `bu_package_flow_sender_rules` BEFORE UPDATE ON `package` FOR EACH ROW BEGIN
  DECLARE v_flow_type_name VARCHAR(30);

  SELECT MAX(`package_flow_type_name`)
  INTO v_flow_type_name
  FROM `package_flow_type`
  WHERE `package_flow_type_id` = NEW.`package_flow_type_id`
    AND `is_active` = 1;

  IF NEW.`recipient_customer_id` IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'package.recipient_customer_id is required.';
  END IF;

  IF v_flow_type_name IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'package.package_flow_type_id must reference an active package_flow_type.';
  END IF;

  IF v_flow_type_name = 'P2P'
     AND NOT (NEW.`sender_customer_id` IS NOT NULL AND NEW.`sender_business_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'P2P packages require sender_customer_id and no sender_business_id.';
  END IF;

  IF v_flow_type_name = 'B2C'
     AND NOT (NEW.`sender_business_id` IS NOT NULL AND NEW.`sender_customer_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'B2C packages require sender_business_id and no sender_customer_id.';
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `afterUpdatePackageRecalculateCharges` AFTER UPDATE ON `package` FOR EACH ROW BEGIN
    DECLARE v_has_shipping_cost INT DEFAULT 0;
    DECLARE v_has_shippingdetails INT DEFAULT 0;
    DECLARE v_material_cost DECIMAL(12,2);
    DECLARE v_actual_shipping_charge DECIMAL(8,2);

    IF NOT (OLD.weight_lbs <=> NEW.weight_lbs)
       OR NOT (OLD.length_in <=> NEW.length_in)
       OR NOT (OLD.width_in <=> NEW.width_in)
       OR NOT (OLD.height_in <=> NEW.height_in)
       OR NOT (OLD.service_type_id <=> NEW.service_type_id) THEN

        SELECT COUNT(*)
        INTO v_has_shipping_cost
        FROM `shipping_cost` sc
        WHERE sc.package_id = NEW.package_id;

        SELECT COUNT(*)
        INTO v_has_shippingdetails
        FROM `shippingdetails` sd
        WHERE sd.package_id = NEW.package_id;

        IF v_has_shipping_cost > 0 THEN
            CALL `CalculateMaterialCost`(NEW.package_id, v_material_cost);
        END IF;

        IF v_has_shipping_cost > 0 AND v_has_shippingdetails > 0 THEN
            CALL `CustomerDeliveryCharge`(NEW.package_id, v_actual_shipping_charge);
        END IF;
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

-- Dump completed on 2026-06-10 14:43:49
