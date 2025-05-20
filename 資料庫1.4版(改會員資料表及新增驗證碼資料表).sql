CREATE DATABASE GameCase;

USE GameCase;

-- 用戶類型表：儲存所有可能的用戶類型
CREATE TABLE tUserTypes (
    FUserTypeID INT IDENTITY(1,1) PRIMARY KEY,
    FUserTypeName NVARCHAR(20) NOT NULL UNIQUE  -- 用戶類型名稱
);

-- 用戶資料表
CREATE TABLE tUsers (
    FUserID INT IDENTITY(1,1) PRIMARY KEY,
    FFullName NVARCHAR(100) NOT NULL,            -- 會員全名
    FEmail NVARCHAR(100) UNIQUE NOT NULL,        -- 電子郵件（登入帳號）
    FPasswordHash NVARCHAR(255) NOT NULL,        -- 密碼雜湊值
    FPhoneNumber NVARCHAR(20),                   -- 電話號碼
    FAddress NVARCHAR(255),                      -- 地址
    FBirthday DATE,                              -- 生日
    FGender NVARCHAR(10),                        -- 性別
    FProfileImageUrl NVARCHAR(255),              -- 頭像URL
    FLastLoginTime DATETIME,                     -- 最後登入時間
    FIsEmailVerified BIT DEFAULT 0,              -- 電子郵件是否驗證
    FStatus TINYINT DEFAULT 1,                   -- 會員狀態：1=啟用, 2=停用, 3=刪除
    FSuspensionReason NVARCHAR(500),            -- 停用原因
    FSuspensionEndTime DATETIME,                -- 停用結束時間
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FUpdatedAt DATETIME                          -- 更新時間
);

-- 用戶類型關聯表：連接用戶和用戶類型
CREATE TABLE UserUserTypes (
    FUserID INT NOT NULL,                        -- 關聯用戶ID
    FUserTypeID INT NOT NULL,                    -- 關聯用戶類型ID
    PRIMARY KEY (FUserID, FUserTypeID),          -- 主鍵為用戶ID和用戶類型ID的組合
    FOREIGN KEY (FUserID) REFERENCES tUsers(FUserID),
    FOREIGN KEY (FUserTypeID) REFERENCES tUserTypes(FUserTypeID)
);

-- 驗證碼資料表：用於電子郵件驗證
CREATE TABLE tVerificationCodes (
    FId INT IDENTITY(1,1) PRIMARY KEY,           -- 主鍵
    FEmail NVARCHAR(100) NOT NULL,               -- 待驗證的電子郵件
    FCode NVARCHAR(6) NOT NULL,                  -- 6位數驗證碼
    FExpireTime DATETIME NOT NULL,               -- 驗證碼過期時間
    FIsUsed BIT DEFAULT 0,                       -- 是否已使用
    FCreatedAt DATETIME DEFAULT GETDATE()        -- 建立時間
);

-- 建立索引
CREATE INDEX IX_VerificationCodes_Email ON tVerificationCodes(FEmail);
CREATE INDEX IX_VerificationCodes_Code ON tVerificationCodes(FCode);

-- 插入初始資料
-- 1. 插入用戶類型
INSERT INTO tUserTypes (FUserTypeName) VALUES 
('Worker'),   -- 工作者 (ID: 1)
('Poster');   -- 發布者 (ID: 2)

-- 2. 插入測試用戶資料
INSERT INTO tUsers (
    FFullName, 
    FEmail, 
    FPasswordHash, 
    FPhoneNumber,
    FBirthday,
    FGender, 
    FStatus
) VALUES 
('測試用戶一', 'test1@example.com', 'hash_password', '0912345678', '1990-01-01', '男', 1),
('測試用戶二', 'test2@example.com', 'hash_password', '0923456789', '1992-02-02', '女', 1);

-- 3. 設定用戶類型關聯
INSERT INTO UserUserTypes (FUserID, FUserTypeID)
VALUES 
(1, 1),  -- 用戶一是工作者
(2, 2);  -- 用戶二是發布者

