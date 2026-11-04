# ************************************************************
# Sequel Pro SQL dump
# Version 4096
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: localhost (MySQL 5.5.33)
# Database: ci_codeclub
# Generation Time: 2013-11-21 08:50:41 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table dances
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dances`;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table dances_robots
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dances_robots`;

CREATE TABLE `dances_robots` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `dance_id` int(11) DEFAULT NULL,
  `robot_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table dances_soundtracks
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dances_soundtracks`;

CREATE TABLE `dances_soundtracks` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `dance_id` int(11) DEFAULT NULL,
  `soundtrack_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table dances_users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dances_users`;

CREATE TABLE `dances_users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `dance_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table robots
# ------------------------------------------------------------

DROP TABLE IF EXISTS `robots`;

CREATE TABLE `robots` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Data help in puppets.json',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table soundtracks
# ------------------------------------------------------------

DROP TABLE IF EXISTS `soundtracks`;

CREATE TABLE `soundtracks` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

-- ------------------------------------------------------------
-- Test data: fake owners, one row per case the import must handle.
-- Regenerate test/fixtures/legacy_dump.sql from this file as described
-- in tools/legacy_import/README.md.
-- ------------------------------------------------------------

SET NAMES utf8;

INSERT INTO robots (id) VALUES (1),(2),(3),(4),(5),(6),(7);
INSERT INTO soundtracks (id) VALUES (1),(2),(3),(4);
INSERT INTO users (id, uuid) VALUES
  (1, '11111111-2222-4333-8444-555555555555'),
  (2, '99999999-8888-4777-8666-555555555555'),
  (3, '33333333-3333-4333-8333-333333333333'); -- a visitor who never saved a dance

