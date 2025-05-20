CREATE DATABASE GameCase;

USE GameCase;

-- �Τ�������G�x�s�Ҧ��i�઺�Τ�����
CREATE TABLE tUserTypes (
    FUserTypeID INT IDENTITY(1,1) PRIMARY KEY,
    FUserTypeName NVARCHAR(20) NOT NULL UNIQUE  -- �Τ������W��
);

-- �Τ��ƪ�
CREATE TABLE tUsers (
    FUserID INT IDENTITY(1,1) PRIMARY KEY,
    FFullName NVARCHAR(100) NOT NULL,            -- �|�����W
    FEmail NVARCHAR(100) UNIQUE NOT NULL,        -- �q�l�l��]�n�J�b���^
    FPasswordHash NVARCHAR(255) NOT NULL,        -- �K�X�����
    FPhoneNumber NVARCHAR(20),                   -- �q�ܸ��X
    FAddress NVARCHAR(255),                      -- �a�}
    FBirthday DATE,                              -- �ͤ�
    FGender NVARCHAR(10),                        -- �ʧO
    FProfileImageUrl NVARCHAR(255),              -- �Y��URL
    FLastLoginTime DATETIME,                     -- �̫�n�J�ɶ�
    FIsEmailVerified BIT DEFAULT 0,              -- �q�l�l��O�_����
    FStatus TINYINT DEFAULT 1,                   -- �|�����A�G1=�ҥ�, 2=����, 3=�R��
    FSuspensionReason NVARCHAR(500),            -- ���έ�]
    FSuspensionEndTime DATETIME,                -- ���ε����ɶ�
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FUpdatedAt DATETIME                          -- ��s�ɶ�
);

-- �Τ��������p��G�s���Τ�M�Τ�����
CREATE TABLE UserUserTypes (
    FUserID INT NOT NULL,                        -- ���p�Τ�ID
    FUserTypeID INT NOT NULL,                    -- ���p�Τ�����ID
    PRIMARY KEY (FUserID, FUserTypeID),          -- �D�䬰�Τ�ID�M�Τ�����ID���զX
    FOREIGN KEY (FUserID) REFERENCES tUsers(FUserID),
    FOREIGN KEY (FUserTypeID) REFERENCES tUserTypes(FUserTypeID)
);

-- ���ҽX��ƪ�G�Ω�q�l�l������
CREATE TABLE tVerificationCodes (
    FId INT IDENTITY(1,1) PRIMARY KEY,           -- �D��
    FEmail NVARCHAR(100) NOT NULL,               -- �����Ҫ��q�l�l��
    FCode NVARCHAR(6) NOT NULL,                  -- 6������ҽX
    FExpireTime DATETIME NOT NULL,               -- ���ҽX�L���ɶ�
    FIsUsed BIT DEFAULT 0,                       -- �O�_�w�ϥ�
    FCreatedAt DATETIME DEFAULT GETDATE()        -- �إ߮ɶ�
);

-- �إ߯���
CREATE INDEX IX_VerificationCodes_Email ON tVerificationCodes(FEmail);
CREATE INDEX IX_VerificationCodes_Code ON tVerificationCodes(FCode);

-- ���J��l���
-- 1. ���J�Τ�����
INSERT INTO tUserTypes (FUserTypeName) VALUES 
('Worker'),   -- �u�@�� (ID: 1)
('Poster');   -- �o���� (ID: 2)

-- 2. ���J���եΤ���
INSERT INTO tUsers (
    FFullName, 
    FEmail, 
    FPasswordHash, 
    FPhoneNumber,
    FBirthday,
    FGender, 
    FStatus
) VALUES 
('���եΤ�@', 'test1@example.com', 'hash_password', '0912345678', '1990-01-01', '�k', 1),
('���եΤ�G', 'test2@example.com', 'hash_password', '0923456789', '1992-02-02', '�k', 1);