-- 接案者資料表：儲存接案者特定資訊
CREATE TABLE tWorkers (
    FWorkerID INT IDENTITY(1,1) PRIMARY KEY,
    FWorkerNo NVARCHAR(20) UNIQUE NOT NULL,      -- 接案者編號
    FUserID INT NOT NULL,                        -- 關聯用戶ID
    FCompletedTasksCount INT DEFAULT 0,          -- 已完成案件數
    FRating FLOAT CHECK (FRating BETWEEN 0 AND 5), -- 評分
    FIsVerified BIT DEFAULT 0,                   -- 是否已驗證
    FIsDeleted BIT DEFAULT 0,                    -- 是否已刪除
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FUpdatedAt DATETIME,                         -- 更新時間
    CONSTRAINT FK_Workers_Users FOREIGN KEY (FUserID) REFERENCES tUsers(FUserID)
);

-- 發案者資料表：儲存發案者特定資訊
CREATE TABLE tPosters (
    FPosterID INT IDENTITY(1,1) PRIMARY KEY,
    FPosterNo NVARCHAR(20) UNIQUE NOT NULL,      -- 發案者編號
    FUserID INT NOT NULL,                        -- 關聯用戶ID
    FCompanyName NVARCHAR(255),                  -- 公司名稱
    FCompanyRegistrationNumber NVARCHAR(50),     -- 公司註冊編號
    FReputationScore FLOAT CHECK (FReputationScore BETWEEN 0 AND 5), -- 信譽評分
    FIsVerified BIT DEFAULT 0,                   -- 是否已驗證
    FIsDeleted BIT DEFAULT 0,                    -- 是否已刪除
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FUpdatedAt DATETIME,                         -- 更新時間
    CONSTRAINT FK_Posters_Users FOREIGN KEY (FUserID) REFERENCES tUsers(FUserID)
);

-- 任務類別表：儲存任務的分類
CREATE TABLE tTaskCategories (
    FCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    FCategoryNo NVARCHAR(20) UNIQUE NOT NULL,    -- 類別編號
    FName NVARCHAR(100) NOT NULL UNIQUE,         -- 類別名稱
    FDescription NVARCHAR(255),                  -- 類別描述
    FParentCategoryID INT,                       -- 父類別ID（可選，用於多層分類）
    FIsActive BIT DEFAULT 1,                     -- 是否啟用
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FUpdatedAt DATETIME                          -- 更新時間
    -- 外鍵約束可以在這裡添加，但要確保 tTaskCategories 表已經存在
);
-- 任務資料表：儲存所有案件資訊
CREATE TABLE tTasks (
    FTaskID INT IDENTITY(1,1) PRIMARY KEY,   
    FPosterID INT NOT NULL,                      -- 發案者ID
    FCategoryID INT NOT NULL,                    -- 任務類別ID
    FTitle NVARCHAR(255) NOT NULL,               -- 任務標題
    FDescription NVARCHAR(MAX) NOT NULL,         -- 任務描述   
    FBudget INT CHECK (FBudget > 0) NOT NULL,	 -- 預算金額
	FLocation NVARCHAR(255) NOT NULL,            -- 工作地點 (縣市、遠端)
	FLocationDetail NVARCHAR(255) NOT NULL,		 -- 詳細地址
	FMember nvarchar(50) NOT NULL,				 -- 聯絡人資訊 (讓使用者可在修改)
	FPhone int NOT NULL,						 -- 聯絡人電話 (讓使用者可在修改)
	FEmail nvarchar(50) NOT NULL,				 -- 聯絡人Email (讓使用者可在修改)
    FStatus NVARCHAR(20) NOT NULL,				 -- 任務狀態 (尋人、審核、取消、刪除)     
    FDeadline DATETIME NOT NULL,                 -- 截止日期   
    FCreatedAt DATETIME DEFAULT GETDATE() NOT NULL,		-- 建立時間
    FUpdatedAt DATETIME DEFAULT GETDATE() NOT NULL,     -- 更新時間
    --CONSTRAINT FK_Tasks_Posters FOREIGN KEY (FPosterID) REFERENCES tPosters(FPosterID),
    --CONSTRAINT FK_Tasks_TaskCategories FOREIGN KEY (FCategoryID) REFERENCES tTaskCategories(FCategoryID)
);