INSERT INTO dances (id, robot_name, robot_still, guid, move, votes, date_created, date_updated, is_entered_into_comp) VALUES
  -- The live example dance, exactly as the PHP API stored it
  (101, 'Lieutenant Jigalot Code', '', '6aea71ac6af51', '{"masterTempo":"1","neck_tempoMultiplier":"1","neck_upDown":"2.6","neck_leftRight":"9.4","rightForearm_reverse":"","rightForearm_tempoMultiplier":"1","rightForearm_amount":"33","rightForearm_angle":"0","rightUpperArm_reverse":"","rightUpperArm_tempoMultiplier":"0.5","rightUpperArm_amount":"98","rightUpperArm_angle":"129","leftForearm_reverse":"1","leftForearm_tempoMultiplier":"1","leftForearm_amount":"37","leftForearm_angle":"0","leftUpperArm_reverse":"1","leftUpperArm_tempoMultiplier":"0.5","leftUpperArm_amount":"105","leftUpperArm_angle":"146","hips_tempoMultiplier":"1","hips_upDown":"20","hips_leftRight":"6.4"}', 0, 1793749420, 1793749420, 0),
  -- Non-ASCII name, entered into the competition, with an old robot_still image
  (102, 'Señor Groove Byte', X'89504E470D0A1A0A0027225C0A', '5281068541414', '{"masterTempo":"0.5","neck_tempoMultiplier":"1","neck_upDown":"2.6","neck_leftRight":"9.4","rightForearm_reverse":"","rightForearm_tempoMultiplier":"1","rightForearm_amount":"33","rightForearm_angle":"0","rightUpperArm_reverse":"","rightUpperArm_tempoMultiplier":"0.5","rightUpperArm_amount":"98","rightUpperArm_angle":"129","leftForearm_reverse":"1","leftForearm_tempoMultiplier":"1","leftForearm_amount":"37","leftForearm_angle":"0","leftUpperArm_reverse":"1","leftUpperArm_tempoMultiplier":"0.5","leftUpperArm_amount":"105","leftUpperArm_angle":"146","hips_tempoMultiplier":"1","hips_upDown":"20","hips_leftRight":"6.4"}', 3, 1384187525, 1384190000, 1),
  -- Quote and backslash in the name
  (103, 'Captain D''Artagnan \\ Slash', '', '5281029d56337', '{"masterTempo":"1","neck_tempoMultiplier":"1","neck_upDown":"2.6","neck_leftRight":"9.4","rightForearm_reverse":"","rightForearm_tempoMultiplier":"1","rightForearm_amount":"33","rightForearm_angle":"0","rightUpperArm_reverse":"","rightUpperArm_tempoMultiplier":"0.5","rightUpperArm_amount":"98","rightUpperArm_angle":"129","leftForearm_reverse":"1","leftForearm_tempoMultiplier":"1","leftForearm_amount":"37","leftForearm_angle":"0","leftUpperArm_reverse":"1","leftUpperArm_tempoMultiplier":"0.5","leftUpperArm_amount":"105","leftUpperArm_angle":"146","hips_tempoMultiplier":"1","hips_upDown":"20","hips_leftRight":"6.4"}', 0, 1384186525, 1384186525, 0),
  -- Same guid as 103: the PHP API always read the lower id
  (104, 'Duplicate Dancer', '', '5281029d56337', '{"masterTempo":"0.5","neck_tempoMultiplier":"1","neck_upDown":"2.6","neck_leftRight":"9.4","rightForearm_reverse":"","rightForearm_tempoMultiplier":"1","rightForearm_amount":"33","rightForearm_angle":"0","rightUpperArm_reverse":"","rightUpperArm_tempoMultiplier":"0.5","rightUpperArm_amount":"98","rightUpperArm_angle":"129","leftForearm_reverse":"1","leftForearm_tempoMultiplier":"1","leftForearm_amount":"37","leftForearm_angle":"0","leftUpperArm_reverse":"1","leftUpperArm_tempoMultiplier":"0.5","leftUpperArm_amount":"105","leftUpperArm_angle":"146","hips_tempoMultiplier":"1","hips_upDown":"20","hips_leftRight":"6.4"}', 0, 1384186999, 1384186999, 0),
  -- Two robot links and two soundtrack links
  (105, 'Double Linked', '', '5281017967e1e', '{"masterTempo":"1","neck_tempoMultiplier":"1","neck_upDown":"2.6","neck_leftRight":"9.4","rightForearm_reverse":"","rightForearm_tempoMultiplier":"1","rightForearm_amount":"33","rightForearm_angle":"0","rightUpperArm_reverse":"","rightUpperArm_tempoMultiplier":"0.5","rightUpperArm_amount":"98","rightUpperArm_angle":"129","leftForearm_reverse":"1","leftForearm_tempoMultiplier":"1","leftForearm_amount":"37","leftForearm_angle":"0","leftUpperArm_reverse":"1","leftUpperArm_tempoMultiplier":"0.5","leftUpperArm_amount":"105","leftUpperArm_angle":"146","hips_tempoMultiplier":"1","hips_upDown":"20","hips_leftRight":"6.4"}', 0, 1384185000, 1384185000, 0),
  -- No owner
  (106, 'Orphan Annie', '', '5280e42a38b40', '{"masterTempo":"1","neck_tempoMultiplier":"1","neck_upDown":"2.6","neck_leftRight":"9.4","rightForearm_reverse":"","rightForearm_tempoMultiplier":"1","rightForearm_amount":"33","rightForearm_angle":"0","rightUpperArm_reverse":"","rightUpperArm_tempoMultiplier":"0.5","rightUpperArm_amount":"98","rightUpperArm_angle":"129","leftForearm_reverse":"1","leftForearm_tempoMultiplier":"1","leftForearm_amount":"37","leftForearm_angle":"0","leftUpperArm_reverse":"1","leftUpperArm_tempoMultiplier":"0.5","leftUpperArm_amount":"105","leftUpperArm_angle":"146","hips_tempoMultiplier":"1","hips_upDown":"20","hips_leftRight":"6.4"}', 0, 1384178000, 1384178000, 0),
  -- Unreadable move
  (107, 'Broken Moves', '', '5280e4e19b9e8', 'not json{', 0, 1384178100, 1384178100, 0),
  -- No timestamps and no soundtrack
  (108, 'Timeless', '', '5280c68fa4b52', '{"masterTempo":"1","neck_tempoMultiplier":"1","neck_upDown":"2.6","neck_leftRight":"9.4","rightForearm_reverse":"","rightForearm_tempoMultiplier":"1","rightForearm_amount":"33","rightForearm_angle":"0","rightUpperArm_reverse":"","rightUpperArm_tempoMultiplier":"0.5","rightUpperArm_amount":"98","rightUpperArm_angle":"129","leftForearm_reverse":"1","leftForearm_tempoMultiplier":"1","leftForearm_amount":"37","leftForearm_angle":"0","leftUpperArm_reverse":"1","leftUpperArm_tempoMultiplier":"0.5","leftUpperArm_amount":"105","leftUpperArm_angle":"146","hips_tempoMultiplier":"1","hips_upDown":"20","hips_leftRight":"6.4"}', 0, NULL, NULL, 0),
  -- Linked to a robot that doesn't exist
  (109, 'Ghost Robot', '', '52aa00000000a', '{"masterTempo":"1","neck_tempoMultiplier":"1","neck_upDown":"2.6","neck_leftRight":"9.4","rightForearm_reverse":"","rightForearm_tempoMultiplier":"1","rightForearm_amount":"33","rightForearm_angle":"0","rightUpperArm_reverse":"","rightUpperArm_tempoMultiplier":"0.5","rightUpperArm_amount":"98","rightUpperArm_angle":"129","leftForearm_reverse":"1","leftForearm_tempoMultiplier":"1","leftForearm_amount":"37","leftForearm_angle":"0","leftUpperArm_reverse":"1","leftUpperArm_tempoMultiplier":"0.5","leftUpperArm_amount":"105","leftUpperArm_angle":"146","hips_tempoMultiplier":"1","hips_upDown":"20","hips_leftRight":"6.4"}', 0, 1386000000, 1386000000, 0),
  -- No guid at all
  (110, 'Nameless', '', NULL, '{"masterTempo":"1","neck_tempoMultiplier":"1","neck_upDown":"2.6","neck_leftRight":"9.4","rightForearm_reverse":"","rightForearm_tempoMultiplier":"1","rightForearm_amount":"33","rightForearm_angle":"0","rightUpperArm_reverse":"","rightUpperArm_tempoMultiplier":"0.5","rightUpperArm_amount":"98","rightUpperArm_angle":"129","leftForearm_reverse":"1","leftForearm_tempoMultiplier":"1","leftForearm_amount":"37","leftForearm_angle":"0","leftUpperArm_reverse":"1","leftUpperArm_tempoMultiplier":"0.5","leftUpperArm_amount":"105","leftUpperArm_angle":"146","hips_tempoMultiplier":"1","hips_upDown":"20","hips_leftRight":"6.4"}', 0, 1386000001, 1386000001, 0),
  -- Linked to a user that doesn't exist
  (111, 'Lost Owner', '', '52aa00000000b', '{"masterTempo":"1","neck_tempoMultiplier":"1","neck_upDown":"2.6","neck_leftRight":"9.4","rightForearm_reverse":"","rightForearm_tempoMultiplier":"1","rightForearm_amount":"33","rightForearm_angle":"0","rightUpperArm_reverse":"","rightUpperArm_tempoMultiplier":"0.5","rightUpperArm_amount":"98","rightUpperArm_angle":"129","leftForearm_reverse":"1","leftForearm_tempoMultiplier":"1","leftForearm_amount":"37","leftForearm_angle":"0","leftUpperArm_reverse":"1","leftUpperArm_tempoMultiplier":"0.5","leftUpperArm_amount":"105","leftUpperArm_angle":"146","hips_tempoMultiplier":"1","hips_upDown":"20","hips_leftRight":"6.4"}', 0, 1386000002, 1386000002, 0),
  -- A second dance for owner 1 with robot 2 (the chooser keeps the last one)
  (112, 'Encore', '', '52aa00000000c', '{"masterTempo":"0.5","neck_tempoMultiplier":"1","neck_upDown":"2.6","neck_leftRight":"9.4","rightForearm_reverse":"","rightForearm_tempoMultiplier":"1","rightForearm_amount":"33","rightForearm_angle":"0","rightUpperArm_reverse":"","rightUpperArm_tempoMultiplier":"0.5","rightUpperArm_amount":"98","rightUpperArm_angle":"129","leftForearm_reverse":"1","leftForearm_tempoMultiplier":"1","leftForearm_amount":"37","leftForearm_angle":"0","leftUpperArm_reverse":"1","leftUpperArm_tempoMultiplier":"0.5","leftUpperArm_amount":"105","leftUpperArm_angle":"146","hips_tempoMultiplier":"1","hips_upDown":"20","hips_leftRight":"6.4"}', 0, 1386000003, 1386000003, 0);

INSERT INTO dances_robots (id, dance_id, robot_id) VALUES
  (1, 101, 1), (2, 102, 2), (3, 103, 3), (4, 104, 3), (5, 105, 4), (6, 105, 5),
  (7, 106, 6), (8, 107, 7), (9, 108, 1), (10, 109, 99), (11, 111, 2), (12, 112, 2);

INSERT INTO dances_soundtracks (id, dance_id, soundtrack_id) VALUES
  (1, 101, 1), (2, 102, 2), (3, 103, 3), (4, 104, 3), (5, 105, 4), (6, 105, 2),
  (7, 106, 4), (8, 107, 1), (9, 109, 2), (10, 111, 1), (11, 112, 3);

INSERT INTO dances_users (id, dance_id, user_id) VALUES
  (1, 101, 1), (2, 102, 1), (3, 103, 2), (4, 104, 2), (5, 105, 1),
  (6, 107, 2), (7, 108, 1), (8, 109, 2), (9, 111, 999), (10, 112, 1);
