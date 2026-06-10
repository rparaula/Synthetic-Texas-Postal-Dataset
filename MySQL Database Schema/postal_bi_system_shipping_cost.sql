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
-- Table structure for table `shipping_cost`
--

DROP TABLE IF EXISTS `shipping_cost`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipping_cost` (
  `package_id` binary(16) NOT NULL,
  `actual_shipping_charge` decimal(8,2) NOT NULL,
  `material_cost` decimal(12,2) NOT NULL DEFAULT '0.00',
  `transportation_cost` decimal(12,2) NOT NULL DEFAULT '0.00',
  `charge_source` varchar(50) NOT NULL DEFAULT 'Web App',
  `charge_recorded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`package_id`),
  CONSTRAINT `fk_shipping_cost_package` FOREIGN KEY (`package_id`) REFERENCES `package` (`package_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_shipping_cost_actual_charge_nonnegative` CHECK ((`actual_shipping_charge` >= 0)),
  CONSTRAINT `chk_shipping_cost_material_cost_nonnegative` CHECK ((`material_cost` >= 0)),
  CONSTRAINT `chk_shipping_cost_transportation_cost_nonnegative` CHECK ((`transportation_cost` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipping_cost`
--

LOCK TABLES `shipping_cost` WRITE;
/*!40000 ALTER TABLE `shipping_cost` DISABLE KEYS */;
/*!40000 ALTER TABLE `shipping_cost` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `trg_shipping_cost_bi_component_costs` BEFORE INSERT ON `shipping_cost` FOR EACH ROW BEGIN
    SET NEW.material_cost = COALESCE((
        SELECT ROUND(
            (COALESCE(p.width_in, 0) * 0.05)
            + (COALESCE(p.length_in, 0) * 0.10)
            + (COALESCE(p.height_in, 0) * 0.15),
            2
        )
        FROM `package` p
        WHERE p.package_id = NEW.package_id
    ), 0.00);

    SET NEW.transportation_cost = COALESCE((
        SELECT ROUND(
            (COUNT(*) * 0.10)
            + CASE
                WHEN COALESCE(SUM(
                    CASE
                        WHEN met.event_type_name = 'Delivered'
                             OR ps.status_name = 'Delivered'
                        THEN 1
                        ELSE 0
                    END
                ), 0) > 0
                THEN 0.50
                ELSE 0.00
              END,
            2
        )
        FROM `package_movement` pm
        JOIN `package_movement_event_type` met
            ON met.package_movement_event_type_id = pm.package_movement_event_type_id
        JOIN `package_status` ps
            ON ps.package_status_id = pm.package_status_id
        WHERE pm.package_id = NEW.package_id
    ), 0.00);
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
/*!50003 CREATE*/ /*!50017 DEFINER=`ryan`@`%`*/ /*!50003 TRIGGER `trg_shipping_cost_bu_component_costs` BEFORE UPDATE ON `shipping_cost` FOR EACH ROW BEGIN
    SET NEW.material_cost = COALESCE((
        SELECT ROUND(
            (COALESCE(p.width_in, 0) * 0.05)
            + (COALESCE(p.length_in, 0) * 0.10)
            + (COALESCE(p.height_in, 0) * 0.15),
            2
        )
        FROM `package` p
        WHERE p.package_id = NEW.package_id
    ), 0.00);

    SET NEW.transportation_cost = COALESCE((
        SELECT ROUND(
            (COUNT(*) * 0.10)
            + CASE
                WHEN COALESCE(SUM(
                    CASE
                        WHEN met.event_type_name = 'Delivered'
                             OR ps.status_name = 'Delivered'
                        THEN 1
                        ELSE 0
                    END
                ), 0) > 0
                THEN 0.50
                ELSE 0.00
              END,
            2
        )
        FROM `package_movement` pm
        JOIN `package_movement_event_type` met
            ON met.package_movement_event_type_id = pm.package_movement_event_type_id
        JOIN `package_status` ps
            ON ps.package_status_id = pm.package_status_id
        WHERE pm.package_id = NEW.package_id
    ), 0.00);
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

-- Dump completed on 2026-06-09 21:46:55