--插入案件資訊
INSERT INTO tTasks (FPosterID, FCategoryID, FTitle, FDescription, FBudget, FLocation, FLocationDetail, FMember, FPhone, FEmail, FStatus, FDeadline)
VALUES
(1, 1, N'網頁設計', N'設計一個響應式網站，包含前端與後端功能。', 20000, N'台北市', N'中正區信義路一段', N'陳先生', 0912345678, N'chen@example.com', N'尋人', '2025-02-15'),
(2, 2, N'平面設計', N'設計一款品牌Logo，需提供3個提案。', 5000, N'新北市', N'板橋區中山路二段', N'林小姐', 0922123456, N'lin@example.com', N'審核', '2025-03-01'),
(3, 3, N'翻譯服務', N'將5000字的文件從英文翻譯成中文。', 8000, N'台中市', N'西屯區台灣大道三段', N'張小姐', 0933123456, N'zhang@example.com', N'取消', '2025-01-30'),
(4, 4, N'軟體開發', N'開發一個任務管理系統，包含資料庫設計。', 50000, N'台南市', N'東區勝利路', N'王先生', 0945123456, N'wang@example.com', N'尋人', '2025-04-01'),
(5, 5, N'攝影服務', N'為一場婚禮提供全程攝影與剪輯服務。', 30000, N'高雄市', N'三民區民族一路', N'周小姐', 0956123456, N'zhou@example.com', N'審核', '2025-03-15'),
(6, 1, N'網頁更新', N'更新現有網站的內容及排版。', 7000, N'新竹市', N'東區光復路', N'許先生', 0967123456, N'xu@example.com', N'取消', '2025-02-28'),
(7, 2, N'商品包裝設計', N'設計一款高端產品的包裝外盒。', 12000, N'台北市', N'大安區敦化南路', N'何小姐', 0978123456, N'he@example.com', N'刪除', '2025-03-10'),
(8, 3, N'日文翻譯', N'翻譯技術文件約3000字，從日文到中文。', 6000, N'新北市', N'永和區中正路', N'龔先生', 0989123456, N'gong@example.com', N'尋人', '2025-02-20'),
(9, 4, N'移動應用開發', N'開發一款簡單的安卓APP，包含登錄功能。', 40000, N'桃園市', N'中壢區中山東路', N'李先生', 0912123456, N'li@example.com', N'審核', '2025-04-05'),
(10, 5, N'活動攝影', N'記錄企業年度活動並進行後期剪輯。', 20000, N'台中市', N'北區學士路', N'吳小姐', 0922123456, N'wu@example.com', N'取消', '2025-03-20'),
(11, 1, N'WordPress網站建置', N'使用WordPress建置一個企業網站，包含安裝與設置。', 15000, N'嘉義市', N'西區文化路', N'徐先生', 0933123456, N'xu@example.com', N'尋人', '2025-02-25'),
(12, 2, N'品牌識別設計', N'設計企業的完整品牌識別，包括Logo與名片。', 25000, N'台南市', N'北區成功路', N'賴小姐', 0944123456, N'lai@example.com', N'審核', '2025-03-05'),
(13, 3, N'韓文翻譯', N'翻譯一篇學術文章，從韓文到中文，約2000字。', 9000, N'高雄市', N'鳳山區中山路', N'戴先生', 0955123456, N'dai@example.com', N'取消', '2025-01-25'),
(14, 4, N'數據分析系統', N'開發一個數據分析後台，整合多個API。', 60000, N'新北市', N'新店區北新路', N'杜小姐', 0966123456, N'du@example.com', N'尋人', '2025-04-10'),
(15, 5, N'商品拍攝', N'拍攝電商平台使用的產品圖片，約50張。', 18000, N'台北市', N'內湖區瑞光路', N'宋先生', 0977123456, N'song@example.com', N'審核', '2025-03-30');

-- 技能類別表：儲存技能的主要分類
CREATE TABLE tSkillCategories (
    FCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    FCategoryNo NVARCHAR(20) UNIQUE NOT NULL,    -- 類別編號
    FName NVARCHAR(100) NOT NULL UNIQUE,         -- 類別名稱
    FDescription NVARCHAR(MAX),                  -- 類別描述
    FIsActive BIT DEFAULT 1,                     -- 是否啟用
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FUpdatedAt DATETIME                          -- 更新時間
);

