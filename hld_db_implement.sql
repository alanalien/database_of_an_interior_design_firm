-- DATABASE CREATION ----------------------------
DROP DATABASE IF EXISTS `HLD_DB`;
CREATE DATABASE IF NOT EXISTS `HLD_DB`;

USE `HLD_DB`;
-- USE `ywang61_639_f19`;
-- DROP TABLE IF EXISTS
--   `ywang61_639_f19`.`ASSIGNMENT`,
--   `ywang61_639_f19`.`AUTHORSHIP`,
--   `ywang61_639_f19`.`CLIENT`,
--   `ywang61_639_f19`.`CONTACT_PERSON`,
--   `ywang61_639_f19`.`CONTRACT`,
--   `ywang61_639_f19`.`EMPLOYEE`,
--   `ywang61_639_f19`.`FILE`,
--   `ywang61_639_f19`.`FILE_TYPE`,
--   `ywang61_639_f19`.`PAYMENT`,
--   `ywang61_639_f19`.`PHASE`,
--   `ywang61_639_f19`.`PORTFOLIO_MATERIAL`,
--   `ywang61_639_f19`.`POSITION`,
--   `ywang61_639_f19`.`PRODUCT`,
--   `ywang61_639_f19`.`PRODUCT_LIST`,
--   `ywang61_639_f19`.`PRODUCT_LIST_ITEM`,
--   `ywang61_639_f19`.`PROJECT`,
--   `ywang61_639_f19`.`PROJECT_CLASS`,
--   `ywang61_639_f19`.`PROJECT_CONTACT`,
--   `ywang61_639_f19`.`REVIEW`,
--   `ywang61_639_f19`.`ROLE`,
--   `ywang61_639_f19`.`SUPPLIER`;

-- CENTER ENTITY --------------------------------
CREATE TABLE `PROJECT_CLASS`(
  PROJECT_CLASS_ID INT AUTO_INCREMENT PRIMARY KEY,
  PROJECT_CLASS_NAME VARCHAR(200) NOT NULL
  -- hotel design, home decoration, etc..
  );
  
CREATE TABLE `PROJECT`(
  PROJECT_ID INT AUTO_INCREMENT PRIMARY KEY,
  PROJECT_NAME VARCHAR(2000) NOT NULL,
  ADDRESS VARCHAR(5000) DEFAULT NULL,
  CITY VARCHAR(50) NOT NULL, 
  PROVINCE VARCHAR(50) NOT NULL, 
  -- project site location information, 
  -- broke down 'location' for the convinience of query
  -- i.e. list all projects in a certain province
  -- country is not included for the company only provide service in China
  START_DATE DATE NOT NULL,
  END_DATE DATE DEFAULT NULL,
  PROJECT_STATUS ENUM( 
  -- renamed to avoid conflict with SQL (not necessary but personal preference)
    'preparing', 'in-progress', 'under-construction', 'constructed'
    ) DEFAULT 'preparing' 
    COMMENT "Values are limited to 'preparing', 'in-progress', 'under-construction', and 'constructed'",
  -- project type is removed for some over-lapping with PROJECT_CLASS, 
  -- if a project is for a bid, such info will be stored in STAGE
  PROJECT_CLASS_ID INT NOT NULL,
  FOREIGN KEY (PROJECT_CLASS_ID) 
    REFERENCES `PROJECT_CLASS`(PROJECT_CLASS_ID)
    ON UPDATE CASCADE
    -- on delete cascade is dangerous here
    -- which could cause massive data lose
    -- to avoid that, include only update cascade here
  );

-- CONTRACT BRANCH ------------------------------
CREATE TABLE `CONTRACT`(
  CONTRACT_ID INT AUTO_INCREMENT PRIMARY KEY,
  PROJECT_ID INT UNIQUE NOT NULL,
  -- unique to enforce an 1:1 relationship
  -- one project can only have one contract
  CONTRACT_PATH VARCHAR(2000) NOT NULL,
  REQUIREMENT_PATH VARCHAR(2000) NOT NULL,
  -- if a contract exists, 
  -- there must be a contract file and a requirement folder
  CONTRACT_VALUE DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (PROJECT_ID) 
    REFERENCES `PROJECT`(PROJECT_ID)
    ON UPDATE CASCADE ON DELETE CASCADE
    -- when a project is removed for any reason, 
    -- the contract shouldn't exist as well
  );

CREATE TABLE `PAYMENT`(
  PAYMENT_ID INT AUTO_INCREMENT PRIMARY KEY,
  CONTRACT_ID INT NOT NULL,
  PAYMENT_STATUS ENUM (
    'Undue',
    'Received',
    'Overdue'
    ) DEFAULT 'Undue'
    COMMENT "values is limited to 'Undue', 'Received', and 'Overdue'",
  DUE_DATE DATE NOT NULL,
  COMPLETE_DATE DATE DEFAULT NULL,
  AMOUNT DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (CONTRACT_ID)
    REFERENCES `CONTRACT`(CONTRACT_ID)
    ON UPDATE CASCADE ON DELETE CASCADE
  );
  
-- CREATE TRIGGER payment_completion 
--   AFTER INSERT ON `PAYMENT`
--   FOR EACH ROW
--   UPDATE `PAYMENT`
--   SET PAYMENT_STATUS = 'Received';

-- CLIENT BRANCH --------------------------------
CREATE TABLE `CLIENT`(
  CLIENT_ID INT AUTO_INCREMENT PRIMARY KEY,
  CLIENT_NAME VARCHAR(2000) DEFAULT NULL, 
  -- full name of the client company, 
  -- default null for some times its not necessary
  CLIENT_ABBR VARCHAR(500) NOT NULL,
  -- in comparism, an abbreviation is more often used
  IN_TANK_STATUS BOOLEAN DEFAULT NULL
  -- whether the client has HLD in their 'expert tank'
  -- for those clients doesn't have such tanks, default null
  );

CREATE TABLE `CONTACT_PERSON`(
  CONTACT_PERSON_ID INT AUTO_INCREMENT PRIMARY KEY,
  FULL_NAME VARCHAR(100) NOT NULL,
  -- for it stores mostly Chinese names,
  -- which usually doesn't treat family and given names separately
  CLIENT_ID INT NOT NULL,
  CELL_PHONE CHAR(11) NOT NULL,
  -- length of Chinese cell phone number
  OFFICE_PHONE CHAR(13) DEFAULT NULL,
  -- length of Chinese landline phones number plus reginal code
  WECHAT_ACCOUNT VARCHAR(100) NOT NULL,
  QQ_ACCOUNT VARCHAR(100) DEFAULT NULL, 
  -- another social media that sometimes being used in business
  EMAIL VARCHAR(100) DEFAULT NULL,
  -- email is rarely used in China's domestic business,
  -- they use WeChat more as an alternative instead
  FOREIGN KEY (CLIENT_ID)
    REFERENCES `CLIENT`(CLIENT_ID)
    ON UPDATE CASCADE ON DELETE CASCADE
  );

CREATE TABLE `PROJECT_CONTACT`(
  CONTACT_ID INT AUTO_INCREMENT PRIMARY KEY,
  CONTACT_PERSON_ID INT NOT NULL,
  PROJECT_ID INT NOT NULL,
  START_DATE DATE DEFAULT NULL,
  END_DATE DATE DEFAULT NULL,
  FOREIGN KEY (CONTACT_PERSON_ID)
    REFERENCES `CONTACT_PERSON`(CONTACT_PERSON_ID)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (PROJECT_ID)
    REFERENCES `PROJECT`(PROJECT_ID)
    ON UPDATE CASCADE ON DELETE CASCADE
  );

-- EMLOYEE BRANCH -------------------------------
-- Table 'DEPARTMENT' is abandoned for it does not exist in this firm
CREATE TABLE `POSITION`(
  POSITION_ID INT AUTO_INCREMENT PRIMARY KEY,
  POSITION_NAME VARCHAR(200) NOT NULL,
  SALARY_MIN DECIMAL(10,2) DEFAULT 2200.00,
  -- default is the minimum wage of Shenzhen, China
  SALARY_MAX DECIMAL(10,2) DEFAULT 1000000.00
  -- to differenciate from 'yearly bonus' which is out of the scope of this database
  -- project bonus are based on project income, while yearly bonus is based on yearly profit
  );
  
CREATE TABLE `EMPLOYEE`(
  EMPLOYEE_ID INT AUTO_INCREMENT PRIMARY KEY,
  FULL_NAME VARCHAR(100) NOT NULL,
  POSITION_ID INT NOT NULL,
  CELL_PHONE CHAR(11) NOT NULL,
  WORK_PHONE CHAR(13) DEFAULT NULL,
  WECHAT_ACCOUNT VARCHAR(100) NOT NULL,
  QQ_ACCOUNT VARCHAR(100) DEFAULT NULL,
  EMAIL VARCHAR(100) DEFAULT NULL,
  SALARY DECIMAL(10,2) DEFAULT 2200.00,
  EMPLOYMENT_STATUS BOOLEAN DEFAULT 1,
  -- employment status, 1 for current employee, 0 for dimissioned
  -- new, to ensure dimission employees will remain in the database,
  -- and won't affect other tables while changing status
  FOREIGN KEY (POSITION_ID)
    REFERENCES `POSITION`(POSITION_ID)
    ON UPDATE CASCADE
  );  
  
  CREATE TABLE `ROLE` (
  ROLE_ID INT AUTO_INCREMENT PRIMARY KEY,
  ROLE_NAME VARCHAR(500) UNIQUE NOT NULL,
  PROJECT_BONUS_RATE DECIMAL(3,2) DEFAULT 0.00,
  ROLE_DESCRIPTION VARCHAR(5000) DEFAULT NULL
  );
  
CREATE TABLE `ASSIGNMENT`(
  ASSIGNMENT_ID INT AUTO_INCREMENT PRIMARY KEY,
  PROJECT_ID INT NOT NULL,
  EMPLOYEE_ID INT NOT NULL,
  ROLE_ID INT NOT NULL,
  CURRENT_WAGE DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (PROJECT_ID)
  REFERENCES `PROJECT`(PROJECT_ID)
    ON UPDATE CASCADE ON DELETE CASCADE,
    -- after a long discussion with the owner,
    -- we decided to connect employees to project directly for 2 reasons,
    -- a. it is rare to have employees assign to projects in the middle,
    -- especially those higher rank ones (who have bonus price);
    -- b. it would be easier for the manager level to calculate bonus,
    -- which is based on projects instead of phases.
  FOREIGN KEY (EMPLOYEE_ID)
    REFERENCES `EMPLOYEE`(EMPLOYEE_ID)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (ROLE_ID)
    REFERENCES `ROLE`(ROLE_ID)
    ON UPDATE CASCADE
    -- to avoid massive data delete, no on delete cascade
    -- i.e. remove a role won't be allowed under safe update mode
  );
  
  
