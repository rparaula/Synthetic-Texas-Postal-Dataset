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
-- Table structure for table `incident`
--

DROP TABLE IF EXISTS `incident`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `incident` (
  `incident_id` int NOT NULL AUTO_INCREMENT,
  `reported_by_employee_id` int NOT NULL,
  `package_id` binary(16) DEFAULT NULL,
  `incident_type_id` int NOT NULL,
  `incident_severity_id` int NOT NULL,
  `incident_status_id` int NOT NULL DEFAULT '1',
  `description` varchar(255) NOT NULL,
  `incident_date` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `facility_id` int DEFAULT NULL,
  `package_movement_id` int DEFAULT NULL,
  `customer_id` binary(16) DEFAULT NULL,
  PRIMARY KEY (`incident_id`),
  KEY `fk_incident_reported_by_employee` (`reported_by_employee_id`),
  KEY `fk_incident_package` (`package_id`),
  KEY `fk_incident_type` (`incident_type_id`),
  KEY `fk_incident_severity` (`incident_severity_id`),
  KEY `fk_incident_status` (`incident_status_id`),
  KEY `idx_incident_facility_id` (`facility_id`),
  KEY `idx_incident_package_movement_id` (`package_movement_id`),
  KEY `fk_incident_customer` (`customer_id`),
  CONSTRAINT `fk_incident_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_incident_facility` FOREIGN KEY (`facility_id`) REFERENCES `facility` (`facility_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_incident_package` FOREIGN KEY (`package_id`) REFERENCES `package` (`package_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_incident_package_movement` FOREIGN KEY (`package_movement_id`) REFERENCES `package_movement` (`package_movement_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_incident_reported_by_employee` FOREIGN KEY (`reported_by_employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_incident_severity` FOREIGN KEY (`incident_severity_id`) REFERENCES `incident_severity` (`incident_severity_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_incident_status` FOREIGN KEY (`incident_status_id`) REFERENCES `incident_status` (`incident_status_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_incident_type` FOREIGN KEY (`incident_type_id`) REFERENCES `incident_type` (`incident_type_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `incident`
--

LOCK TABLES `incident` WRITE;
/*!40000 ALTER TABLE `incident` DISABLE KEYS */;
/*!40000 ALTER TABLE `incident` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `trg_incident_bi_validate_package_movement` BEFORE INSERT ON `incident` FOR EACH ROW BEGIN
    DECLARE v_movement_package_id INT;
    DECLARE v_package_received_date DATETIME;

    IF NEW.package_movement_id IS NOT NULL THEN
        SELECT pm.package_id
        INTO v_movement_package_id
        FROM package_movement pm
        WHERE pm.package_movement_id = NEW.package_movement_id;

        IF v_movement_package_id IS NULL OR v_movement_package_id <> NEW.package_id THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'incident.package_movement_id must belong to incident.package_id.';
        END IF;
    END IF;

    IF NEW.package_id IS NOT NULL THEN
        SELECT p.received_date
        INTO v_package_received_date
        FROM package p
        WHERE p.package_id = NEW.package_id;

        IF v_package_received_date IS NOT NULL AND NEW.incident_date < v_package_received_date THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'incident_date cannot be before package.received_date.';
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `trg_incident_bu_validate_package_movement` BEFORE UPDATE ON `incident` FOR EACH ROW BEGIN
    DECLARE v_movement_package_id INT;
    DECLARE v_package_received_date DATETIME;

    IF NEW.package_movement_id IS NOT NULL THEN
        SELECT pm.package_id
        INTO v_movement_package_id
        FROM package_movement pm
        WHERE pm.package_movement_id = NEW.package_movement_id;

        IF v_movement_package_id IS NULL OR v_movement_package_id <> NEW.package_id THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'incident.package_movement_id must belong to incident.package_id.';
        END IF;
    END IF;

    IF NEW.package_id IS NOT NULL THEN
        SELECT p.received_date
        INTO v_package_received_date
        FROM package p
        WHERE p.package_id = NEW.package_id;

        IF v_package_received_date IS NOT NULL AND NEW.incident_date < v_package_received_date THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'incident_date cannot be before package.received_date.';
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

-- Dump completed on 2026-06-10 14:43:23