-- 技能表：儲存具體的技能項目
CREATE TABLE tSkills (
    FSkillID INT IDENTITY(1,1) PRIMARY KEY,
    FSkillNo NVARCHAR(20) UNIQUE NOT NULL,       -- 技能編號
    FCategoryID INT NOT NULL,                    -- 所屬類別ID
    FName NVARCHAR(100) NOT NULL UNIQUE,         -- 技能名稱
    FDescription NVARCHAR(MAX),                  -- 技能描述
    FIsActive BIT DEFAULT 1,                     -- 是否啟用
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FUpdatedAt DATETIME,                         -- 更新時間
    CONSTRAINT FK_Skills_Categories FOREIGN KEY (FCategoryID) REFERENCES tSkillCategories(FCategoryID)
);

-- 接案者技能表：記錄接案者擁有的技能
CREATE TABLE tWorkerSkills (
    FWorkerSkillID INT IDENTITY(1,1) PRIMARY KEY,
    FWorkerID INT NOT NULL,                      -- 接案者ID
    FSkillID INT NOT NULL,                       -- 技能ID
    FSkillLevel NVARCHAR(20) CHECK (FSkillLevel IN ('初級', '中級', '高級', '專家')),
    FYearsOfExperience INT,                      -- 相關年資
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FUpdatedAt DATETIME,                         -- 更新時間
    CONSTRAINT FK_WorkerSkills_Workers FOREIGN KEY (FWorkerID) REFERENCES tWorkers(FWorkerID),
    CONSTRAINT FK_WorkerSkills_Skills FOREIGN KEY (FSkillID) REFERENCES tSkills(FSkillID)
);
-- 應徵紀錄表：記錄接案者應徵任務的紀錄
CREATE TABLE tApplications (
    FApplicationID INT IDENTITY(1,1) PRIMARY KEY,
    FApplicationNo NVARCHAR(20) UNIQUE NOT NULL, -- 應徵編號
    FTaskID INT NOT NULL,                        -- 任務ID
    FWorkerID INT NOT NULL,                      -- 接案者ID
    FProposedPrice MONEY CHECK (FProposedPrice >= 0), -- 建議價格
    FMessage NVARCHAR(MAX),                      -- 應徵訊息
    FStatus NVARCHAR(20) CHECK (FStatus IN ('Pending', 'Accepted', 'Rejected')) NOT NULL,
    FIsDeleted BIT DEFAULT 0,                    -- 是否已刪除（保留，因為應徵紀錄重要）
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 應徵時間
    FUpdatedAt DATETIME,                         -- 更新時間
    CONSTRAINT FK_Applications_Tasks FOREIGN KEY (FTaskID) REFERENCES tTasks(FTaskID),
    CONSTRAINT FK_Applications_Workers FOREIGN KEY (FWorkerID) REFERENCES tWorkers(FWorkerID)
);

-- 交易表：儲存平台上的所有交易記錄
CREATE TABLE tTransactions (
    FTransactionID INT IDENTITY(1,1) PRIMARY KEY,
    FTransactionNo NVARCHAR(20) UNIQUE NOT NULL, -- 交易編號
    FTaskID INT NOT NULL,                        -- 關聯任務ID
    FPayerID INT NOT NULL,                       -- 付款人ID
    FPayeeID INT NOT NULL,                       -- 收款人ID
    FAmount MONEY NOT NULL CHECK (FAmount >= 0),  -- 交易金額
    FPlatformFee MONEY NOT NULL CHECK (FPlatformFee >= 0), -- 平台手續費
    FStatus NVARCHAR(20) CHECK (FStatus IN ('處理中', '成功', '失敗', '退款')) NOT NULL,
    FPaymentMethod NVARCHAR(50),                 -- 支付方式
    FIsDeleted BIT DEFAULT 0,                    -- 是否已刪除（保留，因為交易紀錄重要）
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FUpdatedAt DATETIME,                         -- 更新時間
    FCompletedAt DATETIME,                       -- 完成時間
    CONSTRAINT FK_Transactions_Tasks FOREIGN KEY (FTaskID) REFERENCES tTasks(FTaskID),
    CONSTRAINT FK_Transactions_Users_Payer FOREIGN KEY (FPayerID) REFERENCES tUsers(FUserID),
    CONSTRAINT FK_Transactions_Users_Payee FOREIGN KEY (FPayeeID) REFERENCES tUsers(FUserID)
);