-- 3. �]�w�Τ��������p
INSERT INTO UserUserTypes (FUserID, FUserTypeID)
VALUES 
(1, 1),  -- �Τ�@�O�u�@��
(2, 2);  -- �Τ�G�O�o����

-- ���ת̸�ƪ�G�x�s���ת̯S�w��T
CREATE TABLE tWorkers (
    FWorkerID INT IDENTITY(1,1) PRIMARY KEY,
    FWorkerNo NVARCHAR(20) UNIQUE NOT NULL,      -- ���ת̽s��
    FUserID INT NOT NULL,                        -- ���p�Τ�ID
    FCompletedTasksCount INT DEFAULT 0,          -- �w�����ץ��
    FRating FLOAT CHECK (FRating BETWEEN 0 AND 5), -- ����
    FIsVerified BIT DEFAULT 0,                   -- �O�_�w����
    FIsDeleted BIT DEFAULT 0,                    -- �O�_�w�R��
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FUpdatedAt DATETIME,                         -- ��s�ɶ�
    CONSTRAINT FK_Workers_Users FOREIGN KEY (FUserID) REFERENCES tUsers(FUserID)
);

-- �o�ת̸�ƪ�G�x�s�o�ת̯S�w��T
CREATE TABLE tPosters (
    FPosterID INT IDENTITY(1,1) PRIMARY KEY,
    FPosterNo NVARCHAR(20) UNIQUE NOT NULL,      -- �o�ת̽s��
    FUserID INT NOT NULL,                        -- ���p�Τ�ID
    FCompanyName NVARCHAR(255),                  -- ���q�W��
    FCompanyRegistrationNumber NVARCHAR(50),     -- ���q���U�s��
    FReputationScore FLOAT CHECK (FReputationScore BETWEEN 0 AND 5), -- �H�A����
    FIsVerified BIT DEFAULT 0,                   -- �O�_�w����
    FIsDeleted BIT DEFAULT 0,                    -- �O�_�w�R��
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FUpdatedAt DATETIME,                         -- ��s�ɶ�
    CONSTRAINT FK_Posters_Users FOREIGN KEY (FUserID) REFERENCES tUsers(FUserID)
);

-- �������O��G�x�s���Ȫ�����
CREATE TABLE tTaskCategories (
    FCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    FCategoryNo NVARCHAR(20) UNIQUE NOT NULL,    -- ���O�s��
    FName NVARCHAR(100) NOT NULL UNIQUE,         -- ���O�W��
    FDescription NVARCHAR(255),                  -- ���O�y�z
    FParentCategoryID INT,                       -- �����OID�]�i��A�Ω�h�h�����^
    FIsActive BIT DEFAULT 1,                     -- �O�_�ҥ�
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FUpdatedAt DATETIME                          -- ��s�ɶ�
    -- �~������i�H�b�o�̲K�[�A���n�T�O tTaskCategories ��w�g�s�b
);
-- ���ȸ�ƪ�G�x�s�Ҧ��ץ��T
CREATE TABLE tTasks (
    FTaskID INT IDENTITY(1,1) PRIMARY KEY,   
    FPosterID INT NOT NULL,                      -- �o�ת�ID
    FCategoryID INT NOT NULL,                    -- �������OID
    FTitle NVARCHAR(255) NOT NULL,               -- ���ȼ��D
    FDescription NVARCHAR(MAX) NOT NULL,         -- ���ȴy�z   
    FBudget INT CHECK (FBudget > 0) NOT NULL,	 -- �w����B
	FLocation NVARCHAR(255) NOT NULL,            -- �u�@�a�I (�����B����)
	FLocationDetail NVARCHAR(255) NOT NULL,		 -- �ԲӦa�}
	FMember nvarchar(50) NOT NULL,				 -- �p���H��T (���ϥΪ̥i�b�ק�)
	FPhone int NOT NULL,						 -- �p���H�q�� (���ϥΪ̥i�b�ק�)
	FEmail nvarchar(50) NOT NULL,				 -- �p���HEmail (���ϥΪ̥i�b�ק�)
    FStatus NVARCHAR(20) NOT NULL,				 -- ���Ȫ��A (�M�H�B�f�֡B�����B�R��)     
    FDeadline DATETIME NOT NULL,                 -- �I����   
    FCreatedAt DATETIME DEFAULT GETDATE() NOT NULL,		-- �إ߮ɶ�
    FUpdatedAt DATETIME DEFAULT GETDATE() NOT NULL,     -- ��s�ɶ�
    --CONSTRAINT FK_Tasks_Posters FOREIGN KEY (FPosterID) REFERENCES tPosters(FPosterID),
    --CONSTRAINT FK_Tasks_TaskCategories FOREIGN KEY (FCategoryID) REFERENCES tTaskCategories(FCategoryID)
);

