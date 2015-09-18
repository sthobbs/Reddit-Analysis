-- MySQL dump 10.13  Distrib 5.6.25, for Win64 (x86_64)
--
-- Host: localhost    Database: db1
-- ------------------------------------------------------
-- Server version	5.6.25-log

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
-- Table structure for table `amazonprices`
--

DROP TABLE IF EXISTS `amazonprices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `amazonprices` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `time` varchar(30) NOT NULL,
  `stone_price` decimal(5,2) NOT NULL,
  `umbrella_price` decimal(5,2) NOT NULL,
  `clay_price` decimal(5,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `amazonprices`
--

LOCK TABLES `amazonprices` WRITE;
/*!40000 ALTER TABLE `amazonprices` DISABLE KEYS */;
INSERT INTO `amazonprices` VALUES (8,'2015-09-13 20:12:01.060000',9.99,106.32,15.10);
INSERT INTO `amazonprices` VALUES (9,'2015-09-13 20:23:23.841000',9.99,106.32,15.10);
INSERT INTO `amazonprices` VALUES (10,'2015-09-13 21:46:49.590000',9.99,106.32,15.10);
INSERT INTO `amazonprices` VALUES (11,'2015-09-13 23:53:54.302000',9.99,106.32,15.10);
INSERT INTO `amazonprices` VALUES (12,'2015-09-14 14:13:29.162000',9.99,106.32,15.10);
INSERT INTO `amazonprices` VALUES (13,'2015-09-14 16:19:24.184000',9.99,106.32,15.10);
INSERT INTO `amazonprices` VALUES (14,'2015-09-15 00:18:50.219000',9.99,106.32,15.10);
/*!40000 ALTER TABLE `amazonprices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb12`
--

DROP TABLE IF EXISTS `tb12`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb12` (
  `col1` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `col2` varchar(25) NOT NULL,
  `col3` varchar(25) NOT NULL,
  PRIMARY KEY (`col1`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb12`
--

LOCK TABLES `tb12` WRITE;
/*!40000 ALTER TABLE `tb12` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb12` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbl1`
--

DROP TABLE IF EXISTS `tbl1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl1` (
  `col1` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `col2` varchar(25) NOT NULL,
  PRIMARY KEY (`col1`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbl1`
--

LOCK TABLES `tbl1` WRITE;
/*!40000 ALTER TABLE `tbl1` DISABLE KEYS */;
INSERT INTO `tbl1` VALUES (1,'test123');
INSERT INTO `tbl1` VALUES (2,'test456');
INSERT INTO `tbl1` VALUES (3,'test456');
/*!40000 ALTER TABLE `tbl1` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbl2`
--

DROP TABLE IF EXISTS `tbl2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl2` (
  `col1` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `col2` varchar(25) NOT NULL,
  `col3` varchar(25) NOT NULL,
  PRIMARY KEY (`col1`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbl2`
--

LOCK TABLES `tbl2` WRITE;
/*!40000 ALTER TABLE `tbl2` DISABLE KEYS */;
INSERT INTO `tbl2` VALUES (1,'0','test1.2\n');
INSERT INTO `tbl2` VALUES (2,'0','12343');
/*!40000 ALTER TABLE `tbl2` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-09-18 15:20:56