-- WORK BRANCH ----------------------------------
CREATE TABLE `PHASE`(
-- renamed to match commonly accepted translation
-- source: https://www.proz.com/kudoz/english-to-chinese/tech-engineering/431302-schematic-design-design-development.html
  PHASE_ID INT AUTO_INCREMENT PRIMARY KEY,
  PROJECT_ID INT NOT NULL,
  PHASE_NAME ENUM(
    'bid project',
    -- it is stored here for that
    -- bid projects usually have diiferent process (stages)
    -- than other projects, and it's usually much shorter
    'Conceptual Design Phase',
    'Schematic Design Phase',
    'Design Development Phase',
    'Construction Document Phase'
    ) NOT NULL 
    COMMENT "entries are limited to 'bid project', 'Conceptual Design Phase', 'Schematic Design Phase', 'Design Development Phase', and 'Construction Document Phase'",
  PORTFOLIO_NAME VARCHAR(1000) DEFAULT NULL,
  PORTFOLIO_PATH VARCHAR(2000) DEFAULT NULL,
  -- a stage maybe stored earlier than
  -- its portfolio's creation
  SUBMIT_DATE DATE DEFAULT NULL,
  FOREIGN KEY (PROJECT_ID)
    REFERENCES `PROJECT`(PROJECT_ID)
    ON UPDATE CASCADE ON DELETE CASCADE
  );

CREATE TABLE `FILE_TYPE`(
-- it is added to ensure consistency of 'file type'
  FILE_TYPE_ID INT AUTO_INCREMENT PRIMARY KEY,
  FILE_TYPE_NAME VARCHAR(800) NOT NULL
  );
  
CREATE TABLE `FILE`(
  FILE_ID INT AUTO_INCREMENT PRIMARY KEY,
  FILE_NAME VARCHAR(2000) NOT NULL,
  FILE_TYPE_ID INT NOT NULL,
  FILE_PATH VARCHAR(2000) NOT NULL,
  CREATED_DATE DATE NOT NULL,
  LAST_EDIT_DATE DATE NOT NULL,
  -- changed from created and finalized date
  -- after discussing with the designers, 
  -- file will be stored to the 'archival' folder only after finished
  -- and in progress files are not worth to be stored in the database
  FOREIGN KEY (FILE_TYPE_ID)
    REFERENCES `FILE_TYPE`(FILE_TYPE_ID)
    ON UPDATE CASCADE
    -- no delete cascade for data safty
  );

CREATE TABLE `PORTFOLIO_MATERIAL`(
  PHASE_ID INT,
  FILE_ID INT,
  PRIMARY KEY (PHASE_ID, FILE_ID),
  FOREIGN KEY (PHASE_ID)
    REFERENCES `PHASE`(PHASE_ID)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (FILE_ID)
    REFERENCES `FILE`(FILE_ID)
    ON UPDATE CASCADE ON DELETE CASCADE
  );

CREATE TABLE `AUTHORSHIP`(
  AUTHORSHIP_ID INT AUTO_INCREMENT PRIMARY KEY,
  FILE_ID INT NOT NULL,
  EMPLOYEE_ID INT NOT NULL,
  CONTRIBUTION VARCHAR(5000) DEFAULT NULL, 
  -- new, a description of the author's contribution to this work
  FOREIGN KEY (FILE_ID)
  REFERENCES `FILE`(FILE_ID)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (EMPLOYEE_ID)
    REFERENCES `EMPLOYEE`(EMPLOYEE_ID)
    ON UPDATE CASCADE ON DELETE CASCADE
  );

CREATE TABLE `REVIEW`(
  REVIEW_ID INT AUTO_INCREMENT PRIMARY KEY,
  FILE_ID INT UNIQUE NOT NULL, 
  -- to enforce an 1:1 relationship, 
  -- each file has only one review entry, 
  -- and the verified date will be updated after each review.
  -- it is because the main purpose of this entity is to store the reviewer 
  -- and the time of the file being verified
  EMPLOYEE_ID INT NOT NULL,
  VERIFIED_DATE DATE COMMENT 'the date of the last review',
  FOREIGN KEY (FILE_ID)
  REFERENCES `FILE`(FILE_ID)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (EMPLOYEE_ID)
    REFERENCES `EMPLOYEE`(EMPLOYEE_ID)
    ON UPDATE CASCADE ON DELETE CASCADE
  );

-- SUPPLIER BRANCH ------------------------------
CREATE TABLE `SUPPLIER`(
  SUPPLIER_ID INT AUTO_INCREMENT PRIMARY KEY,
  SUPPLIER_NAME VARCHAR(2000) DEFAULT NULL, 
  SUPPLIER_ABBR VARCHAR(500) NOT NULL,
  -- added to provide a commonly used name to assist query
  -- similar to CLIENT, abbreviation will be used more
  WEBSITE VARCHAR(500) DEFAULT NULL,
  ADDRESS VARCHAR(1000) DEFAULT NULL,
  CITY VARCHAR(50) DEFAULT NULL, 
  PROVINCE VARCHAR(50) DEFAULT NULL,
  COUNTRY VARCHAR(50) DEFAULT NULL,
  EMAIL VARCHAR(100) DEFAULT NULL,
  PHONE CHAR(13) DEFAULT NULL
  );
  
CREATE TABLE `PRODUCT_LIST`(
  PRODUCT_LIST_ID INT AUTO_INCREMENT PRIMARY KEY,
  PROJECT_ID INT NOT NULL,
  WHITEPAPER_PATH VARCHAR(2000) DEFAULT NULL,
  -- a whitepaper book that documents details of products in the list
  EMPLOYEE_ID INT NOT NULL,
  -- added to track the employee who created the list
  CREATED_DATE DATE NOT NULL,
  -- added to track the created date
  FOREIGN KEY (PROJECT_ID)
    REFERENCES `PROJECT`(PROJECT_ID)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (EMPLOYEE_ID)
    REFERENCES `EMPLOYEE`(EMPLOYEE_ID)
    ON UPDATE CASCADE ON DELETE CASCADE
  );

CREATE TABLE `PRODUCT`(
  PRODUCT_ID INT AUTO_INCREMENT PRIMARY KEY,
  SUPPLIER_ID INT DEFAULT NULL,
  -- DEFAULT NULL to allow optional relationship
  -- the relationship here has been changed to 
  -- optional on BOTH sides,
  -- for in real practice, some product might not have
  -- a 'supplier' but something bought from
  -- a third party retailer, which isn't worth to be 
  -- stored in the database
  PRODUCT_NAME VARCHAR(2000) NOT NULL,
  IMAGE_PATH VARCHAR(2000) DEFAULT NULL,
  PRICE DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (SUPPLIER_ID)
    REFERENCES `SUPPLIER`(SUPPLIER_ID)
    ON UPDATE CASCADE ON DELETE CASCADE
  );
  -- one or more product classification entity should be added in the real practice,
  -- which is omitted due to the scope of this project
  -- these entities should help users query products by
  -- usage (office, commercial, residential, etc)
  -- or type (chair, lighting, desk, ...)
  
  CREATE TABLE `PRODUCT_LIST_ITEM`(
  -- table name has changed to reflect it's an associate entity
  PRODUCT_LIST_ID INT,
  PRODUCT_ID INT,
  PRIMARY KEY (PRODUCT_LIST_ID, PRODUCT_ID), 
  -- in the interest of saving sapce and emphasize the associate relationship
  -- use a composite PK than create a new PK
  PRODUCT_COUNT INT NOT NULL DEFAULT 1,
  FOREIGN KEY (PRODUCT_LIST_ID)
    REFERENCES `PRODUCT_LIST`(PRODUCT_LIST_ID)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (PRODUCT_ID)
    REFERENCES `PRODUCT`(PRODUCT_ID)
    ON UPDATE CASCADE ON DELETE CASCADE
  -- TOTAL_PRICE is removed because
  -- a derived attribute cannot base on values from another table
  -- a view with this info will be created instead
  );

-- DATA INPUT SECTION ---------------------------
SET AUTOCOMMIT = 0;
START TRANSACTION;

INSERT INTO `POSITION`
-- Salary is in RMB and counted monthly
  VALUES
    (null, 'Design Director', 50000.00, 100000.00), -- highest wage + largest bonus
    (null, 'Case Managing Designer', 12000.00, 30000.00), -- high wage with higher ceiling + high bonus
    (null, 'Senior Interior Designer', 8000.00, 15000.00), -- high wage + medium bonus
    (null, 'Junior Interior Designer', 5000.00, 10000.00), -- high wage + low bonus
    (null, 'Senior Decoration Designer', 8000.00, 15000.00), -- high wage + medium bonus
    (null, 'Junior Decoration Designer', 5000.00, 10000.00), -- high wage + low bonus
    (null, 'Construction Engineer', 8000.00, 15000.00), -- high wage + medium bonus
    (null, 'Desgin Assistant', 3000.00, 6000.00), -- no bonus
    (null, 'Desgin Intern', 2200.00, 2200.00), -- no bonus
    (null, 'Project Manager', 5000.00, 15000.00), -- high wage + medium bonus
    (null, 'Graphic Designer', 5000.00, 12000.00), -- wide salary range depending on experience
    (null, 'Business Development Specialist', 3000.00, 5000.00), -- low wage + high bonus rate
    (null, 'Human Resource Manager', 6000.00, 12000.00),
	(null, 'Public Relationship Manager', 6000.00, 12000.00),
    (null, 'Human Resource Specialist', 4000.00, 8000.00),
    (null, 'Public Relationship Specialist', 4000.00, 8000.00),
    (null, 'Advertise and Media Specialist', 4000.00, 8000.00),
    (null, 'Administration Clerk', 2800.00, 5000.00),
    (null, 'Acceptance Clerk', 2800.00, 5000.00)
    ;
SELECT * FROM `POSITION`;

