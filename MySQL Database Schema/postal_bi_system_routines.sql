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
-- Temporary view structure for view `vw_customer_id_hex_lookup`
--

DROP TABLE IF EXISTS `vw_customer_id_hex_lookup`;
/*!50001 DROP VIEW IF EXISTS `vw_customer_id_hex_lookup`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_customer_id_hex_lookup` AS SELECT 
 1 AS `customer_id_hex`,
 1 AS `customer_id`,
 1 AS `first_name`,
 1 AS `last_name`,
 1 AS `email`,
 1 AS `city`,
 1 AS `state_code`,
 1 AS `zip_code`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_territory`
--

DROP TABLE IF EXISTS `dim_territory`;
/*!50001 DROP VIEW IF EXISTS `dim_territory`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_territory` AS SELECT 
 1 AS `territory_id`,
 1 AS `state`,
 1 AS `city`,
 1 AS `county`,
 1 AS `zip_code`,
 1 AS `latitude`,
 1 AS `longitude`,
 1 AS `created_at`,
 1 AS `updated_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_incident_movement_summary`
--

DROP TABLE IF EXISTS `vw_incident_movement_summary`;
/*!50001 DROP VIEW IF EXISTS `vw_incident_movement_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_incident_movement_summary` AS SELECT 
 1 AS `incident_id`,
 1 AS `incident_date`,
 1 AS `description`,
 1 AS `incident_type`,
 1 AS `type_category`,
 1 AS `severity_name`,
 1 AS `incident_status`,
 1 AS `reported_by_employee_id`,
 1 AS `reported_by_employee`,
 1 AS `package_id`,
 1 AS `package_movement_id`,
 1 AS `movement_event_type`,
 1 AS `customer_id`,
 1 AS `customer_name`,
 1 AS `facility_id`,
 1 AS `facility_name`,
 1 AS `facility_type_code`,
 1 AS `facility_type_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_incident_summary`
--

DROP TABLE IF EXISTS `vw_incident_summary`;
/*!50001 DROP VIEW IF EXISTS `vw_incident_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_incident_summary` AS SELECT 
 1 AS `incident_id`,
 1 AS `incident_date`,
 1 AS `description`,
 1 AS `incident_type`,
 1 AS `type_category`,
 1 AS `severity_name`,
 1 AS `severity_order`,
 1 AS `incident_status`,
 1 AS `is_closed_status`,
 1 AS `reported_by_employee_id`,
 1 AS `reported_by_employee`,
 1 AS `package_id`,
 1 AS `customer_id`,
 1 AS `customer_name`,
 1 AS `facility_id`,
 1 AS `facility_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `fact_package`
--

DROP TABLE IF EXISTS `fact_package`;
/*!50001 DROP VIEW IF EXISTS `fact_package`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `fact_package` AS SELECT 
 1 AS `package_id`,
 1 AS `customer_id`,
 1 AS `recipient_customer_id`,
 1 AS `package_flow_type_id`,
 1 AS `package_flow_type_name`,
 1 AS `sender_customer_id`,
 1 AS `sender_business_id`,
 1 AS `service_type_id`,
 1 AS `package_status_id`,
 1 AS `received_facility_id`,
 1 AS `received_facility_territory_id`,
 1 AS `received_by_employee_id`,
 1 AS `received_datetime`,
 1 AS `weight_lbs`,
 1 AS `length_in`,
 1 AS `width_in`,
 1 AS `height_in`,
 1 AS `package_volume_cubic_in`,
 1 AS `package_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_employee`
--

DROP TABLE IF EXISTS `dim_employee`;
/*!50001 DROP VIEW IF EXISTS `dim_employee`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_employee` AS SELECT 
 1 AS `employee_id`,
 1 AS `employee_name`,
 1 AS `job_title`,
 1 AS `department_id`,
 1 AS `department_name`,
 1 AS `facility_id`,
 1 AS `facility_territory_id`,
 1 AS `facility_name`,
 1 AS `manager_employee_id`,
 1 AS `is_manager`,
 1 AS `hours_worked`,
 1 AS `employee_created_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_customer`
--

DROP TABLE IF EXISTS `dim_customer`;
/*!50001 DROP VIEW IF EXISTS `dim_customer`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_customer` AS SELECT 
 1 AS `customer_id`,
 1 AS `territory_id`,
 1 AS `first_name`,
 1 AS `middle_initial`,
 1 AS `last_name`,
 1 AS `customer_name`,
 1 AS `city`,
 1 AS `state_code`,
 1 AS `zip_code`,
 1 AS `preferred_facility_id`,
 1 AS `preferred_facility_territory_id`,
 1 AS `birth_date`,
 1 AS `age_years`,
 1 AS `marital_status`,
 1 AS `gender`,
 1 AS `email_address`,
 1 AS `annual_income`,
 1 AS `total_children`,
 1 AS `education_level`,
 1 AS `occupation`,
 1 AS `home_owner`,
 1 AS `customer_created_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_package_delay_summary`
--

DROP TABLE IF EXISTS `vw_package_delay_summary`;
/*!50001 DROP VIEW IF EXISTS `vw_package_delay_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_package_delay_summary` AS SELECT 
 1 AS `package_movement_id`,
 1 AS `package_id`,
 1 AS `event_timestamp`,
 1 AS `delay_facility_id`,
 1 AS `delay_facility_name`,
 1 AS `event_type_name`,
 1 AS `expected_event_at`,
 1 AS `delay_minutes`,
 1 AS `delay_reason`,
 1 AS `movement_note`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_package_status`
--

DROP TABLE IF EXISTS `dim_package_status`;
/*!50001 DROP VIEW IF EXISTS `dim_package_status`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_package_status` AS SELECT 
 1 AS `package_status_id`,
 1 AS `status_name`,
 1 AS `status_category`,
 1 AS `sort_order`,
 1 AS `is_final_status`,
 1 AS `is_active`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_incident_status`
--

DROP TABLE IF EXISTS `dim_incident_status`;
/*!50001 DROP VIEW IF EXISTS `dim_incident_status`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_incident_status` AS SELECT 
 1 AS `incident_status_id`,
 1 AS `status_name`,
 1 AS `sort_order`,
 1 AS `is_closed_status`,
 1 AS `is_active`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_smartlocker`
--

DROP TABLE IF EXISTS `dim_smartlocker`;
/*!50001 DROP VIEW IF EXISTS `dim_smartlocker`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_smartlocker` AS SELECT 
 1 AS `locker_id`,
 1 AS `locker_location_id`,
 1 AS `location_name`,
 1 AS `facility_id`,
 1 AS `facility_territory_id`,
 1 AS `facility_name`,
 1 AS `locker_status`,
 1 AS `locker_created_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_employee_facility_assignment`
--

DROP TABLE IF EXISTS `vw_employee_facility_assignment`;
/*!50001 DROP VIEW IF EXISTS `vw_employee_facility_assignment`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_employee_facility_assignment` AS SELECT 
 1 AS `employee_id`,
 1 AS `full_name`,
 1 AS `email`,
 1 AS `phone_number`,
 1 AS `job_title`,
 1 AS `department_id`,
 1 AS `department_name`,
 1 AS `facility_id`,
 1 AS `facility_name`,
 1 AS `facility_type_code`,
 1 AS `facility_type_name`,
 1 AS `manager_employee_id`,
 1 AS `manager_name`,
 1 AS `salary`,
 1 AS `hours_worked`,
 1 AS `user_id`,
 1 AS `created_at`,
 1 AS `updated_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_package_route_history`
--

DROP TABLE IF EXISTS `vw_package_route_history`;
/*!50001 DROP VIEW IF EXISTS `vw_package_route_history`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_package_route_history` AS SELECT 
 1 AS `package_movement_id`,
 1 AS `package_id`,
 1 AS `event_timestamp`,
 1 AS `event_type_name`,
 1 AS `package_status`,
 1 AS `facility_id`,
 1 AS `facility_name`,
 1 AS `facility_type_code`,
 1 AS `facility_type_name`,
 1 AS `from_facility_id`,
 1 AS `from_facility_name`,
 1 AS `to_facility_id`,
 1 AS `to_facility_name`,
 1 AS `processed_by_employee_id`,
 1 AS `processed_by_employee`,
 1 AS `expected_event_at`,
 1 AS `delay_minutes`,
 1 AS `delay_reason`,
 1 AS `movement_note`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `fact_incident`
--

DROP TABLE IF EXISTS `fact_incident`;
/*!50001 DROP VIEW IF EXISTS `fact_incident`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `fact_incident` AS SELECT 
 1 AS `incident_id`,
 1 AS `package_id`,
 1 AS `customer_id`,
 1 AS `customer_territory_id`,
 1 AS `reported_by_employee_id`,
 1 AS `employee_territory_id`,
 1 AS `facility_id`,
 1 AS `facility_territory_id`,
 1 AS `package_movement_id`,
 1 AS `incident_type_id`,
 1 AS `incident_severity_id`,
 1 AS `incident_status_id`,
 1 AS `incident_datetime`,
 1 AS `incident_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_package_id_hex_lookup`
--

DROP TABLE IF EXISTS `vw_package_id_hex_lookup`;
/*!50001 DROP VIEW IF EXISTS `vw_package_id_hex_lookup`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_package_id_hex_lookup` AS SELECT 
 1 AS `package_id_hex`,
 1 AS `package_id`,
 1 AS `recipient_customer_id_hex`,
 1 AS `recipient_customer_id`,
 1 AS `package_flow_type_id`,
 1 AS `package_flow_type_name`,
 1 AS `sender_customer_id_hex`,
 1 AS `sender_customer_id`,
 1 AS `sender_business_id_hex`,
 1 AS `sender_business_id`,
 1 AS `package_status_id`,
 1 AS `service_type_id`,
 1 AS `received_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_incident_severity`
--

DROP TABLE IF EXISTS `dim_incident_severity`;
/*!50001 DROP VIEW IF EXISTS `dim_incident_severity`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_incident_severity` AS SELECT 
 1 AS `incident_severity_id`,
 1 AS `severity_name`,
 1 AS `sort_order`,
 1 AS `is_active`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_service_type`
--

DROP TABLE IF EXISTS `dim_service_type`;
/*!50001 DROP VIEW IF EXISTS `dim_service_type`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_service_type` AS SELECT 
 1 AS `service_type_id`,
 1 AS `service_type_name`,
 1 AS `service_category`,
 1 AS `is_active`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_facility_lane_counts`
--

DROP TABLE IF EXISTS `vw_facility_lane_counts`;
/*!50001 DROP VIEW IF EXISTS `vw_facility_lane_counts`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_facility_lane_counts` AS SELECT 
 1 AS `from_facility_id`,
 1 AS `from_facility_name`,
 1 AS `to_facility_id`,
 1 AS `to_facility_name`,
 1 AS `movement_event_count`,
 1 AS `package_count`,
 1 AS `first_moved_at`,
 1 AS `last_moved_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_facility`
--

DROP TABLE IF EXISTS `dim_facility`;
/*!50001 DROP VIEW IF EXISTS `dim_facility`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_facility` AS SELECT 
 1 AS `facility_id`,
 1 AS `territory_id`,
 1 AS `facility_name`,
 1 AS `facility_type_id`,
 1 AS `facility_type_code`,
 1 AS `facility_type_name`,
 1 AS `facility_type_description`,
 1 AS `city`,
 1 AS `state_code`,
 1 AS `zip_code`,
 1 AS `manager_employee_id`,
 1 AS `is_customer_facing`,
 1 AS `handles_retail`,
 1 AS `handles_processing`,
 1 AS `handles_distribution`,
 1 AS `handles_local_delivery`,
 1 AS `facility_type_is_active`,
 1 AS `is_retail_office`,
 1 AS `is_processing_or_distribution_center`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_movement_event_type`
--

DROP TABLE IF EXISTS `dim_movement_event_type`;
/*!50001 DROP VIEW IF EXISTS `dim_movement_event_type`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_movement_event_type` AS SELECT 
 1 AS `package_movement_event_type_id`,
 1 AS `event_type_name`,
 1 AS `description`,
 1 AS `default_package_status_name`,
 1 AS `is_entry_event`,
 1 AS `is_exit_event`,
 1 AS `is_processing_event`,
 1 AS `is_delay_event`,
 1 AS `is_final_event`,
 1 AS `sort_order`,
 1 AS `is_active`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_package`
--

DROP TABLE IF EXISTS `dim_package`;
/*!50001 DROP VIEW IF EXISTS `dim_package`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_package` AS SELECT 
 1 AS `package_id`,
 1 AS `recipient_customer_id`,
 1 AS `package_flow_type_id`,
 1 AS `package_flow_type_name`,
 1 AS `sender_customer_id`,
 1 AS `sender_business_id`,
 1 AS `service_type_id`,
 1 AS `package_status_id`,
 1 AS `received_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_package_overview`
--

DROP TABLE IF EXISTS `vw_package_overview`;
/*!50001 DROP VIEW IF EXISTS `vw_package_overview`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_package_overview` AS SELECT 
 1 AS `package_id`,
 1 AS `recipient_customer_id`,
 1 AS `recipient_customer_name`,
 1 AS `recipient_customer_email`,
 1 AS `package_flow_type_name`,
 1 AS `sender_customer_id`,
 1 AS `sender_customer_name`,
 1 AS `sender_business_id`,
 1 AS `sender_business_name`,
 1 AS `package_status`,
 1 AS `service_type_name`,
 1 AS `received_date`,
 1 AS `contents`,
 1 AS `weight_lbs`,
 1 AS `length_in`,
 1 AS `width_in`,
 1 AS `height_in`,
 1 AS `employee_id`,
 1 AS `handled_by_employee`,
 1 AS `created_at`,
 1 AS `updated_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_customer_accounts`
--

DROP TABLE IF EXISTS `vw_customer_accounts`;
/*!50001 DROP VIEW IF EXISTS `vw_customer_accounts`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_customer_accounts` AS SELECT 
 1 AS `customer_id`,
 1 AS `customer_name`,
 1 AS `customer_email`,
 1 AS `preferred_facility_id`,
 1 AS `preferred_facility_name`,
 1 AS `user_id`,
 1 AS `username`,
 1 AS `login_email`,
 1 AS `is_active`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_package_facility_stays`
--

DROP TABLE IF EXISTS `vw_package_facility_stays`;
/*!50001 DROP VIEW IF EXISTS `vw_package_facility_stays`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_package_facility_stays` AS SELECT 
 1 AS `package_id`,
 1 AS `entry_package_movement_id`,
 1 AS `facility_id`,
 1 AS `facility_name`,
 1 AS `facility_type_code`,
 1 AS `facility_type_name`,
 1 AS `arrived_at`,
 1 AS `departed_at`,
 1 AS `dwell_minutes`,
 1 AS `is_current_facility`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_package_flow_type`
--

DROP TABLE IF EXISTS `dim_package_flow_type`;
/*!50001 DROP VIEW IF EXISTS `dim_package_flow_type`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_package_flow_type` AS SELECT 
 1 AS `package_flow_type_id`,
 1 AS `package_flow_type_name`,
 1 AS `is_active`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_facility_map`
--

DROP TABLE IF EXISTS `vw_facility_map`;
/*!50001 DROP VIEW IF EXISTS `vw_facility_map`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_facility_map` AS SELECT 
 1 AS `facility_id`,
 1 AS `facility_name`,
 1 AS `facility_type_code`,
 1 AS `facility_type_name`,
 1 AS `street_address`,
 1 AS `city`,
 1 AS `county`,
 1 AS `state_code`,
 1 AS `zip_code`,
 1 AS `map_zip_code`,
 1 AS `latitude`,
 1 AS `longitude`,
 1 AS `full_address`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_facility_processing_counts`
--

DROP TABLE IF EXISTS `vw_facility_processing_counts`;
/*!50001 DROP VIEW IF EXISTS `vw_facility_processing_counts`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_facility_processing_counts` AS SELECT 
 1 AS `facility_id`,
 1 AS `facility_name`,
 1 AS `facility_type_code`,
 1 AS `facility_type_name`,
 1 AS `movement_event_count`,
 1 AS `processing_event_count`,
 1 AS `packages_processed`,
 1 AS `most_recent_processed_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_package_route_plan_actual_movement`
--

DROP TABLE IF EXISTS `vw_package_route_plan_actual_movement`;
/*!50001 DROP VIEW IF EXISTS `vw_package_route_plan_actual_movement`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_package_route_plan_actual_movement` AS SELECT 
 1 AS `package_id`,
 1 AS `service_type_name`,
 1 AS `destination_purpose`,
 1 AS `planned_origin_facility_id`,
 1 AS `planned_origin_facility_name`,
 1 AS `planned_destination_facility_id`,
 1 AS `planned_destination_facility_name`,
 1 AS `latest_package_movement_id`,
 1 AS `latest_event_type_name`,
 1 AS `latest_status_name`,
 1 AS `latest_facility_id`,
 1 AS `latest_facility_name`,
 1 AS `latest_from_facility_id`,
 1 AS `latest_to_facility_id`,
 1 AS `latest_event_timestamp`,
 1 AS `route_alignment_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_facility_delay_totals`
--

DROP TABLE IF EXISTS `vw_facility_delay_totals`;
/*!50001 DROP VIEW IF EXISTS `vw_facility_delay_totals`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_facility_delay_totals` AS SELECT 
 1 AS `facility_id`,
 1 AS `facility_name`,
 1 AS `delay_event_count`,
 1 AS `delayed_package_count`,
 1 AS `total_delay_minutes`,
 1 AS `avg_delay_minutes`,
 1 AS `max_delay_minutes`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_user_account_roles`
--

DROP TABLE IF EXISTS `vw_user_account_roles`;
/*!50001 DROP VIEW IF EXISTS `vw_user_account_roles`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_user_account_roles` AS SELECT 
 1 AS `user_id`,
 1 AS `username`,
 1 AS `email`,
 1 AS `is_active`,
 1 AS `first_name`,
 1 AS `last_name`,
 1 AS `role_id`,
 1 AS `role_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_incident_type`
--

DROP TABLE IF EXISTS `dim_incident_type`;
/*!50001 DROP VIEW IF EXISTS `dim_incident_type`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_incident_type` AS SELECT 
 1 AS `incident_type_id`,
 1 AS `type_name`,
 1 AS `type_category`,
 1 AS `is_active`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `fact_package_movement`
--

DROP TABLE IF EXISTS `fact_package_movement`;
/*!50001 DROP VIEW IF EXISTS `fact_package_movement`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `fact_package_movement` AS SELECT 
 1 AS `package_movement_id`,
 1 AS `package_id`,
 1 AS `package_movement_event_type_id`,
 1 AS `package_status_id`,
 1 AS `facility_id`,
 1 AS `facility_territory_id`,
 1 AS `from_facility_id`,
 1 AS `from_territory_id`,
 1 AS `to_facility_id`,
 1 AS `to_territory_id`,
 1 AS `processed_by_employee_id`,
 1 AS `handled_by_employee_id`,
 1 AS `event_datetime`,
 1 AS `expected_event_at`,
 1 AS `delay_minutes`,
 1 AS `movement_event_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_locker_occupancy`
--

DROP TABLE IF EXISTS `vw_locker_occupancy`;
/*!50001 DROP VIEW IF EXISTS `vw_locker_occupancy`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_locker_occupancy` AS SELECT 
 1 AS `locker_id`,
 1 AS `locker_location_id`,
 1 AS `location_name`,
 1 AS `locker_status`,
 1 AS `locker_assignment_id`,
 1 AS `customer_id`,
 1 AS `customer_name`,
 1 AS `package_id`,
 1 AS `assigned_at`,
 1 AS `expires_at`,
 1 AS `retrieved_at`,
 1 AS `is_expired`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `fact_shipping_revenue`
--

DROP TABLE IF EXISTS `fact_shipping_revenue`;
/*!50001 DROP VIEW IF EXISTS `fact_shipping_revenue`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `fact_shipping_revenue` AS SELECT 
 1 AS `package_id`,
 1 AS `customer_id`,
 1 AS `recipient_customer_id`,
 1 AS `package_flow_type_id`,
 1 AS `package_flow_type_name`,
 1 AS `sender_customer_id`,
 1 AS `sender_business_id`,
 1 AS `customer_territory_id`,
 1 AS `received_by_employee_id`,
 1 AS `service_type_id`,
 1 AS `package_status_id`,
 1 AS `revenue_datetime`,
 1 AS `gross_shipping_revenue`,
 1 AS `material_cost`,
 1 AS `transportation_cost`,
 1 AS `total_internal_shipping_cost`,
 1 AS `estimated_shipping_margin`,
 1 AS `charge_source`,
 1 AS `charge_recorded_at`,
 1 AS `shipping_charge_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `fact_refund`
--

DROP TABLE IF EXISTS `fact_refund`;
/*!50001 DROP VIEW IF EXISTS `fact_refund`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `fact_refund` AS SELECT 
 1 AS `refund_id`,
 1 AS `package_id`,
 1 AS `customer_id`,
 1 AS `customer_territory_id`,
 1 AS `incident_id`,
 1 AS `refund_facility_id`,
 1 AS `refund_facility_territory_id`,
 1 AS `reported_by_employee_id`,
 1 AS `employee_territory_id`,
 1 AS `incident_type_id`,
 1 AS `incident_severity_id`,
 1 AS `incident_status_id`,
 1 AS `service_type_id`,
 1 AS `refund_datetime`,
 1 AS `refund_amount`,
 1 AS `refund_status`,
 1 AS `refund_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_locker_location`
--

DROP TABLE IF EXISTS `dim_locker_location`;
/*!50001 DROP VIEW IF EXISTS `dim_locker_location`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_locker_location` AS SELECT 
 1 AS `locker_location_id`,
 1 AS `location_name`,
 1 AS `facility_id`,
 1 AS `facility_territory_id`,
 1 AS `facility_name`,
 1 AS `city`,
 1 AS `state_code`,
 1 AS `zip_code`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `fact_delivery`
--

DROP TABLE IF EXISTS `fact_delivery`;
/*!50001 DROP VIEW IF EXISTS `fact_delivery`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `fact_delivery` AS SELECT 
 1 AS `delivery_fact_key`,
 1 AS `package_id`,
 1 AS `package_customer_id`,
 1 AS `recipient_customer_id`,
 1 AS `package_flow_type_id`,
 1 AS `package_flow_type_name`,
 1 AS `sender_customer_id`,
 1 AS `sender_business_id`,
 1 AS `service_type_id`,
 1 AS `package_status_id`,
 1 AS `employee_id`,
 1 AS `package_received_datetime`,
 1 AS `shippingdetails_created_datetime`,
 1 AS `expected_delivery_date`,
 1 AS `delivered_date`,
 1 AS `shippingdetails_updated_datetime`,
 1 AS `recipient_first_name`,
 1 AS `recipient_middle_initial`,
 1 AS `recipient_last_name`,
 1 AS `recipient_address`,
 1 AS `sender_address`,
 1 AS `distance_traveled`,
 1 AS `delivery_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_package_revenue`
--

DROP TABLE IF EXISTS `vw_package_revenue`;
/*!50001 DROP VIEW IF EXISTS `vw_package_revenue`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_package_revenue` AS SELECT 
 1 AS `package_id`,
 1 AS `recipient_customer_id`,
 1 AS `recipient_customer_name`,
 1 AS `package_flow_type_name`,
 1 AS `sender_customer_id`,
 1 AS `sender_customer_name`,
 1 AS `sender_business_id`,
 1 AS `sender_business_name`,
 1 AS `service_type_id`,
 1 AS `service_type_name`,
 1 AS `package_status_id`,
 1 AS `package_status`,
 1 AS `received_date`,
 1 AS `expected_delivery_date`,
 1 AS `delivered_date`,
 1 AS `actual_shipping_charge`,
 1 AS `charge_source`,
 1 AS `charge_recorded_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `fact_smartlocker_assignment`
--

DROP TABLE IF EXISTS `fact_smartlocker_assignment`;
/*!50001 DROP VIEW IF EXISTS `fact_smartlocker_assignment`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `fact_smartlocker_assignment` AS SELECT 
 1 AS `locker_assignment_id`,
 1 AS `package_id`,
 1 AS `locker_id`,
 1 AS `locker_location_id`,
 1 AS `facility_id`,
 1 AS `facility_territory_id`,
 1 AS `package_customer_id`,
 1 AS `recipient_customer_id`,
 1 AS `package_flow_type_id`,
 1 AS `package_flow_type_name`,
 1 AS `sender_customer_id`,
 1 AS `sender_business_id`,
 1 AS `locker_customer_id`,
 1 AS `assigned_datetime`,
 1 AS `expiration_datetime`,
 1 AS `retrieved_datetime`,
 1 AS `locker_assignment_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `dim_department`
--

DROP TABLE IF EXISTS `dim_department`;
/*!50001 DROP VIEW IF EXISTS `dim_department`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `dim_department` AS SELECT 
 1 AS `department_id`,
 1 AS `department_name`,
 1 AS `facility_id`,
 1 AS `facility_territory_id`,
 1 AS `facility_name`,
 1 AS `manager_employee_id`,
 1 AS `manager_start_date`,
 1 AS `department_created_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_customer_id_hex_lookup`
--

/*!50001 DROP VIEW IF EXISTS `vw_customer_id_hex_lookup`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_customer_id_hex_lookup` AS select hex(`customer`.`customer_id`) AS `customer_id_hex`,`customer`.`customer_id` AS `customer_id`,`customer`.`first_name` AS `first_name`,`customer`.`last_name` AS `last_name`,`customer`.`email` AS `email`,`customer`.`city` AS `city`,`customer`.`state_code` AS `state_code`,`customer`.`zip_code` AS `zip_code` from `customer` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_territory`
--

/*!50001 DROP VIEW IF EXISTS `dim_territory`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY INVOKER */
/*!50001 VIEW `dim_territory` AS select `t`.`territory_id` AS `territory_id`,`t`.`state` AS `state`,`t`.`city` AS `city`,`t`.`county` AS `county`,`t`.`zip_code` AS `zip_code`,`z`.`latitude` AS `latitude`,`z`.`longitude` AS `longitude`,`t`.`created_at` AS `created_at`,`t`.`updated_at` AS `updated_at` from (`territory` `t` left join `zip_geo` `z` on((`z`.`zip_code` = `t`.`zip_code`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_incident_movement_summary`
--

/*!50001 DROP VIEW IF EXISTS `vw_incident_movement_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_incident_movement_summary` AS select `i`.`incident_id` AS `incident_id`,`i`.`incident_date` AS `incident_date`,`i`.`description` AS `description`,`it`.`type_name` AS `incident_type`,`it`.`type_category` AS `type_category`,`sev`.`severity_name` AS `severity_name`,`ist`.`status_name` AS `incident_status`,`i`.`reported_by_employee_id` AS `reported_by_employee_id`,`e`.`full_name` AS `reported_by_employee`,`i`.`package_id` AS `package_id`,`i`.`package_movement_id` AS `package_movement_id`,`met`.`event_type_name` AS `movement_event_type`,`i`.`customer_id` AS `customer_id`,concat(`c`.`first_name`,' ',`c`.`last_name`) AS `customer_name`,`i`.`facility_id` AS `facility_id`,`f`.`facility_name` AS `facility_name`,`ft`.`facility_type_code` AS `facility_type_code`,`ft`.`facility_type_name` AS `facility_type_name` from (((((((((`incident` `i` join `incident_type` `it` on((`i`.`incident_type_id` = `it`.`incident_type_id`))) join `incident_severity` `sev` on((`i`.`incident_severity_id` = `sev`.`incident_severity_id`))) join `incident_status` `ist` on((`i`.`incident_status_id` = `ist`.`incident_status_id`))) join `employee` `e` on((`i`.`reported_by_employee_id` = `e`.`employee_id`))) left join `package_movement` `pm` on((`i`.`package_movement_id` = `pm`.`package_movement_id`))) left join `package_movement_event_type` `met` on((`pm`.`package_movement_event_type_id` = `met`.`package_movement_event_type_id`))) left join `customer` `c` on((`i`.`customer_id` = `c`.`customer_id`))) left join `facility` `f` on((`i`.`facility_id` = `f`.`facility_id`))) left join `facility_type` `ft` on((`f`.`facility_type_id` = `ft`.`facility_type_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_incident_summary`
--

/*!50001 DROP VIEW IF EXISTS `vw_incident_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_incident_summary` AS select `i`.`incident_id` AS `incident_id`,`i`.`incident_date` AS `incident_date`,`i`.`description` AS `description`,`it`.`type_name` AS `incident_type`,`it`.`type_category` AS `type_category`,`sev`.`severity_name` AS `severity_name`,`sev`.`sort_order` AS `severity_order`,`ist`.`status_name` AS `incident_status`,`ist`.`is_closed_status` AS `is_closed_status`,`i`.`reported_by_employee_id` AS `reported_by_employee_id`,`e`.`full_name` AS `reported_by_employee`,`i`.`package_id` AS `package_id`,`i`.`customer_id` AS `customer_id`,concat(`c`.`first_name`,' ',`c`.`last_name`) AS `customer_name`,`i`.`facility_id` AS `facility_id`,`f`.`facility_name` AS `facility_name` from ((((((`incident` `i` join `incident_type` `it` on((`i`.`incident_type_id` = `it`.`incident_type_id`))) join `incident_severity` `sev` on((`i`.`incident_severity_id` = `sev`.`incident_severity_id`))) join `incident_status` `ist` on((`i`.`incident_status_id` = `ist`.`incident_status_id`))) join `employee` `e` on((`i`.`reported_by_employee_id` = `e`.`employee_id`))) left join `customer` `c` on((`i`.`customer_id` = `c`.`customer_id`))) left join `facility` `f` on((`i`.`facility_id` = `f`.`facility_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `fact_package`
--

/*!50001 DROP VIEW IF EXISTS `fact_package`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `fact_package` AS select `p`.`package_id` AS `package_id`,`p`.`recipient_customer_id` AS `customer_id`,`p`.`recipient_customer_id` AS `recipient_customer_id`,`p`.`package_flow_type_id` AS `package_flow_type_id`,`pft`.`package_flow_type_name` AS `package_flow_type_name`,`p`.`sender_customer_id` AS `sender_customer_id`,`p`.`sender_business_id` AS `sender_business_id`,`p`.`service_type_id` AS `service_type_id`,`p`.`package_status_id` AS `package_status_id`,`d`.`facility_id` AS `received_facility_id`,`f`.`territory_id` AS `received_facility_territory_id`,`p`.`employee_id` AS `received_by_employee_id`,`p`.`received_date` AS `received_datetime`,`p`.`weight_lbs` AS `weight_lbs`,`p`.`length_in` AS `length_in`,`p`.`width_in` AS `width_in`,`p`.`height_in` AS `height_in`,(case when ((`p`.`length_in` is not null) and (`p`.`width_in` is not null) and (`p`.`height_in` is not null)) then ((`p`.`length_in` * `p`.`width_in`) * `p`.`height_in`) else NULL end) AS `package_volume_cubic_in`,1 AS `package_count` from ((((`package` `p` join `package_flow_type` `pft` on((`pft`.`package_flow_type_id` = `p`.`package_flow_type_id`))) left join `employee` `e` on((`e`.`employee_id` = `p`.`employee_id`))) left join `departments` `d` on((`d`.`department_id` = `e`.`department_id`))) left join `facility` `f` on((`f`.`facility_id` = `d`.`facility_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_employee`
--

/*!50001 DROP VIEW IF EXISTS `dim_employee`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `dim_employee` AS select `e`.`employee_id` AS `employee_id`,`e`.`full_name` AS `employee_name`,`e`.`job_title` AS `job_title`,`e`.`department_id` AS `department_id`,`d`.`department_name` AS `department_name`,`d`.`facility_id` AS `facility_id`,`f`.`territory_id` AS `facility_territory_id`,`f`.`facility_name` AS `facility_name`,`e`.`manager_employee_id` AS `manager_employee_id`,(case when (exists(select 1 from `employee` `e2` where (`e2`.`manager_employee_id` = `e`.`employee_id`)) or exists(select 1 from `departments` `d2` where (`d2`.`manager_employee_id` = `e`.`employee_id`)) or (`f`.`manager_employee_id` = `e`.`employee_id`)) then 1 else 0 end) AS `is_manager`,`e`.`hours_worked` AS `hours_worked`,cast(`e`.`created_at` as date) AS `employee_created_date` from ((`employee` `e` left join `departments` `d` on((`d`.`department_id` = `e`.`department_id`))) left join `facility` `f` on((`f`.`facility_id` = `d`.`facility_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_customer`
--

/*!50001 DROP VIEW IF EXISTS `dim_customer`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `dim_customer` AS select `c`.`customer_id` AS `customer_id`,`c`.`territory_id` AS `territory_id`,`c`.`first_name` AS `first_name`,`c`.`middle_initial` AS `middle_initial`,`c`.`last_name` AS `last_name`,trim(concat(`c`.`first_name`,' ',coalesce(concat(`c`.`middle_initial`,'. '),''),`c`.`last_name`)) AS `customer_name`,`c`.`city` AS `city`,`c`.`state_code` AS `state_code`,`c`.`zip_code` AS `zip_code`,`c`.`preferred_facility_id` AS `preferred_facility_id`,`pf`.`territory_id` AS `preferred_facility_territory_id`,`c`.`birth_date` AS `birth_date`,timestampdiff(YEAR,`c`.`birth_date`,curdate()) AS `age_years`,`c`.`marital_status` AS `marital_status`,`c`.`gender` AS `gender`,`c`.`email_address` AS `email_address`,`c`.`annual_income` AS `annual_income`,`c`.`total_children` AS `total_children`,`c`.`education_level` AS `education_level`,`c`.`occupation` AS `occupation`,`c`.`home_owner` AS `home_owner`,cast(`c`.`created_at` as date) AS `customer_created_date` from (`customer` `c` left join `facility` `pf` on((`pf`.`facility_id` = `c`.`preferred_facility_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_package_delay_summary`
--

/*!50001 DROP VIEW IF EXISTS `vw_package_delay_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_package_delay_summary` AS select `pm`.`package_movement_id` AS `package_movement_id`,`pm`.`package_id` AS `package_id`,`pm`.`event_timestamp` AS `event_timestamp`,coalesce(`pm`.`facility_id`,`pm`.`from_facility_id`,`pm`.`to_facility_id`) AS `delay_facility_id`,coalesce(`f`.`facility_name`,`from_f`.`facility_name`,`to_f`.`facility_name`) AS `delay_facility_name`,`met`.`event_type_name` AS `event_type_name`,`pm`.`expected_event_at` AS `expected_event_at`,`pm`.`delay_minutes` AS `delay_minutes`,`pm`.`delay_reason` AS `delay_reason`,`pm`.`movement_note` AS `movement_note` from ((((`package_movement` `pm` join `package_movement_event_type` `met` on((`pm`.`package_movement_event_type_id` = `met`.`package_movement_event_type_id`))) left join `facility` `f` on((`pm`.`facility_id` = `f`.`facility_id`))) left join `facility` `from_f` on((`pm`.`from_facility_id` = `from_f`.`facility_id`))) left join `facility` `to_f` on((`pm`.`to_facility_id` = `to_f`.`facility_id`))) where ((`met`.`is_delay_event` = 1) or (`pm`.`delay_minutes` > 0)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_package_status`
--

/*!50001 DROP VIEW IF EXISTS `dim_package_status`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `dim_package_status` AS select `ps`.`package_status_id` AS `package_status_id`,`ps`.`status_name` AS `status_name`,`ps`.`status_category` AS `status_category`,`ps`.`sort_order` AS `sort_order`,`ps`.`is_final_status` AS `is_final_status`,`ps`.`is_active` AS `is_active` from `package_status` `ps` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_incident_status`
--

/*!50001 DROP VIEW IF EXISTS `dim_incident_status`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `dim_incident_status` AS select `ist`.`incident_status_id` AS `incident_status_id`,`ist`.`status_name` AS `status_name`,`ist`.`sort_order` AS `sort_order`,`ist`.`is_closed_status` AS `is_closed_status`,`ist`.`is_active` AS `is_active` from `incident_status` `ist` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_smartlocker`
--

/*!50001 DROP VIEW IF EXISTS `dim_smartlocker`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `dim_smartlocker` AS select `sl`.`locker_id` AS `locker_id`,`sl`.`locker_location_id` AS `locker_location_id`,`ll`.`location_name` AS `location_name`,`ll`.`facility_id` AS `facility_id`,`f`.`territory_id` AS `facility_territory_id`,`f`.`facility_name` AS `facility_name`,`sl`.`locker_status` AS `locker_status`,cast(`sl`.`created_at` as date) AS `locker_created_date` from ((`smartlocker` `sl` left join `lockerlocations` `ll` on((`ll`.`locker_location_id` = `sl`.`locker_location_id`))) left join `facility` `f` on((`f`.`facility_id` = `ll`.`facility_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_employee_facility_assignment`
--

/*!50001 DROP VIEW IF EXISTS `vw_employee_facility_assignment`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_employee_facility_assignment` AS select `e`.`employee_id` AS `employee_id`,`e`.`full_name` AS `full_name`,`e`.`email` AS `email`,`e`.`phone_number` AS `phone_number`,`e`.`job_title` AS `job_title`,`e`.`department_id` AS `department_id`,`d`.`department_name` AS `department_name`,`d`.`facility_id` AS `facility_id`,`f`.`facility_name` AS `facility_name`,`ft`.`facility_type_code` AS `facility_type_code`,`ft`.`facility_type_name` AS `facility_type_name`,`e`.`manager_employee_id` AS `manager_employee_id`,`m`.`full_name` AS `manager_name`,`e`.`salary` AS `salary`,`e`.`hours_worked` AS `hours_worked`,`e`.`user_id` AS `user_id`,`e`.`created_at` AS `created_at`,`e`.`updated_at` AS `updated_at` from ((((`employee` `e` join `departments` `d` on((`e`.`department_id` = `d`.`department_id`))) left join `facility` `f` on((`d`.`facility_id` = `f`.`facility_id`))) left join `facility_type` `ft` on((`f`.`facility_type_id` = `ft`.`facility_type_id`))) left join `employee` `m` on((`e`.`manager_employee_id` = `m`.`employee_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_package_route_history`
--

/*!50001 DROP VIEW IF EXISTS `vw_package_route_history`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_package_route_history` AS select `pm`.`package_movement_id` AS `package_movement_id`,`pm`.`package_id` AS `package_id`,`pm`.`event_timestamp` AS `event_timestamp`,`met`.`event_type_name` AS `event_type_name`,`ps`.`status_name` AS `package_status`,`pm`.`facility_id` AS `facility_id`,`f`.`facility_name` AS `facility_name`,`ft`.`facility_type_code` AS `facility_type_code`,`ft`.`facility_type_name` AS `facility_type_name`,`pm`.`from_facility_id` AS `from_facility_id`,`from_f`.`facility_name` AS `from_facility_name`,`pm`.`to_facility_id` AS `to_facility_id`,`to_f`.`facility_name` AS `to_facility_name`,`pm`.`processed_by_employee_id` AS `processed_by_employee_id`,`e`.`full_name` AS `processed_by_employee`,`pm`.`expected_event_at` AS `expected_event_at`,`pm`.`delay_minutes` AS `delay_minutes`,`pm`.`delay_reason` AS `delay_reason`,`pm`.`movement_note` AS `movement_note` from (((((((`package_movement` `pm` join `package_movement_event_type` `met` on((`pm`.`package_movement_event_type_id` = `met`.`package_movement_event_type_id`))) join `package_status` `ps` on((`pm`.`package_status_id` = `ps`.`package_status_id`))) left join `facility` `f` on((`pm`.`facility_id` = `f`.`facility_id`))) left join `facility_type` `ft` on((`f`.`facility_type_id` = `ft`.`facility_type_id`))) left join `facility` `from_f` on((`pm`.`from_facility_id` = `from_f`.`facility_id`))) left join `facility` `to_f` on((`pm`.`to_facility_id` = `to_f`.`facility_id`))) left join `employee` `e` on((`pm`.`processed_by_employee_id` = `e`.`employee_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `fact_incident`
--

/*!50001 DROP VIEW IF EXISTS `fact_incident`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `fact_incident` AS select `i`.`incident_id` AS `incident_id`,`i`.`package_id` AS `package_id`,`i`.`customer_id` AS `customer_id`,`c`.`territory_id` AS `customer_territory_id`,`i`.`reported_by_employee_id` AS `reported_by_employee_id`,`ef`.`territory_id` AS `employee_territory_id`,`i`.`facility_id` AS `facility_id`,`inf`.`territory_id` AS `facility_territory_id`,`i`.`package_movement_id` AS `package_movement_id`,`i`.`incident_type_id` AS `incident_type_id`,`i`.`incident_severity_id` AS `incident_severity_id`,`i`.`incident_status_id` AS `incident_status_id`,`i`.`incident_date` AS `incident_datetime`,1 AS `incident_count` from (((((`incident` `i` left join `customer` `c` on((`c`.`customer_id` = `i`.`customer_id`))) left join `employee` `e` on((`e`.`employee_id` = `i`.`reported_by_employee_id`))) left join `departments` `d` on((`d`.`department_id` = `e`.`department_id`))) left join `facility` `ef` on((`ef`.`facility_id` = `d`.`facility_id`))) left join `facility` `inf` on((`inf`.`facility_id` = `i`.`facility_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_package_id_hex_lookup`
--

/*!50001 DROP VIEW IF EXISTS `vw_package_id_hex_lookup`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_package_id_hex_lookup` AS select hex(`p`.`package_id`) AS `package_id_hex`,`p`.`package_id` AS `package_id`,hex(`p`.`recipient_customer_id`) AS `recipient_customer_id_hex`,`p`.`recipient_customer_id` AS `recipient_customer_id`,`p`.`package_flow_type_id` AS `package_flow_type_id`,`pft`.`package_flow_type_name` AS `package_flow_type_name`,hex(`p`.`sender_customer_id`) AS `sender_customer_id_hex`,`p`.`sender_customer_id` AS `sender_customer_id`,hex(`p`.`sender_business_id`) AS `sender_business_id_hex`,`p`.`sender_business_id` AS `sender_business_id`,`p`.`package_status_id` AS `package_status_id`,`p`.`service_type_id` AS `service_type_id`,`p`.`received_date` AS `received_date` from (`package` `p` join `package_flow_type` `pft` on((`pft`.`package_flow_type_id` = `p`.`package_flow_type_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_incident_severity`
--

/*!50001 DROP VIEW IF EXISTS `dim_incident_severity`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `dim_incident_severity` AS select `ise`.`incident_severity_id` AS `incident_severity_id`,`ise`.`severity_name` AS `severity_name`,`ise`.`sort_order` AS `sort_order`,`ise`.`is_active` AS `is_active` from `incident_severity` `ise` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_service_type`
--

/*!50001 DROP VIEW IF EXISTS `dim_service_type`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `dim_service_type` AS select `st`.`service_type_id` AS `service_type_id`,`st`.`service_type_name` AS `service_type_name`,(case when (lower(`st`.`service_type_name`) like '%delivery%') then 'Delivery' when (lower(`st`.`service_type_name`) like '%locker%') then 'SmartLocker' when (lower(`st`.`service_type_name`) like '%pickup%') then 'Pickup' else 'Other' end) AS `service_category`,`st`.`is_active` AS `is_active` from `service_type` `st` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_facility_lane_counts`
--

/*!50001 DROP VIEW IF EXISTS `vw_facility_lane_counts`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_facility_lane_counts` AS select `pm`.`from_facility_id` AS `from_facility_id`,`from_f`.`facility_name` AS `from_facility_name`,`pm`.`to_facility_id` AS `to_facility_id`,`to_f`.`facility_name` AS `to_facility_name`,count(0) AS `movement_event_count`,count(distinct `pm`.`package_id`) AS `package_count`,min(`pm`.`event_timestamp`) AS `first_moved_at`,max(`pm`.`event_timestamp`) AS `last_moved_at` from ((`package_movement` `pm` join `facility` `from_f` on((`pm`.`from_facility_id` = `from_f`.`facility_id`))) join `facility` `to_f` on((`pm`.`to_facility_id` = `to_f`.`facility_id`))) group by `pm`.`from_facility_id`,`from_f`.`facility_name`,`pm`.`to_facility_id`,`to_f`.`facility_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_facility`
--

/*!50001 DROP VIEW IF EXISTS `dim_facility`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `dim_facility` AS select `f`.`facility_id` AS `facility_id`,`f`.`territory_id` AS `territory_id`,`f`.`facility_name` AS `facility_name`,`f`.`facility_type_id` AS `facility_type_id`,`ft`.`facility_type_code` AS `facility_type_code`,`ft`.`facility_type_name` AS `facility_type_name`,`ft`.`description` AS `facility_type_description`,`f`.`city` AS `city`,`f`.`state_code` AS `state_code`,`f`.`zip_code` AS `zip_code`,`f`.`manager_employee_id` AS `manager_employee_id`,`ft`.`is_customer_facing` AS `is_customer_facing`,`ft`.`handles_retail` AS `handles_retail`,`ft`.`handles_processing` AS `handles_processing`,`ft`.`handles_distribution` AS `handles_distribution`,`ft`.`handles_local_delivery` AS `handles_local_delivery`,`ft`.`is_active` AS `facility_type_is_active`,(case when (`ft`.`handles_retail` = 1) then 1 else 0 end) AS `is_retail_office`,(case when ((`ft`.`handles_processing` = 1) or (`ft`.`handles_distribution` = 1)) then 1 else 0 end) AS `is_processing_or_distribution_center` from (`facility` `f` left join `facility_type` `ft` on((`ft`.`facility_type_id` = `f`.`facility_type_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_movement_event_type`
--

/*!50001 DROP VIEW IF EXISTS `dim_movement_event_type`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `dim_movement_event_type` AS select `met`.`package_movement_event_type_id` AS `package_movement_event_type_id`,`met`.`event_type_name` AS `event_type_name`,`met`.`description` AS `description`,`met`.`default_package_status_name` AS `default_package_status_name`,`met`.`is_entry_event` AS `is_entry_event`,`met`.`is_exit_event` AS `is_exit_event`,`met`.`is_processing_event` AS `is_processing_event`,`met`.`is_delay_event` AS `is_delay_event`,`met`.`is_final_event` AS `is_final_event`,`met`.`sort_order` AS `sort_order`,`met`.`is_active` AS `is_active` from `package_movement_event_type` `met` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_package`
--

/*!50001 DROP VIEW IF EXISTS `dim_package`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `dim_package` AS select `p`.`package_id` AS `package_id`,`p`.`recipient_customer_id` AS `recipient_customer_id`,`p`.`package_flow_type_id` AS `package_flow_type_id`,`pft`.`package_flow_type_name` AS `package_flow_type_name`,`p`.`sender_customer_id` AS `sender_customer_id`,`p`.`sender_business_id` AS `sender_business_id`,`p`.`service_type_id` AS `service_type_id`,`p`.`package_status_id` AS `package_status_id`,`p`.`received_date` AS `received_date` from (`package` `p` join `package_flow_type` `pft` on((`pft`.`package_flow_type_id` = `p`.`package_flow_type_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_package_overview`
--

/*!50001 DROP VIEW IF EXISTS `vw_package_overview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_package_overview` AS select `p`.`package_id` AS `package_id`,`p`.`recipient_customer_id` AS `recipient_customer_id`,trim(concat(`c`.`first_name`,' ',`c`.`last_name`)) AS `recipient_customer_name`,`c`.`email` AS `recipient_customer_email`,`pft`.`package_flow_type_name` AS `package_flow_type_name`,`p`.`sender_customer_id` AS `sender_customer_id`,trim(concat(`sc`.`first_name`,' ',`sc`.`last_name`)) AS `sender_customer_name`,`p`.`sender_business_id` AS `sender_business_id`,`b`.`business_name` AS `sender_business_name`,`ps`.`status_name` AS `package_status`,`st`.`service_type_name` AS `service_type_name`,`p`.`received_date` AS `received_date`,`p`.`contents` AS `contents`,`p`.`weight_lbs` AS `weight_lbs`,`p`.`length_in` AS `length_in`,`p`.`width_in` AS `width_in`,`p`.`height_in` AS `height_in`,`p`.`employee_id` AS `employee_id`,`e`.`full_name` AS `handled_by_employee`,`p`.`created_at` AS `created_at`,`p`.`updated_at` AS `updated_at` from (((((((`package` `p` join `customer` `c` on((`c`.`customer_id` = `p`.`recipient_customer_id`))) join `package_flow_type` `pft` on((`pft`.`package_flow_type_id` = `p`.`package_flow_type_id`))) join `package_status` `ps` on((`ps`.`package_status_id` = `p`.`package_status_id`))) left join `service_type` `st` on((`st`.`service_type_id` = `p`.`service_type_id`))) left join `customer` `sc` on((`sc`.`customer_id` = `p`.`sender_customer_id`))) left join `business` `b` on((`b`.`business_id` = `p`.`sender_business_id`))) left join `employee` `e` on((`e`.`employee_id` = `p`.`employee_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_customer_accounts`
--

/*!50001 DROP VIEW IF EXISTS `vw_customer_accounts`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_customer_accounts` AS select `c`.`customer_id` AS `customer_id`,concat(`c`.`first_name`,' ',`c`.`last_name`) AS `customer_name`,`c`.`email` AS `customer_email`,`c`.`preferred_facility_id` AS `preferred_facility_id`,`f`.`facility_name` AS `preferred_facility_name`,`ul`.`user_id` AS `user_id`,`ul`.`username` AS `username`,`ul`.`email` AS `login_email`,`ul`.`is_active` AS `is_active` from ((`customer` `c` left join `user_logins` `ul` on((`c`.`user_id` = `ul`.`user_id`))) left join `facility` `f` on((`c`.`preferred_facility_id` = `f`.`facility_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_package_facility_stays`
--

/*!50001 DROP VIEW IF EXISTS `vw_package_facility_stays`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_package_facility_stays` AS select `x`.`package_id` AS `package_id`,`x`.`entry_package_movement_id` AS `entry_package_movement_id`,`x`.`facility_id` AS `facility_id`,`x`.`facility_name` AS `facility_name`,`x`.`facility_type_code` AS `facility_type_code`,`x`.`facility_type_name` AS `facility_type_name`,`x`.`arrived_at` AS `arrived_at`,`x`.`departed_at` AS `departed_at`,timestampdiff(MINUTE,`x`.`arrived_at`,coalesce(`x`.`departed_at`,now())) AS `dwell_minutes`,(case when (`x`.`departed_at` is null) then 1 else 0 end) AS `is_current_facility` from (select `pm`.`package_id` AS `package_id`,`pm`.`package_movement_id` AS `entry_package_movement_id`,`pm`.`facility_id` AS `facility_id`,`f`.`facility_name` AS `facility_name`,`ft`.`facility_type_code` AS `facility_type_code`,`ft`.`facility_type_name` AS `facility_type_name`,`pm`.`event_timestamp` AS `arrived_at`,(select min(`pm2`.`event_timestamp`) from (`package_movement` `pm2` join `package_movement_event_type` `met2` on((`pm2`.`package_movement_event_type_id` = `met2`.`package_movement_event_type_id`))) where ((`pm2`.`package_id` = `pm`.`package_id`) and (`met2`.`is_exit_event` = 1) and (`pm2`.`event_timestamp` > `pm`.`event_timestamp`) and ((`pm2`.`facility_id` = `pm`.`facility_id`) or (`pm2`.`from_facility_id` = `pm`.`facility_id`)))) AS `departed_at` from (((`package_movement` `pm` join `package_movement_event_type` `met` on((`pm`.`package_movement_event_type_id` = `met`.`package_movement_event_type_id`))) join `facility` `f` on((`pm`.`facility_id` = `f`.`facility_id`))) join `facility_type` `ft` on((`f`.`facility_type_id` = `ft`.`facility_type_id`))) where (`met`.`is_entry_event` = 1)) `x` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_package_flow_type`
--

/*!50001 DROP VIEW IF EXISTS `dim_package_flow_type`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `dim_package_flow_type` AS select `package_flow_type`.`package_flow_type_id` AS `package_flow_type_id`,`package_flow_type`.`package_flow_type_name` AS `package_flow_type_name`,`package_flow_type`.`is_active` AS `is_active` from `package_flow_type` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_facility_map`
--

/*!50001 DROP VIEW IF EXISTS `vw_facility_map`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_facility_map` AS select `f`.`facility_id` AS `facility_id`,`f`.`facility_name` AS `facility_name`,`ft`.`facility_type_code` AS `facility_type_code`,`ft`.`facility_type_name` AS `facility_type_name`,`f`.`street_address` AS `street_address`,`f`.`city` AS `city`,`f`.`county` AS `county`,`f`.`state_code` AS `state_code`,`f`.`zip_code` AS `zip_code`,coalesce(`t`.`zip_code`,left(`f`.`zip_code`,5)) AS `map_zip_code`,`zg`.`latitude` AS `latitude`,`zg`.`longitude` AS `longitude`,concat(`f`.`street_address`,', ',`f`.`city`,', ',`f`.`state_code`,' ',`f`.`zip_code`) AS `full_address` from (((`facility` `f` join `facility_type` `ft` on((`f`.`facility_type_id` = `ft`.`facility_type_id`))) left join `territory` `t` on((`f`.`territory_id` = `t`.`territory_id`))) left join `zip_geo` `zg` on((`zg`.`zip_code` = coalesce(`t`.`zip_code`,left(`f`.`zip_code`,5))))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_facility_processing_counts`
--

/*!50001 DROP VIEW IF EXISTS `vw_facility_processing_counts`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_facility_processing_counts` AS select `pm`.`facility_id` AS `facility_id`,`f`.`facility_name` AS `facility_name`,`ft`.`facility_type_code` AS `facility_type_code`,`ft`.`facility_type_name` AS `facility_type_name`,count(0) AS `movement_event_count`,sum((case when (`met`.`is_processing_event` = 1) then 1 else 0 end)) AS `processing_event_count`,count(distinct `pm`.`package_id`) AS `packages_processed`,max(`pm`.`event_timestamp`) AS `most_recent_processed_at` from (((`package_movement` `pm` join `package_movement_event_type` `met` on((`pm`.`package_movement_event_type_id` = `met`.`package_movement_event_type_id`))) join `facility` `f` on((`pm`.`facility_id` = `f`.`facility_id`))) join `facility_type` `ft` on((`f`.`facility_type_id` = `ft`.`facility_type_id`))) group by `pm`.`facility_id`,`f`.`facility_name`,`ft`.`facility_type_code`,`ft`.`facility_type_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_package_route_plan_actual_movement`
--

/*!50001 DROP VIEW IF EXISTS `vw_package_route_plan_actual_movement`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_package_route_plan_actual_movement` AS with `latest_movement` as (select `pm`.`package_movement_id` AS `package_movement_id`,`pm`.`package_id` AS `package_id`,`pm`.`facility_id` AS `facility_id`,`pm`.`from_facility_id` AS `from_facility_id`,`pm`.`to_facility_id` AS `to_facility_id`,`pm`.`event_timestamp` AS `event_timestamp`,`met`.`event_type_name` AS `event_type_name`,`ps`.`status_name` AS `status_name`,row_number() OVER (PARTITION BY `pm`.`package_id` ORDER BY `pm`.`event_timestamp` desc,`pm`.`package_movement_id` desc )  AS `movement_rank` from ((`package_movement` `pm` join `package_movement_event_type` `met` on((`met`.`package_movement_event_type_id` = `pm`.`package_movement_event_type_id`))) join `package_status` `ps` on((`ps`.`package_status_id` = `pm`.`package_status_id`)))) select `prp`.`package_id` AS `package_id`,`st`.`service_type_name` AS `service_type_name`,`prp`.`destination_purpose` AS `destination_purpose`,`prp`.`planned_origin_facility_id` AS `planned_origin_facility_id`,`origin_f`.`facility_name` AS `planned_origin_facility_name`,`prp`.`planned_destination_facility_id` AS `planned_destination_facility_id`,`dest_f`.`facility_name` AS `planned_destination_facility_name`,`lm`.`package_movement_id` AS `latest_package_movement_id`,`lm`.`event_type_name` AS `latest_event_type_name`,`lm`.`status_name` AS `latest_status_name`,`lm`.`facility_id` AS `latest_facility_id`,`latest_f`.`facility_name` AS `latest_facility_name`,`lm`.`from_facility_id` AS `latest_from_facility_id`,`lm`.`to_facility_id` AS `latest_to_facility_id`,`lm`.`event_timestamp` AS `latest_event_timestamp`,(case when (`lm`.`package_id` is null) then 'No Movement' when (`lm`.`facility_id` = `prp`.`planned_destination_facility_id`) then 'At Planned Destination' when (`lm`.`to_facility_id` = `prp`.`planned_destination_facility_id`) then 'En Route To Planned Destination' when (`lm`.`facility_id` = `prp`.`planned_origin_facility_id`) then 'At Planned Origin' else 'Off Planned Route' end) AS `route_alignment_status` from ((((((`package_route_plan` `prp` join `package` `p` on((`p`.`package_id` = `prp`.`package_id`))) left join `service_type` `st` on((`st`.`service_type_id` = `p`.`service_type_id`))) left join `facility` `origin_f` on((`origin_f`.`facility_id` = `prp`.`planned_origin_facility_id`))) left join `facility` `dest_f` on((`dest_f`.`facility_id` = `prp`.`planned_destination_facility_id`))) left join `latest_movement` `lm` on(((`lm`.`package_id` = `prp`.`package_id`) and (`lm`.`movement_rank` = 1)))) left join `facility` `latest_f` on((`latest_f`.`facility_id` = `lm`.`facility_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_facility_delay_totals`
--

/*!50001 DROP VIEW IF EXISTS `vw_facility_delay_totals`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_facility_delay_totals` AS select `d`.`delay_facility_id` AS `facility_id`,`d`.`delay_facility_name` AS `facility_name`,count(0) AS `delay_event_count`,count(distinct `d`.`package_id`) AS `delayed_package_count`,sum(`d`.`delay_minutes`) AS `total_delay_minutes`,avg(`d`.`delay_minutes`) AS `avg_delay_minutes`,max(`d`.`delay_minutes`) AS `max_delay_minutes` from `vw_package_delay_summary` `d` where (`d`.`delay_facility_id` is not null) group by `d`.`delay_facility_id`,`d`.`delay_facility_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_user_account_roles`
--

/*!50001 DROP VIEW IF EXISTS `vw_user_account_roles`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY INVOKER */
/*!50001 VIEW `vw_user_account_roles` AS select `ul`.`user_id` AS `user_id`,`ul`.`username` AS `username`,`ul`.`email` AS `email`,`ul`.`is_active` AS `is_active`,`ul`.`first_name` AS `first_name`,`ul`.`last_name` AS `last_name`,`r`.`role_id` AS `role_id`,`r`.`role_name` AS `role_name` from ((`user_logins` `ul` join `user_roles` `ur` on((`ul`.`user_id` = `ur`.`user_id`))) join `roles` `r` on((`ur`.`role_id` = `r`.`role_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_incident_type`
--

/*!50001 DROP VIEW IF EXISTS `dim_incident_type`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `dim_incident_type` AS select `it`.`incident_type_id` AS `incident_type_id`,`it`.`type_name` AS `type_name`,`it`.`type_category` AS `type_category`,`it`.`is_active` AS `is_active` from `incident_type` `it` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `fact_package_movement`
--

/*!50001 DROP VIEW IF EXISTS `fact_package_movement`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `fact_package_movement` AS select `pm`.`package_movement_id` AS `package_movement_id`,`pm`.`package_id` AS `package_id`,`pm`.`package_movement_event_type_id` AS `package_movement_event_type_id`,`pm`.`package_status_id` AS `package_status_id`,`pm`.`facility_id` AS `facility_id`,`current_f`.`territory_id` AS `facility_territory_id`,`pm`.`from_facility_id` AS `from_facility_id`,`from_f`.`territory_id` AS `from_territory_id`,`pm`.`to_facility_id` AS `to_facility_id`,`to_f`.`territory_id` AS `to_territory_id`,`pm`.`processed_by_employee_id` AS `processed_by_employee_id`,`pm`.`processed_by_employee_id` AS `handled_by_employee_id`,`pm`.`event_timestamp` AS `event_datetime`,`pm`.`expected_event_at` AS `expected_event_at`,`pm`.`delay_minutes` AS `delay_minutes`,1 AS `movement_event_count` from (((`package_movement` `pm` left join `facility` `current_f` on((`current_f`.`facility_id` = `pm`.`facility_id`))) left join `facility` `from_f` on((`from_f`.`facility_id` = `pm`.`from_facility_id`))) left join `facility` `to_f` on((`to_f`.`facility_id` = `pm`.`to_facility_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_locker_occupancy`
--

/*!50001 DROP VIEW IF EXISTS `vw_locker_occupancy`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY INVOKER */
/*!50001 VIEW `vw_locker_occupancy` AS select `sl`.`locker_id` AS `locker_id`,`ll`.`locker_location_id` AS `locker_location_id`,`ll`.`location_name` AS `location_name`,`sl`.`locker_status` AS `locker_status`,`la`.`locker_assignment_id` AS `locker_assignment_id`,`la`.`customer_id` AS `customer_id`,concat(`c`.`first_name`,' ',`c`.`last_name`) AS `customer_name`,`ptl`.`package_id` AS `package_id`,`la`.`assigned_at` AS `assigned_at`,`la`.`expires_at` AS `expires_at`,`la`.`retrieved_at` AS `retrieved_at`,(case when ((`la`.`locker_assignment_id` is not null) and (`la`.`expires_at` is not null) and (`la`.`expires_at` <= now())) then 1 else 0 end) AS `is_expired` from ((((`smartlocker` `sl` left join `lockerlocations` `ll` on((`sl`.`locker_location_id` = `ll`.`locker_location_id`))) left join `lockerassignment` `la` on(((`sl`.`locker_id` = `la`.`locker_id`) and (`la`.`retrieved_at` is null)))) left join `customer` `c` on((`la`.`customer_id` = `c`.`customer_id`))) left join `package_to_locker` `ptl` on((`la`.`locker_assignment_id` = `ptl`.`locker_assignment_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `fact_shipping_revenue`
--

/*!50001 DROP VIEW IF EXISTS `fact_shipping_revenue`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `fact_shipping_revenue` AS select `sc`.`package_id` AS `package_id`,`p`.`recipient_customer_id` AS `customer_id`,`p`.`recipient_customer_id` AS `recipient_customer_id`,`p`.`package_flow_type_id` AS `package_flow_type_id`,`pft`.`package_flow_type_name` AS `package_flow_type_name`,`p`.`sender_customer_id` AS `sender_customer_id`,`p`.`sender_business_id` AS `sender_business_id`,`c`.`territory_id` AS `customer_territory_id`,`p`.`employee_id` AS `received_by_employee_id`,`p`.`service_type_id` AS `service_type_id`,`p`.`package_status_id` AS `package_status_id`,`p`.`received_date` AS `revenue_datetime`,`sc`.`actual_shipping_charge` AS `gross_shipping_revenue`,`sc`.`material_cost` AS `material_cost`,`sc`.`transportation_cost` AS `transportation_cost`,round((coalesce(`sc`.`material_cost`,0) + coalesce(`sc`.`transportation_cost`,0)),2) AS `total_internal_shipping_cost`,round(((`sc`.`actual_shipping_charge` - coalesce(`sc`.`material_cost`,0)) - coalesce(`sc`.`transportation_cost`,0)),2) AS `estimated_shipping_margin`,`sc`.`charge_source` AS `charge_source`,`sc`.`charge_recorded_at` AS `charge_recorded_at`,1 AS `shipping_charge_count` from (((`shipping_cost` `sc` join `package` `p` on((`p`.`package_id` = `sc`.`package_id`))) join `package_flow_type` `pft` on((`pft`.`package_flow_type_id` = `p`.`package_flow_type_id`))) left join `customer` `c` on((`c`.`customer_id` = `p`.`recipient_customer_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `fact_refund`
--

/*!50001 DROP VIEW IF EXISTS `fact_refund`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `fact_refund` AS select `r`.`refund_id` AS `refund_id`,`r`.`package_id` AS `package_id`,`r`.`customer_id` AS `customer_id`,`c`.`territory_id` AS `customer_territory_id`,`i`.`incident_id` AS `incident_id`,`i`.`facility_id` AS `refund_facility_id`,`f`.`territory_id` AS `refund_facility_territory_id`,`i`.`reported_by_employee_id` AS `reported_by_employee_id`,`ef`.`territory_id` AS `employee_territory_id`,`i`.`incident_type_id` AS `incident_type_id`,`i`.`incident_severity_id` AS `incident_severity_id`,`i`.`incident_status_id` AS `incident_status_id`,`p`.`service_type_id` AS `service_type_id`,`r`.`refund_date` AS `refund_datetime`,`r`.`refund_amount` AS `refund_amount`,`r`.`refund_status` AS `refund_status`,1 AS `refund_count` from (((((((`refunds` `r` join `package` `p` on((`p`.`package_id` = `r`.`package_id`))) left join `customer` `c` on((`c`.`customer_id` = `r`.`customer_id`))) left join `incident` `i` on((`i`.`incident_id` = (select `i2`.`incident_id` from `incident` `i2` where ((`i2`.`package_id` = `r`.`package_id`) and ((`i2`.`customer_id` = `r`.`customer_id`) or (`i2`.`customer_id` is null)) and (`i2`.`facility_id` is not null) and (`i2`.`incident_date` <= `r`.`refund_date`)) order by `i2`.`incident_date` desc,`i2`.`incident_id` desc limit 1)))) left join `facility` `f` on((`f`.`facility_id` = `i`.`facility_id`))) left join `employee` `e` on((`e`.`employee_id` = `i`.`reported_by_employee_id`))) left join `departments` `d` on((`d`.`department_id` = `e`.`department_id`))) left join `facility` `ef` on((`ef`.`facility_id` = `d`.`facility_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_locker_location`
--

/*!50001 DROP VIEW IF EXISTS `dim_locker_location`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `dim_locker_location` AS select `ll`.`locker_location_id` AS `locker_location_id`,`ll`.`location_name` AS `location_name`,`ll`.`facility_id` AS `facility_id`,`f`.`territory_id` AS `facility_territory_id`,`f`.`facility_name` AS `facility_name`,`f`.`city` AS `city`,`f`.`state_code` AS `state_code`,`f`.`zip_code` AS `zip_code` from (`lockerlocations` `ll` left join `facility` `f` on((`f`.`facility_id` = `ll`.`facility_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `fact_delivery`
--

/*!50001 DROP VIEW IF EXISTS `fact_delivery`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `fact_delivery` AS select `sd`.`package_id` AS `delivery_fact_key`,`sd`.`package_id` AS `package_id`,`p`.`recipient_customer_id` AS `package_customer_id`,`p`.`recipient_customer_id` AS `recipient_customer_id`,`p`.`package_flow_type_id` AS `package_flow_type_id`,`pft`.`package_flow_type_name` AS `package_flow_type_name`,`p`.`sender_customer_id` AS `sender_customer_id`,`p`.`sender_business_id` AS `sender_business_id`,`p`.`service_type_id` AS `service_type_id`,`p`.`package_status_id` AS `package_status_id`,`p`.`employee_id` AS `employee_id`,`p`.`received_date` AS `package_received_datetime`,`sd`.`created_at` AS `shippingdetails_created_datetime`,`sd`.`expected_delivery_date` AS `expected_delivery_date`,`sd`.`delivered_date` AS `delivered_date`,`sd`.`updated_at` AS `shippingdetails_updated_datetime`,`sd`.`recipient_first_name` AS `recipient_first_name`,`sd`.`recipient_middle_initial` AS `recipient_middle_initial`,`sd`.`recipient_last_name` AS `recipient_last_name`,`sd`.`recipient_address` AS `recipient_address`,`sd`.`sender_address` AS `sender_address`,`sd`.`estimated_delivery_distance` AS `distance_traveled`,1 AS `delivery_count` from ((`shippingdetails` `sd` join `package` `p` on((`p`.`package_id` = `sd`.`package_id`))) join `package_flow_type` `pft` on((`pft`.`package_flow_type_id` = `p`.`package_flow_type_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_package_revenue`
--

/*!50001 DROP VIEW IF EXISTS `vw_package_revenue`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_package_revenue` AS select `p`.`package_id` AS `package_id`,`p`.`recipient_customer_id` AS `recipient_customer_id`,trim(concat(`c`.`first_name`,' ',`c`.`last_name`)) AS `recipient_customer_name`,`pft`.`package_flow_type_name` AS `package_flow_type_name`,`p`.`sender_customer_id` AS `sender_customer_id`,trim(concat(`scust`.`first_name`,' ',`scust`.`last_name`)) AS `sender_customer_name`,`p`.`sender_business_id` AS `sender_business_id`,`b`.`business_name` AS `sender_business_name`,`p`.`service_type_id` AS `service_type_id`,`st`.`service_type_name` AS `service_type_name`,`p`.`package_status_id` AS `package_status_id`,`ps`.`status_name` AS `package_status`,`p`.`received_date` AS `received_date`,`sd`.`expected_delivery_date` AS `expected_delivery_date`,`sd`.`delivered_date` AS `delivered_date`,`ship_cost`.`actual_shipping_charge` AS `actual_shipping_charge`,`ship_cost`.`charge_source` AS `charge_source`,`ship_cost`.`charge_recorded_at` AS `charge_recorded_at` from ((((((((`package` `p` join `customer` `c` on((`c`.`customer_id` = `p`.`recipient_customer_id`))) join `package_flow_type` `pft` on((`pft`.`package_flow_type_id` = `p`.`package_flow_type_id`))) join `package_status` `ps` on((`ps`.`package_status_id` = `p`.`package_status_id`))) left join `customer` `scust` on((`scust`.`customer_id` = `p`.`sender_customer_id`))) left join `business` `b` on((`b`.`business_id` = `p`.`sender_business_id`))) left join `service_type` `st` on((`st`.`service_type_id` = `p`.`service_type_id`))) left join `shippingdetails` `sd` on((`sd`.`package_id` = `p`.`package_id`))) left join `shipping_cost` `ship_cost` on((`ship_cost`.`package_id` = `p`.`package_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `fact_smartlocker_assignment`
--

/*!50001 DROP VIEW IF EXISTS `fact_smartlocker_assignment`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `fact_smartlocker_assignment` AS select `la`.`locker_assignment_id` AS `locker_assignment_id`,`ptl`.`package_id` AS `package_id`,`la`.`locker_id` AS `locker_id`,`sl`.`locker_location_id` AS `locker_location_id`,`ll`.`facility_id` AS `facility_id`,`f`.`territory_id` AS `facility_territory_id`,`p`.`recipient_customer_id` AS `package_customer_id`,`p`.`recipient_customer_id` AS `recipient_customer_id`,`p`.`package_flow_type_id` AS `package_flow_type_id`,`pft`.`package_flow_type_name` AS `package_flow_type_name`,`p`.`sender_customer_id` AS `sender_customer_id`,`p`.`sender_business_id` AS `sender_business_id`,`ptl`.`customer_id` AS `locker_customer_id`,`la`.`assigned_at` AS `assigned_datetime`,`la`.`expires_at` AS `expiration_datetime`,`la`.`retrieved_at` AS `retrieved_datetime`,1 AS `locker_assignment_count` from ((((((`lockerassignment` `la` join `package_to_locker` `ptl` on((`ptl`.`locker_assignment_id` = `la`.`locker_assignment_id`))) join `package` `p` on((`p`.`package_id` = `ptl`.`package_id`))) join `package_flow_type` `pft` on((`pft`.`package_flow_type_id` = `p`.`package_flow_type_id`))) join `smartlocker` `sl` on((`sl`.`locker_id` = `la`.`locker_id`))) left join `lockerlocations` `ll` on((`ll`.`locker_location_id` = `sl`.`locker_location_id`))) left join `facility` `f` on((`f`.`facility_id` = `ll`.`facility_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dim_department`
--

/*!50001 DROP VIEW IF EXISTS `dim_department`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`ryan`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `dim_department` AS select `d`.`department_id` AS `department_id`,`d`.`department_name` AS `department_name`,`d`.`facility_id` AS `facility_id`,`f`.`territory_id` AS `facility_territory_id`,`f`.`facility_name` AS `facility_name`,`d`.`manager_employee_id` AS `manager_employee_id`,`d`.`manager_start_date` AS `manager_start_date`,cast(`d`.`created_at` as date) AS `department_created_date` from (`departments` `d` left join `facility` `f` on((`f`.`facility_id` = `d`.`facility_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Dumping events for database 'postal_bi_system'
--

--
-- Dumping routines for database 'postal_bi_system'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_facility_dept_prefix` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` FUNCTION `fn_facility_dept_prefix`(
    p_county VARCHAR(45),
    p_city VARCHAR(60),
    p_facility_name VARCHAR(100),
    p_zip_code VARCHAR(10)
) RETURNS varchar(30) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE name_part VARCHAR(100);
    DECLARE cleaned VARCHAR(100);
    DECLARE token VARCHAR(40);
    DECLARE initials VARCHAR(20) DEFAULT '';

    SET name_part = TRIM(
        CASE
            WHEN LOCATE('-', p_facility_name) > 0
                THEN SUBSTRING_INDEX(p_facility_name, '-', -1)
            ELSE p_facility_name
        END
    );

    SET name_part = SUBSTRING_INDEX(name_part, ';', 1);
    SET cleaned = REGEXP_REPLACE(UPPER(name_part), '[^A-Z0-9]+', ' ');

    WHILE LENGTH(TRIM(cleaned)) > 0 DO
        SET token = SUBSTRING_INDEX(TRIM(cleaned), ' ', 1);
        SET initials = CONCAT(initials, LEFT(token, 1));

        IF LOCATE(' ', TRIM(cleaned)) = 0 THEN
            SET cleaned = '';
        ELSE
            SET cleaned = SUBSTRING(TRIM(cleaned), LOCATE(' ', TRIM(cleaned)) + 1);
        END IF;
    END WHILE;

    RETURN CONCAT(
        LEFT(REGEXP_REPLACE(UPPER(p_county), '[^A-Z]', ''), 2),
        LEFT(REGEXP_REPLACE(UPPER(p_city), '[^A-Z]', ''), 2),
        initials,
        RIGHT(REGEXP_REPLACE(p_zip_code, '[^0-9]', ''), 3)
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CalculateDistEstimate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `CalculateDistEstimate`(
    IN p_package_id INT,
    OUT p_estimated_delivery_distance DECIMAL(10,2)
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_sender_territory_id INT;
    DECLARE v_recipient_territory_id INT;
    DECLARE v_sender_zip_code CHAR(5);
    DECLARE v_recipient_zip_code CHAR(5);

    SET p_estimated_delivery_distance = NULL;

    IF p_package_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package_id is required.';
    END IF;

    SELECT sd.sender_territory_id, sd.recipient_territory_id
    INTO v_sender_territory_id, v_recipient_territory_id
    FROM `shippingdetails` sd
    WHERE sd.package_id = p_package_id;

    IF v_sender_territory_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'shippingdetails.sender_territory_id is required to estimate delivery distance.';
    END IF;

    IF v_recipient_territory_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'shippingdetails.recipient_territory_id is required to estimate delivery distance.';
    END IF;

    SELECT t.zip_code
    INTO v_sender_zip_code
    FROM `territory` t
    WHERE t.territory_id = v_sender_territory_id
    LIMIT 1;

    IF v_sender_zip_code IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sender territory was not found.';
    END IF;

    SELECT t.zip_code
    INTO v_recipient_zip_code
    FROM `territory` t
    WHERE t.territory_id = v_recipient_territory_id
    LIMIT 1;

    IF v_recipient_zip_code IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'recipient territory was not found.';
    END IF;

    CALL `CalculatePointDifference`(
        v_sender_zip_code,
        v_recipient_zip_code,
        p_estimated_delivery_distance
    );

    UPDATE `shippingdetails`
    SET estimated_delivery_distance = p_estimated_delivery_distance,
        updated_at = NOW()
    WHERE package_id = p_package_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CalculateMaterialCost` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `CalculateMaterialCost`(
    IN p_package_id INT,
    OUT p_material_cost DECIMAL(12,2)
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_weight_lbs DECIMAL(8,2);
    DECLARE v_length_in DECIMAL(8,2);
    DECLARE v_width_in DECIMAL(8,2);
    DECLARE v_height_in DECIMAL(8,2);

    SET p_material_cost = NULL;

    IF p_package_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package_id is required.';
    END IF;

    SELECT p.weight_lbs, p.length_in, p.width_in, p.height_in
    INTO v_weight_lbs, v_length_in, v_width_in, v_height_in
    FROM `package` p
    WHERE p.package_id = p_package_id;

    IF v_weight_lbs IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package was not found or package weight is missing.';
    END IF;

    SET p_material_cost = ROUND(
        (COALESCE(v_weight_lbs, 0) * 0.20)
        + (COALESCE(v_length_in, 0) * 0.05)
        + (COALESCE(v_width_in, 0) * 0.10)
        + (COALESCE(v_height_in, 0) * 0.15),
        2
    );

    INSERT INTO `shipping_cost` (
        package_id,
        actual_shipping_charge,
        material_cost,
        transportation_cost,
        charge_source,
        charge_recorded_at
    )
    VALUES (
        p_package_id,
        0.00,
        p_material_cost,
        0.00,
        'Procedure: CalculateMaterialCost',
        NOW()
    )
    ON DUPLICATE KEY UPDATE
        material_cost = VALUES(material_cost),
        updated_at = NOW();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CalculatePointDifference` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `CalculatePointDifference`(
    IN p_origin_zip_code VARCHAR(10),
    IN p_destination_zip_code VARCHAR(10),
    OUT p_distance_miles DECIMAL(10,2)
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_origin_zip5 CHAR(5);
    DECLARE v_destination_zip5 CHAR(5);
    DECLARE v_origin_latitude DECIMAL(10,6);
    DECLARE v_origin_longitude DECIMAL(10,6);
    DECLARE v_destination_latitude DECIMAL(10,6);
    DECLARE v_destination_longitude DECIMAL(10,6);
    DECLARE v_origin_point POINT;
    DECLARE v_destination_point POINT;

    SET p_distance_miles = NULL;
    SET v_origin_zip5 = LEFT(TRIM(p_origin_zip_code), 5);
    SET v_destination_zip5 = LEFT(TRIM(p_destination_zip_code), 5);

    IF v_origin_zip5 IS NULL OR CHAR_LENGTH(v_origin_zip5) <> 5 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'origin ZIP code must contain at least 5 characters.';
    END IF;

    IF v_destination_zip5 IS NULL OR CHAR_LENGTH(v_destination_zip5) <> 5 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'destination ZIP code must contain at least 5 characters.';
    END IF;

    SELECT zg.latitude, zg.longitude
    INTO v_origin_latitude, v_origin_longitude
    FROM `zip_geo` zg
    WHERE zg.zip_code = v_origin_zip5
    LIMIT 1;

    IF v_origin_latitude IS NULL OR v_origin_longitude IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'origin ZIP code was not found in zip_geo.';
    END IF;

    SELECT zg.latitude, zg.longitude
    INTO v_destination_latitude, v_destination_longitude
    FROM `zip_geo` zg
    WHERE zg.zip_code = v_destination_zip5
    LIMIT 1;

    IF v_destination_latitude IS NULL OR v_destination_longitude IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'destination ZIP code was not found in zip_geo.';
    END IF;

    SET v_origin_point = ST_SRID(POINT(v_origin_longitude, v_origin_latitude), 4326);
    SET v_destination_point = ST_SRID(POINT(v_destination_longitude, v_destination_latitude), 4326);

    SET p_distance_miles = ROUND(ST_Distance_Sphere(v_origin_point, v_destination_point) / 1609.344, 2);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CalculateTransporation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `CalculateTransporation`(
    IN p_package_id INT,
    OUT p_transportation_cost DECIMAL(12,2)
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_package_exists INT DEFAULT 0;
    DECLARE v_movement_count INT DEFAULT 0;
    DECLARE v_has_delivered_event TINYINT DEFAULT 0;

    SET p_transportation_cost = NULL;

    IF p_package_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package_id is required.';
    END IF;

    SELECT COUNT(*)
    INTO v_package_exists
    FROM `package` p
    WHERE p.package_id = p_package_id;

    IF v_package_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package was not found.';
    END IF;

    SELECT
        COUNT(*),
        COALESCE(MAX(CASE
            WHEN met.event_type_name = 'Delivered'
                 OR ps.status_name = 'Delivered'
                 OR ps.is_final_status = 1
            THEN 1
            ELSE 0
        END), 0)
    INTO v_movement_count, v_has_delivered_event
    FROM `package_movement` pm
    JOIN `package_movement_event_type` met
        ON met.package_movement_event_type_id = pm.package_movement_event_type_id
    JOIN `package_status` ps
        ON ps.package_status_id = pm.package_status_id
    WHERE pm.package_id = p_package_id;

    SET p_transportation_cost = ROUND(
        (v_movement_count * 0.10)
        + CASE WHEN v_has_delivered_event = 1 THEN 0.50 ELSE 0.00 END,
        2
    );

    INSERT INTO `shipping_cost` (
        package_id,
        actual_shipping_charge,
        material_cost,
        transportation_cost,
        charge_source,
        charge_recorded_at
    )
    VALUES (
        p_package_id,
        0.00,
        0.00,
        p_transportation_cost,
        'Procedure: CalculateTransporation',
        NOW()
    )
    ON DUPLICATE KEY UPDATE
        transportation_cost = VALUES(transportation_cost),
        updated_at = NOW();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CompletePackageDelivery` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `CompletePackageDelivery`(
  IN p_package_id INT,
  IN p_facility_id INT,
  IN p_processed_by_employee_id INT,
  IN p_delivered_at DATETIME,
  IN p_note VARCHAR(255),
  OUT p_package_movement_id INT
)
    SQL SECURITY INVOKER
BEGIN
  DECLARE v_delivered_at DATETIME DEFAULT NULL;
  DECLARE v_shippingdetails_count INT DEFAULT 0;
  DECLARE v_latest_event_name VARCHAR(80) DEFAULT NULL;
  DECLARE v_latest_is_final TINYINT DEFAULT 0;
  DECLARE v_latest_facility_id INT DEFAULT NULL;
  DECLARE v_service_type_name VARCHAR(30) DEFAULT NULL;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET p_package_movement_id = NULL;
  SET v_delivered_at = COALESCE(p_delivered_at, NOW());

  START TRANSACTION;

  SELECT st.service_type_name
  INTO v_service_type_name
  FROM `package` p
  JOIN `service_type` st
    ON st.service_type_id = p.service_type_id
  WHERE p.package_id = p_package_id
  FOR UPDATE;

  IF v_service_type_name <> 'Delivery' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'CompletePackageDelivery is only valid for Delivery packages.';
  END IF;

  IF v_service_type_name IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package does not exist.';
  END IF;

  SELECT COUNT(*)
  INTO v_shippingdetails_count
  FROM `shippingdetails`
  WHERE package_id = p_package_id;

  IF v_shippingdetails_count = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'shippingdetails row does not exist for this package.';
  END IF;

  SELECT met.event_type_name,
         ps.is_final_status,
         pm.facility_id
  INTO v_latest_event_name,
       v_latest_is_final,
       v_latest_facility_id
  FROM `package_movement` pm
  JOIN `package_movement_event_type` met
    ON met.package_movement_event_type_id = pm.package_movement_event_type_id
  JOIN `package_status` ps
    ON ps.package_status_id = pm.package_status_id
  WHERE pm.package_id = p_package_id
  ORDER BY pm.event_timestamp DESC, pm.package_movement_id DESC
  LIMIT 1
  FOR UPDATE;

  IF v_latest_event_name <> 'Out For Delivery' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Latest movement must be Out For Delivery before delivery completion.';
  END IF;

  IF v_latest_is_final = 1 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot complete delivery for a package already in a final status.';
  END IF;

  IF v_latest_facility_id <> p_facility_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Delivery completion facility must match the out-for-delivery facility.';
  END IF;

  CALL `RecordPackageMovement`(
    p_package_id,
    'Delivered',
    NULL,
    p_facility_id,
    p_facility_id,
    NULL,
    p_processed_by_employee_id,
    v_delivered_at,
    NULL,
    NULL,
    COALESCE(p_note, 'Package delivered to customer.'),
    p_package_movement_id
  );

  UPDATE `shippingdetails`
  SET delivered_date = v_delivered_at,
      updated_at = NOW()
  WHERE package_id = p_package_id;

  CALL `CustomerDeliveryCharge`(p_package_id, @recalculated_delivery_charge);

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CompletePackagePickup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `CompletePackagePickup`(
  IN p_package_id INT,
  IN p_facility_id INT,
  IN p_processed_by_employee_id INT,
  IN p_picked_up_at DATETIME,
  IN p_note VARCHAR(255),
  OUT p_package_movement_id INT
)
    SQL SECURITY INVOKER
BEGIN
  DECLARE v_picked_up_at DATETIME DEFAULT NULL;
  DECLARE v_service_type_name VARCHAR(30) DEFAULT NULL;
  DECLARE v_latest_event_name VARCHAR(80) DEFAULT NULL;
  DECLARE v_latest_is_final TINYINT DEFAULT 0;
  DECLARE v_latest_facility_id INT DEFAULT NULL;
  DECLARE v_transportation_cost DECIMAL(12,2) DEFAULT NULL;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET p_package_movement_id = NULL;
  SET v_picked_up_at = COALESCE(p_picked_up_at, NOW());
  START TRANSACTION;

  SELECT st.service_type_name
  INTO v_service_type_name
  FROM `package` p
  JOIN `service_type` st
    ON st.service_type_id = p.service_type_id
  WHERE p.package_id = p_package_id
  FOR UPDATE;

  IF v_service_type_name IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package does not exist.';
  END IF;

  IF v_service_type_name <> 'Pickup' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'CompletePackagePickup is only valid for Pickup packages.';
  END IF;

  SELECT met.event_type_name,
         ps.is_final_status,
         pm.facility_id
  INTO v_latest_event_name,
       v_latest_is_final,
       v_latest_facility_id
  FROM `package_movement` pm
  JOIN `package_movement_event_type` met
    ON met.package_movement_event_type_id = pm.package_movement_event_type_id
  JOIN `package_status` ps
    ON ps.package_status_id = pm.package_status_id
  WHERE pm.package_id = p_package_id
  ORDER BY pm.event_timestamp DESC, pm.package_movement_id DESC
  LIMIT 1
  FOR UPDATE;

  IF v_latest_is_final = 1 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot complete pickup for a package already in a final status.';
  END IF;

  IF v_latest_event_name <> 'Ready For Pickup' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Latest movement must be Ready For Pickup before pickup completion.';
  END IF;

  IF v_latest_facility_id <> p_facility_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Pickup completion facility must match the ready-for-pickup facility.';
  END IF;

  CALL `RecordPackageMovement`(
    p_package_id,
    'Picked Up By Customer',
    NULL,
    p_facility_id,
    NULL,
    NULL,
    p_processed_by_employee_id,
    v_picked_up_at,
    NULL,
    NULL,
    COALESCE(p_note, 'Package picked up by customer.'),
    p_package_movement_id
  );

  CALL `CalculateTransporation`(p_package_id, v_transportation_cost);

  UPDATE `shipping_cost`
  SET transportation_cost = COALESCE(v_transportation_cost, transportation_cost),
      updated_at = NOW()
  WHERE package_id = p_package_id;

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CompleteSmartLockerPickup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `CompleteSmartLockerPickup`(
  IN p_locker_assignment_id INT,
  IN p_processed_by_employee_id INT,
  IN p_retrieved_at DATETIME,
  IN p_note VARCHAR(255),
  OUT p_package_id INT,
  OUT p_package_movement_id INT
)
    SQL SECURITY INVOKER
BEGIN
  DECLARE v_retrieved_at DATETIME DEFAULT NULL;
  DECLARE v_locker_id INT DEFAULT NULL;
  DECLARE v_customer_id INT DEFAULT NULL;
  DECLARE v_existing_retrieved_at DATETIME DEFAULT NULL;
  DECLARE v_facility_id INT DEFAULT NULL;
  DECLARE v_service_type_name VARCHAR(30) DEFAULT NULL;
  DECLARE v_latest_event_name VARCHAR(80) DEFAULT NULL;
  DECLARE v_latest_is_final TINYINT DEFAULT 0;
  DECLARE v_latest_facility_id INT DEFAULT NULL;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET p_package_id = NULL;
  SET p_package_movement_id = NULL;
  SET v_retrieved_at = COALESCE(p_retrieved_at, NOW());

  START TRANSACTION;

  IF p_locker_assignment_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'locker_assignment_id is required.';
  END IF;

  SELECT la.locker_id,
         la.customer_id,
         la.retrieved_at,
         ll.facility_id
  INTO v_locker_id,
       v_customer_id,
       v_existing_retrieved_at,
       v_facility_id
  FROM `lockerassignment` la
  JOIN `smartlocker` sl
    ON sl.locker_id = la.locker_id
  JOIN `lockerlocations` ll
    ON ll.locker_location_id = sl.locker_location_id
  WHERE la.locker_assignment_id = p_locker_assignment_id
  FOR UPDATE;

  IF v_locker_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Locker assignment does not exist.';
  END IF;

  IF v_existing_retrieved_at IS NOT NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Locker assignment has already been retrieved.';
  END IF;

  SELECT ptl.package_id
  INTO p_package_id
  FROM `package_to_locker` ptl
  WHERE ptl.locker_assignment_id = p_locker_assignment_id
  LIMIT 1
  FOR UPDATE;

  IF p_package_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No package is connected to this locker assignment.';
  END IF;

  SELECT st.service_type_name
  INTO v_service_type_name
  FROM `package` p
  JOIN `service_type` st
    ON st.service_type_id = p.service_type_id
  WHERE p.package_id = p_package_id
  FOR UPDATE;

  IF v_service_type_name <> 'SmartLocker' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'CompleteSmartLockerPickup is only valid for SmartLocker packages.';
  END IF;

  SELECT met.event_type_name,
         ps.is_final_status,
         pm.facility_id
  INTO v_latest_event_name,
       v_latest_is_final,
       v_latest_facility_id
  FROM `package_movement` pm
  JOIN `package_movement_event_type` met
    ON met.package_movement_event_type_id = pm.package_movement_event_type_id
  JOIN `package_status` ps
    ON ps.package_status_id = pm.package_status_id
  WHERE pm.package_id = p_package_id
  ORDER BY pm.event_timestamp DESC, pm.package_movement_id DESC
  LIMIT 1
  FOR UPDATE;

  IF v_latest_is_final = 1 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot retrieve a SmartLocker package already in a final status.';
  END IF;

  IF v_latest_event_name <> 'Placed In SmartLocker' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Latest movement must be Placed In SmartLocker before retrieval completion.';
  END IF;

  IF v_latest_facility_id <> v_facility_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'SmartLocker retrieval facility must match the placement facility.';
  END IF;

  CALL `RecordPackageMovement`(
    p_package_id,
    'Retrieved From SmartLocker',
    NULL,
    v_facility_id,
    NULL,
    NULL,
    p_processed_by_employee_id,
    v_retrieved_at,
    NULL,
    NULL,
    COALESCE(p_note, 'Package retrieved from SmartLocker by customer.'),
    p_package_movement_id
  );

  UPDATE `lockerassignment`
  SET retrieved_at = v_retrieved_at
  WHERE locker_assignment_id = p_locker_assignment_id;

  DELETE FROM `package_to_locker`
  WHERE package_id = p_package_id;

  UPDATE `smartlocker`
  SET locker_status = 'Available',
      updated_at = NOW()
  WHERE locker_id = v_locker_id;

  INSERT INTO `notifications` (
    customer_id,
    package_id,
    notification_message,
    notification_date
  )
  VALUES (
    v_customer_id,
    p_package_id,
    CONCAT('Your package with ID ', p_package_id, ' has been retrieved from your locker.'),
    v_retrieved_at
  );

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DetermineDestinationFacility` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `DetermineDestinationFacility`(
    IN p_recipient_territory_id INT,
    IN p_recipient_zip_code VARCHAR(10),
    IN p_requested_destination_facility_id INT,
    OUT p_destination_facility_id INT
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_recipient_zip5 CHAR(5);
    DECLARE v_facility_exists INT DEFAULT 0;
    DECLARE v_zip_exists INT DEFAULT 0;

    SET p_destination_facility_id = NULL;
    SET v_recipient_zip5 = LEFT(TRIM(p_recipient_zip_code), 5);

    IF p_recipient_territory_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'recipient_territory_id is required to determine destination facility.';
    END IF;

    IF v_recipient_zip5 IS NULL OR CHAR_LENGTH(v_recipient_zip5) <> 5 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'recipient ZIP code must contain at least 5 characters.';
    END IF;

    SELECT COUNT(*)
    INTO v_zip_exists
    FROM `zip_geo` zg
    WHERE zg.zip_code = v_recipient_zip5;

    IF v_zip_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'recipient ZIP code does not exist in zip_geo.';
    END IF;

    IF p_requested_destination_facility_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_facility_exists
        FROM `facility` f
        WHERE f.facility_id = p_requested_destination_facility_id;

        IF v_facility_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'requested destination facility does not exist.';
        END IF;

        SET p_destination_facility_id = p_requested_destination_facility_id;
    END IF;

    IF p_destination_facility_id IS NULL THEN
        SELECT f.facility_id
        INTO p_destination_facility_id
        FROM `facility` f
        WHERE f.territory_id = p_recipient_territory_id
        ORDER BY f.facility_id
        LIMIT 1;
    END IF;

    IF p_destination_facility_id IS NULL THEN
        SELECT f.facility_id
        INTO p_destination_facility_id
        FROM `facility` f
        JOIN `zip_geo` fz
            ON fz.zip_code = LEFT(TRIM(f.zip_code), 5)
        JOIN `zip_geo` rz
            ON rz.zip_code = v_recipient_zip5
        ORDER BY ST_Distance_Sphere(
            ST_SRID(POINT(fz.longitude, fz.latitude), 4326),
            ST_SRID(POINT(rz.longitude, rz.latitude), 4326)
        ), f.facility_id
        LIMIT 1;
    END IF;

    IF p_destination_facility_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Unable to determine destination facility.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DetermineOriginFacility` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `DetermineOriginFacility`(
    IN p_customer_id INT,
    IN p_sender_territory_id INT,
    IN p_requested_origin_facility_id INT,
    OUT p_origin_facility_id INT
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_customer_exists INT DEFAULT 0;
    DECLARE v_facility_exists INT DEFAULT 0;
    DECLARE v_sender_zip_code CHAR(5);

    SET p_origin_facility_id = NULL;

    IF p_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'customer_id is required to determine origin facility.';
    END IF;

    IF p_sender_territory_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sender_territory_id is required to determine origin facility.';
    END IF;

    SELECT COUNT(*), MAX(LEFT(TRIM(c.zip_code), 5))
    INTO v_customer_exists, v_sender_zip_code
    FROM `customer` c
    WHERE c.customer_id = p_customer_id;

    IF v_customer_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer does not exist.';
    END IF;

    IF p_requested_origin_facility_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_facility_exists
        FROM `facility` f
        WHERE f.facility_id = p_requested_origin_facility_id;

        IF v_facility_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'requested origin facility does not exist.';
        END IF;

        SET p_origin_facility_id = p_requested_origin_facility_id;
    END IF;

    IF p_origin_facility_id IS NULL THEN
        SELECT c.preferred_facility_id
        INTO p_origin_facility_id
        FROM `customer` c
        WHERE c.customer_id = p_customer_id
          AND c.preferred_facility_id IS NOT NULL
        LIMIT 1;
    END IF;

    IF p_origin_facility_id IS NULL THEN
        SELECT f.facility_id
        INTO p_origin_facility_id
        FROM `facility` f
        WHERE f.territory_id = p_sender_territory_id
        ORDER BY f.facility_id
        LIMIT 1;
    END IF;

    IF p_origin_facility_id IS NULL THEN
        SELECT f.facility_id
        INTO p_origin_facility_id
        FROM `facility` f
        JOIN `zip_geo` fz
            ON fz.zip_code = LEFT(TRIM(f.zip_code), 5)
        JOIN `zip_geo` sz
            ON sz.zip_code = v_sender_zip_code
        ORDER BY ST_Distance_Sphere(
            ST_SRID(POINT(fz.longitude, fz.latitude), 4326),
            ST_SRID(POINT(sz.longitude, sz.latitude), 4326)
        ), f.facility_id
        LIMIT 1;
    END IF;

    IF p_origin_facility_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Unable to determine origin facility.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DispatchPackageToFacility` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `DispatchPackageToFacility`(
  IN p_package_id INT,
  IN p_from_facility_id INT,
  IN p_to_facility_id INT,
  IN p_processed_by_employee_id INT,
  IN p_departed_at DATETIME,
  IN p_expected_arrival_at DATETIME,
  IN p_note VARCHAR(255),
  OUT p_departure_movement_id INT
)
    SQL SECURITY INVOKER
BEGIN
  DECLARE v_latest_event_name VARCHAR(80) DEFAULT NULL;
  DECLARE v_latest_is_final TINYINT DEFAULT 0;
  DECLARE v_latest_facility_id INT DEFAULT NULL;
  DECLARE v_latest_to_facility_id INT DEFAULT NULL;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET p_departure_movement_id = NULL;

  START TRANSACTION;

  IF p_from_facility_id IS NULL OR p_to_facility_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Both from_facility_id and to_facility_id are required.';
  END IF;

  IF p_from_facility_id = p_to_facility_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot dispatch a package to the same facility.';
  END IF;

  SELECT met.event_type_name,
         ps.is_final_status,
         pm.facility_id,
         pm.to_facility_id
  INTO v_latest_event_name,
       v_latest_is_final,
       v_latest_facility_id,
       v_latest_to_facility_id
  FROM `package_movement` pm
  JOIN `package_movement_event_type` met
    ON met.package_movement_event_type_id = pm.package_movement_event_type_id
  JOIN `package_status` ps
    ON ps.package_status_id = pm.package_status_id
  WHERE pm.package_id = p_package_id
  ORDER BY pm.event_timestamp DESC, pm.package_movement_id DESC
  LIMIT 1
  FOR UPDATE;

  IF v_latest_event_name IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package must have an existing movement before dispatch.';
  END IF;

  IF v_latest_is_final = 1 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot dispatch a package in a final status.';
  END IF;

  IF COALESCE(v_latest_facility_id, v_latest_to_facility_id) <> p_from_facility_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package is not currently at from_facility_id.';
  END IF;

  IF v_latest_event_name IN ('Sent To Facility', 'Out For Delivery', 'Delivered') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Latest movement is not eligible for dispatch.';
  END IF;

  CALL `RecordPackageMovement`(
    p_package_id,
    'Sent To Facility',
    NULL,
    p_from_facility_id,
    p_from_facility_id,
    p_to_facility_id,
    p_processed_by_employee_id,
    COALESCE(p_departed_at, NOW()),
    p_expected_arrival_at,
    NULL,
    COALESCE(p_note, 'Package dispatched to another facility.'),
    p_departure_movement_id
  );

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `EstimatePackageShippingCost` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `EstimatePackageShippingCost`(
    IN p_package_id INT,
    OUT p_estimated_shipping_charge DECIMAL(8,2)
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_package_count INT DEFAULT 0;

    SET p_estimated_shipping_charge = NULL;

    SELECT COUNT(*)
    INTO v_package_count
    FROM package
    WHERE package_id = p_package_id;

    IF v_package_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Package does not exist.';
    END IF;

    SELECT
        ROUND(
            (p.weight_lbs * 0.50)
            +
            (
                (
                    COALESCE(p.length_in, 0)
                    + COALESCE(p.width_in, 0)
                    + COALESCE(p.height_in, 0)
                ) * 0.50
            ),
            2
        )
    INTO p_estimated_shipping_charge
    FROM package p
    WHERE p.package_id = p_package_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAvailableLocker` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `GetAvailableLocker`(
    IN p_locker_location_id INT,
    OUT p_available_locker_id INT
)
BEGIN
    SELECT locker_id
    INTO p_available_locker_id
    FROM smartlocker
    WHERE locker_location_id = p_locker_location_id
      AND locker_status = 'Available'
    ORDER BY locker_id
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `HoldPackageForPickup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `HoldPackageForPickup`(
  IN p_package_id INT,
  IN p_facility_id INT,
  IN p_processed_by_employee_id INT,
  IN p_ready_at DATETIME,
  IN p_note VARCHAR(255),
  OUT p_package_movement_id INT
)
    SQL SECURITY INVOKER
BEGIN
  DECLARE v_service_type_name VARCHAR(30) DEFAULT NULL;
  DECLARE v_planned_destination_facility_id INT DEFAULT NULL;
  DECLARE v_latest_event_name VARCHAR(80) DEFAULT NULL;
  DECLARE v_latest_is_final TINYINT DEFAULT 0;
  DECLARE v_latest_facility_id INT DEFAULT NULL;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET p_package_movement_id = NULL;
  START TRANSACTION;

  SELECT st.service_type_name
  INTO v_service_type_name
  FROM `package` p
  JOIN `service_type` st
    ON st.service_type_id = p.service_type_id
  WHERE p.package_id = p_package_id
  FOR UPDATE;

  IF v_service_type_name IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package does not exist.';
  END IF;

  IF v_service_type_name <> 'Pickup' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'HoldPackageForPickup is only valid for Pickup packages.';
  END IF;

  SELECT planned_destination_facility_id
  INTO v_planned_destination_facility_id
  FROM `package_route_plan`
  WHERE package_id = p_package_id;

  IF v_planned_destination_facility_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package route plan is required before holding for pickup.';
  END IF;

  IF v_planned_destination_facility_id <> p_facility_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Pickup package can only be held at its planned pickup facility.';
  END IF;

  SELECT met.event_type_name,
         ps.is_final_status,
         pm.facility_id
  INTO v_latest_event_name,
       v_latest_is_final,
       v_latest_facility_id
  FROM `package_movement` pm
  JOIN `package_movement_event_type` met
    ON met.package_movement_event_type_id = pm.package_movement_event_type_id
  JOIN `package_status` ps
    ON ps.package_status_id = pm.package_status_id
  WHERE pm.package_id = p_package_id
  ORDER BY pm.event_timestamp DESC, pm.package_movement_id DESC
  LIMIT 1
  FOR UPDATE;

  IF v_latest_is_final = 1 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot hold a package in a final status.';
  END IF;

  IF v_latest_event_name NOT IN ('Received At Facility', 'Arrived At Facility', 'Sorted At Facility') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Latest movement must be Received, Arrived, or Sorted before holding for pickup.';
  END IF;

  IF v_latest_facility_id <> p_facility_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package is not currently at p_facility_id.';
  END IF;

  CALL `RecordPackageMovement`(
    p_package_id,
    'Ready For Pickup',
    NULL,
    p_facility_id,
    NULL,
    NULL,
    p_processed_by_employee_id,
    p_ready_at,
    NULL,
    NULL,
    COALESCE(p_note, 'Package is ready for customer pickup.'),
    p_package_movement_id
  );

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertInitialPackageMovement` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `InsertInitialPackageMovement`(
    IN p_package_id INT,
    IN p_origin_facility_id INT,
    IN p_destination_facility_id INT,
    IN p_processed_by_employee_id INT,
    IN p_event_timestamp DATETIME,
    OUT p_package_movement_id INT
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_package_exists INT DEFAULT 0;
    DECLARE v_origin_facility_exists INT DEFAULT 0;
    DECLARE v_destination_facility_exists INT DEFAULT 0;
    DECLARE v_employee_exists INT DEFAULT 0;
    DECLARE v_received_status_id INT;
    DECLARE v_received_event_type_id INT;
    DECLARE v_event_timestamp DATETIME;

    SET p_package_movement_id = NULL;
    SET v_event_timestamp = COALESCE(p_event_timestamp, NOW());

    IF p_package_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'package_id is required to insert initial package movement.';
    END IF;

    IF p_origin_facility_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'origin_facility_id is required to insert initial package movement.';
    END IF;

    IF p_destination_facility_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'destination_facility_id is required to insert initial package movement.';
    END IF;

    SELECT COUNT(*)
    INTO v_package_exists
    FROM `package` p
    WHERE p.package_id = p_package_id;

    IF v_package_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Package does not exist.';
    END IF;

    SELECT COUNT(*)
    INTO v_origin_facility_exists
    FROM `facility` f
    WHERE f.facility_id = p_origin_facility_id;

    IF v_origin_facility_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'origin facility does not exist.';
    END IF;

    SELECT COUNT(*)
    INTO v_destination_facility_exists
    FROM `facility` f
    WHERE f.facility_id = p_destination_facility_id;

    IF v_destination_facility_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'destination facility does not exist.';
    END IF;

    IF p_processed_by_employee_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_employee_exists
        FROM `employee` e
        WHERE e.employee_id = p_processed_by_employee_id;

        IF v_employee_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'processed_by_employee_id does not exist.';
        END IF;
    END IF;

    SELECT ps.package_status_id
    INTO v_received_status_id
    FROM `package_status` ps
    WHERE ps.status_name = 'Received'
      AND ps.is_active = 1
    LIMIT 1;

    SELECT met.package_movement_event_type_id
    INTO v_received_event_type_id
    FROM `package_movement_event_type` met
    WHERE met.event_type_name = 'Received At Facility'
      AND met.is_active = 1
    LIMIT 1;

    IF v_received_status_id IS NULL OR v_received_event_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Received status or Received At Facility event type is missing.';
    END IF;

    INSERT INTO `package_movement` (
        package_id,
        package_movement_event_type_id,
        package_status_id,
        facility_id,
        to_facility_id,
        processed_by_employee_id,
        event_timestamp,
        expected_event_at,
        movement_note
    )
    VALUES (
        p_package_id,
        v_received_event_type_id,
        v_received_status_id,
        p_origin_facility_id,
        p_origin_facility_id,
        p_processed_by_employee_id,
        v_event_timestamp,
        v_event_timestamp,
        CONCAT('Delivery package received at origin facility ', p_origin_facility_id,
               ' for destination facility ', p_destination_facility_id, '.')
    );

    SET p_package_movement_id = LAST_INSERT_ID();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `my_signal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `my_signal`(
    IN p_notification_code INT
)
BEGIN
    CASE p_notification_code
        WHEN 0 THEN
            SELECT 'No notification found' AS message;
        WHEN 1 THEN
            SELECT 'Employee has more than 5 errors' AS message;
        WHEN 2 THEN
            SELECT 'Package has been received' AS message;
        WHEN 3 THEN
            SELECT 'Package has been delivered' AS message;
        WHEN 4 THEN
            SELECT 'Refund has been requested' AS message;
        WHEN 5 THEN
            SELECT 'Invalid delivery type' AS message;
        WHEN 6 THEN
            SELECT 'Inventory is low' AS message;
        WHEN 7 THEN
            SELECT 'Inventory is properly stocked' AS message;
        ELSE
            SELECT 'Unknown notification code' AS message;
    END CASE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `NewCustomer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `NewCustomer`(
    IN p_first_name VARCHAR(50),
    IN p_middle_initial CHAR(1),
    IN p_last_name VARCHAR(50),
    IN p_street_address VARCHAR(100),
    IN p_city VARCHAR(50),
    IN p_state_code CHAR(2),
    IN p_zip_code VARCHAR(10),
    IN p_phone_number VARCHAR(15),
    IN p_email VARCHAR(100),
    IN p_preferred_facility_id INT
)
    SQL SECURITY INVOKER
BEGIN
    INSERT INTO customer (
        first_name,
        middle_initial,
        last_name,
        street_address,
        city,
        state_code,
        zip_code,
        phone_number,
        email,
        preferred_facility_id
    )
    VALUES (
        p_first_name,
        p_middle_initial,
        p_last_name,
        p_street_address,
        p_city,
        p_state_code,
        p_zip_code,
        p_phone_number,
        p_email,
        p_preferred_facility_id
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `NewEmployee` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `NewEmployee`(
    IN p_department_id INT,
    IN p_full_name VARCHAR(50),
    IN p_phone_number VARCHAR(15),
    IN p_email VARCHAR(100),
    IN p_street_address VARCHAR(100),
    IN p_job_title VARCHAR(50),
    IN p_salary DECIMAL(10,2),
    IN p_manager_employee_id INT
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_department_count INT DEFAULT 0;
    DECLARE v_manager_count INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_department_count
    FROM departments
    WHERE department_id = p_department_id;

    IF v_department_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Department does not exist.';
    END IF;

    IF p_manager_employee_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_manager_count
        FROM employee
        WHERE employee_id = p_manager_employee_id;

        IF v_manager_count = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Manager employee does not exist.';
        END IF;
    END IF;

    INSERT INTO employee (
        department_id,
        full_name,
        phone_number,
        email,
        street_address,
        job_title,
        salary,
        manager_employee_id
    )
    VALUES (
        p_department_id,
        p_full_name,
        p_phone_number,
        p_email,
        p_street_address,
        p_job_title,
        p_salary,
        p_manager_employee_id
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ProcessPackageAtFacility` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `ProcessPackageAtFacility`(
  IN p_package_id INT,
  IN p_facility_id INT,
  IN p_processed_by_employee_id INT,
  IN p_processed_at DATETIME,
  IN p_note VARCHAR(255),
  OUT p_package_movement_id INT
)
    SQL SECURITY INVOKER
BEGIN
  DECLARE v_latest_event_name VARCHAR(80) DEFAULT NULL;
  DECLARE v_latest_status_name VARCHAR(30) DEFAULT NULL;
  DECLARE v_latest_is_final TINYINT DEFAULT 0;
  DECLARE v_latest_facility_id INT DEFAULT NULL;
  DECLARE v_latest_to_facility_id INT DEFAULT NULL;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET p_package_movement_id = NULL;
  START TRANSACTION;

  SELECT met.event_type_name,
         ps.status_name,
         ps.is_final_status,
         pm.facility_id,
         pm.to_facility_id
  INTO v_latest_event_name,
       v_latest_status_name,
       v_latest_is_final,
       v_latest_facility_id,
       v_latest_to_facility_id
  FROM `package_movement` pm
  JOIN `package_movement_event_type` met
    ON met.package_movement_event_type_id = pm.package_movement_event_type_id
  JOIN `package_status` ps
    ON ps.package_status_id = pm.package_status_id
  WHERE pm.package_id = p_package_id
  ORDER BY pm.event_timestamp DESC, pm.package_movement_id DESC
  LIMIT 1
  FOR UPDATE;

  IF v_latest_event_name IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package must have an existing movement before processing.';
  END IF;

  IF v_latest_is_final = 1 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot process a package in a final status.';
  END IF;

  IF v_latest_status_name NOT IN ('Received', 'Processing', 'In Transit') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package latest status is not eligible for facility processing.';
  END IF;

  IF COALESCE(v_latest_facility_id, v_latest_to_facility_id) <> p_facility_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package is not currently at p_facility_id.';
  END IF;

  CALL `RecordPackageMovement`(
    p_package_id,
    'Sorted At Facility',
    NULL,
    p_facility_id,
    NULL,
    NULL,
    p_processed_by_employee_id,
    p_processed_at,
    NULL,
    NULL,
    COALESCE(p_note, 'Package processed at facility.'),
    p_package_movement_id
  );

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ReceivePackageAtFacility` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `ReceivePackageAtFacility`(
  IN p_package_id INT,
  IN p_from_facility_id INT,
  IN p_to_facility_id INT,
  IN p_processed_by_employee_id INT,
  IN p_arrived_at DATETIME,
  IN p_expected_arrival_at DATETIME,
  IN p_note VARCHAR(255),
  OUT p_package_movement_id INT
)
    SQL SECURITY INVOKER
BEGIN
  DECLARE v_latest_event_name VARCHAR(80) DEFAULT NULL;
  DECLARE v_latest_is_final TINYINT DEFAULT 0;
  DECLARE v_latest_from_facility_id INT DEFAULT NULL;
  DECLARE v_latest_to_facility_id INT DEFAULT NULL;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET p_package_movement_id = NULL;
  START TRANSACTION;

  SELECT met.event_type_name,
         ps.is_final_status,
         pm.from_facility_id,
         pm.to_facility_id
  INTO v_latest_event_name,
       v_latest_is_final,
       v_latest_from_facility_id,
       v_latest_to_facility_id
  FROM `package_movement` pm
  JOIN `package_movement_event_type` met
    ON met.package_movement_event_type_id = pm.package_movement_event_type_id
  JOIN `package_status` ps
    ON ps.package_status_id = pm.package_status_id
  WHERE pm.package_id = p_package_id
  ORDER BY pm.event_timestamp DESC, pm.package_movement_id DESC
  LIMIT 1
  FOR UPDATE;

  IF v_latest_event_name IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package must have an existing movement before receiving.';
  END IF;

  IF v_latest_is_final = 1 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot receive a package in a final status.';
  END IF;

  IF v_latest_event_name <> 'Sent To Facility' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Latest movement must be Sent To Facility before receiving at a facility.';
  END IF;

  IF v_latest_from_facility_id <> p_from_facility_id
     OR v_latest_to_facility_id <> p_to_facility_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Receive from/to facilities do not match the latest transfer.';
  END IF;

  CALL `RecordPackageMovement`(
    p_package_id,
    'Arrived At Facility',
    NULL,
    p_to_facility_id,
    p_from_facility_id,
    p_to_facility_id,
    p_processed_by_employee_id,
    p_arrived_at,
    p_expected_arrival_at,
    NULL,
    COALESCE(p_note, 'Package received at destination facility.'),
    p_package_movement_id
  );

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `RecentWrongSalaries` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `RecentWrongSalaries`()
BEGIN
    SELECT
        e.employee_id AS employee_id,
        e.full_name AS employee_name,
        e.salary AS employee_salary,
        e.updated_at AS employee_updated_at,
        m.employee_id AS manager_employee_id,
        m.full_name AS manager_name,
        m.salary AS manager_salary
    FROM employee e
    JOIN employee m
        ON e.manager_employee_id = m.employee_id
    WHERE e.salary > m.salary
      AND e.updated_at >= NOW() - INTERVAL 7 DAY;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `RecordPackageMovement` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `RecordPackageMovement`(
  IN p_package_id INT,
  IN p_event_type_name VARCHAR(80),
  IN p_package_status_name VARCHAR(30),
  IN p_facility_id INT,
  IN p_from_facility_id INT,
  IN p_to_facility_id INT,
  IN p_processed_by_employee_id INT,
  IN p_event_timestamp DATETIME,
  IN p_expected_event_at DATETIME,
  IN p_delay_reason VARCHAR(255),
  IN p_movement_note VARCHAR(255),
  OUT p_package_movement_id INT
)
    SQL SECURITY INVOKER
BEGIN
  DECLARE v_event_type_id INT DEFAULT NULL;
  DECLARE v_default_status_name VARCHAR(30) DEFAULT NULL;
  DECLARE v_effective_status_name VARCHAR(30) DEFAULT NULL;
  DECLARE v_package_status_id INT DEFAULT NULL;
  DECLARE v_count INT DEFAULT 0;
  DECLARE v_event_timestamp DATETIME DEFAULT NULL;
  DECLARE v_package_received_date DATETIME DEFAULT NULL;
  DECLARE v_current_status_final TINYINT DEFAULT 0;
  DECLARE v_latest_event_timestamp DATETIME DEFAULT NULL;
  DECLARE v_effective_facility_id INT DEFAULT NULL;

  DECLARE v_is_entry_event TINYINT DEFAULT 0;
  DECLARE v_is_exit_event TINYINT DEFAULT 0;
  DECLARE v_is_processing_event TINYINT DEFAULT 0;
  DECLARE v_is_delay_event TINYINT DEFAULT 0;
  DECLARE v_is_final_event TINYINT DEFAULT 0;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    RESIGNAL;
  END;

  SET p_package_movement_id = NULL;
  SET v_event_timestamp = COALESCE(p_event_timestamp, NOW());

  IF p_package_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'package_id is required.';
  END IF;

  IF p_event_type_name IS NULL OR TRIM(p_event_type_name) = '' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'event_type_name is required.';
  END IF;

  IF p_from_facility_id IS NOT NULL
     AND p_to_facility_id IS NOT NULL
     AND p_from_facility_id = p_to_facility_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'from_facility_id and to_facility_id must be different.';
  END IF;

  SELECT COUNT(*)
  INTO v_count
  FROM `package`
  WHERE package_id = p_package_id;

  IF v_count = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package does not exist.';
  END IF;

  SELECT
      p.received_date,
      ps.is_final_status
  INTO
      v_package_received_date,
      v_current_status_final
  FROM `package` p
  JOIN `package_status` ps
      ON p.package_status_id = ps.package_status_id
  WHERE p.package_id = p_package_id
  FOR UPDATE;

  IF v_current_status_final = 1 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot record movement for a package already in a final status.';
  END IF;

  IF v_event_timestamp < v_package_received_date THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Movement timestamp cannot be before package received_date.';
  END IF;

  SELECT MAX(event_timestamp)
  INTO v_latest_event_timestamp
  FROM `package_movement`
  WHERE package_id = p_package_id;

  IF v_latest_event_timestamp IS NOT NULL
     AND v_event_timestamp < v_latest_event_timestamp THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Movement timestamp cannot be earlier than the latest package movement.';
  END IF;

  SELECT
      package_movement_event_type_id,
      default_package_status_name,
      is_entry_event,
      is_exit_event,
      is_processing_event,
      is_delay_event,
      is_final_event
  INTO
      v_event_type_id,
      v_default_status_name,
      v_is_entry_event,
      v_is_exit_event,
      v_is_processing_event,
      v_is_delay_event,
      v_is_final_event
  FROM `package_movement_event_type`
  WHERE event_type_name = p_event_type_name
    AND is_active = 1
  LIMIT 1;

  IF v_event_type_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Movement event type does not exist or is inactive.';
  END IF;

  SET v_effective_status_name =
      COALESCE(NULLIF(TRIM(p_package_status_name), ''), v_default_status_name);

  IF v_effective_status_name IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'package_status_name is required when event type has no default.';
  END IF;

  SELECT package_status_id
  INTO v_package_status_id
  FROM `package_status`
  WHERE status_name = v_effective_status_name
    AND is_active = 1
  LIMIT 1;

  IF v_package_status_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package status does not exist or is inactive.';
  END IF;

  IF p_facility_id IS NOT NULL THEN
    SELECT COUNT(*)
    INTO v_count
    FROM `facility`
    WHERE facility_id = p_facility_id;

    IF v_count = 0 THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'facility_id does not exist.';
    END IF;
  END IF;

  IF p_from_facility_id IS NOT NULL THEN
    SELECT COUNT(*)
    INTO v_count
    FROM `facility`
    WHERE facility_id = p_from_facility_id;

    IF v_count = 0 THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'from_facility_id does not exist.';
    END IF;
  END IF;

  IF p_to_facility_id IS NOT NULL THEN
    SELECT COUNT(*)
    INTO v_count
    FROM `facility`
    WHERE facility_id = p_to_facility_id;

    IF v_count = 0 THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'to_facility_id does not exist.';
    END IF;
  END IF;

  IF p_processed_by_employee_id IS NOT NULL THEN
    SELECT COUNT(*)
    INTO v_count
    FROM `employee`
    WHERE employee_id = p_processed_by_employee_id;

    IF v_count = 0 THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'processed_by_employee_id does not exist.';
    END IF;
  END IF;

  IF v_is_entry_event = 1
     AND p_facility_id IS NULL
     AND p_to_facility_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Entry event requires facility_id or to_facility_id.';
  END IF;

  IF v_is_exit_event = 1
     AND p_facility_id IS NULL
     AND p_from_facility_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Exit event requires facility_id or from_facility_id.';
  END IF;

  IF v_is_exit_event = 1
     AND p_to_facility_id IS NOT NULL
     AND p_from_facility_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Transfer exit event requires from_facility_id.';
  END IF;

  IF v_is_entry_event = 1
     AND p_from_facility_id IS NOT NULL
     AND p_to_facility_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Transfer arrival event requires to_facility_id.';
  END IF;

  SET v_effective_facility_id = p_facility_id;

  IF v_effective_facility_id IS NULL THEN
    IF v_is_entry_event = 1 THEN
      SET v_effective_facility_id = COALESCE(p_to_facility_id, p_from_facility_id);
    ELSEIF v_is_exit_event = 1 THEN
      SET v_effective_facility_id = COALESCE(p_from_facility_id, p_to_facility_id);
    ELSE
      SET v_effective_facility_id = COALESCE(p_from_facility_id, p_to_facility_id);
    END IF;
  END IF;

  IF v_is_processing_event = 1
     AND v_effective_facility_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Processing event requires a facility.';
  END IF;

  INSERT INTO `package_movement` (
    package_id,
    package_movement_event_type_id,
    package_status_id,
    facility_id,
    from_facility_id,
    to_facility_id,
    processed_by_employee_id,
    event_timestamp,
    expected_event_at,
    delay_reason,
    movement_note
  )
  VALUES (
    p_package_id,
    v_event_type_id,
    v_package_status_id,
    v_effective_facility_id,
    p_from_facility_id,
    p_to_facility_id,
    p_processed_by_employee_id,
    v_event_timestamp,
    p_expected_event_at,
    p_delay_reason,
    p_movement_note
  );

  SET p_package_movement_id = LAST_INSERT_ID();

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `RecordPackageShippingCost` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `RecordPackageShippingCost`(
    IN p_package_id INT,
    IN p_actual_shipping_charge DECIMAL(8,2),
    IN p_charge_source VARCHAR(50)
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_package_count INT DEFAULT 0;

    IF p_package_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'package_id is required.';
    END IF;

    IF p_actual_shipping_charge IS NULL OR p_actual_shipping_charge < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'actual_shipping_charge must be zero or greater.';
    END IF;

    SELECT COUNT(*)
    INTO v_package_count
    FROM package
    WHERE package_id = p_package_id;

    IF v_package_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Package does not exist.';
    END IF;

    INSERT INTO shipping_cost (
        package_id,
        actual_shipping_charge,
        charge_source,
        charge_recorded_at
    )
    VALUES (
        p_package_id,
        p_actual_shipping_charge,
        COALESCE(NULLIF(TRIM(p_charge_source), ''), 'Web App'),
        NOW()
    )
    ON DUPLICATE KEY UPDATE
        actual_shipping_charge = VALUES(actual_shipping_charge),
        charge_source = VALUES(charge_source),
        charge_recorded_at = VALUES(charge_recorded_at),
        updated_at = NOW();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ReleasePackageForDelivery` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `ReleasePackageForDelivery`(
  IN p_package_id INT,
  IN p_facility_id INT,
  IN p_processed_by_employee_id INT,
  IN p_released_at DATETIME,
  IN p_expected_delivery_at DATETIME,
  IN p_note VARCHAR(255),
  OUT p_package_movement_id INT
)
    SQL SECURITY INVOKER
BEGIN
  DECLARE v_latest_event_name VARCHAR(80) DEFAULT NULL;
  DECLARE v_latest_is_final TINYINT DEFAULT 0;
  DECLARE v_latest_facility_id INT DEFAULT NULL;
  DECLARE v_service_type_name VARCHAR(30) DEFAULT NULL;
  DECLARE v_planned_destination_facility_id INT DEFAULT NULL;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET p_package_movement_id = NULL;
  START TRANSACTION;

  SELECT st.service_type_name
  INTO v_service_type_name
  FROM `package` p
  JOIN `service_type` st
    ON st.service_type_id = p.service_type_id
  WHERE p.package_id = p_package_id
  FOR UPDATE;

  IF v_service_type_name <> 'Delivery' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'ReleasePackageForDelivery is only valid for Delivery packages.';
  END IF;

  IF v_service_type_name IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package does not exist.';
  END IF;

  SELECT planned_destination_facility_id
  INTO v_planned_destination_facility_id
  FROM `package_route_plan`
  WHERE package_id = p_package_id;

  IF v_planned_destination_facility_id IS NOT NULL
     AND v_planned_destination_facility_id <> p_facility_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package is not being released from its planned destination facility.';
  END IF;

  IF v_planned_destination_facility_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package route plan is required before release for delivery.';
  END IF;

  SELECT met.event_type_name,
         ps.is_final_status,
         pm.facility_id
  INTO v_latest_event_name,
       v_latest_is_final,
       v_latest_facility_id
  FROM `package_movement` pm
  JOIN `package_movement_event_type` met
    ON met.package_movement_event_type_id = pm.package_movement_event_type_id
  JOIN `package_status` ps
    ON ps.package_status_id = pm.package_status_id
  WHERE pm.package_id = p_package_id
  ORDER BY pm.event_timestamp DESC, pm.package_movement_id DESC
  LIMIT 1
  FOR UPDATE;

  IF v_latest_is_final = 1 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot release a package in a final status.';
  END IF;

  IF v_latest_event_name NOT IN ('Arrived At Facility', 'Sorted At Facility') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Latest movement must be Arrived At Facility or Sorted At Facility before release for delivery.';
  END IF;

  IF v_latest_facility_id <> p_facility_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package is not currently at p_facility_id.';
  END IF;

  CALL `RecordPackageMovement`(
    p_package_id,
    'Out For Delivery',
    NULL,
    p_facility_id,
    p_facility_id,
    NULL,
    p_processed_by_employee_id,
    p_released_at,
    p_expected_delivery_at,
    NULL,
    COALESCE(p_note, 'Package released for final delivery.'),
    p_package_movement_id
  );

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ResolveRecipientTerritory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `ResolveRecipientTerritory`(
    IN p_recipient_city VARCHAR(60),
    IN p_recipient_state_code CHAR(2),
    IN p_recipient_zip_code VARCHAR(10),
    OUT p_recipient_territory_id INT
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_recipient_zip5 CHAR(5);
    DECLARE v_zip_exists INT DEFAULT 0;

    SET p_recipient_territory_id = NULL;
    SET v_recipient_zip5 = LEFT(TRIM(p_recipient_zip_code), 5);

    IF p_recipient_city IS NULL OR TRIM(p_recipient_city) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'recipient_city is required to resolve recipient territory.';
    END IF;

    IF p_recipient_state_code IS NULL OR CHAR_LENGTH(TRIM(p_recipient_state_code)) <> 2 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'recipient_state_code must be 2 characters.';
    END IF;

    IF v_recipient_zip5 IS NULL OR CHAR_LENGTH(v_recipient_zip5) <> 5 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'recipient ZIP code must contain at least 5 characters.';
    END IF;

    SELECT COUNT(*)
    INTO v_zip_exists
    FROM `zip_geo` zg
    WHERE zg.zip_code = v_recipient_zip5;

    IF v_zip_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'recipient ZIP code does not exist in zip_geo.';
    END IF;

    SELECT t.territory_id
    INTO p_recipient_territory_id
    FROM `territory` t
    WHERE t.state = UPPER(TRIM(p_recipient_state_code))
      AND UPPER(TRIM(t.city)) = UPPER(TRIM(p_recipient_city))
      AND t.zip_code = v_recipient_zip5
    ORDER BY COALESCE(t.county_zip_tot_ratio, 0) DESC, t.territory_id
    LIMIT 1;

    IF p_recipient_territory_id IS NULL THEN
        SELECT t.territory_id
        INTO p_recipient_territory_id
        FROM `territory` t
        WHERE t.state = UPPER(TRIM(p_recipient_state_code))
          AND t.zip_code = v_recipient_zip5
        ORDER BY COALESCE(t.county_zip_tot_ratio, 0) DESC, t.territory_id
        LIMIT 1;
    END IF;

    IF p_recipient_territory_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Unable to resolve recipient territory.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ResolveSenderTerritory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `ResolveSenderTerritory`(
    IN p_customer_id INT,
    OUT p_sender_territory_id INT
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_customer_exists INT DEFAULT 0;
    DECLARE v_zip_exists INT DEFAULT 0;
    DECLARE v_territory_exists INT DEFAULT 0;

    DECLARE v_sender_city VARCHAR(50);
    DECLARE v_sender_state_code CHAR(2);
    DECLARE v_sender_zip5 CHAR(5);

    SET p_sender_territory_id = NULL;

    IF p_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'customer_id is required.';
    END IF;

    SELECT COUNT(*)
    INTO v_customer_exists
    FROM customer
    WHERE customer_id = p_customer_id;

    IF v_customer_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer does not exist.';
    END IF;

    SELECT
        city,
        state_code,
        LEFT(TRIM(zip_code), 5)
    INTO
        v_sender_city,
        v_sender_state_code,
        v_sender_zip5
    FROM customer
    WHERE customer_id = p_customer_id
    LIMIT 1;

    IF v_sender_city IS NULL OR TRIM(v_sender_city) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer city is required to resolve sender territory.';
    END IF;

    IF v_sender_state_code IS NULL OR CHAR_LENGTH(TRIM(v_sender_state_code)) <> 2 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer state_code must be 2 characters.';
    END IF;

    IF v_sender_zip5 IS NULL OR CHAR_LENGTH(v_sender_zip5) <> 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer ZIP code must contain at least 5 digits.';
    END IF;

    SELECT COUNT(*)
    INTO v_zip_exists
    FROM zip_geo zg
    WHERE zg.zip_code = v_sender_zip5;

    IF v_zip_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer ZIP code does not exist in zip_geo.';
    END IF;

    SELECT COUNT(*)
    INTO v_territory_exists
    FROM territory t
    JOIN zip_geo zg
        ON zg.zip_code = t.zip_code
    WHERE t.state = UPPER(TRIM(v_sender_state_code))
      AND t.zip_code = v_sender_zip5;

    IF v_territory_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No sender territory found for customer state and ZIP.';
    END IF;

    SELECT t.territory_id
    INTO p_sender_territory_id
    FROM territory t
    JOIN zip_geo zg
        ON zg.zip_code = t.zip_code
    WHERE t.state = UPPER(TRIM(v_sender_state_code))
      AND UPPER(TRIM(t.city)) = UPPER(TRIM(v_sender_city))
      AND t.zip_code = v_sender_zip5
    ORDER BY
        COALESCE(t.county_zip_tot_ratio, 0) DESC,
        t.territory_id
    LIMIT 1;

    IF p_sender_territory_id IS NULL THEN
        SELECT t.territory_id
        INTO p_sender_territory_id
        FROM territory t
        JOIN zip_geo zg
            ON zg.zip_code = t.zip_code
        WHERE t.state = UPPER(TRIM(v_sender_state_code))
          AND t.zip_code = v_sender_zip5
        ORDER BY
            COALESCE(t.county_zip_tot_ratio, 0) DESC,
            t.territory_id
        LIMIT 1;
    END IF;

    IF p_sender_territory_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Unable to resolve sender territory.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `RetrievePackageFromLocker` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `RetrievePackageFromLocker`(
    IN p_locker_assignment_id INT,
    OUT p_package_id INT
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_assignment_exists INT DEFAULT 0;
    DECLARE v_package_link_count INT DEFAULT 0;
    DECLARE v_locker_id INT;
    DECLARE v_customer_id INT;
    DECLARE v_assigned_at DATETIME;
    DECLARE v_existing_retrieved_at DATETIME;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SET p_package_id = NULL;

    IF p_locker_assignment_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'locker_assignment_id is required.';
    END IF;

    SELECT COUNT(*)
    INTO v_assignment_exists
    FROM lockerassignment
    WHERE locker_assignment_id = p_locker_assignment_id;

    IF v_assignment_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Locker assignment does not exist.';
    END IF;

    SELECT
        locker_id,
        customer_id,
        assigned_at,
        retrieved_at
    INTO
        v_locker_id,
        v_customer_id,
        v_assigned_at,
        v_existing_retrieved_at
    FROM lockerassignment
    WHERE locker_assignment_id = p_locker_assignment_id
    FOR UPDATE;

    IF v_existing_retrieved_at IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Locker assignment has already been retrieved.';
    END IF;

    SELECT COUNT(*)
    INTO v_package_link_count
    FROM package_to_locker
    WHERE locker_assignment_id = p_locker_assignment_id;

    IF v_package_link_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No package is connected to this locker assignment.';
    END IF;

    SELECT package_id
    INTO p_package_id
    FROM package_to_locker
    WHERE locker_assignment_id = p_locker_assignment_id;

    UPDATE lockerassignment
    SET retrieved_at = NOW()
    WHERE locker_assignment_id = p_locker_assignment_id;

    DELETE FROM package_to_locker
    WHERE package_id = p_package_id;

    UPDATE smartlocker
    SET locker_status = 'Available',
        updated_at = NOW()
    WHERE locker_id = v_locker_id;

    INSERT INTO notifications (
        customer_id,
        package_id,
        notification_message,
        notification_date
    )
    VALUES (
        v_customer_id,
        p_package_id,
        CONCAT('Your package with ID ', p_package_id, ' has been retrieved from your locker.'),
        NOW()
    );

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `rollback_date_key_view_changes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `rollback_date_key_view_changes`(IN p_backup_label varchar(100))
BEGIN
    DECLARE done int DEFAULT 0;
    DECLARE v_view_name varchar(64);
    DECLARE v_view_definition longtext;
    DECLARE v_security_type varchar(20);
    DECLARE v_check_option varchar(20);
    DECLARE v_sql longtext;

    DECLARE cur CURSOR FOR
        SELECT `view_name`, `view_definition`, `security_type`, `check_option`
        FROM `bi_view_definition_backup`
        WHERE `backup_label` = p_backup_label
          AND `view_schema` = DATABASE()
        ORDER BY FIELD(`view_name`, 'dim_date'), `view_name`;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    IF (SELECT COUNT(*)
        FROM `bi_view_definition_backup`
        WHERE `backup_label` = p_backup_label
          AND `view_schema` = DATABASE()) <> 14 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Rollback backup label does not contain the expected 14 view definitions.';
    END IF;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_view_name, v_view_definition, v_security_type, v_check_option;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        SET v_sql = CONCAT(
            'CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY ', v_security_type,
            ' VIEW `', REPLACE(v_view_name, '`', '``'), '` AS ',
            v_view_definition,
            CASE
                WHEN v_check_option = 'NONE' THEN ''
                WHEN v_check_option = 'LOCAL' THEN ' WITH LOCAL CHECK OPTION'
                WHEN v_check_option = 'CASCADED' THEN ' WITH CASCADED CHECK OPTION'
                ELSE ''
            END
        );

        SET @restore_view_sql = v_sql;
        PREPARE restore_stmt FROM @restore_view_sql;
        EXECUTE restore_stmt;
        DEALLOCATE PREPARE restore_stmt;
    END LOOP;
    CLOSE cur;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `seed_delivery_package_movements` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `seed_delivery_package_movements`(IN p_batch_count INT)
BEGIN
    DECLARE v_batch INT DEFAULT 0;

    SET v_batch = 0;
    WHILE v_batch < p_batch_count DO
        -- Received at retail office.
        INSERT INTO package_movement
        (
            package_id,
            package_movement_event_type_id,
            package_status_id,
            facility_id,
            from_facility_id,
            to_facility_id,
            processed_by_employee_id,
            event_timestamp,
            expected_event_at,
            delay_minutes,
            delay_reason,
            movement_note
        )
        SELECT
            t.package_id,
            @evt_received_id,
            @status_received_id,
            t.origin_facility_id,
            NULL,
            t.origin_facility_id,
            t.intake_employee_id,
            t.t_received,
            t.t_received,
            0,
            NULL,
            CONCAT(
                'Package accepted for Delivery service at retail office. Customer destination: ',
                COALESCE(t.customer_street_address, 'Unknown address'), ', ',
                COALESCE(t.customer_city, 'Unknown city'), ', ',
                COALESCE(t.customer_state_code, 'Unknown state'), ' ',
                COALESCE(t.customer_zip_code, 'Unknown ZIP'), '.'
            )
        FROM tmp_delivery_packages t
        WHERE t.origin_facility_id IS NOT NULL
          AND MOD(t.package_id, p_batch_count) = v_batch;

        SET v_batch = v_batch + 1;
    END WHILE;

    SET v_batch = 0;
    WHILE v_batch < p_batch_count DO
        -- Sent from retail office to RPDC/RDPC.
        INSERT INTO package_movement
        (
            package_id,
            package_movement_event_type_id,
            package_status_id,
            facility_id,
            from_facility_id,
            to_facility_id,
            processed_by_employee_id,
            event_timestamp,
            expected_event_at,
            delay_minutes,
            delay_reason,
            movement_note
        )
        SELECT
            t.package_id,
            @evt_sent_id,
            CASE WHEN t.current_status_name = 'Shipped' THEN @status_shipped_id ELSE @status_in_transit_id END,
            t.origin_facility_id,
            t.origin_facility_id,
            t.rdpc_facility_id,
            t.intake_employee_id,
            t.t_sent_from_retail,
            DATE_ADD(t.t_received, INTERVAL 6 HOUR),
            0,
            NULL,
            'Package dispatched from retail office to RPDC/RDPC for regional processing.'
        FROM tmp_delivery_packages t
        WHERE t.origin_facility_id IS NOT NULL
          AND t.current_status_name IN ('Processing', 'Shipped', 'In Transit', 'Delayed', 'Out For Delivery', 'Delivered', 'Returned')
          AND MOD(t.package_id, p_batch_count) = v_batch;

        SET v_batch = v_batch + 1;
    END WHILE;

    SET v_batch = 0;
    WHILE v_batch < p_batch_count DO
        -- Arrived at RPDC/RDPC after 24 hours.
        INSERT INTO package_movement
        (
            package_id,
            package_movement_event_type_id,
            package_status_id,
            facility_id,
            from_facility_id,
            to_facility_id,
            processed_by_employee_id,
            event_timestamp,
            expected_event_at,
            delay_minutes,
            delay_reason,
            movement_note
        )
        SELECT
            t.package_id,
            @evt_arrived_id,
            @status_in_transit_id,
            t.rdpc_facility_id,
            t.origin_facility_id,
            t.rdpc_facility_id,
            t.rdpc_employee_id,
            t.t_arrived_rdpc,
            DATE_ADD(t.t_received, INTERVAL 24 HOUR),
            0,
            NULL,
            'Package arrived at RPDC/RDPC approximately 24 hours after retail acceptance.'
        FROM tmp_delivery_packages t
        WHERE t.origin_facility_id IS NOT NULL
          AND t.current_status_name IN ('Processing', 'Shipped', 'In Transit', 'Delayed', 'Out For Delivery', 'Delivered', 'Returned')
          AND MOD(t.package_id, p_batch_count) = v_batch;

        SET v_batch = v_batch + 1;
    END WHILE;

    SET v_batch = 0;
    WHILE v_batch < p_batch_count DO
        -- Sorted at RPDC/RDPC.
        INSERT INTO package_movement
        (
            package_id,
            package_movement_event_type_id,
            package_status_id,
            facility_id,
            from_facility_id,
            to_facility_id,
            processed_by_employee_id,
            event_timestamp,
            expected_event_at,
            delay_minutes,
            delay_reason,
            movement_note
        )
        SELECT
            t.package_id,
            @evt_sorted_id,
            @status_processing_id,
            t.rdpc_facility_id,
            NULL,
            NULL,
            t.rdpc_employee_id,
            t.t_sorted_rdpc,
            DATE_ADD(t.t_arrived_rdpc, INTERVAL 2 HOUR),
            0,
            NULL,
            'Package sorted and processed at RPDC/RDPC for final-mile routing.'
        FROM tmp_delivery_packages t
        WHERE t.origin_facility_id IS NOT NULL
          AND t.current_status_name IN ('Processing', 'Shipped', 'In Transit', 'Delayed', 'Out For Delivery', 'Delivered', 'Returned')
          AND MOD(t.package_id, p_batch_count) = v_batch;

        SET v_batch = v_batch + 1;
    END WHILE;

    SET v_batch = 0;
    WHILE v_batch < p_batch_count DO
        -- Delayed exception event.
        INSERT INTO package_movement
        (
            package_id,
            package_movement_event_type_id,
            package_status_id,
            facility_id,
            from_facility_id,
            to_facility_id,
            processed_by_employee_id,
            event_timestamp,
            expected_event_at,
            delay_minutes,
            delay_reason,
            movement_note
        )
        SELECT
            t.package_id,
            @evt_delayed_id,
            @status_delayed_id,
            t.rdpc_facility_id,
            NULL,
            NULL,
            t.rdpc_employee_id,
            DATE_ADD(t.t_sorted_rdpc, INTERVAL 3 HOUR),
            t.expected_delivery_at,
            t.simulated_delay_minutes,
            CASE
                WHEN MOD(t.package_id, 4) = 0 THEN 'High package volume at RPDC/RDPC'
                WHEN MOD(t.package_id, 4) = 1 THEN 'Weather-related transportation delay'
                WHEN MOD(t.package_id, 4) = 2 THEN 'Address verification required'
                ELSE 'Route capacity delay'
            END,
            'Package delayed during RPDC/RDPC processing or final-mile staging.'
        FROM tmp_delivery_packages t
        WHERE t.origin_facility_id IS NOT NULL
          AND t.current_status_name = 'Delayed'
          AND MOD(t.package_id, p_batch_count) = v_batch;

        SET v_batch = v_batch + 1;
    END WHILE;

    SET v_batch = 0;
    WHILE v_batch < p_batch_count DO
        -- Departed RPDC/RDPC for delivery route.
        INSERT INTO package_movement
        (
            package_id,
            package_movement_event_type_id,
            package_status_id,
            facility_id,
            from_facility_id,
            to_facility_id,
            processed_by_employee_id,
            event_timestamp,
            expected_event_at,
            delay_minutes,
            delay_reason,
            movement_note
        )
        SELECT
            t.package_id,
            @evt_departed_id,
            CASE WHEN t.current_status_name = 'Shipped' THEN @status_shipped_id ELSE @status_in_transit_id END,
            t.rdpc_facility_id,
            t.rdpc_facility_id,
            NULL,
            t.rdpc_employee_id,
            t.t_departed_rdpc,
            DATE_SUB(t.expected_delivery_at, INTERVAL 4 HOUR),
            0,
            NULL,
            'Package departed RPDC/RDPC for final-mile delivery route.'
        FROM tmp_delivery_packages t
        WHERE t.origin_facility_id IS NOT NULL
          AND t.current_status_name IN ('Shipped', 'In Transit', 'Out For Delivery', 'Delivered', 'Returned')
          AND MOD(t.package_id, p_batch_count) = v_batch;

        SET v_batch = v_batch + 1;
    END WHILE;

    SET v_batch = 0;
    WHILE v_batch < p_batch_count DO
        -- Out for delivery.
        INSERT INTO package_movement
        (
            package_id,
            package_movement_event_type_id,
            package_status_id,
            facility_id,
            from_facility_id,
            to_facility_id,
            processed_by_employee_id,
            event_timestamp,
            expected_event_at,
            delay_minutes,
            delay_reason,
            movement_note
        )
        SELECT
            t.package_id,
            @evt_out_for_delivery_id,
            @status_out_for_delivery_id,
            t.rdpc_facility_id,
            t.rdpc_facility_id,
            NULL,
            t.rdpc_employee_id,
            t.t_out_for_delivery,
            DATE_SUB(t.expected_delivery_at, INTERVAL 2 HOUR),
            0,
            NULL,
            CONCAT(
                'Package is out for delivery to customer address: ',
                COALESCE(t.customer_street_address, 'Unknown address'), ', ',
                COALESCE(t.customer_city, 'Unknown city'), ', ',
                COALESCE(t.customer_state_code, 'Unknown state'), ' ',
                COALESCE(t.customer_zip_code, 'Unknown ZIP'), '.'
            )
        FROM tmp_delivery_packages t
        WHERE t.origin_facility_id IS NOT NULL
          AND t.current_status_name IN ('Out For Delivery', 'Delivered')
          AND MOD(t.package_id, p_batch_count) = v_batch;

        SET v_batch = v_batch + 1;
    END WHILE;

    SET v_batch = 0;
    WHILE v_batch < p_batch_count DO
        -- Delivered final event.
        INSERT INTO package_movement
        (
            package_id,
            package_movement_event_type_id,
            package_status_id,
            facility_id,
            from_facility_id,
            to_facility_id,
            processed_by_employee_id,
            event_timestamp,
            expected_event_at,
            delay_minutes,
            delay_reason,
            movement_note
        )
        SELECT
            t.package_id,
            @evt_delivered_id,
            @status_delivered_id,
            t.rdpc_facility_id,
            t.rdpc_facility_id,
            NULL,
            t.rdpc_employee_id,
            t.t_delivered_customer,
            t.expected_delivery_at,
            CASE
                WHEN t.t_delivered_customer > t.expected_delivery_at THEN TIMESTAMPDIFF(MINUTE, t.expected_delivery_at, t.t_delivered_customer)
                ELSE 0
            END,
            CASE
                WHEN t.t_delivered_customer > t.expected_delivery_at THEN 'Final-mile route completed after expected delivery window'
                ELSE NULL
            END,
            CONCAT(
                'Package delivered to customer address: ',
                COALESCE(t.customer_street_address, 'Unknown address'), ', ',
                COALESCE(t.customer_city, 'Unknown city'), ', ',
                COALESCE(t.customer_state_code, 'Unknown state'), ' ',
                COALESCE(t.customer_zip_code, 'Unknown ZIP'), '.'
            )
        FROM tmp_delivery_packages t
        WHERE t.origin_facility_id IS NOT NULL
          AND t.current_status_name = 'Delivered'
          AND MOD(t.package_id, p_batch_count) = v_batch;

        SET v_batch = v_batch + 1;
    END WHILE;

    SET v_batch = 0;
    WHILE v_batch < p_batch_count DO
        -- Returned final exception.
        INSERT INTO package_movement
        (
            package_id,
            package_movement_event_type_id,
            package_status_id,
            facility_id,
            from_facility_id,
            to_facility_id,
            processed_by_employee_id,
            event_timestamp,
            expected_event_at,
            delay_minutes,
            delay_reason,
            movement_note
        )
        SELECT
            t.package_id,
            @evt_tracking_scan_id,
            @status_returned_id,
            t.rdpc_facility_id,
            NULL,
            NULL,
            t.rdpc_employee_id,
            DATE_ADD(t.t_departed_rdpc, INTERVAL 3 HOUR),
            t.expected_delivery_at,
            0,
            NULL,
            'Package marked returned after delivery route exception or failed delivery attempt.'
        FROM tmp_delivery_packages t
        WHERE t.origin_facility_id IS NOT NULL
          AND t.current_status_name = 'Returned'
          AND MOD(t.package_id, p_batch_count) = v_batch;

        SET v_batch = v_batch + 1;
    END WHILE;

    SET v_batch = 0;
    WHILE v_batch < p_batch_count DO
        -- Cancelled final exception.
        INSERT INTO package_movement
        (
            package_id,
            package_movement_event_type_id,
            package_status_id,
            facility_id,
            from_facility_id,
            to_facility_id,
            processed_by_employee_id,
            event_timestamp,
            expected_event_at,
            delay_minutes,
            delay_reason,
            movement_note
        )
        SELECT
            t.package_id,
            @evt_tracking_scan_id,
            @status_cancelled_id,
            t.origin_facility_id,
            NULL,
            NULL,
            t.intake_employee_id,
            DATE_ADD(t.t_received, INTERVAL 1 HOUR),
            DATE_ADD(t.t_received, INTERVAL 1 HOUR),
            0,
            NULL,
            'Delivery service request cancelled before transfer to RPDC/RDPC.'
        FROM tmp_delivery_packages t
        WHERE t.origin_facility_id IS NOT NULL
          AND t.current_status_name = 'Cancelled'
          AND MOD(t.package_id, p_batch_count) = v_batch;

        SET v_batch = v_batch + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SelectWrongSalaries` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `SelectWrongSalaries`()
BEGIN
    SELECT
        e.employee_id AS employee_id,
        e.full_name AS employee_name,
        e.salary AS employee_salary,
        m.employee_id AS manager_employee_id,
        m.full_name AS manager_name,
        m.salary AS manager_salary
    FROM employee e
    JOIN employee m
        ON e.manager_employee_id = m.employee_id
    WHERE e.salary > m.salary;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_recalculate_shipping_cost_components` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `sp_recalculate_shipping_cost_components`(
    IN p_package_id INT
)
BEGIN
    UPDATE `shipping_cost` sc
    JOIN `package` p
        ON p.package_id = sc.package_id
    LEFT JOIN (
        SELECT
            pm.package_id,
            COUNT(*) AS movement_count,
            MAX(
                CASE
                    WHEN met.event_type_name = 'Delivered'
                         OR ps.status_name = 'Delivered'
                    THEN 1
                    ELSE 0
                END
            ) AS has_delivered_event
        FROM `package_movement` pm
        JOIN `package_movement_event_type` met
            ON met.package_movement_event_type_id = pm.package_movement_event_type_id
        JOIN `package_status` ps
            ON ps.package_status_id = pm.package_status_id
        WHERE pm.package_id = p_package_id
        GROUP BY pm.package_id
    ) ms
        ON ms.package_id = sc.package_id
    SET
        sc.material_cost = ROUND(
            (COALESCE(p.width_in, 0) * 0.05)
            + (COALESCE(p.length_in, 0) * 0.10)
            + (COALESCE(p.height_in, 0) * 0.15),
            2
        ),
        sc.transportation_cost = ROUND(
            (COALESCE(ms.movement_count, 0) * 0.10)
            + CASE WHEN COALESCE(ms.has_delivered_event, 0) = 1 THEN 0.50 ELSE 0.00 END,
            2
        )
    WHERE sc.package_id = p_package_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `TransferPackageBetweenFacilities` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `TransferPackageBetweenFacilities`(
  IN p_package_id INT,
  IN p_from_facility_id INT,
  IN p_to_facility_id INT,
  IN p_processed_by_employee_id INT,
  IN p_departed_at DATETIME,
  IN p_expected_arrival_at DATETIME,
  IN p_arrived_at DATETIME,
  IN p_note VARCHAR(255),
  OUT p_departure_movement_id INT,
  OUT p_arrival_movement_id INT
)
    SQL SECURITY INVOKER
BEGIN
  DECLARE v_latest_event_name VARCHAR(80) DEFAULT NULL;
  DECLARE v_latest_status_name VARCHAR(30) DEFAULT NULL;
  DECLARE v_latest_is_final TINYINT DEFAULT 0;
  DECLARE v_latest_facility_id INT DEFAULT NULL;
  DECLARE v_latest_to_facility_id INT DEFAULT NULL;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET p_departure_movement_id = NULL;
  SET p_arrival_movement_id = NULL;

  START TRANSACTION;

  IF p_from_facility_id IS NULL OR p_to_facility_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Both from_facility_id and to_facility_id are required.';
  END IF;

  IF p_from_facility_id = p_to_facility_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot transfer a package to the same facility.';
  END IF;

  IF p_arrived_at IS NOT NULL
     AND p_arrived_at < COALESCE(p_departed_at, NOW()) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Arrival time cannot be before departure time.';
  END IF;

  SELECT met.event_type_name,
         ps.status_name,
         ps.is_final_status,
         pm.facility_id,
         pm.to_facility_id
  INTO v_latest_event_name,
       v_latest_status_name,
       v_latest_is_final,
       v_latest_facility_id,
       v_latest_to_facility_id
  FROM `package_movement` pm
  JOIN `package_movement_event_type` met
    ON met.package_movement_event_type_id = pm.package_movement_event_type_id
  JOIN `package_status` ps
    ON ps.package_status_id = pm.package_status_id
  WHERE pm.package_id = p_package_id
  ORDER BY pm.event_timestamp DESC, pm.package_movement_id DESC
  LIMIT 1
  FOR UPDATE;

  IF v_latest_event_name IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package must have an existing movement before it can be transferred.';
  END IF;

  IF v_latest_is_final = 1 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot transfer a package in a final status.';
  END IF;

  IF COALESCE(v_latest_facility_id, v_latest_to_facility_id) <> p_from_facility_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Package is not currently at from_facility_id.';
  END IF;

  IF v_latest_event_name IN ('Sent To Facility', 'Out For Delivery', 'Delivered') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Latest movement is not eligible for facility transfer.';
  END IF;

  CALL `RecordPackageMovement`(
    p_package_id,
    'Sent To Facility',
    NULL,
    p_from_facility_id,
    p_from_facility_id,
    p_to_facility_id,
    p_processed_by_employee_id,
    COALESCE(p_departed_at, NOW()),
    p_expected_arrival_at,
    NULL,
    COALESCE(p_note, 'Package sent to another facility.'),
    p_departure_movement_id
  );

  IF p_arrived_at IS NOT NULL THEN
    CALL `RecordPackageMovement`(
      p_package_id,
      'Arrived At Facility',
      NULL,
      p_to_facility_id,
      p_from_facility_id,
      p_to_facility_id,
      p_processed_by_employee_id,
      p_arrived_at,
      p_expected_arrival_at,
      NULL,
      'Package arrived at destination facility.',
      p_arrival_movement_id
    );
  END IF;

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `u_UpdatingCustomerTerritoryIDs` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `u_UpdatingCustomerTerritoryIDs`()
    SQL SECURITY INVOKER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    UPDATE `customer` c
    JOIN `territory` t
      ON t.`state` = UPPER(TRIM(c.`state_code`))
     AND t.`city` = UPPER(TRIM(c.`city`))
     AND t.`county` = TRIM(c.`county`)
     AND t.`zip_code` = LEFT(TRIM(c.`zip_code`), 5)
    SET c.`territory_id` = t.`territory_id`,
        c.`updated_at` = CURRENT_TIMESTAMP
    WHERE c.`territory_id` IS NULL
      AND NULLIF(TRIM(c.`zip_code`), '') IS NOT NULL
      AND NULLIF(TRIM(c.`city`), '') IS NOT NULL
      AND NULLIF(TRIM(c.`county`), '') IS NOT NULL
      AND UPPER(TRIM(c.`state_code`)) = 'TX'
      AND CHAR_LENGTH(LEFT(TRIM(c.`zip_code`), 5)) = 5;

    COMMIT;

    SELECT
        HEX(c.`customer_id`) AS customer_id_hex,
        c.`first_name`,
        c.`middle_initial`,
        c.`last_name`,
        c.`street_address`,
        c.`city`,
        c.`county`,
        c.`state_code`,
        c.`zip_code`,
        LEFT(TRIM(c.`zip_code`), 5) AS normalized_zip_code,
        CASE
            WHEN c.`zip_code` IS NULL OR TRIM(c.`zip_code`) = ''
                THEN 'missing ZIP'
            WHEN c.`city` IS NULL OR TRIM(c.`city`) = ''
                THEN 'missing city'
            WHEN c.`state_code` IS NULL OR UPPER(TRIM(c.`state_code`)) <> 'TX'
                THEN 'non-TX state'
            WHEN NOT EXISTS (
                SELECT 1
                FROM `territory` tz
                WHERE tz.`zip_code` = LEFT(TRIM(c.`zip_code`), 5)
            )
                THEN 'ZIP not tracked'
            ELSE 'city/county/ZIP combination not tracked'
        END AS validation_reason
    FROM `customer` c
    WHERE c.`territory_id` IS NULL
    ORDER BY
        validation_reason,
        c.`state_code`,
        normalized_zip_code,
        c.`city`,
        c.`county`,
        customer_id_hex;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ValidateCustomerExists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `ValidateCustomerExists`(
    IN p_customer_id INT
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_customer_exists INT DEFAULT 0;

    IF p_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'customer_id is required.';
    END IF;

    SELECT COUNT(*)
    INTO v_customer_exists
    FROM customer
    WHERE customer_id = p_customer_id;

    IF v_customer_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer does not exist.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v_update_facility_territory_ids` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `v_update_facility_territory_ids`()
BEGIN
    UPDATE facility f
    LEFT JOIN territory exact_match
        ON exact_match.state = UPPER(TRIM(f.state_code))
       AND exact_match.city = UPPER(TRIM(f.city))
       AND exact_match.county = TRIM(f.county)
       AND exact_match.zip_code = LEFT(TRIM(f.zip_code), 5)

    LEFT JOIN (
        SELECT state, city, zip_code, MIN(territory_id) AS territory_id
        FROM territory
        GROUP BY state, city, zip_code
        HAVING COUNT(*) = 1
    ) city_zip_match
        ON city_zip_match.state = UPPER(TRIM(f.state_code))
       AND city_zip_match.city = UPPER(TRIM(f.city))
       AND city_zip_match.zip_code = LEFT(TRIM(f.zip_code), 5)

    LEFT JOIN (
        SELECT state, county, zip_code, MIN(territory_id) AS territory_id
        FROM territory
        GROUP BY state, county, zip_code
        HAVING COUNT(*) = 1
    ) county_zip_match
        ON county_zip_match.state = UPPER(TRIM(f.state_code))
       AND county_zip_match.county = TRIM(f.county)
       AND county_zip_match.zip_code = LEFT(TRIM(f.zip_code), 5)

    SET f.territory_id = COALESCE(
        exact_match.territory_id,
        city_zip_match.territory_id,
        county_zip_match.territory_id
    )
    WHERE REGEXP_LIKE(TRIM(f.zip_code), '^[0-9]{5}')
      AND COALESCE(
            exact_match.territory_id,
            city_zip_match.territory_id,
            county_zip_match.territory_id
          ) IS NOT NULL;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v_ValidateCustomerTerritoryID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`ryan`@`%` PROCEDURE `v_ValidateCustomerTerritoryID`()
    READS SQL DATA
    SQL SECURITY INVOKER
BEGIN
    SELECT
        HEX(c.`customer_id`) AS customer_id_hex,
        c.`first_name`,
        c.`middle_initial`,
        c.`last_name`,
        c.`street_address`,
        c.`city` AS customer_city,
        c.`county` AS customer_county,
        c.`state_code` AS customer_state_code,
        c.`zip_code` AS customer_zip_code,
        UPPER(TRIM(c.`state_code`)) AS normalized_state_code,
        UPPER(TRIM(c.`city`)) AS normalized_city,
        TRIM(c.`county`) AS normalized_county,
        LEFT(TRIM(c.`zip_code`), 5) AS normalized_zip_code,
        c.`territory_id` AS assigned_territory_id,
        assigned_t.`state` AS assigned_state,
        assigned_t.`city` AS assigned_city,
        assigned_t.`county` AS assigned_county,
        assigned_t.`zip_code` AS assigned_zip_code,
        implied_t.`territory_id` AS implied_territory_id,
        implied_t.`state` AS implied_state,
        implied_t.`city` AS implied_city,
        implied_t.`county` AS implied_county,
        implied_t.`zip_code` AS implied_zip_code,
        CASE
            WHEN assigned_t.`territory_id` IS NULL
                THEN 'assigned territory missing'
            WHEN c.`zip_code` IS NULL OR TRIM(c.`zip_code`) = ''
                THEN 'missing ZIP'
            WHEN c.`city` IS NULL OR TRIM(c.`city`) = ''
                THEN 'missing city'
            WHEN c.`county` IS NULL OR TRIM(c.`county`) = ''
                THEN 'missing county'
            WHEN c.`state_code` IS NULL OR UPPER(TRIM(c.`state_code`)) <> 'TX'
                THEN 'non-TX state'
            WHEN implied_t.`territory_id` IS NULL
                THEN 'derived territory missing'
            ELSE 'territory mismatch'
        END AS validation_reason
    FROM `customer` c
    LEFT JOIN `territory` assigned_t
      ON assigned_t.`territory_id` = c.`territory_id`
    LEFT JOIN `territory` implied_t
      ON implied_t.`state` = UPPER(TRIM(c.`state_code`))
     AND implied_t.`city` = UPPER(TRIM(c.`city`))
     AND implied_t.`county` = TRIM(c.`county`)
     AND implied_t.`zip_code` = LEFT(TRIM(c.`zip_code`), 5)
    WHERE c.`territory_id` IS NOT NULL
      AND (
          assigned_t.`territory_id` IS NULL
          OR implied_t.`territory_id` IS NULL
          OR assigned_t.`territory_id` <> implied_t.`territory_id`
      )
    ORDER BY
        validation_reason,
        c.`state_code`,
        normalized_zip_code,
        c.`city`,
        c.`county`,
        customer_id_hex;
END ;;
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

-- Dump completed on 2026-06-09 21:47:18