--���J�ץ��T
INSERT INTO tTasks (FPosterID, FCategoryID, FTitle, FDescription, FBudget, FLocation, FLocationDetail, FMember, FPhone, FEmail, FStatus, FDeadline)
VALUES
(1, 1, N'�����]�p', N'�]�p�@���T���������A�]�t�e�ݻP��ݥ\��C', 20000, N'�x�_��', N'�����ϫH�q���@�q', N'������', 0912345678, N'chen@example.com', N'�M�H', '2025-02-15'),
(2, 2, N'�����]�p', N'�]�p�@�ګ~�PLogo�A�ݴ���3�Ӵ��סC', 5000, N'�s�_��', N'�O���Ϥ��s���G�q', N'�L�p�j', 0922123456, N'lin@example.com', N'�f��', '2025-03-01'),
(3, 3, N'½Ķ�A��', N'�N5000�r�����q�^��½Ķ������C', 8000, N'�x����', N'��ٰϥx�W�j�D�T�q', N'�i�p�j', 0933123456, N'zhang@example.com', N'����', '2025-01-30'),
(4, 4, N'�n��}�o', N'�}�o�@�ӥ��Ⱥ޲z�t�ΡA�]�t��Ʈw�]�p�C', 50000, N'�x�n��', N'�F�ϳӧQ��', N'������', 0945123456, N'wang@example.com', N'�M�H', '2025-04-01'),
(5, 5, N'��v�A��', N'���@���B§���ѥ��{��v�P�ſ�A�ȡC', 30000, N'������', N'�T���ϥ��ڤ@��', N'�P�p�j', 0956123456, N'zhou@example.com', N'�f��', '2025-03-15'),
(6, 1, N'������s', N'��s�{�����������e�αƪ��C', 7000, N'�s�˥�', N'�F�ϥ��_��', N'�\����', 0967123456, N'xu@example.com', N'����', '2025-02-28'),
(7, 2, N'�ӫ~�]�˳]�p', N'�]�p�@�ڰ��ݲ��~���]�˥~���C', 12000, N'�x�_��', N'�j�w�ϴ��ƫn��', N'��p�j', 0978123456, N'he@example.com', N'�R��', '2025-03-10'),
(8, 3, N'���½Ķ', N'½Ķ�޳N����3000�r�A�q���줤��C', 6000, N'�s�_��', N'�éM�Ϥ�����', N'�ǥ���', 0989123456, N'gong@example.com', N'�M�H', '2025-02-20'),
(9, 4, N'�������ζ}�o', N'�}�o�@��²�檺�w��APP�A�]�t�n���\��C', 40000, N'��饫', N'���c�Ϥ��s�F��', N'������', 0912123456, N'li@example.com', N'�f��', '2025-04-05'),
(10, 5, N'������v', N'�O�����~�~�׬��ʨöi�����ſ�C', 20000, N'�x����', N'�_�ϾǤh��', N'�d�p�j', 0922123456, N'wu@example.com', N'����', '2025-03-20'),
(11, 1, N'WordPress�����ظm', N'�ϥ�WordPress�ظm�@�ӥ��~�����A�]�t�w�˻P�]�m�C', 15000, N'�Ÿq��', N'��Ϥ�Ƹ�', N'�}����', 0933123456, N'xu@example.com', N'�M�H', '2025-02-25'),
(12, 2, N'�~�P�ѧO�]�p', N'�]�p���~������~�P�ѧO�A�]�ALogo�P�W���C', 25000, N'�x�n��', N'�_�Ϧ��\��', N'��p�j', 0944123456, N'lai@example.com', N'�f��', '2025-03-05'),
(13, 3, N'����½Ķ', N'½Ķ�@�g�ǳN�峹�A�q����줤��A��2000�r�C', 9000, N'������', N'��s�Ϥ��s��', N'������', 0955123456, N'dai@example.com', N'����', '2025-01-25'),
(14, 4, N'�ƾڤ��R�t��', N'�}�o�@�Ӽƾڤ��R��x�A��X�h��API�C', 60000, N'�s�_��', N'�s���ϥ_�s��', N'���p�j', 0966123456, N'du@example.com', N'�M�H', '2025-04-10'),
(15, 5, N'�ӫ~����', N'����q�ӥ��x�ϥΪ����~�Ϥ��A��50�i�C', 18000, N'�x�_��', N'����Ϸ����', N'������', 0977123456, N'song@example.com', N'�f��', '2025-03-30');