INSERT INTO `EMPLOYEE`
  VALUES
    -- note that all 'full name' will be in Chinese in real practice, 
    -- and that's why they weren't separate to first and last name
    (null, 'Wang Heilong', 1, '13900312345', '0755-32456633', 'wangheilong1962', '44335568', 'heilong_wang@hldesign.com', 80000.00, 1),
    (null, 'Wang Zheng', 1, '13769300256', '0755-32456612', 'zhengfengwx', '47335623', 'zheng_johh@163.com', 30000.00, 0),
    (null, 'Zhang Xiaoqiang', 2, '18100331238', '0755-32456833', 'zxq83', null, 'zxq83@qq.com', 28000.00, 0),
    (null, 'Liu Xianfei', 4, '13543367528', null, 'liushahe', null, null, 8000.00, 0),
    (null, 'Wu Ruoyu', 4, '13530586723', null, 'ruoyudazhi', null, null, 8000.00, 0),
    (null, 'Li Xiaojie', 6, '13906357338', null, 'jack1993', null, null, 6000.00, 0),
    (null, 'Zheng Yuanyuan', 8, '13672345689', null, 'luckyuan', null, null, 6000.00, 0),
    (null, 'Wang Yulan', 12, '13866385712', null, 'yulan1968', null, 'yulan_wang@hldesign.com', 12000.00, 1),
    (null, 'Peng Yuan', 13, '13902953887', null, 'pengpeng', null, 'yuan_peng@hldesign.com', 11000.00, 0),
    (null, 'Li Guoqiang', 2, '13506353068', '0755-32456833', 'guoqiang520', null, 'guoqiang520@hotmail.com', 22000.00, 1),
    (null, 'Xiao Jianbin', 2, '13506353068', '0755-32456833', 'interiorXiao', null, 'xiaojianbin_work@hotmail.com', 22000.00, 1),
    (null, 'Zhao Yufeng', 3, '13833536028', '0755-32660301', 'zhaowangye', '580925903', 'feng33@hotmal.com', 15000.00, 0),
    (null, 'Ouyang Yuecheng', 3, '13678853960', '0755-32660301', 'ouyang_flyhigher', null, 'ouyang_design@163.com', 12000.00, 1),
    (null, 'Long Huihui', 3, '15853358761', '0755-32660301', 'huihuihuifei', null, 'huihui_long@163.com', 12000.00, 1),
    (null, 'Ye Zi', 19, '18253386271', '0755-32665528', 'falling-leaf', null, null, 3500.00, 0),
    (null, 'Zhang Siqi', 5, '13465287351', '0755-32660302', 'ouyang_flyhigher', null, 'ouyang_design@163.com', 8000.00, 1),
    (null, 'Lin Qiao', 8, '13672345689', null, 'adroit_qiao', null, null, 6000.00, 0),
    (null, 'Wang Yuner', 8, '13672345689', null, 'sleepnomore', null, null, 4000.00, 0),
    (null, 'Liu Wei', 10, '13553858338', null, 'Liuwei-Design', null, null, 10000.00, 0),
    (null, 'Li Li', 5, '13458637788', '0755-32660302', 'lily_is_lili', '56127259', 'lily_deco@tecent.com', 10000.00, 1),
    (null, 'Ye Feifei', 4, '15044035763', null, 'ibelieveicanfly', null, 'yiyezhiqiu@hotmail.com', 6000.00, 1),
    (null, 'Li Yuanji', 4, '15635723380', null, 'yuanji_jack', null, null, 5000.00, 1),
    (null, 'He Jianfei', 13, '13803786833', null, 'he_jianfei_1973', null, 'jianfei_he@hldesign.com', 10000.00, 1),
    (null, 'Ye Feifei', 4, '15044035763', null, 'ibelieveicanfly', null, 'yiyezhiqiu@hotmail.com', 6000.00, 1),
    (null, 'Chen Sizhe', 4, '13803505638', null, 'sizhe_art', null, null, 10000.00, 1),
    (null, 'Li Longfei', 11, '13805386688', null, 'muzi-dragon', null, 'longfei_li@hldesign.com', 4500.00, 0),
    (null, 'Chen Jun', 4, '13153676758', null, 'junjun93', null, null, 6000.00, 1),
    (null, 'Lin Siyu', 6, '15803305368', null, 'siruquanyong0628', null, null, 5000.00, 1),
    (null, 'Huang Xiaofan', 6, '13432589038', null, 'supernormal', null, null, 6000.00, 1),
    (null, 'Chen Bing', 7, '13503589238', '0755-32665822', 'chenbingice', '503372883', null, 12000.00, 1),
    (null, 'Xu Weilin', 7, '13503853628', '0755-32665822', 'forest_xu_1985', null, null, 10000.00, 1),
    (null, 'Zhang Leihan', 8, '13672345689', null, 'leihan_thunder', null, null, 6000.00, 1),
    (null, 'Zhang jianjun', 14, '13050386685', null, 'junzi', null, 'jianjun_zhang@hldesign.com', 12000.00, 1),
    (null, 'Li Deshen', 16, '13600365483', null, 'deshen_1987', null, 'deshen_li@hldesign.com', 8000.00, 1),
    (null, 'Chen Bin', 15, '15008536233', null, 'binbinbang', null, null, 8000.00, 1),
    (null, 'Wang Sisi', 17, '13053628973', null, 'sisi_think', null, null, 6000.00, 1),
    (null, 'Qian Ling', 8, '13672345689', null, 'lingling1995', null, null, 4000.00, 1),
    (null, 'Yu Dian', 8, '13503358330', null, 'rainynight', null, null, 5000.00, 1),
    (null, 'Shi Zeshen', 11, '13622885368', null, 'stone_83', null, 'zeshen_shi@hldesign.com', 5000.00, 1),
    (null, 'Qian Feng', 10, '18253899638', null, 'Feng_1992', null, null, 8000.00, 1),
    (null, 'Li Qiaoyun', 18, '13566385782', null, 'qiaoyun1995', null, null, 3500.00, 1),
    (null, 'Zheng Yueer', 19, '18135687723', '0755-32665528', 'yueer_moon', null, null, 3500.00, 1),
    (null, 'Deng Xinjie', 9, '13803352386', null, 'xinjieqq', null, null, 2200.00, 1)
    ;
SELECT * FROM `EMPLOYEE`;

INSERT INTO `CLIENT`
  VALUES
    (null, 'China Vanke Co., Ltd.', 'VanKe', 1), -- 万科地产
    (null, 'China Resources Land Limited', 'China Resources', 1), -- 华润置地
    (null, 'Evergrande Real Estate Group', 'Evergrande', 1), -- 恒大地产
    (null, 'Poly Real Estate Group Co., Ltd.', 'Poly', 0), -- 保利置业
    (null, 'Guangzhou R&F Properties', 'R&F', null), -- 富力地产
    (null, 'China Merchants Property Development Co., Ltd.', 'China Merchants', 1), -- 招商地产
    (null, 'SOHO China Co., Ltd', 'SOHO China', 0), -- SOHO中国
    (null, 'KWG Group Holdings Limited', 'KWG', 0), -- 合景泰富地产
    (null, 'Overseas Chinese Town Enterprises Co.', 'OCT', 1), -- 华侨城
    (null, 'Xinyuan Real Estate Co., Ltd.', 'Xinyuan', 0), -- 鑫源地产
    (null, 'Country Garden Holdings Co., Ltd.', 'Country Garden', 0), -- 碧桂园
    (null, 'Agile Property Holdings Limited', 'Agile', 0), -- 雅居乐地产
    (null, 'Financial Street Holding Co., Ltd.', 'Financial Street', 1), -- 金融街控股
    (null, 'China Aoyuan Group Limited', 'Aoyuan', 0), -- 奥园地产
    (null, 'Shanghai Forte Land Co., Ltd.', 'Forte Land', 0), -- 复地地产
    (null, 'Xinyuan Real Estate Co., Ltd.', 'Xinyuan', 0), -- 鑫苑置业
    (null, 'New World China Land Limited', 'New World China', null), -- 新世界地产
    (null, 'Excellence Group Co., Ltd.', 'Excellence', 0), -- 卓越地产
    (null, 'Kingkey Group Co., Ltd.', 'Kingkey', null), -- 京基集团
    (null, 'Greentown China Holdings Limited', 'Greentown', 1), -- 绿城集团
    (null, 'Shum Yip Group Limited', 'Shum Yip', 0), -- 深业集团
    (null, 'Hytera Communications Co., Ltd.', 'Hytera', null), -- 海能达集团
    (null, 'Wang Sicong (Personal)', 'Wang Sicong', null) -- personal project sample
    ;
SELECT * FROM `CLIENT`;
  
INSERT INTO `CONTACT_PERSON`
  VALUES
    (null, 'Chen Sicheng', 1, '13853886273', null, 'StevenChen', null, 'sicheng_chen@vanke.com'),
    (null, 'Zhao Wei', 2, '13954327759', null, 'xiaoyanzi', null, 'weiz3@huarun.com'),
    (null, 'Chen Kun', 1, '18253877631', null, 'kunkunaikun1978', null, null),
    (null, 'Yi Zhongtian', 1, '15033268960', '0755-82358075', 'sanguoyanyi', null, 'zhongtian_yi@vanke.com'),
    (null, 'Wang Dachui', 3, '15372648989', null, '4ever_wanwan', null, 'dc-wang32@evergrand.com'),
    (null, 'Sa Beining', 6, '13754886723', null, 'cctv01', null, null),
    (null, 'Wang Junkai', 6, '15289756638', null, 'xiaobingjia', null, 'wangjk2001@cml.com'),
    (null, 'Yi Yangqianxi', 9, '15986745360', '0755-83645387', 'jacksonyi2k', null, 'jacksonyi@oct.com'),
    (null, 'Wang Yuan', 3, '15988667382', null, 'yuanlaishini01', null, 'y-wang78@evergrand.com'),
    (null, 'Bai Jingting', 13, '16354236678', null, 'xiaotingzi1985', null, null),
    (null, 'Liu Shishi', 20, '18063467833', null, 'poetryshi1963', null, null),
    (null, 'Su Youpeng', 1, '13902653480', null, 'xiaohudui_gogo', null, 'youpeng_su@vanke.com'),
    (null, 'Li Meijin', 11, '18256783373', '0753-33796287', 'crime_psychology', null, 'meijin_liu@country-garden.com'),
    (null, 'Ju Jinyi', 21, '13465673483', null, 'sainaihesiba', null, null),
    (null, 'Tong Liya', 9, '15853367823', null, 'dongria', null, null),
    (null, 'Zhang Ziyi', 17, '13853862743', null, 'xitubudui', null, 'ziyi_zhang@nwc.com'),
    (null, 'Wang Feng', 19, '13763354278', null, 'ziyi520', null, 'wangfeng96@kingkey.com'),
    (null, 'Xu Wei', 10, '13468868608', null, 'blue_lotus', null, 'xw03@xinyuan.com'),
    (null, 'Li Yongle', 20, '13502547843', '0531-67835628', 'xitubudui', null, 'lyl_work@gmail.com'),
    (null, 'Gao Yixiang', 22, '13963368920', null, 'rest_in_peace', null, null),
    (null, 'Wang Sicong', 23, '13753837762', null, 'sicong_rich', null, null)
    ;
