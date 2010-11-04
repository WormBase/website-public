DROP DATABASE IF EXISTS wormbase_user;
CREATE DATABASE wormbase_user;
USE wormbase_user;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
            id            INTEGER AUTO_INCREMENT PRIMARY KEY, 
            username      char(100),
            password      char(255),
            email_address char(35),
            first_name    char(35),
            last_name     char(35),
	    active        int(11) 
);

DROP TABLE IF EXISTS roles;
CREATE TABLE roles (
            id   INTEGER PRIMARY KEY,
            role TEXT
);

DROP TABLE IF EXISTS users_to_roles;
CREATE TABLE users_to_roles (
            user_id INTEGER,
            role_id INTEGER,
            PRIMARY KEY (user_id, role_id)
);

DROP TABLE IF EXISTS openid;
CREATE TABLE openid (
            openid_url char(100) PRIMARY KEY,
            user_id INTEGER
            
);
INSERT INTO `roles` VALUES ('1','admin'),('2','curator'),('3','user');
