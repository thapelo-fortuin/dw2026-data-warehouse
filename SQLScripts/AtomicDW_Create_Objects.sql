USE [AtomicDW]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************Drop Data Objects****************************************/
DROP TABLE IF EXISTS [dbo].[Invoice_Fact]
GO
DROP TABLE IF EXISTS [dbo].[Package_Type]
GO
DROP TABLE IF EXISTS [dbo].[Stock_Item]
GO
DROP TABLE IF EXISTS [dbo].[Employee]
GO
DROP TABLE IF EXISTS [dbo].[Customer]
GO
DROP TABLE IF EXISTS [dbo].[Date]
GO

/***************************Drop Metadata Objects****************************************/
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch_Process_Task]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch_Process]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch_Process_Task_Error_Log]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch_Process_Task]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch_Process]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch]
GO

/***************************Create metadata objects******************************/
CREATE TABLE [dbo].[Import_Batch](
	[IB_ID] [int] IDENTITY(0,1) NOT NULL,
	[IB_Description] [nvarchar](50) NOT NULL,
	[IB_Year] [smallint] NOT NULL,
	[IB_Month] [smallint] NOT NULL,
	[IB_Start] [datetime] NOT NULL,
	[IB_End] [datetime] NULL,
	[IB_Status] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_Import_Batch] PRIMARY KEY CLUSTERED 