-- �ޯ����O��G�x�s�ޯ઺�D�n����
CREATE TABLE tSkillCategories (
    FCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    FCategoryNo NVARCHAR(20) UNIQUE NOT NULL,    -- ���O�s��
    FName NVARCHAR(100) NOT NULL UNIQUE,         -- ���O�W��
    FDescription NVARCHAR(MAX),                  -- ���O�y�z
    FIsActive BIT DEFAULT 1,                     -- �O�_�ҥ�
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FUpdatedAt DATETIME                          -- ��s�ɶ�
);

-- �ޯ��G�x�s���骺�ޯඵ��
CREATE TABLE tSkills (
    FSkillID INT IDENTITY(1,1) PRIMARY KEY,
    FSkillNo NVARCHAR(20) UNIQUE NOT NULL,       -- �ޯ�s��
    FCategoryID INT NOT NULL,                    -- �������OID
    FName NVARCHAR(100) NOT NULL UNIQUE,         -- �ޯ�W��
    FDescription NVARCHAR(MAX),                  -- �ޯ�y�z
    FIsActive BIT DEFAULT 1,                     -- �O�_�ҥ�
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FUpdatedAt DATETIME,                         -- ��s�ɶ�
    CONSTRAINT FK_Skills_Categories FOREIGN KEY (FCategoryID) REFERENCES tSkillCategories(FCategoryID)
);

-- ���ת̧ޯ��G�O�����ת֦̾����ޯ�
CREATE TABLE tWorkerSkills (
    FWorkerSkillID INT IDENTITY(1,1) PRIMARY KEY,
    FWorkerID INT NOT NULL,                      -- ���ת�ID
    FSkillID INT NOT NULL,                       -- �ޯ�ID
    FSkillLevel NVARCHAR(20) CHECK (FSkillLevel IN ('���', '����', '����', '�M�a')),
    FYearsOfExperience INT,                      -- �����~��
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FUpdatedAt DATETIME,                         -- ��s�ɶ�
    CONSTRAINT FK_WorkerSkills_Workers FOREIGN KEY (FWorkerID) REFERENCES tWorkers(FWorkerID),
    CONSTRAINT FK_WorkerSkills_Skills FOREIGN KEY (FSkillID) REFERENCES tSkills(FSkillID)
);
-- ���x������G�O�����ת����x���Ȫ�����
CREATE TABLE tApplications (
    FApplicationID INT IDENTITY(1,1) PRIMARY KEY,
    FApplicationNo NVARCHAR(20) UNIQUE NOT NULL, -- ���x�s��
    FTaskID INT NOT NULL,                        -- ����ID
    FWorkerID INT NOT NULL,                      -- ���ת�ID
    FProposedPrice MONEY CHECK (FProposedPrice >= 0), -- ��ĳ����
    FMessage NVARCHAR(MAX),                      -- ���x�T��
    FStatus NVARCHAR(20) CHECK (FStatus IN ('Pending', 'Accepted', 'Rejected')) NOT NULL,
    FIsDeleted BIT DEFAULT 0,                    -- �O�_�w�R���]�O�d�A�]�����x�������n�^
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- ���x�ɶ�
    FUpdatedAt DATETIME,                         -- ��s�ɶ�
    CONSTRAINT FK_Applications_Tasks FOREIGN KEY (FTaskID) REFERENCES tTasks(FTaskID),
    CONSTRAINT FK_Applications_Workers FOREIGN KEY (FWorkerID) REFERENCES tWorkers(FWorkerID)
);

