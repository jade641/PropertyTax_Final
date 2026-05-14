
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP TABLE IF EXISTS `__efmigrationshistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `__efmigrationshistory` (
  `MigrationId` varchar(150) NOT NULL,
  `ProductVersion` varchar(32) NOT NULL,
  PRIMARY KEY (`MigrationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `auditlogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditlogs` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `Action` longtext NOT NULL,
  `EntityName` longtext NOT NULL,
  `EntityId` longtext DEFAULT NULL,
  `PerformedByUserId` longtext DEFAULT NULL,
  `PerformedByUsername` longtext DEFAULT NULL,
  `UserRole` longtext DEFAULT NULL,
  `IpAddress` longtext DEFAULT NULL,
  `Description` longtext DEFAULT NULL,
  `Succeeded` tinyint(1) NOT NULL,
  `CreatedAtUtc` datetime(6) NOT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `provinces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `provinces` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `RegionCode` varchar(20) NOT NULL,
  `PsgcCode` varchar(20) NOT NULL,
  `Name` varchar(100) NOT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `IX_provinces_PsgcCode` (`PsgcCode`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `cities_municipalities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cities_municipalities` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `ProvinceId` int(11) NOT NULL,
  `PsgcCode` varchar(20) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `LguType` varchar(30) NOT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `IX_cities_municipalities_PsgcCode` (`PsgcCode`),
  KEY `IX_cities_municipalities_ProvinceId_Name` (`ProvinceId`,`Name`),
  CONSTRAINT `FK_cities_municipalities_provinces_ProvinceId` FOREIGN KEY (`ProvinceId`) REFERENCES `provinces` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `barangays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `barangays` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `CityMunicipalityId` int(11) NOT NULL,
  `PsgcCode` varchar(20) NOT NULL,
  `Name` varchar(100) NOT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `IX_barangays_PsgcCode` (`PsgcCode`),
  KEY `IX_barangays_CityMunicipalityId_Name` (`CityMunicipalityId`,`Name`),
  CONSTRAINT `FK_barangays_cities_municipalities_CityMunicipalityId` FOREIGN KEY (`CityMunicipalityId`) REFERENCES `cities_municipalities` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `property_owners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `property_owners` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `FullName` longtext NOT NULL,
  `Email` longtext DEFAULT NULL,
  `PhoneNumber` longtext DEFAULT NULL,
  `Address` longtext DEFAULT NULL,
  `TaxIdentificationNumber` longtext DEFAULT NULL,
  `CreatedAtUtc` datetime(6) NOT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `Id` varchar(255) NOT NULL,
  `Name` varchar(256) DEFAULT NULL,
  `NormalizedName` varchar(256) DEFAULT NULL,
  `ConcurrencyStamp` longtext DEFAULT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `RoleNameIndex` (`NormalizedName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `Id` varchar(255) NOT NULL,
  `FullName` longtext NOT NULL,
  `IsActive` tinyint(1) NOT NULL,
  `CreatedAtUtc` datetime(6) NOT NULL,
  `UserName` varchar(256) DEFAULT NULL,
  `NormalizedUserName` varchar(256) DEFAULT NULL,
  `Email` varchar(256) DEFAULT NULL,
  `NormalizedEmail` varchar(256) DEFAULT NULL,
  `EmailConfirmed` tinyint(1) NOT NULL,
  `PasswordHash` longtext DEFAULT NULL,
  `SecurityStamp` longtext DEFAULT NULL,
  `ConcurrencyStamp` longtext DEFAULT NULL,
  `PhoneNumber` longtext DEFAULT NULL,
  `PhoneNumberConfirmed` tinyint(1) NOT NULL,
  `TwoFactorEnabled` tinyint(1) NOT NULL,
  `LockoutEnd` datetime(6) DEFAULT NULL,
  `LockoutEnabled` tinyint(1) NOT NULL,
  `AccessFailedCount` int(11) NOT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `UserNameIndex` (`NormalizedUserName`),
  KEY `EmailIndex` (`NormalizedEmail`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `properties` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `TaxpayerId` int(11) NOT NULL,
  `Pin` varchar(255) NOT NULL,
  `Barangay` longtext NOT NULL,
  `Municipality` longtext NOT NULL,
  `Address` longtext NOT NULL,
  `PropertyType` longtext NOT NULL,
  `LotNumber` longtext NOT NULL,
  `AreaSquareMeters` decimal(18,2) NOT NULL,
  `MarketValue` decimal(18,2) NOT NULL,
  `AssessmentLevel` decimal(10,4) NOT NULL,
  `TaxRate` decimal(10,4) NOT NULL,
  `Status` longtext NOT NULL,
  `DateRegisteredUtc` datetime(6) NOT NULL,
  `CreatedAtUtc` datetime(6) NOT NULL,
  `UpdatedAtUtc` datetime(6) DEFAULT NULL,
  `BarangayId` int(11) DEFAULT NULL,
  `Remarks` varchar(500) DEFAULT NULL,
  `TaxDeclarationNumber` varchar(50) DEFAULT NULL,
  `ZoningClassification` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `IX_Properties_Pin` (`Pin`),
  UNIQUE KEY `IX_Properties_TaxDeclarationNumber` (`TaxDeclarationNumber`),
  KEY `IX_Properties_TaxpayerId` (`TaxpayerId`),
  KEY `IX_Properties_BarangayId` (`BarangayId`),
  CONSTRAINT `FK_Properties_barangays_BarangayId` FOREIGN KEY (`BarangayId`) REFERENCES `barangays` (`Id`) ON DELETE SET NULL,
  CONSTRAINT `FK_Properties_property_owners_TaxpayerId` FOREIGN KEY (`TaxpayerId`) REFERENCES `property_owners` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payments` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `PropertyId` int(11) NOT NULL,
  `TaxpayerId` int(11) NOT NULL,
  `TaxYear` int(11) NOT NULL,
  `Quarter` longtext NOT NULL,
  `AmountPaid` decimal(18,2) NOT NULL,
  `PaymentMethod` longtext NOT NULL,
  `ReferenceNumber` varchar(100) DEFAULT NULL,
  `BankName` varchar(120) DEFAULT NULL,
  `OfficialReceiptNumber` varchar(255) NOT NULL,
  `PaymentDateUtc` datetime(6) NOT NULL,
  `Notes` longtext DEFAULT NULL,
  `CreatedAtUtc` datetime(6) NOT NULL,
  `RecordedByUserId` longtext DEFAULT NULL,
  `AmountDue` decimal(18,2) NOT NULL DEFAULT 0.00,
  `DueDateUtc` datetime(6) NOT NULL DEFAULT '0001-01-01 00:00:00.000000',
  `Penalty` decimal(18,2) NOT NULL DEFAULT 0.00,
  `Status` longtext NOT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `IX_Payments_OfficialReceiptNumber` (`OfficialReceiptNumber`),
  KEY `IX_Payments_PropertyId` (`PropertyId`),
  KEY `IX_Payments_TaxpayerId` (`TaxpayerId`),
  CONSTRAINT `FK_Payments_Properties_PropertyId` FOREIGN KEY (`PropertyId`) REFERENCES `properties` (`Id`) ON DELETE CASCADE,
  CONSTRAINT `FK_Payments_property_owners_TaxpayerId` FOREIGN KEY (`TaxpayerId`) REFERENCES `property_owners` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `propertydocuments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `propertydocuments` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `PropertyId` int(11) NOT NULL,
  `FileName` longtext NOT NULL,
  `OriginalFileName` longtext NOT NULL,
  `RelativePath` longtext NOT NULL,
  `ContentType` longtext NOT NULL,
  `SizeInBytes` bigint(20) NOT NULL,
  `Folder` longtext NOT NULL,
  `UploadedAtUtc` datetime(6) NOT NULL,
  `UploadedByUserId` longtext DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `IX_PropertyDocuments_PropertyId` (`PropertyId`),
  CONSTRAINT `FK_PropertyDocuments_Properties_PropertyId` FOREIGN KEY (`PropertyId`) REFERENCES `properties` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `taxassessments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxassessments` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `PropertyId` int(11) NOT NULL,
  `TaxYear` int(11) NOT NULL,
  `MarketValue` decimal(18,2) NOT NULL,
  `AssessmentLevel` decimal(10,4) NOT NULL,
  `AssessedValue` decimal(18,2) NOT NULL,
  `TaxRate` decimal(10,4) NOT NULL,
  `TaxDue` decimal(18,2) NOT NULL,
  `CreatedAtUtc` datetime(6) NOT NULL,
  `CalculatedByUserId` longtext DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `IX_TaxAssessments_PropertyId` (`PropertyId`),
  CONSTRAINT `FK_TaxAssessments_Properties_PropertyId` FOREIGN KEY (`PropertyId`) REFERENCES `properties` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `roleclaims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roleclaims` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `RoleId` varchar(255) NOT NULL,
  `ClaimType` longtext DEFAULT NULL,
  `ClaimValue` longtext DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `IX_RoleClaims_RoleId` (`RoleId`),
  CONSTRAINT `FK_RoleClaims_Roles_RoleId` FOREIGN KEY (`RoleId`) REFERENCES `roles` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `userclaims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userclaims` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `UserId` varchar(255) NOT NULL,
  `ClaimType` longtext DEFAULT NULL,
  `ClaimValue` longtext DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `IX_UserClaims_UserId` (`UserId`),
  CONSTRAINT `FK_UserClaims_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `users` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `userlogins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userlogins` (
  `LoginProvider` varchar(255) NOT NULL,
  `ProviderKey` varchar(255) NOT NULL,
  `ProviderDisplayName` longtext DEFAULT NULL,
  `UserId` varchar(255) NOT NULL,
  PRIMARY KEY (`LoginProvider`,`ProviderKey`),
  KEY `IX_UserLogins_UserId` (`UserId`),
  CONSTRAINT `FK_UserLogins_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `users` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `usertokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usertokens` (
  `UserId` varchar(255) NOT NULL,
  `LoginProvider` varchar(255) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Value` longtext DEFAULT NULL,
  PRIMARY KEY (`UserId`,`LoginProvider`,`Name`),
  CONSTRAINT `FK_UserTokens_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `users` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `userroles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userroles` (
  `UserId` varchar(255) NOT NULL,
  `RoleId` varchar(255) NOT NULL,
  PRIMARY KEY (`UserId`,`RoleId`),
  KEY `IX_UserRoles_RoleId` (`RoleId`),
  CONSTRAINT `FK_UserRoles_Roles_RoleId` FOREIGN KEY (`RoleId`) REFERENCES `roles` (`Id`) ON DELETE CASCADE,
  CONSTRAINT `FK_UserRoles_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `users` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

INSERT INTO `__efmigrationshistory` VALUES ('20260510060957_InitialCreate','8.0.26'),('20260510070230_PersistFrontendInputData','8.0.26'),('20260510071901_RenameIdentityTables','8.0.26'),('20260510124241_AddRegionXiPropertyRegistration','8.0.26'),('20260510125453_RenameTaxpayersToPropertyOwners','8.0.26'),('20260511045411_RemoveUserDepartment','8.0.26'),('20260512090000_AddManualPaymentReferenceFields','8.0.26');

INSERT INTO `provinces` VALUES (1,'110000000','112300000','Davao Del Norte'),(2,'110000000','112400000','Davao Del Sur'),(3,'110000000','112500000','Davao Oriental'),(4,'110000000','118200000','Davao De Oro'),(5,'110000000','118600000','Davao Occidental');

INSERT INTO `cities_municipalities` VALUES (1,1,'112301000','Asuncion','Municipality'),(2,1,'112303000','Carmen','Municipality'),(3,1,'112305000','Kapalong','Municipality'),(4,1,'112314000','New Corella','Municipality'),(5,1,'112315000','City of Panabo','City'),(6,1,'112317000','Island Garden City of Samal','City'),(7,1,'112318000','Santo Tomas','Municipality'),(8,1,'112319000','City of Tagum','City'),(9,1,'112322000','Talaingod','Municipality'),(10,1,'112323000','Braulio E. Dujali','Municipality'),(11,1,'112324000','San Isidro','Municipality'),(12,2,'112401000','Bansalan','Municipality'),(13,2,'112402000','City of Davao','City'),(14,2,'112403000','City of Digos','City'),(15,2,'112404000','Hagonoy','Municipality'),(16,2,'112406000','Kiblawan','Municipality'),(17,2,'112407000','Magsaysay','Municipality'),(18,2,'112408000','Malalag','Municipality'),(19,2,'112410000','Matanao','Municipality'),(20,2,'112411000','Padada','Municipality'),(21,2,'112412000','Santa Cruz','Municipality'),(22,2,'112414000','Sulop','Municipality'),(23,3,'112501000','Baganga','Municipality'),(24,3,'112502000','Banaybanay','Municipality'),(25,3,'112503000','Boston','Municipality'),(26,3,'112504000','Caraga','Municipality'),(27,3,'112505000','Cateel','Municipality'),(28,3,'112506000','Governor Generoso','Municipality'),(29,3,'112507000','Lupon','Municipality'),(30,3,'112508000','Manay','Municipality'),(31,3,'112509000','City of Mati','City'),(32,3,'112510000','San Isidro','Municipality'),(33,3,'112511000','Tarragona','Municipality'),(34,4,'118201000','Compostela','Municipality'),(35,4,'118202000','Laak','Municipality'),(36,4,'118203000','Mabini','Municipality'),(37,4,'118204000','Maco','Municipality'),(38,4,'118205000','Maragusan','Municipality'),(39,4,'118206000','Mawab','Municipality'),(40,4,'118207000','Monkayo','Municipality'),(41,4,'118208000','Montevista','Municipality'),(42,4,'118209000','Nabunturan','Municipality'),(43,4,'118210000','New Bataan','Municipality'),(44,4,'118211000','Pantukan','Municipality'),(45,5,'118601000','Don Marcelino','Municipality'),(46,5,'118602000','Jose Abad Santos','Municipality'),(47,5,'118603000','Malita','Municipality'),(48,5,'118604000','Santa Maria','Municipality'),(49,5,'118605000','Sarangani','Municipality');

INSERT INTO `barangays` VALUES (1,1,'112301004','Binancian'),(2,1,'112301006','Buan'),(3,1,'112301007','Buclad'),(4,1,'112301008','Cabaywa'),(5,1,'112301009','Camansa'),(6,1,'112301032','Cambanogoy (Pob.)'),(7,1,'112301010','Camoning'),(8,1,'112301011','Canatan'),(9,1,'112301012','Concepcion'),(10,1,'112301013','Doña Andrea'),(11,1,'112301026','Magatos'),(12,1,'112301028','Napungas'),(13,1,'112301029','New Bantayan'),(14,1,'112301040','New Loon'),(15,1,'112301030','New Santiago'),(16,1,'112301031','Pamacaun'),(17,1,'112301034','Sagayen'),(18,1,'112301036','San Vicente'),(19,1,'112301037','Santa Filomena'),(20,1,'112301039','Sonlon'),(21,2,'112303001','Alejal'),(22,2,'112303002','Anibongan'),(23,2,'112303003','Asuncion'),(24,2,'112303005','Cebulano'),(25,2,'112303006','Guadalupe'),(26,2,'112303007','Ising (Pob.)'),(27,2,'112303008','La Paz'),(28,2,'112303010','Mabaus'),(29,2,'112303011','Mabuhay'),(30,2,'112303012','Magsaysay'),(31,2,'112303014','Mangalcal'),(32,2,'112303015','Minda'),(33,2,'112303016','New Camiling'),(34,2,'112303023','Salvacion'),(35,2,'112303018','San Isidro'),(36,2,'112303019','Santo Niño'),(37,2,'112303024','Taba'),(38,2,'112303020','Tibulao'),(39,2,'112303021','Tubod'),(40,2,'112303022','Tuganay'),(41,3,'112305008','Capungagan'),(42,3,'112305005','Florida'),(43,3,'112305006','Gabuyan'),(44,3,'112305007','Gupitan'),(45,3,'112305009','Katipunan'),(46,3,'112305012','Luna'),(47,3,'112305013','Mabantao'),(48,3,'112305015','Mamacao'),(49,3,'112305021','Maniki'),(50,3,'112305018','Pag-asa'),(51,3,'112305022','Sampao'),(52,3,'112305003','Semong'),(53,3,'112305026','Sua-on'),(54,3,'112305028','Tiburcia'),(55,4,'112314001','Cabidianan'),(56,4,'112314002','Carcor'),(57,4,'112314003','Del Monte'),(58,4,'112314004','Del Pilar'),(59,4,'112314005','El Salvador'),(60,4,'112314006','Limba-an'),(61,4,'112314007','Macgum'),(62,4,'112314008','Mambing'),(63,4,'112314009','Mesaoy'),(64,4,'112314010','New Bohol'),(65,4,'112314011','New Cortez'),(66,4,'112314012','New Sambog'),(67,4,'112314013','Patrocenio'),(68,4,'112314014','Poblacion'),(69,4,'112314020','San Jose'),(70,4,'112314015','San Roque'),(71,4,'112314016','Santa Cruz'),(72,4,'112314017','Santa Fe'),(73,4,'112314018','Santo Niño'),(74,4,'112314019','Suawon'),(75,5,'112315001','A. O. Floirendo'),(76,5,'112315003','Buenavista'),(77,5,'112315004','Cacao'),(78,5,'112315005','Cagangohan'),(79,5,'112315006','Consolacion'),(80,5,'112315007','Dapco'),(81,5,'112315002','Datu Abdul Dadia'),(82,5,'112315009','Gredu (Pob.)'),(83,5,'112315010','J.P. Laurel'),(84,5,'112315011','Kasilak'),(85,5,'112315012','Katipunan'),(86,5,'112315013','Katualan'),(87,5,'112315014','Kauswagan'),(88,5,'112315015','Kiotoy'),(89,5,'112315016','Little Panay'),(90,5,'112315017','Lower Panaga'),(91,5,'112315018','Mabunao'),(92,5,'112315019','Maduao'),(93,5,'112315020','Malativas'),(94,5,'112315021','Manay'),(95,5,'112315022','Nanyo'),(96,5,'112315023','New Malaga'),(97,5,'112315024','New Malitbog'),(98,5,'112315025','New Pandan (Pob.)'),(99,5,'112315026','New Visayas'),(100,5,'112315027','Quezon'),(101,5,'112315028','Salvacion'),(102,5,'112315029','San Francisco (Pob.)'),(103,5,'112315030','San Nicolas'),(104,5,'112315041','San Pedro'),(105,5,'112315031','San Roque'),(106,5,'112315032','San Vicente'),(107,5,'112315033','Santa Cruz'),(108,5,'112315034','Santo Niño (Pob.)'),(109,5,'112315035','Sindaton'),(110,5,'112315036','Southern Davao'),(111,5,'112315037','Tagpore'),(112,5,'112315038','Tibungol'),(113,5,'112315039','Upper Licanan'),(114,5,'112315040','Waterfall'),(115,6,'112317001','Adecor'),(116,6,'112317002','Anonang'),(117,6,'112317003','Aumbay'),(118,6,'112317004','Aundanao'),(119,6,'112317005','Balet'),(120,6,'112317006','Bandera'),(121,6,'112317007','Caliclic'),(122,6,'112317008','Camudmud'),(123,6,'112317009','Catagman'),(124,6,'112317010','Cawag'),(125,6,'112317012','Cogon'),(126,6,'112317011','Cogon'),(127,6,'112317013','Dadatan'),(128,6,'112317014','Del Monte'),(129,6,'112317015','Guilon'),(130,6,'112317016','Kanaan'),(131,6,'112317017','Kinawitnon'),(132,6,'112317018','Libertad'),(133,6,'112317019','Libuak'),(134,6,'112317020','Licup'),(135,6,'112317021','Limao'),(136,6,'112317022','Linosutan'),(137,6,'112317023','Mambago-A'),(138,6,'112317024','Mambago-B'),(139,6,'112317025','Miranda (Pob.)'),(140,6,'112317026','Moncado (Pob.)'),(141,6,'112317027','Pangubatan'),(142,6,'112317028','Peñaplata (Pob.)'),(143,6,'112317029','Poblacion'),(144,6,'112317030','San Agustin'),(145,6,'112317031','San Antonio'),(146,6,'112317033','San Isidro'),(147,6,'112317032','San Isidro'),(148,6,'112317034','San Jose'),(149,6,'112317035','San Miguel'),(150,6,'112317036','San Remigio'),(151,6,'112317037','Santa Cruz'),(152,6,'112317038','Santo Niño'),(153,6,'112317039','Sion'),(154,6,'112317040','Tagbaobo'),(155,6,'112317041','Tagbay'),(156,6,'112317042','Tagbitan-ag'),(157,6,'112317043','Tagdaliao'),(158,6,'112317044','Tagpopongan'),(159,6,'112317045','Tambo'),(160,6,'112317046','Toril'),(161,7,'112318001','Balagunan'),(162,7,'112318002','Bobongon'),(163,7,'112318016','Casig-Ang'),(164,7,'112318003','Esperanza'),(165,7,'112318004','Kimamon'),(166,7,'112318005','Kinamayan'),(167,7,'112318006','La Libertad'),(168,7,'112318007','Lungaog'),(169,7,'112318008','Magwawa'),(170,7,'112318009','New Katipunan'),(171,7,'112318017','New Visayas'),(172,7,'112318010','Pantaron'),(173,7,'112318018','Salvacion'),(174,7,'112318013','San Jose'),(175,7,'112318014','San Miguel'),(176,7,'112318019','San Vicente'),(177,7,'112318015','Talomo'),(178,7,'112318011','Tibal-og (Pob.)'),(179,7,'112318020','Tulalian'),(180,8,'112319001','Apokon'),(181,8,'112319003','Bincungan'),(182,8,'112319004','Busaon'),(183,8,'112319005','Canocotan'),(184,8,'112319006','Cuambogan'),(185,8,'112319007','La Filipina'),(186,8,'112319008','Liboganon'),(187,8,'112319009','Madaum'),(188,8,'112319010','Magdum'),(189,8,'112319023','Magugpo East'),(190,8,'112319024','Magugpo North'),(191,8,'112319016','Magugpo Poblacion'),(192,8,'112319025','Magugpo South'),(193,8,'112319026','Magugpo West'),(194,8,'112319011','Mankilam'),(195,8,'112319012','New Balamban'),(196,8,'112319013','Nueva Fuerza'),(197,8,'112319014','Pagsabangan'),(198,8,'112319015','Pandapan'),(199,8,'112319018','San Agustin'),(200,8,'112319019','San Isidro'),(201,8,'112319020','San Miguel'),(202,8,'112319022','Visayan Village'),(203,9,'112322001','Dagohoy'),(204,9,'112322002','Palma Gil'),(205,9,'112322003','Santo Niño'),(206,10,'112323001','Cabayangan'),(207,10,'112323002','Dujali'),(208,10,'112323003','Magupising'),(209,10,'112323004','New Casay'),(210,10,'112323005','Tanglaw'),(211,11,'112324001','Dacudao'),(212,11,'112324002','Datu Balong'),(213,11,'112324003','Igangon'),(214,11,'112324004','Kipalili'),(215,11,'112324005','Libuton'),(216,11,'112324006','Linao'),(217,11,'112324007','Mamangan'),(218,11,'112324008','Monte Dujali'),(219,11,'112324009','Pinamuno'),(220,11,'112324010','Sabangan'),(221,11,'112324011','San Miguel'),(222,11,'112324012','Santo Niño'),(223,11,'112324013','Sawata'),(224,12,'112401001','Alegre'),(225,12,'112401002','Alta Vista'),(226,12,'112401003','Anonang'),(227,12,'112401004','Bitaug'),(228,12,'112401005','Bonifacio'),(229,12,'112401006','Buenavista'),(230,12,'112401007','Darapuay'),(231,12,'112401008','Dolo'),(232,12,'112401009','Eman'),(233,12,'112401010','Kinuskusan'),(234,12,'112401011','Libertad'),(235,12,'112401012','Linawan'),(236,12,'112401013','Mabuhay'),(237,12,'112401014','Mabunga'),(238,12,'112401015','Managa'),(239,12,'112401016','Marber'),(240,12,'112401017','New Clarin'),(241,12,'112401018','Poblacion'),(242,12,'112401025','Poblacion Dos'),(243,12,'112401019','Rizal'),(244,12,'112401020','Santo Niño'),(245,12,'112401021','Sibayan'),(246,12,'112401022','Tinongtongan'),(247,12,'112401023','Tubod'),(248,12,'112401024','Union'),(249,13,'112402001','Acacia'),(250,13,'112402002','Agdao'),(251,13,'112402003','Alambre'),(252,13,'112402056','Alejandra Navarro'),(253,13,'112402197','Alfonso Angliongto Sr.'),(254,13,'112402174','Angalan'),(255,13,'112402004','Atan-Awe'),(256,13,'112402175','Baganihan'),(257,13,'112402176','Bago Aplaya'),(258,13,'112402005','Bago Gallera'),(259,13,'112402006','Bago Oshiro'),(260,13,'112402007','Baguio (Pob.)'),(261,13,'112402009','Balengaeng'),(262,13,'112402010','Baliok'),(263,13,'112402012','Bangkas Heights'),(264,13,'112402177','Bantol'),(265,13,'112402013','Baracatan'),(266,13,'112402143','Barangay 10-A (Pob.)'),(267,13,'112402144','Barangay 11-B (Pob.)'),(268,13,'112402145','Barangay 12-B (Pob.)'),(269,13,'112402146','Barangay 13-B (Pob.)'),(270,13,'112402147','Barangay 14-B (Pob.)'),(271,13,'112402148','Barangay 15-B (Pob.)'),(272,13,'112402149','Barangay 16-B (Pob.)'),(273,13,'112402150','Barangay 17-B (Pob.)'),(274,13,'112402151','Barangay 18-B (Pob.)'),(275,13,'112402152','Barangay 19-B (Pob.)'),(276,13,'112402134','Barangay 1-A (Pob.)'),(277,13,'112402153','Barangay 20-B (Pob.)'),(278,13,'112402154','Barangay 21-C (Pob.)'),(279,13,'112402155','Barangay 22-C (Pob.)'),(280,13,'112402156','Barangay 23-C (Pob.)'),(281,13,'112402157','Barangay 24-C (Pob.)'),(282,13,'112402158','Barangay 25-C (Pob.)'),(283,13,'112402159','Barangay 26-C (Pob.)'),(284,13,'112402160','Barangay 27-C (Pob.)'),(285,13,'112402161','Barangay 28-C (Pob.)'),(286,13,'112402162','Barangay 29-C (Pob.)'),(287,13,'112402135','Barangay 2-A (Pob.)'),(288,13,'112402163','Barangay 30-C (Pob.)'),(289,13,'112402164','Barangay 31-D (Pob.)'),(290,13,'112402165','Barangay 32-D (Pob.)'),(291,13,'112402166','Barangay 33-D (Pob.)'),(292,13,'112402167','Barangay 34-D (Pob.)'),(293,13,'112402168','Barangay 35-D (Pob.)'),(294,13,'112402169','Barangay 36-D (Pob.)'),(295,13,'112402170','Barangay 37-D (Pob.)'),(296,13,'112402171','Barangay 38-D (Pob.)'),(297,13,'112402172','Barangay 39-D (Pob.)'),(298,13,'112402136','Barangay 3-A (Pob.)'),(299,13,'112402173','Barangay 40-D (Pob.)'),(300,13,'112402137','Barangay 4-A (Pob.)'),(301,13,'112402138','Barangay 5-A (Pob.)'),(302,13,'112402139','Barangay 6-A (Pob.)'),(303,13,'112402140','Barangay 7-A (Pob.)'),(304,13,'112402141','Barangay 8-A (Pob.)'),(305,13,'112402142','Barangay 9-A (Pob.)'),(306,13,'112402014','Bato'),(307,13,'112402015','Bayabas'),(308,13,'112402016','Biao Escuela'),(309,13,'112402017','Biao Guianga'),(310,13,'112402018','Biao Joaquin'),(311,13,'112402019','Binugao'),(312,13,'112402020','Bucana'),(313,13,'112402178','Buda'),(314,13,'112402021','Buhangin (Pob.)'),(315,13,'112402022','Bunawan (Pob.)'),(316,13,'112402023','Cabantian'),(317,13,'112402024','Cadalian'),(318,13,'112402026','Calinan (Pob.)'),(319,13,'112402027','Callawa'),(320,13,'112402028','Camansi'),(321,13,'112402029','Carmen'),(322,13,'112402030','Catalunan Grande'),(323,13,'112402031','Catalunan Pequeño'),(324,13,'112402032','Catigan'),(325,13,'112402033','Cawayan'),(326,13,'112402179','Centro'),(327,13,'112402034','Colosas'),(328,13,'112402035','Communal'),(329,13,'112402036','Crossing Bayabas'),(330,13,'112402037','Dacudao'),(331,13,'112402038','Dalag'),(332,13,'112402039','Dalagdag'),(333,13,'112402040','Daliao'),(334,13,'112402041','Daliaon Plantation'),(335,13,'112402180','Datu Salumay'),(336,13,'112402042','Dominga'),(337,13,'112402043','Dumoy'),(338,13,'112402044','Eden'),(339,13,'112402045','Fatima'),(340,13,'112402047','Gatungan'),(341,13,'112402181','Gov. Paciano Bangoy'),(342,13,'112402182','Gov. Vicente Duterte'),(343,13,'112402048','Gumalang'),(344,13,'112402183','Gumitan'),(345,13,'112402049','Ilang'),(346,13,'112402184','Inayangan'),(347,13,'112402050','Indangan'),(348,13,'112402185','Kap. Tomas Monteverde, Sr.'),(349,13,'112402051','Kilate'),(350,13,'112402052','Lacson'),(351,13,'112402053','Lamanan'),(352,13,'112402054','Lampianao'),(353,13,'112402055','Langub'),(354,13,'112402186','Lapu-lapu'),(355,13,'112402187','Leon Garcia, Sr.'),(356,13,'112402057','Lizada'),(357,13,'112402058','Los Amigos'),(358,13,'112402059','Lubogan'),(359,13,'112402060','Lumiad'),(360,13,'112402061','Ma-a'),(361,13,'112402062','Mabuhay'),(362,13,'112402188','Magsaysay'),(363,13,'112402063','Magtuod'),(364,13,'112402064','Mahayag'),(365,13,'112402065','Malabog'),(366,13,'112402066','Malagos'),(367,13,'112402067','Malamba'),(368,13,'112402068','Manambulan'),(369,13,'112402069','Mandug'),(370,13,'112402070','Manuel Guianga'),(371,13,'112402071','Mapula'),(372,13,'112402072','Marapangi'),(373,13,'112402073','Marilog'),(374,13,'112402074','Matina Aplaya'),(375,13,'112402078','Matina Biao'),(376,13,'112402075','Matina Crossing'),(377,13,'112402077','Matina Pangi'),(378,13,'112402189','Megkawayan'),(379,13,'112402079','Mintal'),(380,13,'112402080','Mudiang'),(381,13,'112402081','Mulig'),(382,13,'112402082','New Carmen'),(383,13,'112402083','New Valencia'),(384,13,'112402086','Pampanga'),(385,13,'112402087','Panacan'),(386,13,'112402088','Panalum'),(387,13,'112402089','Pandaitan'),(388,13,'112402090','Pangyan'),(389,13,'112402091','Paquibato (Pob.)'),(390,13,'112402092','Paradise Embak'),(391,13,'112402190','Rafael Castillo'),(392,13,'112402097','Riverside'),(393,13,'112402098','Salapawan'),(394,13,'112402099','Salaysay'),(395,13,'112402191','Saloy'),(396,13,'112402192','San Antonio'),(397,13,'112402100','San Isidro'),(398,13,'112402193','Santo Niño'),(399,13,'112402101','Sasa'),(400,13,'112402102','Sibulan'),(401,13,'112402104','Sirawan'),(402,13,'112402105','Sirib'),(403,13,'112402106','Suawan'),(404,13,'112402107','Subasta'),(405,13,'112402108','Sumimao'),(406,13,'112402110','Tacunan'),(407,13,'112402112','Tagakpan'),(408,13,'112402113','Tagluno'),(409,13,'112402114','Tagurano'),(410,13,'112402115','Talandang'),(411,13,'112402116','Talomo (Pob.)'),(412,13,'112402117','Talomo River'),(413,13,'112402118','Tamayong'),(414,13,'112402119','Tambobong'),(415,13,'112402120','Tamugan'),(416,13,'112402121','Tapak'),(417,13,'112402122','Tawan-tawan'),(418,13,'112402123','Tibuloy'),(419,13,'112402124','Tibungco'),(420,13,'112402125','Tigatto'),(421,13,'112402126','Toril (Pob.)'),(422,13,'112402127','Tugbok (Pob.)'),(423,13,'112402128','Tungakalan'),(424,13,'112402194','Ubalde'),(425,13,'112402129','Ula'),(426,13,'112402198','Vicente Hizon Sr.'),(427,13,'112402195','Waan'),(428,13,'112402131','Wangan'),(429,13,'112402196','Wilfredo Aquino'),(430,13,'112402133','Wines'),(431,14,'112403001','Aplaya'),(432,14,'112403002','Balabag'),(433,14,'112403004','Binaton'),(434,14,'112403005','Cogon'),(435,14,'112403006','Colorado'),(436,14,'112403007','Dawis'),(437,14,'112403008','Dulangan'),(438,14,'112403009','Goma'),(439,14,'112403010','Igpit'),(440,14,'112403019','Kapatagan'),(441,14,'112403011','Kiagot'),(442,14,'112403012','Lungag'),(443,14,'112403013','Mahayahay'),(444,14,'112403014','Matti'),(445,14,'112403020','Ruparan'),(446,14,'112403021','San Agustin'),(447,14,'112403003','San Jose'),(448,14,'112403022','San Miguel'),(449,14,'112403023','San Roque'),(450,14,'112403024','Sinawilan'),(451,14,'112403025','Soong'),(452,14,'112403026','Tiguman'),(453,14,'112403027','Tres De Mayo'),(454,14,'112403028','Zone 1 (Pob.)'),(455,14,'112403029','Zone 2 (Pob.)'),(456,14,'112403030','Zone 3 (Pob.)'),(457,15,'112404002','Balutakay'),(458,15,'112404005','Clib'),(459,15,'112404007','Guihing'),(460,15,'112404006','Guihing Aplaya'),(461,15,'112404008','Hagonoy Crossing'),(462,15,'112404009','Kibuaya'),(463,15,'112404010','La Union'),(464,15,'112404011','Lanuro'),(465,15,'112404012','Lapulabao'),(466,15,'112404013','Leling'),(467,15,'112404014','Mahayahay'),(468,15,'112404017','Malabang Damsite'),(469,15,'112404018','Maliit Digos'),(470,15,'112404019','New Quezon'),(471,15,'112404020','Paligue'),(472,15,'112404021','Poblacion'),(473,15,'112404022','Sacub'),(474,15,'112404023','San Guillermo'),(475,15,'112404024','San Isidro'),(476,15,'112404025','Sinayawan'),(477,15,'112404026','Tologan'),(478,16,'112406001','Abnate'),(479,16,'112406002','Bagong Negros'),(480,16,'112406003','Bagong Silang'),(481,16,'112406004','Bagumbayan'),(482,16,'112406005','Balasiao'),(483,16,'112406007','Bonifacio'),(484,16,'112406032','Bulol-Salo'),(485,16,'112406008','Bunot'),(486,16,'112406009','Cogon-Bacaca'),(487,16,'112406010','Dapok'),(488,16,'112406011','Ihan'),(489,16,'112406012','Kibongbong'),(490,16,'112406013','Kimlawis'),(491,16,'112406015','Kisulan'),(492,16,'112406016','Lati-an'),(493,16,'112406017','Manual'),(494,16,'112406018','Maraga-a'),(495,16,'112406019','Molopolo'),(496,16,'112406020','New Sibonga'),(497,16,'112406021','Panaglib'),(498,16,'112406022','Pasig'),(499,16,'112406023','Poblacion'),(500,16,'112406024','Pocaleel'),(501,16,'112406025','San Isidro'),(502,16,'112406026','San Jose'),(503,16,'112406027','San Pedro'),(504,16,'112406028','Santo Niño'),(505,16,'112406029','Tacub'),(506,16,'112406030','Tacul'),(507,16,'112406031','Waterfall'),(508,17,'112407001','Bacungan'),(509,17,'112407002','Balnate'),(510,17,'112407003','Barayong'),(511,17,'112407004','Blocon'),(512,17,'112407005','Dalawinon'),(513,17,'112407006','Dalumay'),(514,17,'112407007','Glamang'),(515,17,'112407008','Kanapulo'),(516,17,'112407009','Kasuga'),(517,17,'112407010','Lower Bala'),(518,17,'112407011','Mabini'),(519,17,'112407021','Maibo'),(520,17,'112407012','Malawanit'),(521,17,'112407013','Malongon'),(522,17,'112407014','New Ilocos'),(523,17,'112407022','New Opon'),(524,17,'112407015','Poblacion'),(525,17,'112407016','San Isidro'),(526,17,'112407017','San Miguel'),(527,17,'112407018','Tacul'),(528,17,'112407019','Tagaytay'),(529,17,'112407020','Upper Bala'),(530,18,'112408019','Bagumbayan'),(531,18,'112408002','Baybay'),(532,18,'112408004','Bolton'),(533,18,'112408005','Bulacan'),(534,18,'112408006','Caputian'),(535,18,'112408007','Ibo'),(536,18,'112408009','Kiblagon'),(537,18,'112408010','Lapu-Lapu'),(538,18,'112408011','Mabini'),(539,18,'112408014','New Baclayon'),(540,18,'112408015','Pitu'),(541,18,'112408016','Poblacion'),(542,18,'112408020','Rizal'),(543,18,'112408021','San Isidro'),(544,18,'112408018','Tagansule'),(545,19,'112410001','Asbang'),(546,19,'112410002','Asinan'),(547,19,'112410003','Bagumbayan'),(548,19,'112410004','Bangkal'),(549,19,'112410005','Buas'),(550,19,'112410006','Buri'),(551,19,'112410021','Cabligan'),(552,19,'112410007','Camanchiles'),(553,19,'112410008','Ceboza'),(554,19,'112410009','Colonsabak'),(555,19,'112410010','Dongan-Pekong'),(556,19,'112410012','Kabasagan'),(557,19,'112410013','Kapok'),(558,19,'112410014','Kauswagan'),(559,19,'112410015','Kibao'),(560,19,'112410016','La Suerte'),(561,19,'112410017','Langa-an'),(562,19,'112410019','Lower Marber'),(563,19,'112410022','Manga'),(564,19,'112410023','New Katipunan'),(565,19,'112410024','New Murcia'),(566,19,'112410025','New Visayas'),(567,19,'112410026','Poblacion'),(568,19,'112410027','Saboy'),(569,19,'112410028','San Jose'),(570,19,'112410029','San Miguel'),(571,19,'112410030','San Vicente'),(572,19,'112410031','Saub'),(573,19,'112410032','Sinaragan'),(574,19,'112410033','Sinawilan'),(575,19,'112410034','Tamlangon'),(576,19,'112410036','Tibongbong'),(577,19,'112410035','Towak'),(578,20,'112411001','Almendras (Pob.)'),(579,20,'112411002','Don Sergio Osmeña, Sr.'),(580,20,'112411003','Harada Butai'),(581,20,'112411004','Lower Katipunan'),(582,20,'112411005','Lower Limonzo'),(583,20,'112411006','Lower Malinao'),(584,20,'112411007','N C Ordaneza District (Pob.)'),(585,20,'112411008','Northern Paligue'),(586,20,'112411009','Palili'),(587,20,'112411010','Piape'),(588,20,'112411011','Punta Piape'),(589,20,'112411012','Quirino District (Pob.)'),(590,20,'112411013','San Isidro'),(591,20,'112411014','Southern Paligue'),(592,20,'112411015','Tulogan'),(593,20,'112411016','Upper Limonzo'),(594,20,'112411017','Upper Malinao'),(595,21,'112412001','Astorga'),(596,21,'112412002','Bato'),(597,21,'112412003','Coronon'),(598,21,'112412004','Darong'),(599,21,'112412005','Inawayan'),(600,21,'112412006','Jose Rizal'),(601,21,'112412009','Matutungan'),(602,21,'112412010','Melilia'),(603,21,'112412013','Saliducon'),(604,21,'112412014','Sibulan'),(605,21,'112412015','Sinoron'),(606,21,'112412016','Tagabuli'),(607,21,'112412017','Tibolo'),(608,21,'112412018','Tuban'),(609,21,'112412011','Zone I (Pob.)'),(610,21,'112412019','Zone II (Pob.)'),(611,21,'112412020','Zone III (Pob.)'),(612,21,'112412021','Zone IV (Pob.)'),(613,22,'112414001','Balasinon'),(614,22,'112414002','Buguis'),(615,22,'112414003','Carre'),(616,22,'112414004','Clib'),(617,22,'112414005','Harada Butai'),(618,22,'112414006','Katipunan'),(619,22,'112414007','Kiblagon'),(620,22,'112414008','Labon'),(621,22,'112414009','Laperas'),(622,22,'112414010','Lapla'),(623,22,'112414011','Litos'),(624,22,'112414012','Luparan'),(625,22,'112414013','Mckinley'),(626,22,'112414014','New Cebu'),(627,22,'112414015','Osmeña'),(628,22,'112414016','Palili'),(629,22,'112414017','Parame'),(630,22,'112414018','Poblacion'),(631,22,'112414020','Roxas'),(632,22,'112414021','Solongvale'),(633,22,'112414022','Tagolilong'),(634,22,'112414023','Tala-o'),(635,22,'112414024','Talas'),(636,22,'112414025','Tanwalang'),(637,22,'112414026','Waterfall'),(638,23,'112501001','Baculin'),(639,23,'112501002','Banao'),(640,23,'112501003','Batawan'),(641,23,'112501004','Batiano'),(642,23,'112501005','Binondo'),(643,23,'112501006','Bobonao'),(644,23,'112501007','Campawan'),(645,23,'112501008','Central (Pob.)'),(646,23,'112501009','Dapnan'),(647,23,'112501010','Kinablangan'),(648,23,'112501011','Lambajon'),(649,23,'112501017','Lucod'),(650,23,'112501012','Mahanub'),(651,23,'112501013','Mikit'),(652,23,'112501014','Salingcomot'),(653,23,'112501015','San Isidro'),(654,23,'112501016','San Victor'),(655,23,'112501018','Saoquegue'),(656,24,'112502001','Cabangcalan'),(657,24,'112502002','Caganganan'),(658,24,'112502003','Calubihan'),(659,24,'112502004','Causwagan'),(660,24,'112502006','Mahayag'),(661,24,'112502007','Maputi'),(662,24,'112502008','Mogbongcogon'),(663,24,'112502009','Panikian'),(664,24,'112502010','Pintatagan'),(665,24,'112502011','Piso Proper'),(666,24,'112502012','Poblacion'),(667,24,'112502005','Punta Linao'),(668,24,'112502014','Rang-ay'),(669,24,'112502013','San Vicente'),(670,25,'112503002','Caatihan'),(671,25,'112503001','Cabasagan'),(672,25,'112503007','Carmen'),(673,25,'112503003','Cawayanan'),(674,25,'112503004','Poblacion'),(675,25,'112503005','San Jose'),(676,25,'112503006','Sibajay'),(677,25,'112503008','Simulao'),(678,26,'112504001','Alvar'),(679,26,'112504002','Caningag'),(680,26,'112504004','Don Leon Balante'),(681,26,'112504005','Lamiawan'),(682,26,'112504006','Manorigao'),(683,26,'112504007','Mercedes'),(684,26,'112504008','Palma Gil'),(685,26,'112504009','Pichon'),(686,26,'112504010','Poblacion'),(687,26,'112504011','San Antonio'),(688,26,'112504012','San Jose'),(689,26,'112504013','San Luis'),(690,26,'112504014','San Miguel'),(691,26,'112504015','San Pedro'),(692,26,'112504016','Santa Fe'),(693,26,'112504017','Santiago'),(694,26,'112504018','Sobrecarey'),(695,27,'112505001','Abijod'),(696,27,'112505002','Alegria'),(697,27,'112505003','Aliwagwag'),(698,27,'112505004','Aragon'),(699,27,'112505005','Baybay'),(700,27,'112505009','Maglahus'),(701,27,'112505010','Mainit'),(702,27,'112505011','Malibago'),(703,27,'112505019','Poblacion'),(704,27,'112505012','San Alfonso'),(705,27,'112505013','San Antonio'),(706,27,'112505014','San Miguel'),(707,27,'112505015','San Rafael'),(708,27,'112505016','San Vicente'),(709,27,'112505017','Santa Filomena'),(710,27,'112505018','Taytayan'),(711,28,'112506001','Anitap'),(712,28,'112506020','Crispin Dela Cruz'),(713,28,'112506003','Don Aurelio Chicote'),(714,28,'112506004','Lavigan'),(715,28,'112506005','Luzon'),(716,28,'112506006','Magdug'),(717,28,'112506002','Manuel Roxas'),(718,28,'112506007','Monserrat'),(719,28,'112506008','Nangan'),(720,28,'112506009','Oregon'),(721,28,'112506010','Poblacion'),(722,28,'112506011','Pundaguitan'),(723,28,'112506012','Sergio Osmeña'),(724,28,'112506013','Surop'),(725,28,'112506014','Tagabebe'),(726,28,'112506015','Tamban'),(727,28,'112506016','Tandang Sora'),(728,28,'112506017','Tibanban'),(729,28,'112506018','Tiblawan'),(730,28,'112506019','Upper Tibanban'),(731,29,'112507001','Bagumbayan'),(732,29,'112507003','Cabadiangan'),(733,29,'112507006','Calapagan'),(734,29,'112507008','Cocornon'),(735,29,'112507009','Corporacion'),(736,29,'112507010','Don Mariano Marcos'),(737,29,'112507011','Ilangay'),(738,29,'112507013','Langka'),(739,29,'112507014','Lantawan'),(740,29,'112507015','Limbahan'),(741,29,'112507016','Macangao'),(742,29,'112507017','Magsaysay'),(743,29,'112507019','Mahayahay'),(744,29,'112507021','Maragatas'),(745,29,'112507022','Marayag'),(746,29,'112507024','New Visayas'),(747,29,'112507028','Poblacion'),(748,29,'112507029','San Isidro'),(749,29,'112507030','San Jose'),(750,29,'112507032','Tagboa'),(751,29,'112507033','Tagugpo'),(752,30,'112508001','Capasnan'),(753,30,'112508002','Cayawan'),(754,30,'112508003','Central (Pob.)'),(755,30,'112508004','Concepcion'),(756,30,'112508006','Del Pilar'),(757,30,'112508007','Guza'),(758,30,'112508008','Holy Cross'),(759,30,'112508018','Lambog'),(760,30,'112508009','Mabini'),(761,30,'112508010','Manreza'),(762,30,'112508016','New Taokanga'),(763,30,'112508011','Old Macopa'),(764,30,'112508012','Rizal'),(765,30,'112508013','San Fermin'),(766,30,'112508014','San Ignacio'),(767,30,'112508015','San Isidro'),(768,30,'112508017','Zaragosa'),(769,31,'112509001','Badas'),(770,31,'112509002','Bobon'),(771,31,'112509003','Buso'),(772,31,'112509004','Cabuaya'),(773,31,'112509005','Central (Pob.)'),(774,31,'112509006','Culian'),(775,31,'112509007','Dahican'),(776,31,'112509008','Danao'),(777,31,'112509009','Dawan'),(778,31,'112509010','Don Enrique Lopez'),(779,31,'112509011','Don Martin Marundan'),(780,31,'112509012','Don Salvador Lopez, Sr.'),(781,31,'112509013','Langka'),(782,31,'112509015','Lawigan'),(783,31,'112509016','Libudon'),(784,31,'112509017','Luban'),(785,31,'112509018','Macambol'),(786,31,'112509019','Mamali'),(787,31,'112509020','Matiao'),(788,31,'112509021','Mayo'),(789,31,'112509022','Sainz'),(790,31,'112509023','Sanghay'),(791,31,'112509024','Tagabakid'),(792,31,'112509025','Tagbinonga'),(793,31,'112509026','Taguibo'),(794,31,'112509027','Tamisan'),(795,32,'112510001','Baon'),(796,32,'112510012','Batobato (Pob.)'),(797,32,'112510003','Bitaogan'),(798,32,'112510004','Cambaleon'),(799,32,'112510005','Dugmanon'),(800,32,'112510006','Iba'),(801,32,'112510007','La Union'),(802,32,'112510008','Lapu-lapu'),(803,32,'112510009','Maag'),(804,32,'112510010','Manikling'),(805,32,'112510011','Maputi'),(806,32,'112510013','San Miguel'),(807,32,'112510014','San Roque'),(808,32,'112510015','Santo Rosario'),(809,32,'112510016','Sudlon'),(810,32,'112510017','Talisay'),(811,33,'112511001','Cabagayan'),(812,33,'112511002','Central (Pob.)'),(813,33,'112511003','Dadong'),(814,33,'112511004','Jovellar'),(815,33,'112511005','Limot'),(816,33,'112511006','Lucatan'),(817,33,'112511007','Maganda'),(818,33,'112511008','Ompao'),(819,33,'112511010','Tomoaong'),(820,33,'112511011','Tubaon'),(821,34,'118201016','Aurora'),(822,34,'118201001','Bagongon'),(823,34,'118201002','Gabi'),(824,34,'118201003','Lagab'),(825,34,'118201004','Mangayon'),(826,34,'118201005','Mapaca'),(827,34,'118201006','Maparat'),(828,34,'118201007','New Alegria'),(829,34,'118201008','Ngan'),(830,34,'118201009','Osmeña'),(831,34,'118201010','Panansalan'),(832,34,'118201011','Poblacion'),(833,34,'118201012','San Jose'),(834,34,'118201013','San Miguel'),(835,34,'118201014','Siocon'),(836,34,'118201015','Tamia'),(837,35,'118202001','Aguinaldo'),(838,35,'118202016','Amor Cruz'),(839,35,'118202017','Ampawid'),(840,35,'118202018','Andap'),(841,35,'118202019','Anitap'),(842,35,'118202020','Bagong Silang'),(843,35,'118202002','Banbanon'),(844,35,'118202021','Belmonte'),(845,35,'118202003','Binasbas'),(846,35,'118202022','Bullucan'),(847,35,'118202004','Cebulida'),(848,35,'118202023','Concepcion'),(849,35,'118202024','Datu Ampunan'),(850,35,'118202025','Datu Davao'),(851,35,'118202026','Doña Josefa'),(852,35,'118202027','El Katipunan'),(853,35,'118202005','Il Papa'),(854,35,'118202028','Imelda'),(855,35,'118202029','Inacayan'),(856,35,'118202006','Kaligutan'),(857,35,'118202007','Kapatagan'),(858,35,'118202008','Kidawa'),(859,35,'118202009','Kilagding'),(860,35,'118202010','Kiokmay'),(861,35,'118202014','Laac (Pob.)'),(862,35,'118202011','Langtud'),(863,35,'118202012','Longanapan'),(864,35,'118202030','Mabuhay'),(865,35,'118202031','Macopa'),(866,35,'118202032','Malinao'),(867,35,'118202033','Mangloy'),(868,35,'118202034','Melale'),(869,35,'118202013','Naga'),(870,35,'118202035','New Bethlehem'),(871,35,'118202036','Panamoren'),(872,35,'118202037','Sabud'),(873,35,'118202015','San Antonio'),(874,35,'118202038','Santa Emilia'),(875,35,'118202039','Santo Niño'),(876,35,'118202040','Sisimon'),(877,36,'118203012','Anitapan'),(878,36,'118203013','Cabuyuan'),(879,36,'118203002','Cadunan'),(880,36,'118203007','Cuambog (Pob.)'),(881,36,'118203014','Del Pilar'),(882,36,'118203016','Golden Valley'),(883,36,'118203015','Libodon'),(884,36,'118203017','Pangibiran'),(885,36,'118203006','Pindasan'),(886,36,'118203018','San Antonio'),(887,36,'118203011','Tagnanan'),(888,37,'118204001','Anibongan'),(889,37,'118204002','Anislagan'),(890,37,'118204003','Binuangan'),(891,37,'118204004','Bucana'),(892,37,'118204005','Calabcab'),(893,37,'118204006','Concepcion'),(894,37,'118204007','Dumlan'),(895,37,'118204008','Elizalde'),(896,37,'118204010','Gubatan'),(897,37,'118204011','Hijo'),(898,37,'118204012','Kinuban'),(899,37,'118204013','Langgam'),(900,37,'118204014','Lapu-lapu'),(901,37,'118204015','Libay-libay'),(902,37,'118204016','Limbo'),(903,37,'118204017','Lumatab'),(904,37,'118204018','Magangit'),(905,37,'118204031','Mainit'),(906,37,'118204019','Malamodao'),(907,37,'118204020','Manipongol'),(908,37,'118204021','Mapaang'),(909,37,'118204022','Masara'),(910,37,'118204023','New Asturias'),(911,37,'118204032','New Barili'),(912,37,'118204033','New Leyte'),(913,37,'118204034','New Visayas'),(914,37,'118204035','Panangan'),(915,37,'118204009','Pangi'),(916,37,'118204024','Panibasan'),(917,37,'118204025','Panoraon'),(918,37,'118204026','Poblacion'),(919,37,'118204027','San Juan'),(920,37,'118204028','San Roque'),(921,37,'118204029','Sangab'),(922,37,'118204036','Tagbaros'),(923,37,'118204030','Taglawig'),(924,37,'118204037','Teresa'),(925,38,'118205001','Bagong Silang'),(926,38,'118205006','Bahi'),(927,38,'118205007','Cambagang'),(928,38,'118205008','Coronobe'),(929,38,'118205009','Katipunan'),(930,38,'118205010','Lahi'),(931,38,'118205011','Langgawisan'),(932,38,'118205012','Mabugnao'),(933,38,'118205013','Magcagong'),(934,38,'118205014','Mahayahay'),(935,38,'118205002','Mapawa'),(936,38,'118205003','Maragusan (Pob.)'),(937,38,'118205015','Mauswagon'),(938,38,'118205004','New Albay'),(939,38,'118205016','New Katipunan'),(940,38,'118205017','New Manay'),(941,38,'118205018','New Panay'),(942,38,'118205019','Paloc'),(943,38,'118205020','Pamintaran'),(944,38,'118205021','Parasanon'),(945,38,'118205022','Talian'),(946,38,'118205023','Tandik'),(947,38,'118205024','Tigbao'),(948,38,'118205005','Tupas'),(949,39,'118206001','Andili'),(950,39,'118206002','Bawani'),(951,39,'118206003','Concepcion'),(952,39,'118206004','Malinawon'),(953,39,'118206005','Nueva Visayas'),(954,39,'118206006','Nuevo Iloco'),(955,39,'118206007','Poblacion'),(956,39,'118206008','Salvacion'),(957,39,'118206009','Saosao'),(958,39,'118206010','Sawangan'),(959,39,'118206011','Tuboran'),(960,40,'118207001','Awao'),(961,40,'118207002','Babag'),(962,40,'118207003','Banlag'),(963,40,'118207004','Baylo'),(964,40,'118207005','Casoon'),(965,40,'118207007','Haguimitan'),(966,40,'118207006','Inambatan'),(967,40,'118207008','Macopa'),(968,40,'118207009','Mamunga'),(969,40,'118207022','Mount Diwata'),(970,40,'118207010','Naboc'),(971,40,'118207011','Olaycon'),(972,40,'118207012','Pasian'),(973,40,'118207013','Poblacion'),(974,40,'118207014','Rizal'),(975,40,'118207015','Salvacion'),(976,40,'118207016','San Isidro'),(977,40,'118207017','San Jose'),(978,40,'118207019','Tubo-tubo'),(979,40,'118207021','Union'),(980,40,'118207020','Upper Ulip'),(981,41,'118208001','Banagbanag'),(982,41,'118208002','Banglasan'),(983,41,'118208003','Bankerohan Norte'),(984,41,'118208004','Bankerohan Sur'),(985,41,'118208005','Camansi'),(986,41,'118208006','Camantangan'),(987,41,'118208009','Canidkid'),(988,41,'118208007','Concepcion'),(989,41,'118208008','Dauman'),(990,41,'118208010','Lebanon'),(991,41,'118208011','Linoan'),(992,41,'118208012','Mayaon'),(993,41,'118208014','New Calape'),(994,41,'118208016','New Cebulan'),(995,41,'118208015','New Dalaguete'),(996,41,'118208017','New Visayas'),(997,41,'118208019','Prosperidad'),(998,41,'118208020','San Jose (Pob.)'),(999,41,'118208021','San Vicente'),(1000,41,'118208022','Tapia'),(1001,42,'118209001','Anislagan'),(1002,42,'118209002','Antequera'),(1003,42,'118209003','Basak'),(1004,42,'118209027','Bayabas'),(1005,42,'118209028','Bukal'),(1006,42,'118209004','Cabacungan'),(1007,42,'118209005','Cabidianan'),(1008,42,'118209006','Katipunan'),(1009,42,'118209007','Libasan'),(1010,42,'118209008','Linda'),(1011,42,'118209009','Magading'),(1012,42,'118209010','Magsaysay'),(1013,42,'118209011','Mainit'),(1014,42,'118209012','Manat'),(1015,42,'118209013','Matilo'),(1016,42,'118209014','Mipangi'),(1017,42,'118209015','New Dauis'),(1018,42,'118209016','New Sibonga'),(1019,42,'118209017','Ogao'),(1020,42,'118209018','Pangutosan'),(1021,42,'118209019','Poblacion'),(1022,42,'118209020','San Isidro'),(1023,42,'118209021','San Roque'),(1024,42,'118209022','San Vicente'),(1025,42,'118209023','Santa Maria'),(1026,42,'118209024','Santo Niño'),(1027,42,'118209025','Sasa'),(1028,42,'118209026','Tagnocon'),(1029,43,'118210013','Andap'),(1030,43,'118210001','Bantacan'),(1031,43,'118210002','Batinao'),(1032,43,'118210011','Cabinuangan (Pob.)'),(1033,43,'118210003','Camanlangan'),(1034,43,'118210004','Cogonon'),(1035,43,'118210005','Fatima'),(1036,43,'118210014','Kahayag'),(1037,43,'118210006','Katipunan'),(1038,43,'118210008','Magangit'),(1039,43,'118210007','Magsaysay'),(1040,43,'118210015','Manurigao'),(1041,43,'118210009','Pagsabangan'),(1042,43,'118210010','Panag'),(1043,43,'118210012','San Roque'),(1044,43,'118210016','Tandawan'),(1045,44,'118211013','Araibo'),(1046,44,'118211001','Bongabong'),(1047,44,'118211002','Bongbong'),(1048,44,'118211004','Kingking (Pob.)'),(1049,44,'118211012','Las Arenas'),(1050,44,'118211005','Magnaga'),(1051,44,'118211006','Matiao'),(1052,44,'118211007','Napnapan'),(1053,44,'118211003','P. Fuentes'),(1054,44,'118211009','Tagdangua'),(1055,44,'118211014','Tag-Ugpo'),(1056,44,'118211010','Tambongon'),(1057,44,'118211011','Tibagon'),(1058,45,'118601007','Baluntaya'),(1059,45,'118601001','Calian'),(1060,45,'118601008','Dalupan'),(1061,45,'118601009','Kinanga'),(1062,45,'118601002','Kiobog'),(1063,45,'118601010','Lanao'),(1064,45,'118601011','Lapuan'),(1065,45,'118601004','Lawa (Pob.)'),(1066,45,'118601012','Linadasan'),(1067,45,'118601013','Mabuhay'),(1068,45,'118601003','North Lamidan'),(1069,45,'118601005','Nueva Villa'),(1070,45,'118601014','South Lamidan'),(1071,45,'118601006','Talagutong (Pob.)'),(1072,45,'118601015','West Lamidan'),(1073,46,'118602002','Balangonan'),(1074,46,'118602001','Buguis'),(1075,46,'118602006','Bukid'),(1076,46,'118602007','Butuan'),(1077,46,'118602008','Butulan'),(1078,46,'118602009','Caburan Big'),(1079,46,'118602010','Caburan Small (Pob.)'),(1080,46,'118602011','Camalian'),(1081,46,'118602012','Carahayan'),(1082,46,'118602013','Cayaponga'),(1083,46,'118602014','Culaman'),(1084,46,'118602015','Kalbay'),(1085,46,'118602016','Kitayo'),(1086,46,'118602019','Magulibas'),(1087,46,'118602020','Malalan'),(1088,46,'118602021','Mangile'),(1089,46,'118602022','Marabutuan'),(1090,46,'118602023','Meybio'),(1091,46,'118602024','Molmol'),(1092,46,'118602025','Nuing'),(1093,46,'118602026','Patulang'),(1094,46,'118602027','Quiapo'),(1095,46,'118602028','San Isidro'),(1096,46,'118602033','Sugal'),(1097,46,'118602034','Tabayon'),(1098,46,'118602035','Tanuman'),(1099,47,'118603001','Bito'),(1100,47,'118603002','Bolila'),(1101,47,'118603003','Buhangin'),(1102,47,'118603004','Culaman'),(1103,47,'118603005','Datu Danwata'),(1104,47,'118603006','Demoloc'),(1105,47,'118603007','Felis'),(1106,47,'118603008','Fishing Village'),(1107,47,'118603010','Kibalatong'),(1108,47,'118603011','Kidalapong'),(1109,47,'118603012','Kilalag'),(1110,47,'118603013','Kinangan'),(1111,47,'118603016','Lacaron'),(1112,47,'118603017','Lagumit'),(1113,47,'118603018','Lais'),(1114,47,'118603022','Little Baguio'),(1115,47,'118603023','Macol'),(1116,47,'118603024','Mana'),(1117,47,'118603025','Manuel Peralta'),(1118,47,'118603027','New Argao'),(1119,47,'118603041','Pangaleon'),(1120,47,'118603030','Pangian'),(1121,47,'118603031','Pinalpalan'),(1122,47,'118603032','Poblacion'),(1123,47,'118603033','Sangay'),(1124,47,'118603036','Talogoy'),(1125,47,'118603037','Tical'),(1126,47,'118603038','Ticulon'),(1127,47,'118603039','Tingolo'),(1128,47,'118603040','Tubalan'),(1129,48,'118604001','Basiawan'),(1130,48,'118604002','Buca'),(1131,48,'118604003','Cadaatan'),(1132,48,'118604021','Datu Daligasao'),(1133,48,'118604022','Datu Intan'),(1134,48,'118604004','Kidadan'),(1135,48,'118604023','Kinilidan'),(1136,48,'118604005','Kisulad'),(1137,48,'118604006','Malalag Tubig'),(1138,48,'118604007','Mamacao'),(1139,48,'118604008','Ogpao'),(1140,48,'118604009','Poblacion'),(1141,48,'118604010','Pongpong'),(1142,48,'118604011','San Agustin'),(1143,48,'118604012','San Antonio'),(1144,48,'118604013','San Isidro'),(1145,48,'118604014','San Juan'),(1146,48,'118604015','San Pedro'),(1147,48,'118604016','San Roque'),(1148,48,'118604019','Santo Niño'),(1149,48,'118604020','Santo Rosario'),(1150,48,'118604018','Tanglad'),(1151,49,'118605001','Batuganding'),(1152,49,'118605008','Camahual'),(1153,49,'118605009','Camalig'),(1154,49,'118605010','Gomtago'),(1155,49,'118605002','Konel'),(1156,49,'118605006','Laker'),(1157,49,'118605003','Lipol'),(1158,49,'118605004','Mabila (Pob.)'),(1159,49,'118605005','Patuco'),(1160,49,'118605011','Tagen'),(1161,49,'118605007','Tinina'),(1162,49,'118605012','Tucal');

INSERT INTO `roles` VALUES ('32ec716c-f114-4573-b5bd-6ba6bafa8a0d','Accountant','ACCOUNTANT',NULL),('74a9e42d-a2c4-43db-825b-39a9fd44f416','Staff','STAFF',NULL),('9b3f65e5-6d08-4f5f-9696-a16a1b448cfa','Admin','ADMIN',NULL),('dbdf5fcd-bd6a-4363-8b3e-d849c0a1fbf5','Auditor','AUDITOR',NULL);

INSERT INTO `users` VALUES ('f7aad99d-7100-4878-bb98-fe925df5c4d3','TaxSync Administrator',1,'2026-05-10 13:30:35.668658','admin@taxsync.gov.ph','ADMIN@TAXSYNC.GOV.PH','admin@taxsync.gov.ph','ADMIN@TAXSYNC.GOV.PH',1,'AQAAAAIAAYagAAAAEHtY29Eu5gkSmOFslS6xao9525IYBsOy4hoIpnLSodZEK/kLt29d1EKSo0pXiSi8sw==','HWPZ2IDCSGJUX35IXTZXAIIKXSGQSNZC','c4222dc2-f5f8-4530-8668-a4da61c3725a',NULL,0,0,NULL,1,0);

INSERT INTO `userroles` VALUES ('f7aad99d-7100-4878-bb98-fe925df5c4d3','9b3f65e5-6d08-4f5f-9696-a16a1b448cfa');
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

