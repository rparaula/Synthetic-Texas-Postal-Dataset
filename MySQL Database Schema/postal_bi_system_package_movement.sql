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
-- Table structure for table `package_movement`
--

DROP TABLE IF EXISTS `package_movement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `package_movement` (
  `package_movement_id` int NOT NULL AUTO_INCREMENT,
  `package_id` binary(16) NOT NULL,
  `package_movement_event_type_id` int NOT NULL,
  `package_status_id` int NOT NULL,
  `facility_id` int DEFAULT NULL,
  `from_facility_id` int DEFAULT NULL,
  `to_facility_id` int DEFAULT NULL,
  `processed_by_employee_id` int DEFAULT NULL,
  `event_timestamp` datetime NOT NULL,
  `expected_event_at` datetime DEFAULT NULL,
  `delay_minutes` int NOT NULL DEFAULT '0',
  `delay_reason` varchar(255) DEFAULT NULL,
  `movement_note` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`package_movement_id`),
  KEY `idx_package_movement_package_time` (`package_id`,`event_timestamp`),
  KEY `idx_package_movement_facility_time` (`facility_id`,`event_timestamp`),
  KEY `idx_package_movement_from_to` (`from_facility_id`,`to_facility_id`,`event_timestamp`),
  KEY `idx_package_movement_event_type` (`package_movement_event_type_id`),
  KEY `idx_package_movement_status` (`package_status_id`),
  KEY `idx_package_movement_employee` (`processed_by_employee_id`),
  KEY `fk_package_movement_to_facility` (`to_facility_id`),
  KEY `idx_package_movement_lifecycle_enforcement` (`package_id`,`event_timestamp`,`package_movement_id`),
  CONSTRAINT `fk_package_movement_employee` FOREIGN KEY (`processed_by_employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_package_movement_event_type` FOREIGN KEY (`package_movement_event_type_id`) REFERENCES `package_movement_event_type` (`package_movement_event_type_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_package_movement_facility` FOREIGN KEY (`facility_id`) REFERENCES `facility` (`facility_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_package_movement_from_facility` FOREIGN KEY (`from_facility_id`) REFERENCES `facility` (`facility_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_package_movement_package` FOREIGN KEY (`package_id`) REFERENCES `package` (`package_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_package_movement_status` FOREIGN KEY (`package_status_id`) REFERENCES `package_status` (`package_status_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_package_movement_to_facility` FOREIGN KEY (`to_facility_id`) REFERENCES `facility` (`facility_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_package_movement_delay_minutes` CHECK ((`delay_minutes` >= 0)),
  CONSTRAINT `chk_package_movement_expected_event` CHECK (((`expected_event_at` is null) or (`event_timestamp` is not null)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `package_movement`
--

LOCK TABLES `package_movement` WRITE;
/*!40000 ALTER TABLE `package_movement` DISABLE KEYS */;
/*!40000 ALTER TABLE `package_movement` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `beforeInsertPackageMovementValidateLifecycleRules` BEFORE INSERT ON `package_movement` FOR EACH ROW BEGIN
    DECLARE v_package_exists INT DEFAULT 0;
    DECLARE v_current_status_name VARCHAR(30);
    DECLARE v_current_status_is_final TINYINT DEFAULT 0;
    DECLARE v_event_type_exists INT DEFAULT 0;
    DECLARE v_event_name VARCHAR(80);
    DECLARE v_default_status_name VARCHAR(30);
    DECLARE v_is_delay_event TINYINT DEFAULT 0;
    DECLARE v_is_final_event TINYINT DEFAULT 0;
    DECLARE v_status_exists INT DEFAULT 0;
    DECLARE v_status_name VARCHAR(30);
    DECLARE v_prior_final_count INT DEFAULT 0;
    DECLARE v_later_nonfinal_count INT DEFAULT 0;

    SELECT COUNT(*), MAX(ps.status_name), COALESCE(MAX(ps.is_final_status), 0)
    INTO v_package_exists, v_current_status_name, v_current_status_is_final
    FROM `package` p
    JOIN `package_status` ps
        ON ps.package_status_id = p.package_status_id
    WHERE p.package_id = NEW.package_id;

    IF v_package_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package_movement.package_id must reference an existing package.';
    END IF;

    SELECT
        COUNT(*),
        MAX(met.event_type_name),
        MAX(met.default_package_status_name),
        COALESCE(MAX(met.is_delay_event), 0),
        COALESCE(MAX(met.is_final_event), 0)
    INTO
        v_event_type_exists,
        v_event_name,
        v_default_status_name,
        v_is_delay_event,
        v_is_final_event
    FROM `package_movement_event_type` met
    WHERE met.package_movement_event_type_id = NEW.package_movement_event_type_id
      AND met.is_active = 1;

    IF v_event_type_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package_movement_event_type_id must reference an active movement event type.';
    END IF;

    SELECT COUNT(*), MAX(ps.status_name)
    INTO v_status_exists, v_status_name
    FROM `package_status` ps
    WHERE ps.package_status_id = NEW.package_status_id
      AND ps.is_active = 1;

    IF v_status_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package_movement.package_status_id must reference an active package_status.';
    END IF;

    IF v_default_status_name IS NOT NULL AND v_status_name <> v_default_status_name THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package movement status must match the movement event type default status.';
    END IF;

    IF v_event_name = 'Delivered' AND v_status_name <> 'Delivered' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Delivered movement events must use Delivered status.';
    END IF;

    IF v_is_delay_event = 1
       AND (NEW.delay_minutes IS NULL OR NEW.delay_minutes <= 0
            OR NEW.delay_reason IS NULL OR TRIM(NEW.delay_reason) = '') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Delay movement events require positive delay_minutes and a nonblank delay_reason.';
    END IF;

    IF v_current_status_is_final = 1 AND v_is_final_event = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Normal movement cannot occur after Delivered, Cancelled, or Returned.';
    END IF;

    SELECT COUNT(*)
    INTO v_prior_final_count
    FROM `package_movement` pm
    JOIN `package_status` ps
        ON ps.package_status_id = pm.package_status_id
    WHERE pm.package_id = NEW.package_id
      AND ps.is_final_status = 1
      AND pm.event_timestamp <= NEW.event_timestamp;

    IF v_prior_final_count > 0 AND v_is_final_event = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Normal movement cannot be inserted after a final package movement.';
    END IF;

    IF v_is_final_event = 1 THEN
        SELECT COUNT(*)
        INTO v_later_nonfinal_count
        FROM `package_movement` pm
        JOIN `package_status` ps
            ON ps.package_status_id = pm.package_status_id
        WHERE pm.package_id = NEW.package_id
          AND ps.is_final_status = 0
          AND pm.event_timestamp > NEW.event_timestamp;

        IF v_later_nonfinal_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Final movement cannot be inserted before later normal movements.';
        END IF;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `afterInsertPackageMovementSyncStatus` AFTER INSERT ON `package_movement` FOR EACH ROW BEGIN
    UPDATE `package` p
    SET p.package_status_id = NEW.package_status_id,
        p.updated_at = CURRENT_TIMESTAMP
    WHERE p.package_id = NEW.package_id;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `afterInsertPackageMovementRecalculateTransportationCost` AFTER INSERT ON `package_movement` FOR EACH ROW BEGIN
    DECLARE v_has_shipping_cost INT DEFAULT 0;
    DECLARE v_transportation_cost DECIMAL(12,2);

    SELECT COUNT(*)
    INTO v_has_shipping_cost
    FROM `shipping_cost` sc
    WHERE sc.package_id = NEW.package_id;

    IF v_has_shipping_cost > 0 THEN
        CALL `CalculateTransporation`(NEW.package_id, v_transportation_cost);
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `beforeUpdatePackageMovementValidateLifecycleRules` BEFORE UPDATE ON `package_movement` FOR EACH ROW BEGIN
    DECLARE v_package_exists INT DEFAULT 0;
    DECLARE v_event_type_exists INT DEFAULT 0;
    DECLARE v_event_name VARCHAR(80);
    DECLARE v_default_status_name VARCHAR(30);
    DECLARE v_is_delay_event TINYINT DEFAULT 0;
    DECLARE v_is_final_event TINYINT DEFAULT 0;
    DECLARE v_status_exists INT DEFAULT 0;
    DECLARE v_status_name VARCHAR(30);
    DECLARE v_prior_final_count INT DEFAULT 0;
    DECLARE v_later_nonfinal_count INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_package_exists
    FROM `package` p
    WHERE p.package_id = NEW.package_id;

    IF v_package_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package_movement.package_id must reference an existing package.';
    END IF;

    SELECT
        COUNT(*),
        MAX(met.event_type_name),
        MAX(met.default_package_status_name),
        COALESCE(MAX(met.is_delay_event), 0),
        COALESCE(MAX(met.is_final_event), 0)
    INTO
        v_event_type_exists,
        v_event_name,
        v_default_status_name,
        v_is_delay_event,
        v_is_final_event
    FROM `package_movement_event_type` met
    WHERE met.package_movement_event_type_id = NEW.package_movement_event_type_id
      AND met.is_active = 1;

    IF v_event_type_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package_movement_event_type_id must reference an active movement event type.';
    END IF;

    SELECT COUNT(*), MAX(ps.status_name)
    INTO v_status_exists, v_status_name
    FROM `package_status` ps
    WHERE ps.package_status_id = NEW.package_status_id
      AND ps.is_active = 1;

    IF v_status_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package_movement.package_status_id must reference an active package_status.';
    END IF;

    IF v_default_status_name IS NOT NULL AND v_status_name <> v_default_status_name THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package movement status must match the movement event type default status.';
    END IF;

    IF v_event_name = 'Delivered' AND v_status_name <> 'Delivered' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Delivered movement events must use Delivered status.';
    END IF;

    IF v_is_delay_event = 1
       AND (NEW.delay_minutes IS NULL OR NEW.delay_minutes <= 0
            OR NEW.delay_reason IS NULL OR TRIM(NEW.delay_reason) = '') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Delay movement events require positive delay_minutes and a nonblank delay_reason.';
    END IF;

    SELECT COUNT(*)
    INTO v_prior_final_count
    FROM `package_movement` pm
    JOIN `package_status` ps
        ON ps.package_status_id = pm.package_status_id
    WHERE pm.package_id = NEW.package_id
      AND pm.package_movement_id <> OLD.package_movement_id
      AND ps.is_final_status = 1
      AND pm.event_timestamp <= NEW.event_timestamp;

    IF v_prior_final_count > 0 AND v_is_final_event = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Normal movement cannot be placed after a final package movement.';
    END IF;

    IF v_is_final_event = 1 THEN
        SELECT COUNT(*)
        INTO v_later_nonfinal_count
        FROM `package_movement` pm
        JOIN `package_status` ps
            ON ps.package_status_id = pm.package_status_id
        WHERE pm.package_id = NEW.package_id
          AND pm.package_movement_id <> OLD.package_movement_id
          AND ps.is_final_status = 0
          AND pm.event_timestamp > NEW.event_timestamp;

        IF v_later_nonfinal_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Final movement cannot be placed before later normal movements.';
        END IF;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `afterUpdatePackageMovementSyncStatus` AFTER UPDATE ON `package_movement` FOR EACH ROW BEGIN
    UPDATE `package` p
    JOIN (
        SELECT pm.package_status_id
        FROM `package_movement` pm
        WHERE pm.package_id = NEW.package_id
        ORDER BY pm.event_timestamp DESC, pm.package_movement_id DESC
        LIMIT 1
    ) latest_status
        ON 1 = 1
    SET p.package_status_id = latest_status.package_status_id,
        p.updated_at = CURRENT_TIMESTAMP
    WHERE p.package_id = NEW.package_id;

    IF OLD.package_id <> NEW.package_id THEN
        UPDATE `package` p
        JOIN (
            SELECT pm.package_status_id
            FROM `package_movement` pm
            WHERE pm.package_id = OLD.package_id
            ORDER BY pm.event_timestamp DESC, pm.package_movement_id DESC
            LIMIT 1
        ) latest_status
            ON 1 = 1
        SET p.package_status_id = latest_status.package_status_id,
            p.updated_at = CURRENT_TIMESTAMP
        WHERE p.package_id = OLD.package_id;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `afterUpdatePackageMovementRecalculateTransportationCost` AFTER UPDATE ON `package_movement` FOR EACH ROW BEGIN
    DECLARE v_has_new_shipping_cost INT DEFAULT 0;
    DECLARE v_has_old_shipping_cost INT DEFAULT 0;
    DECLARE v_transportation_cost DECIMAL(12,2);

    SELECT COUNT(*)
    INTO v_has_new_shipping_cost
    FROM `shipping_cost` sc
    WHERE sc.package_id = NEW.package_id;

    IF v_has_new_shipping_cost > 0 THEN
        CALL `CalculateTransporation`(NEW.package_id, v_transportation_cost);
    END IF;

    IF OLD.package_id <> NEW.package_id THEN
        SELECT COUNT(*)
        INTO v_has_old_shipping_cost
        FROM `shipping_cost` sc
        WHERE sc.package_id = OLD.package_id;

        IF v_has_old_shipping_cost > 0 THEN
            CALL `CalculateTransporation`(OLD.package_id, v_transportation_cost);
        END IF;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `afterDeletePackageMovementRecalculateTransportationCost` AFTER DELETE ON `package_movement` FOR EACH ROW BEGIN
    DECLARE v_has_shipping_cost INT DEFAULT 0;
    DECLARE v_transportation_cost DECIMAL(12,2);

    SELECT COUNT(*)
    INTO v_has_shipping_cost
    FROM `shipping_cost` sc
    WHERE sc.package_id = OLD.package_id;

    IF v_has_shipping_cost > 0 THEN
        CALL `CalculateTransporation`(OLD.package_id, v_transportation_cost);
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

-- Dump completed on 2026-06-10 14:43:44