-- �����G�x�s���x�W���Ҧ�����O��
CREATE TABLE tTransactions (
    FTransactionID INT IDENTITY(1,1) PRIMARY KEY,
    FTransactionNo NVARCHAR(20) UNIQUE NOT NULL, -- ����s��
    FTaskID INT NOT NULL,                        -- ���p����ID
    FPayerID INT NOT NULL,                       -- �I�ڤHID
    FPayeeID INT NOT NULL,                       -- ���ڤHID
    FAmount MONEY NOT NULL CHECK (FAmount >= 0),  -- ������B
    FPlatformFee MONEY NOT NULL CHECK (FPlatformFee >= 0), -- ���x����O
    FStatus NVARCHAR(20) CHECK (FStatus IN ('�B�z��', '���\', '����', '�h��')) NOT NULL,
    FPaymentMethod NVARCHAR(50),                 -- ��I�覡
    FIsDeleted BIT DEFAULT 0,                    -- �O�_�w�R���]�O�d�A�]������������n�^
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FUpdatedAt DATETIME,                         -- ��s�ɶ�
    FCompletedAt DATETIME,                       -- �����ɶ�
    CONSTRAINT FK_Transactions_Tasks FOREIGN KEY (FTaskID) REFERENCES tTasks(FTaskID),
    CONSTRAINT FK_Transactions_Users_Payer FOREIGN KEY (FPayerID) REFERENCES tUsers(FUserID),
    CONSTRAINT FK_Transactions_Users_Payee FOREIGN KEY (FPayeeID) REFERENCES tUsers(FUserID)
);

-- �q����G�x�s�t�εo�e���Τ᪺�q��
CREATE TABLE tNotifications (
    FNotificationID INT IDENTITY(1,1) PRIMARY KEY,
    FNotificationNo NVARCHAR(20) UNIQUE NOT NULL, -- �q���s��
    FUserID INT NOT NULL,                        -- �����Τ�ID
    FTitle NVARCHAR(255) NOT NULL,               -- �q�����D
    FContent NVARCHAR(MAX) NOT NULL,             -- �q�����e
    FType NVARCHAR(50) NOT NULL,                 -- �q������
    FIsRead BIT DEFAULT 0,                       -- �O�_�wŪ
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FUpdatedAt DATETIME,                         -- ��s�ɶ�
    CONSTRAINT FK_Notifications_Users FOREIGN KEY (FUserID) REFERENCES tUsers(FUserID)
);

-- �T����G�x�s�Τᶡ����ܤ��e
CREATE TABLE tMessages (
    FMessageID INT IDENTITY(1,1) PRIMARY KEY,
    FMessageNo NVARCHAR(20) UNIQUE NOT NULL,     -- �T���s��
    FSenderID INT NOT NULL,                      -- �o�e��ID
    FReceiverID INT NOT NULL,                    -- ������ID
    FTaskID INT,                                 -- ��������ID�]���^
    FContent NVARCHAR(MAX),                      -- �T�����e
    FIsRead BIT DEFAULT 0,                       -- �O�_�wŪ
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FUpdatedAt DATETIME,                         -- ��s�ɶ�
    CONSTRAINT FK_Messages_Users_Sender FOREIGN KEY (FSenderID) REFERENCES tUsers(FUserID),
    CONSTRAINT FK_Messages_Users_Receiver FOREIGN KEY (FReceiverID) REFERENCES tUsers(FUserID),
    CONSTRAINT FK_Messages_Tasks FOREIGN KEY (FTaskID) REFERENCES tTasks(FTaskID)
);

