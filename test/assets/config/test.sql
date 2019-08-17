/*
Navicat MySQL Data Transfer
Date: 2019-01-08 09:58:52

DROP DATABASE `mytest`;
CREATE DATABASE `mytest` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
use `mytest`;
source /mnt/hgfs/server/test/test/asserts/sql/mytest.sql;
*/

-- DROP DATABASE `demo`;
-- CREATE DATABASE `demo` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
-- use `demo`;

SET FOREIGN_KEY_CHECKS=0;


-- ----------------------------
-- Table structure for User
-- ----------------------------
DROP TABLE IF EXISTS `User`;
CREATE TABLE `User` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `sex` tinyint(4) DEFAULT 0,
    `loginname` varchar(64) NOT NULL,
    `nickname` varchar(64) NOT NULL,
    `portrait` int(11),
    `pass` varchar(128),
    `email` varchar(128),
    `url` varchar(256),
    `profile_image_url` varchar(256),
    `location` varchar(128),
    `signature` varchar(256),
    `profile` varchar(256),
    `weibo` varchar(256),
    `avatar` varchar(256),
    `githubId` int(11),
    `githubUsername` varchar(64),
    `githubAccessToken` varchar(64),
    `is_block` tinyint(4) DEFAULT 0,

    `score` int DEFAULT 0,
    `topic_count` int DEFAULT 0,
    `reply_count` int DEFAULT 0,
    `follower_count` int DEFAULT 0,
    `following_count` int DEFAULT 0,
    `collect_tag_count` int DEFAULT 0,
    `collect_topic_count` int DEFAULT 0,

    `update_at` int DEFAULT 0,
    `create_at` int DEFAULT 0,
    `is_star` tinyint(4) DEFAULT 0,
    `level` int DEFAULT 0,
    `active` tinyint(4) DEFAULT 0,
    `receive_reply_mail` tinyint(4) DEFAULT 0,
    `receive_at_mail` tinyint(4) DEFAULT 0,
    `from_wp` tinyint(4) DEFAULT 0,

    `retrieve_time` int DEFAULT 0,
    `retrieve_key` varchar(128),
    `accessToken` varchar(128),

    `vdata` blob,
    PRIMARY KEY (`id`),
    UNIQUE KEY `id` (`id`) USING BTREE,
    UNIQUE KEY `loginname` (`loginname`) USING BTREE,
    UNIQUE KEY `githubId` (`githubId`) USING BTREE,
    UNIQUE KEY `email` (`email`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


-- ----------------------------
-- Table structure for Topic
-- ----------------------------
DROP TABLE IF EXISTS `Topic`;
CREATE TABLE `Topic` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `title` varchar(256) NOT NULL,
    `content` text NOT NULL,
    `author_id` bigint(20) NOT NULL,

    `top` tinyint(4) DEFAULT 0,
    `good` tinyint(4) DEFAULT 0,
    `lock` tinyint(4) DEFAULT 0,
    
    `reply_count` int(11) DEFAULT 0,
    `visit_count` int(11) DEFAULT 0,
    `collect_count` int(11) DEFAULT 0,

    `update_at` int DEFAULT 0,
    `create_at` int DEFAULT 0,

    `last_reply` bigint(20),
    `last_reply_at` int DEFAULT 0,

    `content_is_html` tinyint(4) DEFAULT 0,
    `tab` varchar(64),
    `deleted` tinyint(4) DEFAULT 0,

    `vdata` blob,
    PRIMARY KEY (`id`),
    UNIQUE KEY `id` (`id`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for TopicCollect
-- ----------------------------
DROP TABLE IF EXISTS `TopicCollect`;
CREATE TABLE `TopicCollect` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `user_id` bigint(4) NOT NULL,
    `topic_id` bigint(4) NOT NULL,
    `create_at` int DEFAULT 0,
    `vdata` blob,
    PRIMARY KEY (`id`),
    UNIQUE KEY `id` (`id`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for Reply
-- ----------------------------
DROP TABLE IF EXISTS `Reply`;
CREATE TABLE `Reply` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `content` text NOT NULL,
    `topic_id` bigint(4) NOT NULL,
    `author_id` bigint(4) NOT NULL,
    `reply_id` bigint(4) NOT NULL,
    `update_at` int DEFAULT 0,
    `create_at` int DEFAULT 0,
    `content_is_html` tinyint(4) DEFAULT 0,
    `deleted` tinyint(4) DEFAULT 0,
    `ups` blob,
    `vdata` blob,
    PRIMARY KEY (`id`),
    UNIQUE KEY `id` (`id`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for Message
-- ----------------------------
DROP TABLE IF EXISTS `Message`;
CREATE TABLE `Message` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `type` varchar(64) NOT NULL,
    `master_id` bigint(4) NOT NULL,
    `author_id` bigint(4) NOT NULL,
    `topic_id` bigint(4) NOT NULL,
    `reply_id` bigint(4) NOT NULL,
    `create_at` int DEFAULT 0,
    `has_read` tinyint(4) DEFAULT 0,
    `vdata` blob,
    PRIMARY KEY (`id`),
    UNIQUE KEY `id` (`id`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for Session
-- ----------------------------
DROP TABLE IF EXISTS `Session`;
CREATE TABLE `Session` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `sessionid` varchar(64) NOT NULL,
    `create_at` int DEFAULT 0,
    `update_at` int DEFAULT 0,
    `referer` varchar(256),
    `req_url` varchar(256),
    `vdata` blob,
    PRIMARY KEY (`id`),
    UNIQUE KEY `id` (`id`) USING BTREE,
    UNIQUE KEY `sessionid` (`sessionid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for Cache
-- ----------------------------
DROP TABLE IF EXISTS `Cache`;
CREATE TABLE `Cache` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `ckey` varchar(256) NOT NULL,
    `create_at` int DEFAULT 0,
    `update_at` int DEFAULT 0,
    `deadline` int DEFAULT 0,
    `timeout` int DEFAULT 0,
    `vdata` blob,
    PRIMARY KEY (`id`),
    UNIQUE KEY `id` (`id`) USING BTREE,
    UNIQUE KEY `ckey` (`ckey`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