-- 通知表：儲存系統發送給用戶的通知
CREATE TABLE tNotifications (
    FNotificationID INT IDENTITY(1,1) PRIMARY KEY,
    FNotificationNo NVARCHAR(20) UNIQUE NOT NULL, -- 通知編號
    FUserID INT NOT NULL,                        -- 接收用戶ID
    FTitle NVARCHAR(255) NOT NULL,               -- 通知標題
    FContent NVARCHAR(MAX) NOT NULL,             -- 通知內容
    FType NVARCHAR(50) NOT NULL,                 -- 通知類型
    FIsRead BIT DEFAULT 0,                       -- 是否已讀
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FUpdatedAt DATETIME,                         -- 更新時間
    CONSTRAINT FK_Notifications_Users FOREIGN KEY (FUserID) REFERENCES tUsers(FUserID)
);

-- 訊息表：儲存用戶間的對話內容
CREATE TABLE tMessages (
    FMessageID INT IDENTITY(1,1) PRIMARY KEY,
    FMessageNo NVARCHAR(20) UNIQUE NOT NULL,     -- 訊息編號
    FSenderID INT NOT NULL,                      -- 發送者ID
    FReceiverID INT NOT NULL,                    -- 接收者ID
    FTaskID INT,                                 -- 相關任務ID（選填）
    FContent NVARCHAR(MAX),                      -- 訊息內容
    FIsRead BIT DEFAULT 0,                       -- 是否已讀
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FUpdatedAt DATETIME,                         -- 更新時間
    CONSTRAINT FK_Messages_Users_Sender FOREIGN KEY (FSenderID) REFERENCES tUsers(FUserID),
    CONSTRAINT FK_Messages_Users_Receiver FOREIGN KEY (FReceiverID) REFERENCES tUsers(FUserID),
    CONSTRAINT FK_Messages_Tasks FOREIGN KEY (FTaskID) REFERENCES tTasks(FTaskID)
);

-----------不一定---------------
-- 檔案表：管理所有上傳的檔案
CREATE TABLE tFiles (
    FFileID INT IDENTITY(1,1) PRIMARY KEY,
    FFileNo NVARCHAR(20) UNIQUE NOT NULL,        -- 檔案編號
    FFileName NVARCHAR(255) NOT NULL,            -- 檔案名稱
    FFileUrl NVARCHAR(MAX) NOT NULL,             -- 檔案URL
    FFileType NVARCHAR(50),                      -- 檔案類型
    FFileSize BIGINT,                            -- 檔案大小
    FUploadedBy INT NOT NULL,                    -- 上傳者ID
    FRelatedTable NVARCHAR(50),                  -- 關聯表名
    FRelatedID INT,                              -- 關聯記錄ID
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FUpdatedAt DATETIME,                         -- 更新時間
    CONSTRAINT FK_Files_Users FOREIGN KEY (FUploadedBy) REFERENCES tUsers(FUserID)
);	
-- 評價表：記錄任務相關的所有評價
CREATE TABLE tReviews (
    FReviewID INT IDENTITY(1,1) PRIMARY KEY,
    FReviewNo NVARCHAR(20) UNIQUE NOT NULL,      -- 評價編號
    FTaskID INT NOT NULL,                        -- 任務ID
    FReviewerID INT NOT NULL,                    -- 評價者ID
    FRevieweeID INT NOT NULL,                    -- 被評價者ID
    FRating INT CHECK (FRating BETWEEN 1 AND 5), -- 評分
    FComment NVARCHAR(MAX),                      -- 評價內容
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FUpdatedAt DATETIME,                         -- 更新時間
    CONSTRAINT FK_Reviews_Tasks FOREIGN KEY (FTaskID) REFERENCES tTasks(FTaskID),
    CONSTRAINT FK_Reviews_Users_Reviewer FOREIGN KEY (FReviewerID) REFERENCES tUsers(FUserID),
    CONSTRAINT FK_Reviews_Users_Reviewee FOREIGN KEY (FRevieweeID) REFERENCES tUsers(FUserID)
);
-- 作品集表：記錄接案者的作品
CREATE TABLE tPortfolios (
    FPortfolioID INT IDENTITY(1,1) PRIMARY KEY,
    FPortfolioNo NVARCHAR(20) UNIQUE NOT NULL,   -- 作品編號
    FWorkerID INT NOT NULL,                      -- 接案者ID
    FTitle NVARCHAR(255) NOT NULL,               -- 作品標題
    FDescription NVARCHAR(MAX),                  -- 作品描述
    FSkillsUsed NVARCHAR(MAX),                  -- 使用技能
    FIsPublic BIT DEFAULT 1,                     -- 是否公開
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FUpdatedAt DATETIME,                         -- 更新時間
    CONSTRAINT FK_Portfolios_Workers FOREIGN KEY (FWorkerID) REFERENCES tWorkers(FWorkerID)
);
-- 爭議表：記錄任務相關的爭議
CREATE TABLE tDisputes (
    FDisputeID INT IDENTITY(1,1) PRIMARY KEY,
    FDisputeNo NVARCHAR(20) UNIQUE NOT NULL,     -- 爭議編號
    FTaskID INT NOT NULL,                        -- 任務ID
    FReporterID INT NOT NULL,                    -- 檢舉人ID
    FReportedID INT NOT NULL,                    -- 被檢舉人ID
    FType NVARCHAR(50) NOT NULL,                 -- 爭議類型
    FDescription NVARCHAR(MAX),                  -- 爭議描述
    FStatus NVARCHAR(20) CHECK (FStatus IN ('Pending', 'Processing', 'Resolved', 'Closed')) NOT NULL,
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FResolvedAt DATETIME,                        -- 解決時間
    CONSTRAINT FK_Disputes_Tasks FOREIGN KEY (FTaskID) REFERENCES tTasks(FTaskID),
    CONSTRAINT FK_Disputes_Users_Reporter FOREIGN KEY (FReporterID) REFERENCES tUsers(FUserID),
    CONSTRAINT FK_Disputes_Users_Reported FOREIGN KEY (FReportedID) REFERENCES tUsers(FUserID)
);