SELECT * FROM `CONTACT_PERSON`;

INSERT INTO `PROJECT_CLASS`(PROJECT_CLASS_NAME)
  VALUES
	('Hospitality Interior Design'),
    ('Work Space Interior Design'),
    ('Retail Space Interior Design'),
    ('Resident Interior Design'),
    ('Public Space Interior Design'),
    ('Restaurant Interior Design'),
    ('Hospitality Decoration Design'),
    ('Work Space Decoration Design'),
    ('Resident Decoration Design'),
    ('Restaurant Decoration Design'),
    ('Health Care Design'),
    ('Exhibition Design')
    ;
SELECT * FROM `PROJECT_CLASS`;
-- 12 instances

INSERT INTO `PROJECT`
-- status enum('preparing','in-progress','under-construction','constructed')
  VALUES
    (null, 'Vanke Grand Meisha Headquarter', '1368 Meisha Rd', 'Shenzhen', 'Guangdong', '2010-10-21', '2011-03-17', 'under-construction', 2),
    (null, 'Changsha New Oriental Hotel', '265 Xinsha Rd', 'Changsha', 'Hunan', '2011-03-31', '2011-10-28', 'constructed', 1),
    (null, 'Zhengzhou Xiangshuwan Garden Hotel', '1680 Liberation Rd', 'Zhengzhou', 'Henan', '2012-05-30', '2013-01-08', 'under-construction', 1),
    (null, 'Barn X Club', '433 Wuzhou Rd', 'Changsha', 'Hunan', '2015-03-06', '2015-08-20', 'constructed', 6),
    (null, 'Hytera Head Quater', '280 Kejiyuan Rd', 'Shenzhen', 'Guangdong', '2013-12-07', '2014-10-31', 'constructed', 2),
    (null, '500 Shopping Center', '500 Jianguomen Rd', 'Beijing', 'Beijing','2014-12-06', '2015-06-28', 'under-construction', 3),
    (null, 'Sothern than Cloud Yunnan Restaurant', '63 Caiyun Rd', 'Kunming', 'Yunnan','2016-01-31', '2016-04-03', 'constructed', 6),
    (null, 'Meixin Diabetes Care Center', '288 Ge Yuan Rd', 'Yangzhou', 'Jiangsu','2017-04-30', '2017-10-24', 'under-construction', 11),
    (null, 'Vanke Grand Meisha Headquarter Decoration Design', '1368 Meisha Rd', 'Shenzhen', 'Guangdong','2018-10-10', null, 'in-progress', 8),
    (null, 'No.1 Shenzhen Bay Sample House Design', 'No.1 Hongli Rd West', 'Shenzhen', 'Guangdong','2019-01-13', null, 'in-progress', 7),
    (null, 'House of Wang\'s', '101 Aigou Rd', 'Ningbo', 'Zhejiang', '2019-06-23', null, 'in-progress', 1),
    (null, 'Hytera Head Quater Decoration Bid', '280 Kejiyuan Rd', 'Shenzhen', 'Guangdong','2019-11-15', null, 'preparing', 1)
    ;
SELECT * FROM `PROJECT`;

SELECT CONTACT_PERSON_ID, FULL_NAME, CLIENT_ABBR FROM `CONTACT_PERSON` NATURAL JOIN `CLIENT`;
INSERT INTO `PROJECT_CONTACT`
  VALUES
    (null, 1, 1, '2010-08-30', null),
    (null, 2, 2, '2010-09-21', '2014-01-20'),
    (null, 3, 3, '2012-03-02', '2014-12-20'),
    (null, 8, 4, '2013-04-27', '2015-01-18'),
    (null, 20, 5, '2013-04-29', '2018-11-21'),
    (null, 4, 3, '2014-12-20', null),
    (null, 2, 6, '2014-06-28', null),
    (null, 16, 7, '2015-01-27', '2017-08-24'),
    (null, 6, 8, '2016-09-21', '2016-10-22'),
    (null, 7, 8, '2016-10-22', null),
    (null, 3, 9, '2018-08-27', null),
    (null, 2, 10, '2018-11-03', null),
    (null, 21, 11, '2019-01-02', null),
    (null, 20, 12, '2019-11-03', null)
    ;
SELECT * FROM `PROJECT_CONTACT`;

INSERT INTO `CONTRACT`
  VALUES
    (null, 1, 'G:\\CompanyDocuments\\Contracts\\VankeHQ.pdf', 'G:\\Project\\VankeHQ\\requirements', 2800000.00),
    (null, 2, 'G:\\CompanyDocuments\\Contracts\\NewOrientalHotel.pdf', 'G:\\Project\\NewOrientalHotel\\requirements', 3200000.00),
    (null, 3, 'G:\\CompanyDocuments\\Contracts\\ZhengzhouXiangshuwan.pdf', 'G:\\Project\\ZhengzhouXiangshuwan\\requirements', 1200000.00),
    (null, 4, 'G:\\CompanyDocuments\\Contracts\\BarnX.pdf', 'G:\\Project\\BarnX\\requirements', 960000.00),
    (null, 5, 'G:\\CompanyDocuments\\Contracts\\HyteraHQ.pdf', 'G:\\Project\\HyteraHQ\\requirements', 2350000.00),
    (null, 6, 'G:\\CompanyDocuments\\Contracts\\500ShoppingCenter.pdf', 'G:\\Project\\500ShoppingCenter\\requirements', 1560000.00),
    (null, 7, 'G:\\CompanyDocuments\\Contracts\\YunnanRestaurant.pdf', 'G:\\Project\\YunnanRestaurant\\requirements', 280000.00),
    (null, 8, 'G:\\CompanyDocuments\\Contracts\\MeixinCareCenter.pdf', 'G:\\Project\\MeixinCareCenter\\requirements', 680000.00),
    (null, 9, 'G:\\CompanyDocuments\\Contracts\\VankeHQ_Deco.pdf', 'G:\\Project\\VankeHQ_Deco\\requirements', 3200000.00),
    (null, 10, 'G:\\CompanyDocuments\\Contracts\\ShengzhenBaySampleHouse.pdf', 'G:\\Project\\ShengzhenBaySampleHouse\\requirements', 540000.00),
    (null, 11, 'G:\\CompanyDocuments\\Contracts\\WangSicongHouse.pdf', 'G:\\Project\\WangSicongHouse\\requirements', 320000.00),
    (null, 12, 'G:\\CompanyDocuments\\Contracts\\HyteraHQ_Deco_bid.pdf', 'G:\\Project\\HyteraHQ_Deco_bid\\requirements', 10000.00)
    ;
SELECT * FROM `CONTRACT`;

SELECT PROJECT_ID, START_DATE, END_DATE FROM `CONTACT_PERSON` NATURAL JOIN `PROJECT_CONTACT` ORDER BY PROJECT_ID;
INSERT INTO `PAYMENT`
-- status enum('Undue','Received','Overdue')
  VALUES
    (null, 1, 'Received', '2010-11-01', '2010-10-31', 400000.00),
    (null, 1, 'Received', '2012-01-01', '2012-01-01', 1000000.00),
    (null, 1, 'Received', '2014-05-01', '2014-04-28', 1400000.00),
    (null, 2, 'Received', '2012-12-31', '2013-01-16', 1600000.00),
    (null, 2, 'Received', '2013-08-01', '2013-12-27', 1600000.00),
    (null, 3, 'Received', '2013-05-01', '2013-05-02', 600000.00),
    (null, 3, 'Received', '2014-08-01', '2014-08-01', 600000.00),
    (null, 4, 'Received', '2014-09-01', '2014-08-27', 480000.00),
    (null, 4, 'Received', '2014-12-31', '2015-01-03', 480000.00),
    (null, 5, 'Received', '2013-10-01', '2013-09-28', 350000.00),
    (null, 5, 'Received', '2014-03-01', '2014-03-01', 500000.00),
    (null, 5, 'Received', '2014-06-01', '2014-05-30', 1000000.00),
    (null, 5, 'Received', '2014-12-30', '2015-01-01', 500000.00),
    (null, 6, 'Received', '2014-11-01', '2014-11-03', 560000.00),
    (null, 6, 'Received', '2015-06-01', '2015-05-20', 1000000.00),
    (null, 7, 'Received', '2016-05-01', '2016-04-28', 80000.00),
    (null, 7, 'Received', '2017-05-01', '2017-04-28', 200000.00),
    (null, 8, 'Overdue', '2019-11-30', null, 680000.00),
    (null, 9, 'Received', '2019-01-01', '2019-01-12', 200000.00),
    (null, 9, 'Received', '2019-05-30', '2019-04-24', 1500000.00),
    (null, 9, 'Undue', '2019-12-31', null, 1500000.00),
    (null, 10, 'Received', '2019-08-31', '2019-08-28', 2400000.00),
    (null, 10, 'Undue', '2020-03-01', null, 3000000.00),
    (null, 11, 'Undue', '2020-01-01', null, 320000.00),
    (null, 12, 'Undue', '2020-01-30', null, 100000.00)
    ;
SELECT * FROM `PAYMENT`;

