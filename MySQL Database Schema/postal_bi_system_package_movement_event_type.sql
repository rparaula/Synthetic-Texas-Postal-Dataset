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
-- Table structure for table `package_movement_event_type`
--

DROP TABLE IF EXISTS `package_movement_event_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `package_movement_event_type` (
  `package_movement_event_type_id` int NOT NULL AUTO_INCREMENT,
  `event_type_name` varchar(80) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `default_package_status_name` varchar(30) DEFAULT NULL,
  `is_entry_event` tinyint(1) NOT NULL DEFAULT '0',
  `is_exit_event` tinyint(1) NOT NULL DEFAULT '0',
  `is_processing_event` tinyint(1) NOT NULL DEFAULT '0',
  `is_delay_event` tinyint(1) NOT NULL DEFAULT '0',
  `is_final_event` tinyint(1) NOT NULL DEFAULT '0',
  `sort_order` int NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`package_movement_event_type_id`),
  UNIQUE KEY `uq_package_movement_event_type_name` (`event_type_name`),
  CONSTRAINT `chk_package_movement_event_type_flags` CHECK (((`is_entry_event` in (0,1)) and (`is_exit_event` in (0,1)) and (`is_processing_event` in (0,1)) and (`is_delay_event` in (0,1)) and (`is_final_event` in (0,1)) and (`is_active` in (0,1)))),
  CONSTRAINT `chk_package_movement_event_type_sort` CHECK ((`sort_order` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `package_movement_event_type`
--

LOCK TABLES `package_movement_event_type` WRITE;
/*!40000 ALTER TABLE `package_movement_event_type` DISABLE KEYS */;
INSERT INTO `package_movement_event_type` VALUES (1,'Received At Facility','Package was accepted or received at a facility.','Received',1,0,1,0,0,1,1),(2,'Sent To Facility','Package was sent from one facility to another facility.','In Transit',0,1,0,0,0,2,1),(3,'Arrived At Facility','Package arrived at a facility.','In Transit',1,0,0,0,0,3,1),(4,'Sorted At Facility','Package was sorted, scanned, or processed at a facility.','Processing',0,0,1,0,0,4,1),(5,'Departed Facility','Package departed a facility.','In Transit',0,1,0,0,0,5,1),(6,'Out For Delivery','Package left the destination facility for final delivery.','Out For Delivery',0,1,0,0,0,6,1),(7,'Delivered','Package was delivered.','Delivered',0,0,0,0,1,7,1),(8,'Delayed At Facility','Package was delayed at a facility.','Delayed',0,0,0,1,0,8,1),(9,'Tracking Scan','Generic non-facility tracking scan.','In Transit',0,0,0,0,0,9,1),(19,'Returned','Package was returned after a failed delivery attempt, refusal, or return-to-sender workflow.','Returned',0,0,0,0,1,10,1),(20,'Cancelled','Package service request was cancelled before completion.','Cancelled',0,0,0,0,1,11,1),(21,'Ready For Pickup','Package is being held at a retail facility for customer pickup.','Processing',0,0,1,0,0,12,1),(22,'Picked Up By Customer','Package was picked up by the customer at a retail facility.','Delivered',0,0,0,0,1,13,1),(23,'Placed In SmartLocker','Package was placed into a SmartLocker for customer retrieval.','Processing',0,0,1,0,0,14,1),(24,'Retrieved From SmartLocker','Package was retrieved from a SmartLocker by the customer.','Delivered',0,0,0,0,1,15,1);
/*!40000 ALTER TABLE `package_movement_event_type` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-10 14:43:22
