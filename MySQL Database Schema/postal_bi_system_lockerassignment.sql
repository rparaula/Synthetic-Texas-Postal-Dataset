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
-- Table structure for table `lockerassignment`
--

DROP TABLE IF EXISTS `lockerassignment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lockerassignment` (
  `locker_assignment_id` int NOT NULL AUTO_INCREMENT,
  `locker_id` int NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` datetime DEFAULT NULL,
  `retrieved_at` datetime DEFAULT NULL,
  `customer_id` binary(16) NOT NULL,
  PRIMARY KEY (`locker_assignment_id`),
  KEY `lockerID_fk_idx` (`locker_id`),
  KEY `idx_lockerassignment_locker_active` (`locker_id`,`retrieved_at`),
  KEY `idx_lockerassignment_locker_active_enforcement` (`locker_id`,`retrieved_at`,`locker_assignment_id`),
  KEY `customerID_fk_idx` (`customer_id`),
  KEY `idx_lockerassignment_customer_active` (`customer_id`,`retrieved_at`),
  CONSTRAINT `customerID_fk` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `lockerID_fk` FOREIGN KEY (`locker_id`) REFERENCES `smartlocker` (`locker_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_lockerassignment_expires_after_assigned` CHECK (((`expires_at` is null) or (`expires_at` > `assigned_at`))),
  CONSTRAINT `chk_lockerassignment_retrieved_after_assigned` CHECK (((`retrieved_at` is null) or (`retrieved_at` >= `assigned_at`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lockerassignment`
--

LOCK TABLES `lockerassignment` WRITE;
/*!40000 ALTER TABLE `lockerassignment` DISABLE KEYS */;
/*!40000 ALTER TABLE `lockerassignment` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `bi_lockerassignment_business_rules` BEFORE INSERT ON `lockerassignment` FOR EACH ROW BEGIN
  DECLARE v_active_count INT DEFAULT 0;

  IF NEW.expires_at IS NOT NULL AND NEW.expires_at <= NEW.assigned_at THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'lockerassignment.expires_at must be after assigned_at.';
  END IF;

  IF NEW.retrieved_at IS NOT NULL AND NEW.retrieved_at < NEW.assigned_at THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'lockerassignment.retrieved_at must be at or after assigned_at.';
  END IF;

  IF NEW.retrieved_at IS NULL THEN
    SELECT COUNT(*)
      INTO v_active_count
    FROM lockerassignment
    WHERE locker_id = NEW.locker_id
      AND retrieved_at IS NULL;

    IF v_active_count > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A locker can have only one active assignment.';
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `ai_lockerassignment_sync_locker_status` AFTER INSERT ON `lockerassignment` FOR EACH ROW BEGIN
  UPDATE smartlocker
  SET locker_status = CASE WHEN NEW.retrieved_at IS NULL THEN 'Occupied' ELSE locker_status END,
      updated_at = CURRENT_TIMESTAMP
  WHERE locker_id = NEW.locker_id;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `bu_lockerassignment_business_rules` BEFORE UPDATE ON `lockerassignment` FOR EACH ROW BEGIN
  DECLARE v_active_count INT DEFAULT 0;
  DECLARE v_bad_retrieval_count INT DEFAULT 0;

  IF NEW.expires_at IS NOT NULL AND NEW.expires_at <= NEW.assigned_at THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'lockerassignment.expires_at must be after assigned_at.';
  END IF;

  IF NEW.retrieved_at IS NOT NULL AND NEW.retrieved_at < NEW.assigned_at THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'lockerassignment.retrieved_at must be at or after assigned_at.';
  END IF;

  IF NEW.retrieved_at IS NULL THEN
    SELECT COUNT(*)
      INTO v_active_count
    FROM lockerassignment
    WHERE locker_id = NEW.locker_id
      AND retrieved_at IS NULL
      AND locker_assignment_id <> OLD.locker_assignment_id;

    IF v_active_count > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A locker can have only one active assignment.';
    END IF;
  ELSE
    SELECT COUNT(*)
      INTO v_bad_retrieval_count
    FROM package_to_locker ptl
    JOIN package p ON p.package_id = ptl.package_id
    JOIN package_status ps ON ps.package_status_id = p.package_status_id
    WHERE ptl.locker_assignment_id = NEW.locker_assignment_id
      AND ps.is_final_status = 0;

    IF v_bad_retrieval_count > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A locker assignment cannot be retrieved until the linked package has a final status.';
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `au_lockerassignment_sync_locker_status` AFTER UPDATE ON `lockerassignment` FOR EACH ROW BEGIN
  UPDATE smartlocker sl
  LEFT JOIN (
    SELECT locker_id, COUNT(*) AS active_assignment_count
    FROM lockerassignment
    WHERE locker_id = OLD.locker_id
      AND retrieved_at IS NULL
    GROUP BY locker_id
  ) active_la ON active_la.locker_id = sl.locker_id
  SET sl.locker_status = CASE
        WHEN COALESCE(active_la.active_assignment_count, 0) > 0 THEN 'Occupied'
        WHEN sl.locker_status = 'Occupied' THEN 'Available'
        ELSE sl.locker_status
      END,
      sl.updated_at = CURRENT_TIMESTAMP
  WHERE sl.locker_id = OLD.locker_id;

  IF OLD.locker_id <> NEW.locker_id THEN
    UPDATE smartlocker sl
    LEFT JOIN (
      SELECT locker_id, COUNT(*) AS active_assignment_count
      FROM lockerassignment
      WHERE locker_id = NEW.locker_id
        AND retrieved_at IS NULL
      GROUP BY locker_id
    ) active_la ON active_la.locker_id = sl.locker_id
    SET sl.locker_status = CASE
          WHEN COALESCE(active_la.active_assignment_count, 0) > 0 THEN 'Occupied'
          WHEN sl.locker_status = 'Occupied' THEN 'Available'
          ELSE sl.locker_status
        END,
        sl.updated_at = CURRENT_TIMESTAMP
    WHERE sl.locker_id = NEW.locker_id;
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

-- Dump completed on 2026-06-09 21:46:25