INSERT INTO `SUPPLIER`
  VALUES
    (null, null, 'Da Vinci Ceremics', 'www.davinciceremic.com', null, 'Dongguan', 'Guangdong', 'China', null, '0756-33825712'),
    (null, null, 'La Chair', 'www.la-chair.com.fr', null, 'Paris', null, 'France', 'service@la-chair.com.fr', null),
    (null, null, 'Chang Xiang Si Fabric', 'www.cxs-fabric.com', null, 'Ningbo', 'Zhejiang', 'China', null, '0516-7335781'),
    (null, null, 'Eversteel Office Furniture', 'www.eversteel.com', null, 'Dongguan', 'Guangdong', 'China', null, '0756-53773268'),
    (null, 'Merida Fabrics Co., Ltd.', 'Merida Fabrics', 'www.merida.com.cn', '53# Changshan Industrial Park, 201 Changshan Rd.', 'Dongguan', 'Guangdong', 'China', null, '0756-33825712'),
    (null, null, 'Beautiful Day Flower', 'www.beautiful-day.com', null, 'Shenzhen', 'Guangdong', 'China', null, '0755-88635723'),
    (null, null, 'Hostak Das Mechanic', 'www.hostak.de', null, 'Schalk', null, 'German', 'customer@hostak.de', null),
    (null, 'Sleep Well Bedding Supplies Merchandise Co., Ltd.', 'Sleep Well Bedding', 'www.sleep-well.com', null, 'Foshan', 'Guangdong', 'China', null, '0756-33825712'),
    (null, null, 'Dai-Hing Lightings', 'www.daxingdengguang.com', null, 'Foshan', 'Guangdong', 'China', null, '0756-87653309'),
    (null, 'Never Stop Furniture Co., Ltd.', 'Never Stop Wardrobes', 'www.neverstop.com.cn', null, 'Dongguan', 'Guangdong', 'China', null, '0756-33825712'),
    (null, 'Zi Qiang Commercial Co., Ltd.', 'Zi Qiang Representative', null, null, 'Zhuhai', 'Guangdong', 'China', null, '0752-88638888'),
    (null, null, 'Yong Xing Furniture', null, null, 'Dongguan', 'Guangdong', 'China', null, '0756-36558723'),
    (null, 'Otakama Wood Product Co., Ltd.', 'Otakama', 'www.otakama.com', null, 'Kyoto', null, 'Japan', null, null),
    (null, null, 'De Sheng Stone', null, null, 'Guiyang', 'Guizhou', 'China', null, '0383-52736588'),
    (null, 'Xing Wang Marble Company', 'Xing Wang Marble', null, null, 'Shaoguan', 'Guangdong', 'China', null, '0733-86338668'),
    (null, null, 'Xiaolan Lightings', null, null, 'Zhongshan', 'Guangdong', 'China', null, '0762-33825712'),
    (null, null, 'Melphia Fabrics', 'www.melphia.com', null, 'Nanjing', 'Jiangsu', 'China', null, '0020-33825712'),
    (null, null, 'Vertice Wood Products', 'www.vertice.com', null, 'San Francisco', 'California', 'United States', null, null),
    (null, null, 'Sharp Edge Metal', 'www.sharp-edge.com', null, 'Detroit', 'Michigan', 'United States', null, null),
    (null, 'Real Care Medical Product Co., Ltd.', 'Real Care Medical', null, null, 'Shenzhen', 'Guangdong', 'China', null, '0755-83376283')
    ;
SELECT * FROM `SUPPLIER`;

INSERT INTO `PRODUCT`
  VALUES
    (null, 1, 'Black Square Ceremic Tile #126', null, 1.50),
    (null, 1, 'Khaki Ceremic #175', null, 0.50),
    (null, 2, 'Curved Arm Chair 2010', null, 18000.00),
    (null, 3, 'Carpet 5308 ', null, 12.00),
    (null, 1, 'C-X Square Ceremic Tile #726', null, 0.50),
    (null, 2, 'Classic Round Stool', null, 5600.00),
    (null, 3, 'Carpet 2307', null, 15.50),
    (null, 4, 'Long Stainless Steel Reception Desk 2009', null, 12000.00),
    (null, 9, 'Desk Lamp 53626', null, 720.00),
    (null, 13, 'Wooden Cabinet 0320', null, 8600.00),
    (null, 15, 'Peacock Blue Marble 5538', null, 402.50),
    (null, 16, 'Glass Droplight', null, 4200.00),
    (null, 1, 'Dark Purple Ceremic Tile #2035', null, 2.30),
    (null, 9, 'Desk Lamp 53085', null, 650.00),
    (null, 8, 'Silk Quilt Red #0552', null, 1200.00),
    (null, 8, 'Silk Pillow Cover Set #0553', null, 250.00),
    (null, 15, 'Cloud Pattern Marble 3250', null, 389.50),
    (null, 20, 'Adjustable Surgery Desk 53b', null, 4200.00),
    (null, 19, '#0538 Brass Vase', null, 660.00),
    (null, 17, 'Beige Curtain 2259', null, 56.00),
    (null, 17, 'Champagne Blinder 0572', null, 120.00),
    (null, 6, 'Blue Rose Basket', null, 993.00),
    (null, 11, 'Brazil Red Wood Table', null, 128000.00),
    (null, 14, 'Terrazzo Grey (precast) #5387', null, 270.50),
    (null, 7, 'Adjustable Office Desk (Green/Grey) #6623a', null, 12000.00),
    (null, 3, 'Carpet 6753', null, 12.00),
    (null, 2, 'Bar Chair 2012', null, 16800.00)
    ;
SELECT * FROM `PRODUCT`;

SELECT * FROM `EMPLOYEE` WHERE POSITION_ID = 3 OR POSITION_ID = 5;
INSERT INTO `PRODUCT_LIST`
  VALUES
    (null, 1, 'G:\\Project\\VankeHQ\\whitepaper', 12, '2012-01-01'),
    (null, 2, 'G:\\Project\\NewOrientalHotel\\whitepaper', 12, '2012-12-08'),
    (null, 3, 'G:\\Project\\ZhengzhouXiangshuwan\\whitepaper', 14, '2014-07-14'),
    (null, 4, 'G:\\Project\\BarnX\\whitepaper', 13, '2014-08-27'),
    (null, 5, 'G:\\Project\\HyteraHQ\\whitepaper', 13, '2014-12-23'),
    (null, 6, 'G:\\Project\\500ShoppingCenter\\whitepaper', 14, '2015-01-22'),
    (null, 7, 'G:\\Project\\YunnanRestaurant\\whitepaper', 16, '2017-02-20'),
    (null, 8, 'G:\\Project\\MeixinCareCenter\\whitepaper', 13, '2019-06-24'),
    (null, 9, 'G:\\Project\\VankeHQ_Deco\\whitepaper', 20, '2019-08-22')
    ;
SELECT * FROM `PRODUCT_LIST`;

INSERT INTO `PRODUCT_LIST_ITEM`
  VALUES
    (1, 1, 5000),
    (1, 2, 630),
    (1, 4, 1000),
    (1, 5, 5200),
    (1, 11, 400),
    (1, 23, 1),
    (1, 19, 12),
    (2, 3, 720),
    (2, 2, 20),
    (2, 23, 1),
    (2, 6, 48),
    (2, 15, 48),
    (2, 16, 48),
    (3, 5, 1200),
    (3, 14, 500),
    (3, 19, 4),
    (3, 20, 80),
    (3, 15, 72),
    (3, 16, 72),
    (4, 19, 12),
    (4, 21, 16),
    (4, 17, 120),
    (4, 22, 4),
    (4, 26, 100),
    (4, 27, 12),
    (5, 2, 1600),
    (5, 4, 12),
    (5, 23, 1),
    (5, 25, 220),
    (5, 8, 1),
    (5, 20, 24),
    (6, 17, 500),
    (6, 24, 500),
    (6, 21, 60),
    (6, 1, 1800),
    (7, 11, 60),
    (7, 12, 82),
    (7, 13, 1200),
    (7, 27, 12),
    (8, 2, 2),
    (8, 8, 1),
    (8, 10, 6),
    (8, 26, 120),
    (9, 3, 6),
    (9, 10, 20),
    (9, 12, 3),
    (9, 14, 20),
    (9, 25, 20),
    (9, 27, 12)
    ;
SELECT * FROM `PRODUCT_LIST_ITEM`;

INSERT INTO `ROLE`
  VALUES
    (null, 'Design Directer', 0.10, 'In Charge of the project.'),
    (null, 'Leading Designer', 0.05, 'Senior Designer or Case Managing Designer. The Leading Designer is responsible for the project, produce the main concept of the project, report to the Design Director'),
    (null, 'Project Manager', 0.03, 'Senior Designer or Project Manager (position). The Project Manager is the contact Person represents HLD, manage the project\'s progress, report to the Design Director'),
    (null, 'Designer', 0.01, 'Senior Desinger or Junior Designer, works under the supervison of the Leading Designer.'),
    (null, 'Decoration Designer Installer', 0.00, 'Junior Decoration Designer or Design Assistant, install the decoration on site, report to the the assigned designer in charge.'),
    (null, 'On Site Contact Designer', 0.03, 'Senior Designer. When the client requires, one designer might be sent on site and be the On Site Contact Designer, report to the Design Director and the Project Manager in charge.'),
    (null, 'Assistant', 0.00, 'Design Assistant or Design Intern, help the design team in petty works, report to the assigned Senior or Junior Designers.'),
    (null, 'Engineer', 0.01, 'Construction Engineer, produce construction plans and provide tech support to the design team.'),
    (null, 'Commercial Specialist', 0.05, 'Act by the Business Development Specialist who obtain this project. Provide following service to the client when need, report to the Project Manager in charge.')
    ;
SELECT * FROM `ROLE`;

SELECT EMPLOYEE_ID, POSITION_NAME, EMPLOYMENT_STATUS FROM `EMPLOYEE` NATURAL JOIN `POSITION`;
INSERT INTO `ASSIGNMENT`
  VALUES
    (null, 1, 1, 1, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 1)),
    (null, 1, 3, 2, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 3)),
    (null, 1, 4, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 4)),
    (null, 1, 5, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 5)),
    (null, 1, 7, 7, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 7)),
    (null, 1, 8, 9, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 8)),
    (null, 2, 2, 1, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 2)),
    (null, 2, 3, 2, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 3)),
    (null, 2, 10, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 10)),
    (null, 2, 19, 3, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 19)),
    (null, 2, 17, 7, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 3, 1, 1, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 1)),
    (null, 3, 10, 2, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 10)),
    (null, 3, 5, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 5)),
    (null, 3, 30, 8, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 30)),
    (null, 3, 17, 7, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 4, 10, 2, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 10)),
    (null, 4, 21, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 21)),
    (null, 4, 18, 7, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 18)),
    (null, 5, 1, 1, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 5, 11, 2, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 5, 19, 3, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 5, 13, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 5, 16, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 5, 18, 7, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 5, 30, 8, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 6, 1, 1, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 6, 19, 3, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 6, 14, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 6, 32, 7, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 7, 12, 2, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 7, 6, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 7, 18, 7, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 8, 14, 2, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 8, 28, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 8, 32, 7, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 9, 1, 1, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 9, 11, 2, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 9, 16, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 9, 28, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 9, 37, 7, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 9, 37, 5, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 10, 16, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 10, 32, 5, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 10, 37, 5, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 11, 1, 1, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 11, 29, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 12, 1, 1, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 12, 13, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17)),
    (null, 12, 28, 4, (SELECT SALARY FROM `EMPLOYEE` WHERE EMPLOYEE_ID = 17))
    ;