-----------���@�w---------------
-- �ɮת�G�޲z�Ҧ��W�Ǫ��ɮ�
CREATE TABLE tFiles (
    FFileID INT IDENTITY(1,1) PRIMARY KEY,
    FFileNo NVARCHAR(20) UNIQUE NOT NULL,        -- �ɮ׽s��
    FFileName NVARCHAR(255) NOT NULL,            -- �ɮצW��
    FFileUrl NVARCHAR(MAX) NOT NULL,             -- �ɮ�URL
    FFileType NVARCHAR(50),                      -- �ɮ�����
    FFileSize BIGINT,                            -- �ɮפj�p
    FUploadedBy INT NOT NULL,                    -- �W�Ǫ�ID
    FRelatedTable NVARCHAR(50),                  -- ���p��W
    FRelatedID INT,                              -- ���p�O��ID
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FUpdatedAt DATETIME,                         -- ��s�ɶ�
    CONSTRAINT FK_Files_Users FOREIGN KEY (FUploadedBy) REFERENCES tUsers(FUserID)
);	
-- ������G�O�����Ȭ������Ҧ�����
CREATE TABLE tReviews (
    FReviewID INT IDENTITY(1,1) PRIMARY KEY,
    FReviewNo NVARCHAR(20) UNIQUE NOT NULL,      -- �����s��
    FTaskID INT NOT NULL,                        -- ����ID
    FReviewerID INT NOT NULL,                    -- ������ID
    FRevieweeID INT NOT NULL,                    -- �Q������ID
    FRating INT CHECK (FRating BETWEEN 1 AND 5), -- ����
    FComment NVARCHAR(MAX),                      -- �������e
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FUpdatedAt DATETIME,                         -- ��s�ɶ�
    CONSTRAINT FK_Reviews_Tasks FOREIGN KEY (FTaskID) REFERENCES tTasks(FTaskID),
    CONSTRAINT FK_Reviews_Users_Reviewer FOREIGN KEY (FReviewerID) REFERENCES tUsers(FUserID),
    CONSTRAINT FK_Reviews_Users_Reviewee FOREIGN KEY (FRevieweeID) REFERENCES tUsers(FUserID)
);
-- �@�~����G�O�����ת̪��@�~
CREATE TABLE tPortfolios (
    FPortfolioID INT IDENTITY(1,1) PRIMARY KEY,
    FPortfolioNo NVARCHAR(20) UNIQUE NOT NULL,   -- �@�~�s��
    FWorkerID INT NOT NULL,                      -- ���ת�ID
    FTitle NVARCHAR(255) NOT NULL,               -- �@�~���D
    FDescription NVARCHAR(MAX),                  -- �@�~�y�z
    FSkillsUsed NVARCHAR(MAX),                  -- �ϥΧޯ�
    FIsPublic BIT DEFAULT 1,                     -- �O�_���}
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FUpdatedAt DATETIME,                         -- ��s�ɶ�
    CONSTRAINT FK_Portfolios_Workers FOREIGN KEY (FWorkerID) REFERENCES tWorkers(FWorkerID)
);
-- ��ĳ��G�O�����Ȭ�������ĳ
CREATE TABLE tDisputes (
    FDisputeID INT IDENTITY(1,1) PRIMARY KEY,
    FDisputeNo NVARCHAR(20) UNIQUE NOT NULL,     -- ��ĳ�s��
    FTaskID INT NOT NULL,                        -- ����ID
    FReporterID INT NOT NULL,                    -- ���|�HID
    FReportedID INT NOT NULL,                    -- �Q���|�HID
    FType NVARCHAR(50) NOT NULL,                 -- ��ĳ����
    FDescription NVARCHAR(MAX),                  -- ��ĳ�y�z
    FStatus NVARCHAR(20) CHECK (FStatus IN ('Pending', 'Processing', 'Resolved', 'Closed')) NOT NULL,
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FResolvedAt DATETIME,                        -- �ѨM�ɶ�
    CONSTRAINT FK_Disputes_Tasks FOREIGN KEY (FTaskID) REFERENCES tTasks(FTaskID),
    CONSTRAINT FK_Disputes_Users_Reporter FOREIGN KEY (FReporterID) REFERENCES tUsers(FUserID),
    CONSTRAINT FK_Disputes_Users_Reported FOREIGN KEY (FReportedID) REFERENCES tUsers(FUserID)
);

