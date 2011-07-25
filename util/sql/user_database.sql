DROP DATABASE IF EXISTS wormbase_user;
CREATE DATABASE wormbase_user;
USE wormbase_user;
GRANT ALL PRIVILEGES ON `wormbase_user`.* TO 'wormbase'@'localhost';

DROP TABLE IF EXISTS users;
CREATE TABLE users (
            id            INTEGER AUTO_INCREMENT PRIMARY KEY, 
            username      char(255),
            password      char(255),
            first_name    char(100),
            last_name     char(100),
	    twitter       char(100),
	    googleplus    char(100),
	    facebook      char(100),
            gtalk_key	  text,
            active        int(11),
            wbid          char(255),
            wb_link_confirm     BOOLEAN
);

DROP TABLE IF EXISTS email;
CREATE TABLE email(
            user_id INTEGER,
            email char(255),
            validated   BOOLEAN,
            primary_email   BOOLEAN,
            PRIMARY KEY (user_id, email)
);

DROP TABLE IF EXISTS roles;
CREATE TABLE roles (
            role_id   INTEGER PRIMARY KEY,
            role char(255)
);

DROP TABLE IF EXISTS users_to_roles;
CREATE TABLE users_to_roles (
            user_id INTEGER,
            role_id INTEGER,
            PRIMARY KEY (user_id, role_id)
);

DROP TABLE IF EXISTS openid;
CREATE TABLE openid (
            openid_url char(255) PRIMARY KEY,
            user_id INTEGER
            
);

DROP TABLE IF EXISTS comments;
CREATE TABLE comments (
            comment_id INTEGER AUTO_INCREMENT PRIMARY KEY,
            user_id INTEGER,
            page_id INTEGER,
            timestamp INTEGER,
            content TEXT
);

DROP TABLE IF EXISTS issues;
CREATE TABLE issues (
        id INTEGER AUTO_INCREMENT PRIMARY KEY,
	    reporter_id INTEGER,
	    responsible_id INTEGER,
	    title TEXT ,
        page_id INTEGER,
	    timestamp char(50),
	    state char(10),
        severity char(10),
        is_private BOOLEAN,
	    content TEXT 
);

DROP TABLE IF EXISTS issues_threads;
CREATE TABLE issues_threads (
        thread_id  INTEGER,
        issue_id INTEGER,
	    user_id INTEGER,
	    timestamp char(50),
	    content TEXT,
        PRIMARY KEY (thread_id, issue_id)
);

DROP TABLE IF EXISTS starred;
CREATE TABLE starred (
		session_id char(72),
		page_id INTEGER,
        save_to char(50),
        timestamp INTEGER,
        PRIMARY KEY (session_id, page_id)
);

DROP TABLE IF EXISTS pages;
CREATE TABLE pages (
		page_id INTEGER AUTO_INCREMENT PRIMARY KEY,
		url char(255),
		title char(255),
        is_obj BOOLEAN
);

DROP TABLE IF EXISTS history;
CREATE TABLE history (
		session_id char(72),
		page_id INTEGER,
        timestamp INTEGER,
        visit_count INTEGER,
        PRIMARY KEY (session_id, page_id)
);

INSERT INTO `roles` VALUES ('1','admin'),('2','curator'),('3','user'),('4','operator'),('5','editor');

DROP TABLE IF EXISTS sessions;
CREATE TABLE sessions (
        id           char(72) primary key,
        session_data text,
        user_id INTEGER,
        expires      int(10)
    );


DROP TABLE IF EXISTS widgets;
CREATE TABLE widgets (
        widget_id INTEGER AUTO_INCREMENT PRIMARY KEY,
        page_id INTEGER,
        widget_title char(72),
        widget_order INTEGER,
        current_revision_id INTEGER
);


DROP TABLE IF EXISTS widget_revision;
CREATE TABLE widget_revision (
        widget_revision_id INTEGER AUTO_INCREMENT PRIMARY KEY,
        widget_id INTEGER,
        content text,
        user_id INTEGER,
        timestamp INTEGER
);

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
        message_id INTEGER AUTO_INCREMENT PRIMARY KEY,
        message text,
        message_type char(72),
        timestamp INTEGER
);

INSERT INTO `users_to_roles` VALUES ('1', '1');