SELECT * FROM `ASSIGNMENT`;

INSERT INTO `PHASE`
-- PHASE NAME enum('bid project','Conceptual Design Phase','Schematic Design Phase','Design Development Phase','Construction Document Phase')
  VALUES
    (null, 1, 'Conceptual Design Phase', 'Vanke Grand Meisha Headquarter Interior Design Concept Design 2011', 'G:\\Project\\VankeHQ\\Binds\\ConceptDesignPortfolio.pdf', '2010-12-10'),
    (null, 1, 'Schematic Design Phase', 'Vanke Grand Meisha Headquarter Interior Design Schematic Design 2011', 'G:\\Project\\VankeHQ\\Binds\\SchematicDesignPortfolio.pdf', '2011-01-06'),
    (null, 1, 'Design Development Phase', 'Vanke Grand Meisha Headquarter Interior Design Design Development 2011', 'G:\\Project\\VankeHQ\\Binds\\DesignDevelopmentPortfolio.pdf', '2011-03-07'),
    (null, 1, 'Construction Document Phase', 'Vanke Grand Meisha Headquarter Interior Design Construction Document Kit 2011', 'G:\\Project\\VankeHQ\\Binds\\ConsutructionKit.pdf', '2011-03-17'),
    
    (null, 2, 'Conceptual Design Phase', 'Changsha New Oriental Hotel Interior Design Concept Design 2011', 'G:\\Project\\NewOrientalHotel\\Binds\\ConceptDesignPortfolio.pdf', '2011-04-15'),
    (null, 2, 'Schematic Design Phase', 'Changsha New Oriental Hotel Interior Design Schematic Design 2011', 'G:\\Project\\NewOrientalHotel\\Binds\\SchematicDesignPortfolio.pdf', '2011-05-03'),
    (null, 2, 'Design Development Phase', 'Changsha New Oriental Hotel Interior Design Design Development 2011', 'G:\\Project\\NewOrientalHotel\\Binds\\DesignDevelopmentPortfolio.pdf', '2011-08-31'),
    (null, 2, 'Construction Document Phase', 'Changsha New Oriental Hotel Interior Design Construction Document Kit 2011', 'G:\\NewOrientalHotel\\VankeHQ\\Binds\\ConsutructionKit.pdf', '2011-10-28'),
    
    (null, 3, 'Conceptual Design Phase', 'Zhengzhou Xiangshuwan Garden Hotel Interior Design Concept Design 2011', 'G:\\Project\\ZhengzhouXiangshuwan\\Binds\\ConceptDesignPortfolio.pdf', '2012-07-22'),
    (null, 3, 'Schematic Design Phase', 'Zhengzhou Xiangshuwan Garden Hotel Interior Design Schematic Design 2011', 'G:\\Project\\ZhengzhouXiangshuwan\\Binds\\SchematicDesignPortfolio.pdf', '2012-09-30'),
    (null, 3, 'Construction Document Phase', 'Zhengzhou Xiangshuwan Garden Hotel Interior Design Construction Document Kit 2011', 'G:\\Project\\ZhengzhouXiangshuwan\\Binds\\ConsutructionKit.pdf', '2013-01-08'),
    
    (null, 4, 'Conceptual Design Phase', 'Barn X Club Renovation Design Concept Design 2011', 'G:\\Project\\BarnX\\Binds\\ConceptDesignPortfolio.pdf', '2015-03-30'),
    (null, 4, 'Schematic Design Phase', 'Barn X Club Renovation Design Schematic Design 2011', 'G:\\Project\\BarnX\\Binds\\SchematicDesignPortfolio.pdf', '2015-04-15'),
    (null, 4, 'Design Development Phase', 'Barn X Club Renovation Design Design Development 2011', 'G:\\Project\\BarnX\\Binds\\DesignDevelopmentPortfolio.pdf', '2015-06-21'),
    (null, 4, 'Construction Document Phase', 'Barn X Club Renovation Design Construction Document Kit 2011', 'G:\\Project\\BarnX\\Binds\\ConsutructionKit.pdf', '2015-08-20'),

    (null, 5, 'Conceptual Design Phase', 'Hytera Communication Co., Ltd. Headquater Interior Design Concept Design 2011', 'G:\\Project\\HyteraHQ\\Binds\\ConceptDesignPortfolio.pdf', '2013-12-27'),
    (null, 5, 'Schematic Design Phase', 'Hytera Communication Co., Ltd. Headquater Interior Design Schematic Design 2011', 'G:\\Project\\HyteraHQ\\Binds\\SchematicDesignPortfolio.pdf', '2014-01-31'),
    (null, 5, 'Design Development Phase', 'Hytera Communication Co., Ltd. Headquater Interior Design Design Development 2011', 'G:\\Project\\HyteraHQ\\Binds\\DesignDevelopmentPortfolio.pdf', '2014-06-10'),
    (null, 5, 'Construction Document Phase', 'Hytera Communication Co., Ltd. Headquater Interior Design Construction Document Kit 2011', 'G:\\Project\\HyteraHQ\\Binds\\ConsutructionKit.pdf', '2014-10-31'),
    
    (null, 6, 'Conceptual Design Phase', 'Beijing 500 Shopping Center Interior Design Concept Design 2011', 'G:\\Project\\500ShoppingCenter\\Binds\\ConceptDesignPortfolio.pdf', '2015-01-12'),
    (null, 6, 'Schematic Design Phase', 'Beijing 500 Shopping Center Interior Design Schematic Design 2011', 'G:\\Project\\500ShoppingCenter\\Binds\\SchematicDesignPortfolio.pdf', '2015-02-28'),
    (null, 6, 'Design Development Phase', 'Beijing 500 Shopping Center  Interior Design Design Development 2011', 'G:\\Project\\500ShoppingCenter\\Binds\\DesignDevelopmentPortfolio.pdf', '2015-04-30'),
    (null, 6, 'Construction Document Phase', 'Beijing 500 Shopping Center  Interior Design Construction Document Kit 2011', 'G:\\Project\\500ShoppingCenter\\Binds\\ConsutructionKit.pdf', '2015-06-28'),
    
    (null, 7, 'Conceptual Design Phase', 'Sothern than Cloud Yunnan Restaurant Interior Design Concept Design 2011', 'G:\\Project\\YunnanRestaurant\\Binds\\ConceptDesignPortfolio.pdf', '2016-02-15'),
    (null, 7, 'Schematic Design Phase', 'Sothern than Cloud Yunnan Restaurant Interior Design Schematic Design 2011', 'G:\\Project\\YunnanRestaurant\\Binds\\SchematicDesignPortfolio.pdf', '2016-03-08'),   
    (null, 7, 'Construction Document Phase', 'Sothern than Cloud Yunnan Restaurant Interior Design Construction Document Kit 2011', 'G:\\Project\\VankeHQ\\Binds\\ConsutructionKit.pdf', '2016-04-03'),
    
    (null, 8, 'Conceptual Design Phase', 'Meixin Diabetes Care Center Interior Design Concept Design 2011', 'G:\\Project\\MeixinCareCenter\\Binds\\ConceptDesignPortfolio.pdf', '2017-05-15'),
    (null, 8, 'Schematic Design Phase', 'Meixin Diabetes Care Center Interior Design Schematic Design 2011', 'G:\\Project\\MeixinCareCenter\\Binds\\SchematicDesignPortfolio.pdf', '2017-06-17'),
    (null, 8, 'Construction Document Phase', 'Meixin Diabetes Care Center Interior Design Construction Document Kit 2011', 'G:\\Project\\MeixinCareCenter\\Binds\\ConsutructionKit.pdf', '2017-10-24'),
    
    (null, 9, 'Conceptual Design Phase', 'Vanke Grand Meisha Headquarter Decoration Design Concept Design 2011', 'G:\\Project\\VankeHQ_Deco\\Binds\\ConceptDesignPortfolio.pdf', '2018-12-31'),
    (null, 9, 'Construction Document Phase', 'Vanke Grand Meisha Headquarter Decoration Design Implementation Kit 2011', 'G:\\Project\\VankeHQ_Deco\\Binds\\SchematicDesignPortfolio.pdf', '2019-03-06'),
    
    (null, 10, 'Conceptual Design Phase', 'No.1 Shenzhen Bay Sample House Interior Design Concept Design 2011', 'G:\\Project\\ShengzhenBaySampleHouse\\Binds\\ConceptDesignPortfolio.pdf', '2019-04-08'),
    
    (null, 11, 'Conceptual Design Phase', 'House of Wang\'s Interior Design Conceptual Design 2011', 'G:\\Project\\WangSicongHouse\\Binds\\SchematicDesignPortfolio.pdf', '2019-09-23')
    ;
SELECT * FROM `PHASE`;

INSERT INTO `FILE_TYPE`
  VALUES
    (null, 'sketch'),
    (null, 'plan'),
    (null, 'elevation'),
    (null, 'section'),
    (null, 'sample'),
    (null, 'detail'),
    (null, 'sketch model'),
    (null, 'rendering'),
    (null, 'BIM model'),
    (null, 'material descriptive document'),
    (null, 'design specification'),
    (null, 'design description'),
    (null, 'reference'),
    (null, 'photograph')
    ;
SELECT * FROM `FILE_TYPE`;