CREATE TABLE tAdminStatus (
		FStatusID TINYINT PRIMARY KEY,           -- ���AID
		FStatusName NVARCHAR(20) NOT NULL,       -- ���A�W��
		FDescription NVARCHAR(100),              -- ���A�y�z
		FCreatedAt DATETIME DEFAULT GETDATE()    -- �إ߮ɶ�
	);


	-- ���u��ƪ�G�x�s���x���u���򥻸��
	INSERT INTO tAdminStatus (FStatusID, FStatusName, FDescription) VALUES
	(1, N'�ҥΤ�', N'�޲z���b�����`�ϥΤ�'),
	(2, N'�f�֤�', N'�޲z���b�����ݼf��'),
	(3, N'�w�R��', N'�޲z���b���w�Q�R��'); 

CREATE TABLE tAdmins (
    FAdminID INT IDENTITY(1,1) PRIMARY KEY,      -- �D��
    FAdminNo NVARCHAR(20) UNIQUE NOT NULL,       -- �޲z���s�� (A001)
    FFullName NVARCHAR(100) NOT NULL,            -- �޲z�����W
    FEmail NVARCHAR(100) UNIQUE NOT NULL,        -- �q�l�l��
    FAdmPassword NVARCHAR(255) NOT NULL,        -- �K�X
    FMobilePhone NVARCHAR(20),                   -- ������X
    FAdminLevel INT NOT NULL,                    -- �޲z������ (1=�@��, 2=�i��, 3=�W�ź޲z��)
    FStatusID TINYINT NOT NULL DEFAULT 1,        -- ���AID
    FCreatedAt DATETIME DEFAULT GETDATE(),       -- �إ߮ɶ�
    FUpdatedAt DATETIME,                         -- ��s�ɶ�
    CONSTRAINT FK_Admin_Status FOREIGN KEY (FStatusID) 
    REFERENCES tAdminStatus(FStatusID)
);


--�Ыغ������i�ƶ���ƪ�
CREATE TABLE tAnnounce (
	fAnnounceId INT PRIMARY KEY IDENTITY(1,1),
	fTitle NVARCHAR(100) NOT NULL,
	fContent NVARCHAR(1000) NOT NULL,
	fCreate_at Datetime Default GetDate(),
);

--���J���i�ƶ�
INSERT INTO tAnnounce (fTitle, fContent, fCreate_at) VALUES
('Platform Maintenance Notice', 'The platform will undergo maintenance from 2 AM to 5 AM. Please plan accordingly.', '2025-01-02 06:21:10'),
('New Feature Release', 'We are excited to introduce a new feature that enhances user experience.', '2025-01-02 06:21:10'),
('Holiday Schedule Update', 'Our holiday schedule has been updated. Check the calendar for details.', '2025-01-02 06:21:10'),
('System Upgrade Announcement', 'A system upgrade is scheduled next week to improve performance and security.', '2025-01-02 06:21:10'),
('Community Guidelines Update', 'Please review the updated community guidelines to ensure compliance.', '2025-01-02 06:21:10');