CREATE TABLE tAdminStatus (
		FStatusID TINYINT PRIMARY KEY,           -- 狀態ID
		FStatusName NVARCHAR(20) NOT NULL,       -- 狀態名稱
		FDescription NVARCHAR(100),              -- 狀態描述
		FCreatedAt DATETIME DEFAULT GETDATE()    -- 建立時間
	);


	-- 員工資料表：儲存平台員工的基本資料
	INSERT INTO tAdminStatus (FStatusID, FStatusName, FDescription) VALUES
	(1, N'啟用中', N'管理員帳號正常使用中'),
	(2, N'審核中', N'管理員帳號等待審核'),
	(3, N'已刪除', N'管理員帳號已被刪除'); 

CREATE TABLE tAdmins (
    FAdminID INT IDENTITY(1,1) PRIMARY KEY,      -- 主鍵
    FAdminNo NVARCHAR(20) UNIQUE NOT NULL,       -- 管理員編號 (A001)
    FFullName NVARCHAR(100) NOT NULL,            -- 管理員全名
    FEmail NVARCHAR(100) UNIQUE NOT NULL,        -- 電子郵件
    FAdmPassword NVARCHAR(255) NOT NULL,        -- 密碼
    FMobilePhone NVARCHAR(20),                   -- 手機號碼
    FAdminLevel INT NOT NULL,                    -- 管理員等級 (1=一般, 2=進階, 3=超級管理員)
    FStatusID TINYINT NOT NULL DEFAULT 1,        -- 狀態ID
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- 建立時間
    FUpdatedAt DATETIME,                         -- 更新時間
    CONSTRAINT FK_Admin_Status FOREIGN KEY (FStatusID) 
    REFERENCES tAdminStatus(FStatusID)
);


--創建網頁公告事項資料表
CREATE TABLE tAnnounce (
	fAnnounceId INT PRIMARY KEY IDENTITY(1,1),
	fTitle NVARCHAR(100) NOT NULL,
	fContent NVARCHAR(1000) NOT NULL,
	fCreate_at Datetime Default GetDate(),
);

--插入公告事項
INSERT INTO tAnnounce (fTitle, fContent, fCreate_at) VALUES
('Platform Maintenance Notice', 'The platform will undergo maintenance from 2 AM to 5 AM. Please plan accordingly.', '2025-01-02 06:21:10'),
('New Feature Release', 'We are excited to introduce a new feature that enhances user experience.', '2025-01-02 06:21:10'),
('Holiday Schedule Update', 'Our holiday schedule has been updated. Check the calendar for details.', '2025-01-02 06:21:10'),
('System Upgrade Announcement', 'A system upgrade is scheduled next week to improve performance and security.', '2025-01-02 06:21:10'),
('Community Guidelines Update', 'Please review the updated community guidelines to ensure compliance.', '2025-01-02 06:21:10');