SELECT * FROM `PROJECT`;
INSERT INTO `FILE`
  VALUES
    (null, 'lobby effect sketch', 1, 'G:\\Project\\VankeHQ\\Files\\lobby effect sketch.jpg', '2010-10-23', '2010-10-26'),
	(null, '1st floor lobby elevation', 3, 'G:\\Project\\VankeHQ\\Files\\1st floor lobby elevation.dwg', '2010-10-31', '2010-11-03'),
    (null, '1st floor reception elevation', 3, 'G:\\Project\\VankeHQ\\Files\\1st floor reception elevation.dwg', '2010-10-28', '2010-10-30'),
    (null, 'design description', 12, 'G:\\Project\\VankeHQ\\Files\\design description.doc', '2010-10-28', '2010-10-30'),
    (null, '2nd floor plan', 2, 'G:\\Project\\VankeHQ\\Files\\2nd floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, '2nd floor conference room entrance detail', 6, 'G:\\Project\\VankeHQ\\Files\\2nd floor conference room entrance detail.dwg', '2010-10-28', '2010-10-30'),
    (null, '2nd floor hall material sample', 5, 'G:\\Project\\VankeHQ\\Files\\2nd floor hall material sample.pdf', '2010-10-28', '2010-10-30'),
    (null, '3rd floor plan', 2, 'G:\\Project\\VankeHQ\\Files\\3rd floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, '4th floor plan', 2, 'G:\\Project\\VankeHQ\\Files\\4th floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'building section', 4, 'G:\\Project\\VankeHQ\\Files\\building section.dwg', '2010-10-28', '2010-10-30'),
    (null, 'references', 13, 'G:\\Project\\VankeHQ\\Files\\references.xlsx', '2010-10-28', '2010-10-30'),
    (null, 'executive lounge elevation', 3, 'G:\\Project\\NewOrientalHotel\\Files\\executive lounge elevation.dwg', '2010-10-28', '2010-10-30'),
    (null, 'lobby elevation', 3, 'G:\\Project\\NewOrientalHotel\\Files\\lobby elevation.dwg', '2010-10-28', '2010-10-30'),
    (null, '1st floor plan', 2, 'G:\\Project\\NewOrientalHotel\\Files\\1st floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, '2nd floor plan', 2, 'G:\\Project\\NewOrientalHotel\\Files\\2nd floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'guest room type A plan', 3, 'G:\\Project\\NewOrientalHotel\\Files\\guest room type A plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'lobby rendering day', 8, 'G:\\Project\\NewOrientalHotel\\Files\\lobby rendering day.jpg', '2010-10-28', '2010-10-30'),
    (null, 'lobby rendering night', 8, 'G:\\Project\\NewOrientalHotel\\Files\\lobby rendering night.jpg', '2010-10-28', '2010-10-30'),
    (null, 'lobby effect model', 7, 'G:\\Project\\NewOrientalHotel\\Files\\lobby effect model.3ds', '2010-10-28', '2010-10-30'),
    (null, 'guest room type B plan', 2, 'G:\\Project\\NewOrientalHotel\\Files\\guest room type B plan.dwg', '2010-10-28', '2010-10-30'),
    (null, '1st floor ceiling plan', 2, 'G:\\Project\\NewOrientalHotel\\Files\\1st floor ceiling plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'design specification', 11, 'G:\\Project\\NewOrientalHotel\\Files\\1st floor ceiling plan.dwg', '2010-10-28', '2010-10-30'),
    (null, '1st floor plan', 2, 'G:\\Project\\ZhengzhouXiangshuwan\\Files\\1st floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, '2nd floor plan', 2, 'G:\\Project\\ZhengzhouXiangshuwan\\Files\\2nd floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, '3rd floor plan', 2, 'G:\\Project\\ZhengzhouXiangshuwan\\Files\\2nd floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'guest room plan', 2, 'G:\\Project\\ZhengzhouXiangshuwan\\Files\\guest room plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'lobby bar plan', 2, 'G:\\Project\\ZhengzhouXiangshuwan\\Files\\lobby bar plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'lobby reception elevation', 3, 'G:\\Project\\ZhengzhouXiangshuwan\\Files\\lobby reception elevation.dwg', '2010-10-28', '2010-10-30'),
    (null, '1st floor lobby floor plan', 3, 'G:\\Project\\ZhengzhouXiangshuwan\\Files\\1st floor lobby floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'lobby redering', 8, 'G:\\Project\\ZhengzhouXiangshuwan\\Files\\lobby redering.dwg', '2010-10-28', '2010-10-30'),
    (null, 'lobby model', 7, 'G:\\Project\\ZhengzhouXiangshuwan\\Files\\lobby model.dwg', '2010-10-28', '2010-10-30'),
    (null, 'sketches bind', 1, 'G:\\Project\\BarnX\\Files\\sketches bind.pdf', '2010-10-28', '2010-10-30'),
    (null, 'entrance elevation', 3, 'G:\\Project\\BarnX\\Files\\entrance elevation.dwg', '2010-10-28', '2010-10-30'),
    (null, '1st floor plan', 2, 'G:\\Project\\BarnX\\Files\\1st floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'stair case detail', 6, 'G:\\Project\\BarnX\\Files\\stair case detail.dwg', '2010-10-28', '2010-10-30'),
    (null, 'embossment sample', 5, 'G:\\Project\\BarnX\\Files\\embossment sample.dwg', '2010-10-28', '2010-10-30'),
    (null, 'design description', 12, 'G:\\Project\\BarnX\\Files\\design description.pdf', '2010-10-28', '2010-10-30'),
    (null, 'lobby concept plan', 2, 'G:\\Project\\HyteraHQ\\Files\\lobby concept plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'CEO office concept sketch', 1, 'G:\\Project\\HyteraHQ\\Files\\CEO office concept sketch.dwg', '2010-10-28', '2010-10-30'),
    (null, '1st floor plan', 2, 'G:\\Project\\HyteraHQ\\Files\\1st floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, '2nd floor plan', 2, 'G:\\Project\\HyteraHQ\\Files\\2nd floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, '4th floor plan', 2, 'G:\\Project\\HyteraHQ\\Files\\4th floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, '3F facility floor plan', 2, 'G:\\Project\\HyteraHQ\\Files\\3F facility floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'CEO office plan', 2, 'G:\\Project\\HyteraHQ\\Files\\2nd floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'lobby elevation', 3, 'G:\\Project\\HyteraHQ\\Files\\2nd floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'design description', 12, 'G:\\Project\\HyteraHQ\\Files\\design description.pdf', '2010-10-28', '2010-10-30'),
    (null, 'revit model', 9, 'G:\\Project\\HyteraHQ\\Files\\revit model', '2010-10-28', '2010-10-30'),
    (null, 'design specification', 11, 'G:\\Project\\HyteraHQ\\Files\\design specification.pdf', '2010-10-28', '2010-10-30'),
    (null, 'concept sketch bind', 1, 'G:\\Project\\500ShoppingCenter\\Files\\concept sketch bind.pdf', '2010-10-28', '2010-10-30'),
    (null, 'site photos', 14, 'G:\\Project\\500ShoppingCenter\\Files\\site photos', '2010-10-28', '2010-10-30'),
    (null, 'main section', 4, 'G:\\Project\\500ShoppingCenter\\Files\\main section.dwg', '2010-10-28', '2010-10-30'),
    (null, '1st floor plan', 2, 'G:\\Project\\500ShoppingCenter\\Files\\1st floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, '2nd floor plan', 2, 'G:\\Project\\500ShoppingCenter\\Files\\2nd floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'design description', 12, 'G:\\Project\\500ShoppingCenter\\Files\\design description.pdf', '2010-10-28', '2010-10-30'),
    (null, 'design specification', 11, 'G:\\Project\\500ShoppingCenter\\Files\\design specification.pdf', '2010-10-28', '2010-10-30'),
    (null, 'revit model', 9, 'G:\\Project\\500ShoppingCenter\\Files\\revit model', '2010-10-28', '2010-10-30'),
    (null, 'references', 13, 'G:\\Project\\500ShoppingCenter\\Files\\2nd floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'concept sketches', 1, 'G:\\Project\\YunnanRestaurant\\Files\\concept sketches.pdf', '2010-10-28', '2010-10-30'),
    (null, 'floor plan', 2, 'G:\\Project\\YunnanRestaurant\\Files\\2nd floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'decorative wall elevation', 3, 'G:\\Project\\YunnanRestaurant\\Files\\decorative wall elevation.dwg', '2010-10-28', '2010-10-30'),
    (null, 'concept sketches', 1, 'G:\\Project\\MeixinCareCenter\\Files\\concept sketches.pdf', '2010-10-28', '2010-10-30'),
    (null, 'floor plan', 2, 'G:\\Project\\MeixinCareCenter\\Files\\2nd floor plan.dwg', '2010-10-28', '2010-10-30'),
    (null, 'decorative wall elevation', 3, 'G:\\Project\\MeixinCareCenter\\Files\\decorative wall elevation.dwg', '2010-10-28', '2010-10-30'),
    (null, 'design description', 12, 'G:\\Project\\MeixinCareCenter\\Files\\design description.pdf', '2010-10-28', '2010-10-30'),
    (null, 'concept design sketches', 3, 'G:\\Project\\VankeHQ_Deco\\Files\\concept design.psd', '2010-10-28', '2010-10-30'),
    (null, 'product locative plan', 10, 'G:\\Project\\VankeHQ_Deco\\Files\\product locative plan.pdf', '2010-10-28', '2010-10-30')
    -- for time's sake, the create and last edit date wasn't realistic
    ;
SELECT * FROM `FILE`;

INSERT INTO `PORTFOLIO_MATERIAL`
  VALUES
    (1, 1),
    (2, 2),
    (2, 3),
    (2, 4),
    (2, 5),
    (3, 6),
    (3, 7),
    (3, 8),
    (3, 9),
    (4, 5),
    (4, 8),
    (4, 9),
	(4, 2),
    (4, 3),
    (4, 10),
    (4, 11),
    (5, 12),
    (5, 13),
    (6, 12),
    (6, 13),
    (6, 14),
    (6, 15),
    (7, 16),
    (7, 17),
    (7, 18),
    (7, 19),
    (7, 20),
    (7, 21),
    (8, 22),
    (9, 23),
    (9, 24),
    (9, 25),
    (9, 26),
    (10, 27),
    (10, 28),
    (10, 29),
    (11, 27),
    (11, 28),
    (11, 29),
    (11, 30),
    (11, 31),
    (12, 32),
    (12, 33),
    (13, 32),
    (13, 33),
    (13, 34),
    (13, 35),
    (14, 36),
    (14, 37),
    (15, 32),
    (15, 33),
    (15, 34),
    (15, 35),
    (15, 36),
    (15, 37),
    (16, 38),
    (16, 39),
    (17, 40),
    (17, 41),
    (17, 42),
    (18, 43),
    (18, 44),
    (18, 45),
    (18, 46),
    (18, 47),
    (19, 46),
    (19, 47),
    (19, 48),
    (20, 49),
    (20, 50),
    (21, 51),
    (21, 52),
    (21, 53),
    (22, 52),
    (22, 53),
    (22, 54),
    (23, 55),
    (23, 56),
    (23, 57),
    (24, 58),
    (25, 59),
    (26, 59),
    (26, 60),
    (27, 61),
    (28, 62),
    (28, 63),
	(29, 62),
    (29, 63),
    (29, 64),
    (30, 65),
    (31, 66)
    ;
SELECT * FROM `PORTFOLIO_MATERIAL`;

SELECT FILE_ID, FILE_TYPE_NAME, FILE_PATH FROM `FILE` NATURAL JOIN `FILE_TYPE` ORDER BY FILE_ID;
SELECT EMPLOYEE_ID, POSITION_NAME, PROJECT_NAME FROM `EMPLOYEE` NATURAL JOIN `ASSIGNMENT` NATURAL JOIN `PROJECT` NATURAL JOIN `POSITION`;
INSERT INTO `AUTHORSHIP`
  VALUES
    (null, 1, 1, '1st Author'),
    (null, 2, 3, '1st Author'),
    (null, 2, 1, 'Mentor'),
    (null, 2, 4, '2nd Author'),
    (null, 3, 3, 'Mentor'),
    (null, 3, 5, '2nd Author'),
    (null, 3, 5, '1st Author'),
    (null, 4, 1, '1st Author'),
    (null, 5, 1, '1st Author'),
    (null, 5, 3, '2nd Author'),
    (null, 5, 5, '3rd Author'),
    (null, 6, 4, '1st Author'),
    (null, 6, 1, 'Mentor'),
    (null, 7, 3, '1st Author'),
    (null, 7, 7, 'Mentor'),
    (null, 8, 3, '1st Author'),
    (null, 8, 1, 'Mentor'),
    (null, 8, 4, '2nd Author'),
    (null, 9, 3, '1st Author'),
    (null, 9, 1, 'Mentor'),
    (null, 9, 4, '2nd Author'),
    (null, 9, 5, '3rd Author'),
    (null, 10, 1, '1st Author'),
    (null, 10, 3, '2nd Author'),
    (null, 11, 7, 'Editor'),
    (null, 12, 2, '1st Author'),
    (null, 13, 3, '1st Author'),
    (null, 14, 3, '1st Author'),
    (null, 15, 3, '1st Author'),
    (null, 16, 2, '1st Author'),
    (null, 17, 3, '1st Author'),
    (null, 18, 10, '1st Author'),
    (null, 19, 2, '1st Author'),
    (null, 20, 3, '1st Author'),
    (null, 21, 2, '1st Author'),
    (null, 22, 2, '1st Author'),
    (null, 23, 1, '1st Author'),
    (null, 24, 30, '1st Author'),
    (null, 25, 30, '1st Author'),
    (null, 26, 5, '1st Author'),
    (null, 27, 5, '1st Author'),
    (null, 28, 30, '1st Author'),
    (null, 29, 1, '1st Author'),
    (null, 30, 5, '1st Author'),
    (null, 31, 5, '1st Author'),
    (null, 32, 10, '1st Author'),
    (null, 33, 10, '1st Author'),
    (null, 34, 10, '1st Author'),
    (null, 35, 18, '1st Author'),
    (null, 36, 21, '1st Author'),
    (null, 37, 18, '1st Author'),
    (null, 38, 1, '1st Author'),
    (null, 39, 1, '1st Author'),
    (null, 40, 11, '1st Author'),
    (null, 41, 1, '1st Author'),
    (null, 42, 16, '1st Author'),
    (null, 43, 13, '1st Author'),
    (null, 44, 30, '1st Author'),
    (null, 45, 13, '1st Author'),
    (null, 46, 13, '1st Author'),
    (null, 47, 30, '1st Author'),
    (null, 48, 11, '1st Author'),
    (null, 49, 1, '1st Author'),
    (null, 50, 1, '1st Author'),
    (null, 51, 32, '1st Author'),
    (null, 52, 14, '1st Author'),
    (null, 53, 1, '1st Author'),
    (null, 54, 14, '1st Author'),
    (null, 55, 32, '1st Author'),
    (null, 56, 12, '1st Author'),
    (null, 57, 12, '1st Author'),
    (null, 58, 6, '1st Author'),
    (null, 59, 12, '1st Author'),
    (null, 60, 12, '1st Author'),
    (null, 61, 14, '1st Author'),
    (null, 62, 28, '1st Author'),
    (null, 63, 14, '1st Author'),
    (null, 64, 14, '1st Author'),
    (null, 65, 1, '1st Author'),
    (null, 66, 11, '1st Author')
    -- for time's sake, only one author for each file has been recoreded here execpt for the 1st project
    ;
SELECT * FROM `AUTHORSHIP`;

SELECT PROJECT_ID, PROJECT_NAME, ROLE_ID, EMPLOYEE_ID FROM `PROJECT` NATURAL JOIN `ASSIGNMENT` NATURAL JOIN `ROLE` NATURAL JOIN `EMPLOYEE` ORDER BY PROJECT_ID;
SELECT FILE_ID, FILE_TYPE_NAME, FILE_PATH FROM `FILE` NATURAL JOIN `FILE_TYPE` ORDER BY FILE_ID;
INSERT INTO `REVIEW`
  VALUES
    (null, 1, 1, '2010-01-01'),
    (null, 2, 1, '2010-01-01'),
    (null, 3, 1, '2010-01-01'),
    (null, 4, 1, '2010-01-01'),
    (null, 5, 1, '2010-01-01'),
    (null, 6, 1, '2010-01-01'),
    (null, 7, 1, '2010-01-01'),
    (null, 8, 1, '2010-01-01'),
    (null, 9, 1, '2010-01-01'),
    (null, 10, 1, '2010-01-01'),
    (null, 11, 1, '2010-01-01'),
    
    (null, 12, 2, '2010-01-01'),
    (null, 13, 2, '2010-01-01'),
    (null, 14, 2, '2010-01-01'),
    (null, 15, 2, '2010-01-01'),
    (null, 16, 2, '2010-01-01'),
    (null, 17, 2, '2010-01-01'),
    (null, 18, 2, '2010-01-01'),
    (null, 19, 2, '2010-01-01'),
    (null, 20, 2, '2010-01-01'),
    (null, 21, 2, '2010-01-01'),
    (null, 22, 2, '2010-01-01'),
    
    (null, 23, 1, '2010-01-01'),
    (null, 24, 1, '2010-01-01'),
    (null, 25, 1, '2010-01-01'),
    (null, 26, 1, '2010-01-01'),
    (null, 27, 1, '2010-01-01'),
    (null, 28, 1, '2010-01-01'),
    (null, 29, 1, '2010-01-01'),
    (null, 30, 1, '2010-01-01'),
    (null, 31, 1, '2010-01-01'),
    
    (null, 32, 10, '2010-01-01'),
    (null, 33, 10, '2010-01-01'),
    (null, 34, 10, '2010-01-01'),
    (null, 35, 10, '2010-01-01'),
    (null, 36, 10, '2010-01-01'),
    (null, 37, 10, '2010-01-01'),
    
    (null, 38, 1, '2010-01-01'),
    (null, 39, 1, '2010-01-01'),
    (null, 40, 1, '2010-01-01'),
    (null, 41, 1, '2010-01-01'),
    (null, 42, 1, '2010-01-01'),
    (null, 43, 1, '2010-01-01'),
    (null, 44, 1, '2010-01-01'),
    (null, 45, 1, '2010-01-01'),
    (null, 46, 1, '2010-01-01'),
    (null, 47, 1, '2010-01-01'),
    (null, 48, 1, '2010-01-01'),
    
    (null, 49, 1, '2010-01-01'),
    (null, 50, 1, '2010-01-01'),
    (null, 51, 1, '2010-01-01'),
    (null, 52, 1, '2010-01-01'),
    (null, 53, 1, '2010-01-01'),
    (null, 54, 1, '2010-01-01'),
    (null, 55, 1, '2010-01-01'),
    (null, 56, 1, '2010-01-01'),
    (null, 57, 1, '2010-01-01'),
    
    (null, 58, 12, '2010-01-01'),
    (null, 59, 12, '2010-01-01'),
    (null, 60, 12, '2010-01-01'),
    
    (null, 61, 14, '2010-01-01'),
    (null, 62, 14, '2010-01-01'),
    (null, 63, 14, '2010-01-01'),
    (null, 64, 14, '2010-01-01'),
    
    (null, 65, 1, '2010-01-01'),
    (null, 66, 1, '2010-01-01')
    ;
SELECT * FROM `REVIEW`;

COMMIT;

DROP VIEW IF EXISTS `PRODUCT_LIST_TOTAL`;
CREATE VIEW `PRODUCT_LIST_TOTAL` AS
  SELECT PROJECT_ID, PROJECT_NAME, PRODUCT_LIST_ID, 
    SUM(PRODUCT_COUNT * PRICE) AS TOTAL_PRICE
    FROM PROJECT 
      NATURAL JOIN PRODUCT_LIST 
      NATURAL JOIN PRODUCT_LIST_ITEM 
      NATURAL JOIN PRODUCT
  GROUP BY PRODUCT_LIST_ID;
  
SELECT * FROM `PRODUCT_LIST_TOTAL`;

DROP TRIGGER IF EXISTS `AUTO_UPDATE_PRODUCT_LIST_DATE`;
DELIMITER //
CREATE TRIGGER `AUTO_UPDATE_PRODUCT_LIST_DATE`
AFTER INSERT
ON PRODUCT_LIST_ITEM 
FOR EACH ROW
  UPDATE PRODUCT_LIST
  SET CREATED_DATE = CURDATE()
  WHERE PRODUCT_LIST_ID = NEW.PRODUCT_LIST_ID
;
DELIMITER;

SELECT TABLE_NAME, TABLE_ROWS
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'HLD_DB'
ORDER BY TABLE_ROWS DESC;