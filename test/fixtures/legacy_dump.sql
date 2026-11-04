-- MySQL dump 10.13  Distrib 5.5.62, for linux-glibc2.12 (x86_64)
--
-- Host: 127.0.0.1    Database: production
-- ------------------------------------------------------
-- Server version	5.5.62

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `dances`
--

DROP TABLE IF EXISTS `dances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dances` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `robot_name` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `robot_still` blob,
  `guid` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `move` text CHARACTER SET latin1,
  `votes` int(11) DEFAULT '0',
  `date_created` int(11) DEFAULT NULL,
  `date_updated` int(11) DEFAULT NULL,
  `is_entered_into_comp` int(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=113 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dances`
--

LOCK TABLES `dances` WRITE;
/*!40000 ALTER TABLE `dances` DISABLE KEYS */;
INSERT INTO `dances` VALUES (101,'Lieutenant Jigalot Code','','6aea71ac6af51','{\"masterTempo\":\"1\",\"neck_tempoMultiplier\":\"1\",\"neck_upDown\":\"2.6\",\"neck_leftRight\":\"9.4\",\"rightForearm_reverse\":\"\",\"rightForearm_tempoMultiplier\":\"1\",\"rightForearm_amount\":\"33\",\"rightForearm_angle\":\"0\",\"rightUpperArm_reverse\":\"\",\"rightUpperArm_tempoMultiplier\":\"0.5\",\"rightUpperArm_amount\":\"98\",\"rightUpperArm_angle\":\"129\",\"leftForearm_reverse\":\"1\",\"leftForearm_tempoMultiplier\":\"1\",\"leftForearm_amount\":\"37\",\"leftForearm_angle\":\"0\",\"leftUpperArm_reverse\":\"1\",\"leftUpperArm_tempoMultiplier\":\"0.5\",\"leftUpperArm_amount\":\"105\",\"leftUpperArm_angle\":\"146\",\"hips_tempoMultiplier\":\"1\",\"hips_upDown\":\"20\",\"hips_leftRight\":\"6.4\"}',0,1793749420,1793749420,0),(102,'Señor Groove Byte',0x89504E470D0A1A0A0027225C0A,'5281068541414','{\"masterTempo\":\"0.5\",\"neck_tempoMultiplier\":\"1\",\"neck_upDown\":\"2.6\",\"neck_leftRight\":\"9.4\",\"rightForearm_reverse\":\"\",\"rightForearm_tempoMultiplier\":\"1\",\"rightForearm_amount\":\"33\",\"rightForearm_angle\":\"0\",\"rightUpperArm_reverse\":\"\",\"rightUpperArm_tempoMultiplier\":\"0.5\",\"rightUpperArm_amount\":\"98\",\"rightUpperArm_angle\":\"129\",\"leftForearm_reverse\":\"1\",\"leftForearm_tempoMultiplier\":\"1\",\"leftForearm_amount\":\"37\",\"leftForearm_angle\":\"0\",\"leftUpperArm_reverse\":\"1\",\"leftUpperArm_tempoMultiplier\":\"0.5\",\"leftUpperArm_amount\":\"105\",\"leftUpperArm_angle\":\"146\",\"hips_tempoMultiplier\":\"1\",\"hips_upDown\":\"20\",\"hips_leftRight\":\"6.4\"}',3,1384187525,1384190000,1),(103,'Captain D\'Artagnan \\ Slash','','5281029d56337','{\"masterTempo\":\"1\",\"neck_tempoMultiplier\":\"1\",\"neck_upDown\":\"2.6\",\"neck_leftRight\":\"9.4\",\"rightForearm_reverse\":\"\",\"rightForearm_tempoMultiplier\":\"1\",\"rightForearm_amount\":\"33\",\"rightForearm_angle\":\"0\",\"rightUpperArm_reverse\":\"\",\"rightUpperArm_tempoMultiplier\":\"0.5\",\"rightUpperArm_amount\":\"98\",\"rightUpperArm_angle\":\"129\",\"leftForearm_reverse\":\"1\",\"leftForearm_tempoMultiplier\":\"1\",\"leftForearm_amount\":\"37\",\"leftForearm_angle\":\"0\",\"leftUpperArm_reverse\":\"1\",\"leftUpperArm_tempoMultiplier\":\"0.5\",\"leftUpperArm_amount\":\"105\",\"leftUpperArm_angle\":\"146\",\"hips_tempoMultiplier\":\"1\",\"hips_upDown\":\"20\",\"hips_leftRight\":\"6.4\"}',0,1384186525,1384186525,0),(104,'Duplicate Dancer','','5281029d56337','{\"masterTempo\":\"0.5\",\"neck_tempoMultiplier\":\"1\",\"neck_upDown\":\"2.6\",\"neck_leftRight\":\"9.4\",\"rightForearm_reverse\":\"\",\"rightForearm_tempoMultiplier\":\"1\",\"rightForearm_amount\":\"33\",\"rightForearm_angle\":\"0\",\"rightUpperArm_reverse\":\"\",\"rightUpperArm_tempoMultiplier\":\"0.5\",\"rightUpperArm_amount\":\"98\",\"rightUpperArm_angle\":\"129\",\"leftForearm_reverse\":\"1\",\"leftForearm_tempoMultiplier\":\"1\",\"leftForearm_amount\":\"37\",\"leftForearm_angle\":\"0\",\"leftUpperArm_reverse\":\"1\",\"leftUpperArm_tempoMultiplier\":\"0.5\",\"leftUpperArm_amount\":\"105\",\"leftUpperArm_angle\":\"146\",\"hips_tempoMultiplier\":\"1\",\"hips_upDown\":\"20\",\"hips_leftRight\":\"6.4\"}',0,1384186999,1384186999,0),(105,'Double Linked','','5281017967e1e','{\"masterTempo\":\"1\",\"neck_tempoMultiplier\":\"1\",\"neck_upDown\":\"2.6\",\"neck_leftRight\":\"9.4\",\"rightForearm_reverse\":\"\",\"rightForearm_tempoMultiplier\":\"1\",\"rightForearm_amount\":\"33\",\"rightForearm_angle\":\"0\",\"rightUpperArm_reverse\":\"\",\"rightUpperArm_tempoMultiplier\":\"0.5\",\"rightUpperArm_amount\":\"98\",\"rightUpperArm_angle\":\"129\",\"leftForearm_reverse\":\"1\",\"leftForearm_tempoMultiplier\":\"1\",\"leftForearm_amount\":\"37\",\"leftForearm_angle\":\"0\",\"leftUpperArm_reverse\":\"1\",\"leftUpperArm_tempoMultiplier\":\"0.5\",\"leftUpperArm_amount\":\"105\",\"leftUpperArm_angle\":\"146\",\"hips_tempoMultiplier\":\"1\",\"hips_upDown\":\"20\",\"hips_leftRight\":\"6.4\"}',0,1384185000,1384185000,0),(106,'Orphan Annie','','5280e42a38b40','{\"masterTempo\":\"1\",\"neck_tempoMultiplier\":\"1\",\"neck_upDown\":\"2.6\",\"neck_leftRight\":\"9.4\",\"rightForearm_reverse\":\"\",\"rightForearm_tempoMultiplier\":\"1\",\"rightForearm_amount\":\"33\",\"rightForearm_angle\":\"0\",\"rightUpperArm_reverse\":\"\",\"rightUpperArm_tempoMultiplier\":\"0.5\",\"rightUpperArm_amount\":\"98\",\"rightUpperArm_angle\":\"129\",\"leftForearm_reverse\":\"1\",\"leftForearm_tempoMultiplier\":\"1\",\"leftForearm_amount\":\"37\",\"leftForearm_angle\":\"0\",\"leftUpperArm_reverse\":\"1\",\"leftUpperArm_tempoMultiplier\":\"0.5\",\"leftUpperArm_amount\":\"105\",\"leftUpperArm_angle\":\"146\",\"hips_tempoMultiplier\":\"1\",\"hips_upDown\":\"20\",\"hips_leftRight\":\"6.4\"}',0,1384178000,1384178000,0),(107,'Broken Moves','','5280e4e19b9e8','not json{',0,1384178100,1384178100,0),(108,'Timeless','','5280c68fa4b52','{\"masterTempo\":\"1\",\"neck_tempoMultiplier\":\"1\",\"neck_upDown\":\"2.6\",\"neck_leftRight\":\"9.4\",\"rightForearm_reverse\":\"\",\"rightForearm_tempoMultiplier\":\"1\",\"rightForearm_amount\":\"33\",\"rightForearm_angle\":\"0\",\"rightUpperArm_reverse\":\"\",\"rightUpperArm_tempoMultiplier\":\"0.5\",\"rightUpperArm_amount\":\"98\",\"rightUpperArm_angle\":\"129\",\"leftForearm_reverse\":\"1\",\"leftForearm_tempoMultiplier\":\"1\",\"leftForearm_amount\":\"37\",\"leftForearm_angle\":\"0\",\"leftUpperArm_reverse\":\"1\",\"leftUpperArm_tempoMultiplier\":\"0.5\",\"leftUpperArm_amount\":\"105\",\"leftUpperArm_angle\":\"146\",\"hips_tempoMultiplier\":\"1\",\"hips_upDown\":\"20\",\"hips_leftRight\":\"6.4\"}',0,NULL,NULL,0),(109,'Ghost Robot','','52aa00000000a','{\"masterTempo\":\"1\",\"neck_tempoMultiplier\":\"1\",\"neck_upDown\":\"2.6\",\"neck_leftRight\":\"9.4\",\"rightForearm_reverse\":\"\",\"rightForearm_tempoMultiplier\":\"1\",\"rightForearm_amount\":\"33\",\"rightForearm_angle\":\"0\",\"rightUpperArm_reverse\":\"\",\"rightUpperArm_tempoMultiplier\":\"0.5\",\"rightUpperArm_amount\":\"98\",\"rightUpperArm_angle\":\"129\",\"leftForearm_reverse\":\"1\",\"leftForearm_tempoMultiplier\":\"1\",\"leftForearm_amount\":\"37\",\"leftForearm_angle\":\"0\",\"leftUpperArm_reverse\":\"1\",\"leftUpperArm_tempoMultiplier\":\"0.5\",\"leftUpperArm_amount\":\"105\",\"leftUpperArm_angle\":\"146\",\"hips_tempoMultiplier\":\"1\",\"hips_upDown\":\"20\",\"hips_leftRight\":\"6.4\"}',0,1386000000,1386000000,0),(110,'Nameless','',NULL,'{\"masterTempo\":\"1\",\"neck_tempoMultiplier\":\"1\",\"neck_upDown\":\"2.6\",\"neck_leftRight\":\"9.4\",\"rightForearm_reverse\":\"\",\"rightForearm_tempoMultiplier\":\"1\",\"rightForearm_amount\":\"33\",\"rightForearm_angle\":\"0\",\"rightUpperArm_reverse\":\"\",\"rightUpperArm_tempoMultiplier\":\"0.5\",\"rightUpperArm_amount\":\"98\",\"rightUpperArm_angle\":\"129\",\"leftForearm_reverse\":\"1\",\"leftForearm_tempoMultiplier\":\"1\",\"leftForearm_amount\":\"37\",\"leftForearm_angle\":\"0\",\"leftUpperArm_reverse\":\"1\",\"leftUpperArm_tempoMultiplier\":\"0.5\",\"leftUpperArm_amount\":\"105\",\"leftUpperArm_angle\":\"146\",\"hips_tempoMultiplier\":\"1\",\"hips_upDown\":\"20\",\"hips_leftRight\":\"6.4\"}',0,1386000001,1386000001,0),(111,'Lost Owner','','52aa00000000b','{\"masterTempo\":\"1\",\"neck_tempoMultiplier\":\"1\",\"neck_upDown\":\"2.6\",\"neck_leftRight\":\"9.4\",\"rightForearm_reverse\":\"\",\"rightForearm_tempoMultiplier\":\"1\",\"rightForearm_amount\":\"33\",\"rightForearm_angle\":\"0\",\"rightUpperArm_reverse\":\"\",\"rightUpperArm_tempoMultiplier\":\"0.5\",\"rightUpperArm_amount\":\"98\",\"rightUpperArm_angle\":\"129\",\"leftForearm_reverse\":\"1\",\"leftForearm_tempoMultiplier\":\"1\",\"leftForearm_amount\":\"37\",\"leftForearm_angle\":\"0\",\"leftUpperArm_reverse\":\"1\",\"leftUpperArm_tempoMultiplier\":\"0.5\",\"leftUpperArm_amount\":\"105\",\"leftUpperArm_angle\":\"146\",\"hips_tempoMultiplier\":\"1\",\"hips_upDown\":\"20\",\"hips_leftRight\":\"6.4\"}',0,1386000002,1386000002,0),(112,'Encore','','52aa00000000c','{\"masterTempo\":\"0.5\",\"neck_tempoMultiplier\":\"1\",\"neck_upDown\":\"2.6\",\"neck_leftRight\":\"9.4\",\"rightForearm_reverse\":\"\",\"rightForearm_tempoMultiplier\":\"1\",\"rightForearm_amount\":\"33\",\"rightForearm_angle\":\"0\",\"rightUpperArm_reverse\":\"\",\"rightUpperArm_tempoMultiplier\":\"0.5\",\"rightUpperArm_amount\":\"98\",\"rightUpperArm_angle\":\"129\",\"leftForearm_reverse\":\"1\",\"leftForearm_tempoMultiplier\":\"1\",\"leftForearm_amount\":\"37\",\"leftForearm_angle\":\"0\",\"leftUpperArm_reverse\":\"1\",\"leftUpperArm_tempoMultiplier\":\"0.5\",\"leftUpperArm_amount\":\"105\",\"leftUpperArm_angle\":\"146\",\"hips_tempoMultiplier\":\"1\",\"hips_upDown\":\"20\",\"hips_leftRight\":\"6.4\"}',0,1386000003,1386000003,0);
/*!40000 ALTER TABLE `dances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dances_robots`
--

DROP TABLE IF EXISTS `dances_robots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dances_robots` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `dance_id` int(11) DEFAULT NULL,
  `robot_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dances_robots`
--

LOCK TABLES `dances_robots` WRITE;
/*!40000 ALTER TABLE `dances_robots` DISABLE KEYS */;
INSERT INTO `dances_robots` VALUES (1,101,1),(2,102,2),(3,103,3),(4,104,3),(5,105,4),(6,105,5),(7,106,6),(8,107,7),(9,108,1),(10,109,99),(11,111,2),(12,112,2);
/*!40000 ALTER TABLE `dances_robots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dances_soundtracks`
--

DROP TABLE IF EXISTS `dances_soundtracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dances_soundtracks` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `dance_id` int(11) DEFAULT NULL,
  `soundtrack_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dances_soundtracks`
--

LOCK TABLES `dances_soundtracks` WRITE;
/*!40000 ALTER TABLE `dances_soundtracks` DISABLE KEYS */;
INSERT INTO `dances_soundtracks` VALUES (1,101,1),(2,102,2),(3,103,3),(4,104,3),(5,105,4),(6,105,2),(7,106,4),(8,107,1),(9,109,2),(10,111,1),(11,112,3);
/*!40000 ALTER TABLE `dances_soundtracks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dances_users`
--

DROP TABLE IF EXISTS `dances_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dances_users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `dance_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dances_users`
--

LOCK TABLES `dances_users` WRITE;
/*!40000 ALTER TABLE `dances_users` DISABLE KEYS */;
INSERT INTO `dances_users` VALUES (1,101,1),(2,102,1),(3,103,2),(4,104,2),(5,105,1),(6,107,2),(7,108,1),(8,109,2),(9,111,999),(10,112,1);
/*!40000 ALTER TABLE `dances_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `robots`
--

DROP TABLE IF EXISTS `robots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `robots` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Data help in puppets.json',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `robots`
--

LOCK TABLES `robots` WRITE;
/*!40000 ALTER TABLE `robots` DISABLE KEYS */;
INSERT INTO `robots` VALUES (1),(2),(3),(4),(5),(6),(7);
/*!40000 ALTER TABLE `robots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `soundtracks`
--

DROP TABLE IF EXISTS `soundtracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `soundtracks` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `soundtracks`
--

LOCK TABLES `soundtracks` WRITE;
/*!40000 ALTER TABLE `soundtracks` DISABLE KEYS */;
INSERT INTO `soundtracks` VALUES (1),(2),(3),(4);
/*!40000 ALTER TABLE `soundtracks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'11111111-2222-4333-8444-555555555555'),(2,'99999999-8888-4777-8666-555555555555'),(3,'33333333-3333-4333-8333-333333333333');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-04  0:39:48