(
	[IB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT INTO [dbo].[Import_Batch] /*Default values insert*/
     VALUES
           ('Insert_Default_Values'
           ,1900
           ,1
           ,'1900-01-01'
           ,'1900-01-01'
           ,'Completed')
GO

CREATE TABLE [dbo].[Import_Batch_Process](
	[IBP_ID] [int] IDENTITY(0,1) NOT NULL,
	[IB_ID] [int] NOT NULL,
	[IBP_Description] [nvarchar](50) NOT NULL,
	[IBP_Start] [datetime] NOT NULL,
	[IBP_End] [datetime] NULL,
	[IBP_Status] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_Import_Batch_Process] PRIMARY KEY CLUSTERED 
(
	[IBP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Import_Batch_Process]  WITH CHECK ADD  CONSTRAINT [FK_IBP_IB_ID] FOREIGN KEY([IB_ID])
REFERENCES [dbo].[Import_Batch] ([IB_ID])
GO
INSERT INTO [dbo].[Import_Batch_Process] /*Default values insert*/
     VALUES
           (0
           ,'Insert_Default_Values'
           ,'1900-01-01'
           ,'1900-01-01'
           ,'Completed')
GO

CREATE TABLE [dbo].[Import_Batch_Process_Task](
	[IBPT_ID] [int] IDENTITY(0,1) NOT NULL,
	[IBP_ID] [int] NOT NULL,
	[IBPT_Description] [nvarchar](50) NOT NULL,
	[IBPT_Start] [datetime] NOT NULL,
	[IBPT_End] [datetime] NULL,
	[IBPT_Status] [nvarchar](10) NOT NULL,
	[IBPT_Records_In] [int] NULL,
	[IBPT_Records_Failed] [int] NULL,
	[IBPT_Records_Out] [int] NULL,
	[IBPT_Dim_Historical] [int] NULL,
	[IBPT_Dim_Changing] [int] NULL,
	[IBPT_Dim_New] [int] NULL,
	[IBPT_Dim_Unchanged] [int] NULL,
	[IBPT_Dim_Fixed_Errors] [int] NULL,
 CONSTRAINT [PK_Import_Batch_Process_Task] PRIMARY KEY CLUSTERED 
(
	[IBPT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Import_Batch_Process_Task]  WITH CHECK ADD  CONSTRAINT [FK_IBPT_IBP_ID] FOREIGN KEY([IBP_ID])
REFERENCES [dbo].[Import_Batch_Process] ([IBP_ID])
GO
INSERT INTO [dbo].[Import_Batch_Process_Task]  /*Default values insert*/
     VALUES
           (0
           ,'Insert_Default_Values'
           ,'1900-01-01'
           ,'1900-01-01'
           ,'Completed'
           ,NULL
           ,NULL
           ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL)
GO

CREATE TABLE [dbo].[Import_Batch_Process_Task_Error_Log](
	[IBPT_ID] [int] NOT NULL,
	[ErrorDescription] [ntext] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Import_Batch_Process_Task_Error_Log]  WITH CHECK ADD  CONSTRAINT [FK_IBPT_Error_Log_IBPT_ID] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

CREATE PROCEDURE [dbo].[Create_Import_Batch]
	-- Add the parameters for the stored procedure here
	@IB_Description nvarchar(50),
	@IB_Year smallint,
	@IB_Month smallint,
	@IB_Start datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[Import_Batch] VALUES
           (@IB_Description,
            @IB_Year,
			@IB_Month,
			@IB_Start,
            NULL,
			'Running');
	RETURN SCOPE_IDENTITY()
END
GO
CREATE PROCEDURE [dbo].[Create_Import_Batch_Process]
	-- Add the parameters for the stored procedure here
	@IB_ID int,
	@IBP_Description nvarchar(50),
	@IBP_Start datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[Import_Batch_Process] VALUES
           (@IB_ID,
            @IBP_Description,
			@IBP_Start,
			NULL,
			'Running');
	RETURN SCOPE_IDENTITY()
END
GO
CREATE PROCEDURE [dbo].[Create_Import_Batch_Process_Task]
	-- Add the parameters for the stored procedure here
	@IBP_ID int,
	@IBPT_Description nvarchar(50),
	@IBPT_Start datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[Import_Batch_Process_Task] VALUES
           (@IBP_ID,
            @IBPT_Description,
			@IBPT_Start,
			NULL,
			'Running',
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL);
	RETURN SCOPE_IDENTITY()
END
GO

/***************************Create Data objects******************************/
CREATE TABLE [dbo].[Date](
	[Date_Key] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Date_Description] [nvarchar](20) NOT NULL,
	[Month_Of_Year] [tinyint] NOT NULL,
	[Month] [nvarchar](10) NOT NULL,
	[Year] [int] NOT NULL,
	[Year_Month] [nchar](7) NOT NULL,
	[Week_Of_Year] [smallint] NOT NULL,
 CONSTRAINT [PK_Date] PRIMARY KEY CLUSTERED 
(
	[Date_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_Date] UNIQUE NONCLUSTERED 
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Customer](
	[Customer_Key] [int] IDENTITY(0,1) NOT NULL,
	[Customer_ID] [int] NOT NULL,
	[Customer_Name] [nvarchar](50) NOT NULL,
	[Current_Customer_Category] [nvarchar](50) NOT NULL,
	[Customer_Category] [nvarchar](50) NOT NULL,
	[Customer_Buying_Group] [nvarchar](50) NOT NULL,
	[Credit_Limit_Indicator] [nvarchar](50) NOT NULL,
	[Customer_Credit_Limit] [numeric](10, 0) NOT NULL,
	[Customer_Account_Opened_Date] [date] NOT NULL,
	[Effective_Date] [date] NOT NULL,
	[Expiration_Date] [date] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
	[Import_Action] [nvarchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[Customer_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])

INSERT INTO [dbo].[Customer]
           ([Customer_ID]
           ,[Customer_Name]
           ,[Current_Customer_Category]
           ,[Customer_Category]
           ,[Customer_Buying_Group]
           ,[Credit_Limit_Indicator]
           ,[Customer_Credit_Limit]
           ,[Customer_Account_Opened_Date]
           ,[Effective_Date]
           ,[Expiration_Date]
           ,[IsCurrent]
           ,[Import_Action]
           ,[IBPT_ID])
     VALUES
           (0
           ,'*Unknown'
           ,'*Unknown'
           ,'*Unknown'
           ,'*Unknown'
           ,'*Unknown'
           ,-1
           ,'1900/01/01'
           ,'1900/01/01'
           ,'9999/12/31'
           ,1
           ,'Insert'
           ,0)
GO

CREATE TABLE [dbo].[Employee](
	[Employee_Key] [int] IDENTITY(0,1) NOT NULL,
	[Employee_ID] [int] NOT NULL,
	[Employee_Full_Name] [nchar](50) NOT NULL,
	[Employee_Preferred_Name] [nchar](50) NOT NULL,
	[Employee_Email_Address] [nchar](100) NOT NULL,
	[Employee_Indicator] [nchar](50) NOT NULL,
	[System_User_Indicator] [nchar](50) NOT NULL,
	[Effective_Date] [date] NOT NULL,
	[Expiration_Date] [date] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
	[Import_Action] [nchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED 
(
	[Employee_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO
INSERT INTO [dbo].[Employee]
           ([Employee_ID]
           ,[Employee_Full_Name]
           ,[Employee_Preferred_Name]
           ,[Employee_Email_Address]
           ,[Employee_Indicator]
           ,[System_User_Indicator]
           ,[Effective_Date]
           ,[Expiration_Date]
           ,[IsCurrent]
           ,[Import_Action]
           ,[IBPT_ID])
     VALUES
           (0
           ,'*No name'
           ,'*Unknown'
           ,'*Unknown'
           ,'-1'
           ,'-1'
           ,'1900/01/01'
           ,'9999/12/31'
           ,1
           ,'Insert'
           ,0)
GO
CREATE TABLE [dbo].[Stock_Item](
	[Stock_Item_Key] [int] IDENTITY(0,1) NOT NULL,
	[Stock_Item_ID] [int] NOT NULL,
	[Stock_Item_Name] [nchar](100) NOT NULL,
	[Supplier_ID] [int] NOT NULL,
	[Stock_Item_Colour] [nchar](20) NOT NULL,
	[Stock_Item_Brand] [nchar](20) NOT NULL,
	[Stock_Item_Size] [nchar](20) NOT NULL,
	[Chiller_Stock_Indicator] [nchar](50) NOT NULL,
	[Recommended_Retail_Price] [numeric](10,2) NOT NULL,
	[Marketing_Comments] [nvarchar](100) NOT NULL,
	[Stock_Item_Tags] [nchar](100) NOT NULL,
	[Stock_Item_Unit_Price] [numeric](10, 2) NOT NULL,
	[Effective_Date] [date] NOT NULL,
	[Expiration_Date] [date] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
	[Import_Action] [nchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_Stock_Item] PRIMARY KEY CLUSTERED 
(
	[Stock_Item_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Stock_Item]  WITH CHECK ADD  CONSTRAINT [FK_Stock_Item_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO
INSERT INTO [dbo].[Stock_Item]
           ([Stock_Item_ID]
           ,[Stock_Item_Name]
           ,[Supplier_ID]
           ,[Stock_Item_Colour]
           ,[Stock_Item_Brand]
           ,[Stock_Item_Size]
           ,[Chiller_Stock_Indicator]
           ,[Recommended_Retail_Price]
		   ,[Marketing_Comments]
           ,[Stock_Item_Tags]
           ,[Stock_Item_Unit_Price]
           ,[Effective_Date]
           ,[Expiration_Date]
           ,[IsCurrent]
           ,[Import_Action]
           ,[IBPT_ID])
     VALUES
           (0
           ,'Unknown'
           ,-1
           ,'*No colour'
           ,'*No brand'
           ,'*No size'
           ,-1
           ,-1
		   ,'*No comments'
           ,'*No tags'
           ,-1
           ,'1900/01/01'
           ,'9999/12/31'
           ,1
           ,'Insert'
           ,0)
GO
CREATE TABLE [dbo].[Package_Type](
	[Package_Type_Key] [int] IDENTITY(0,1) NOT NULL,
	[Package_Type_Name] [nchar](20) NOT NULL,
	[Effective_Date] [date] NOT NULL,
	[Import_Action] [nchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_Package_Type] PRIMARY KEY CLUSTERED 
(
	[Package_Type_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Package_Type]  WITH CHECK ADD  CONSTRAINT [FK_Package_Type_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO
INSERT INTO [dbo].[Package_Type]
           ([Package_Type_Name]
           ,[Effective_Date]
           ,[Import_Action]
           ,[IBPT_ID])
     VALUES
           (
'*No name'
           ,'1900/01/01'
           ,'Insert'
           ,0)
GO
CREATE TABLE [dbo].[Invoice_Fact](
	[Invoice_Line_ID] [int] NOT NULL,
	[Invoice_Date_Key] [int] NOT NULL,
	[Customer_Key] [int] NOT NULL,
	[Employee_Key] [int] NOT NULL,
	[Stock_Item_Key] [int] NOT NULL,
	[Package_Type_Key] [int] NOT NULL,
	[Invoice_Line_Quantity] [int] NULL,
	[Invoice_Line_Unit_Price] [numeric](10, 2) NULL,
	[Invoice_Line_Tax_Rate] [numeric](10, 2) NULL,
	[InvoiceLine_Extended_Price_Excluded] [numeric](10, 2) NULL,
	[Invoice_Line_Tax_Amount] [numeric](10, 2) NULL,
	[InvoiceLine_Profit] [numeric](10, 2) NULL,
	[InvoiceLine_Extended_Price_Included] [numeric](10, 2) NULL,
	[Import_Action] [nchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_Invoice_Fact] PRIMARY KEY CLUSTERED 
(
	[Invoice_Line_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Invoice_Fact]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Fact_Customer] FOREIGN KEY([Customer_Key])
REFERENCES [dbo].[Customer] ([Customer_Key])
GO

ALTER TABLE [dbo].[Invoice_Fact] CHECK CONSTRAINT [FK_Invoice_Fact_Customer]
GO

ALTER TABLE [dbo].[Invoice_Fact]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Fact_Date] FOREIGN KEY([Invoice_Date_Key])
REFERENCES [dbo].[Date] ([Date_Key])
GO

ALTER TABLE [dbo].[Invoice_Fact] CHECK CONSTRAINT [FK_Invoice_Fact_Date]
GO

ALTER TABLE [dbo].[Invoice_Fact]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Fact_Employee] FOREIGN KEY([Employee_Key])
REFERENCES [dbo].[Employee] ([Employee_Key])
GO

ALTER TABLE [dbo].[Invoice_Fact] CHECK CONSTRAINT [FK_Invoice_Fact_Employee]
GO

ALTER TABLE [dbo].[Invoice_Fact]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Fact_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

ALTER TABLE [dbo].[Invoice_Fact] CHECK CONSTRAINT [FK_Invoice_Fact_Import_Batch_Process_Task]
GO

ALTER TABLE [dbo].[Invoice_Fact]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Fact_Package_Type] FOREIGN KEY([Package_Type_Key])
REFERENCES [dbo].[Package_Type] ([Package_Type_Key])
GO

ALTER TABLE [dbo].[Invoice_Fact] CHECK CONSTRAINT [FK_Invoice_Fact_Package_Type]
GO

ALTER TABLE [dbo].[Invoice_Fact]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Fact_Stock_Item] FOREIGN KEY([Stock_Item_Key])
REFERENCES [dbo].[Stock_Item] ([Stock_Item_Key])
GO

ALTER TABLE [dbo].[Invoice_Fact] CHECK CONSTRAINT [FK_Invoice_Fact_Stock_Item]
GO




