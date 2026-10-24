USE [Stage2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************Drop Data Objects****************************************/
DROP VIEW IF EXISTS [dbo].[S2_V_Stock_Item]
GO
DROP VIEW IF EXISTS [dbo].[S2_V_Employee]
GO
DROP VIEW IF EXISTS [dbo].[S2_V_Customer]
GO
DROP VIEW IF EXISTS [dbo].[S2_V_Package_Type]
GO
DROP TABLE IF EXISTS [dbo].[S2_Invoice_Lines]
GO
DROP TABLE IF EXISTS [dbo].[S2_Invoice_Date]
GO
DROP TABLE IF EXISTS [dbo].[S2_Employee]
GO
DROP TABLE IF EXISTS [dbo].[S2_Stock_Item]
GO
DROP TABLE IF EXISTS [dbo].[S2_Customer]
GO
DROP TABLE IF EXISTS [dbo].[S2_Customer_Category_Lookup]
GO
/***************************Drop Metadata Objects****************************************/

DROP VIEW IF EXISTS [dbo].[V_IB_Latest]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch_Process_Task]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch_Process]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch_Process_Task]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch_Process]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch]
GO

/***************************Create metadata Objects******************************/
CREATE TABLE [dbo].[Import_Batch](
	[IB_ID] [int] IDENTITY(0,1) NOT NULL,
	[IB_Description] [nvarchar](50) NOT NULL,
	[IB_Year] [smallint] NOT NULL,
	[IB_Month] [smallint] NULL,
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
 CONSTRAINT [PK_Import_Batch_Process_Task] PRIMARY KEY CLUSTERED 
(
	[IBPT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
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
           ,NULL)
GO

CREATE PROCEDURE [dbo].[Create_Import_Batch]
	-- Add the parameters for the stored procedure here
	@IB_Description nvarchar(50),
	@IB_Year smallint,
	@IB_Month smallint = NULL,
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
			NULL);
	RETURN SCOPE_IDENTITY()
END
GO

CREATE VIEW [dbo].[V_IB_Latest]
AS
SELECT        IB_Year, IB_Month, MAX(IB_ID) AS Latest_IB_ID, EOMONTH(DATEFROMPARTS(IB_Year, IB_Month, 1)) AS Last_Day_Of_Month
FROM            dbo.Import_Batch
GROUP BY IB_Year, IB_Month, EOMONTH(DATEFROMPARTS(IB_Year, IB_Month, 1))
GO


/***************************Create Data Objects*****************************/
CREATE TABLE [dbo].[S2_Customer_Category_Lookup](
	[Customer_Category_ID] [int] NOT NULL,
	[Customer_Category] [nchar](50) NOT NULL,
 CONSTRAINT [PK_S2_Customer_Category_Lookup] PRIMARY KEY CLUSTERED 
(
	[Customer_Category_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT INTO [dbo].[S2_Customer_Category_Lookup]
           ([Customer_Category_ID]
           ,[Customer_Category])
     VALUES
           (-1
           ,'*Unknown')
GO
CREATE TABLE [dbo].[S2_Customer](
	[Customer_ID] [int] NOT NULL,
	[Customer_Name] [nvarchar](50) NOT NULL,
	[Customer_Category_ID] [int] NOT NULL,
	[Customer_Buying_Group_Name] [nvarchar](50) NOT NULL,
	[Customer_Credit_Limit] [numeric](10, 2) NOT NULL,
	[Customer_Account_Opened_Date] [date] NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_S2_Customer] PRIMARY KEY CLUSTERED 
(
	[Customer_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S2_Customer]  WITH CHECK ADD  CONSTRAINT [FK_S2_Customer_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO
ALTER TABLE [dbo].[S2_Customer]  WITH CHECK ADD  CONSTRAINT [FK_S2_Customer_S2_Customer_Category_Lookup] FOREIGN KEY([Customer_Category_ID])
REFERENCES [dbo].[S2_Customer_Category_Lookup] ([Customer_Category_ID])
GO
INSERT INTO [dbo].[S2_Customer]
           ([Customer_ID]
           ,[Customer_Name]
           ,[Customer_Category_ID]
           ,[Customer_Buying_Group_Name]
           ,[Customer_Credit_Limit]
           ,[Customer_Account_Opened_Date]
           ,[IBPT_ID])
     VALUES
           (0
           ,'*Unknown'
           ,-1
           ,'*No buying group'
           ,-1
           ,'1990-01-01'
           ,0)
GO
CREATE TABLE [dbo].[S2_Stock_Item](
	[Stock_Item_ID] [int] NOT NULL,
	[Stock_Item_Name] [nvarchar](100) NOT NULL,
	[Stock_Item_Supplier_ID] [int] NOT NULL,
	[Stock_Item_Colour] [nvarchar](20) NOT NULL,
	[Stock_Item_Brand] [nvarchar](20) NOT NULL,
	[Stock_Item_Size] [nvarchar](20) NOT NULL,
	[ChillerStock_Indicator] [nvarchar](50) NOT NULL,
	[Stock_Item_Unit_Price] [numeric](10, 2) NOT NULL,
	[Stock_Item_Recommended_Retail_Price] [numeric](10, 2) NOT NULL,
	[Stock_Item_Marketing_Comments] [nvarchar](100) NOT NULL,
	[Stock_Item_Tags] [nvarchar](100) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_S2_Stock_Item] PRIMARY KEY CLUSTERED 
(
	[Stock_Item_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S2_Stock_Item]  WITH CHECK ADD  CONSTRAINT [FK_S2_Stock_Item_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO
INSERT INTO [dbo].[S2_Stock_Item]
           ([Stock_Item_ID]
           ,[Stock_Item_Name]
           ,[Stock_Item_Supplier_ID]
           ,[Stock_Item_Colour]
           ,[Stock_Item_Brand]
           ,[Stock_Item_Size]
           ,[ChillerStock_Indicator]
           ,[Stock_Item_Unit_Price]
           ,[Stock_Item_Recommended_Retail_Price]
           ,[Stock_Item_Marketing_Comments]
           ,[Stock_Item_Tags]
           ,[IBPT_ID])
     VALUES
           (0
           ,'*Unknown'
           ,0
           ,'*No colour'
           ,'*No brand'
           ,'*No size'
           ,-1
           ,-1
           ,-1
           ,'*No comments'
           ,'*No tags'
           ,0)
GO

CREATE TABLE [dbo].[S2_Employee](
	[Employee_ID] [int] NOT NULL,
	[Employee_Full_Name] [nvarchar](50) NOT NULL,
	[Employee_Preferred_Name] [nvarchar](50) NOT NULL,
	[Employee_Indicator] [nvarchar](50) NOT NULL,
	[Employee_Email_Address] [nvarchar](100) NOT NULL,
	[System_User_Indicator] [nvarchar](50) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_S2_Employee] PRIMARY KEY CLUSTERED 
(
	[Employee_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S2_Employee]  WITH CHECK ADD  CONSTRAINT [FK_S2_Employee_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO
INSERT INTO [dbo].[S2_Employee]
           ([Employee_ID]
           ,[Employee_Full_Name]
           ,[Employee_Preferred_Name]
           ,[Employee_Indicator]
           ,[Employee_Email_Address]
           ,[System_User_Indicator]
           ,[IBPT_ID])
     VALUES
           (0
           ,'*No name'
           ,'*Unknown'
           ,-1
           ,'*Unknown'
           ,-1
           ,0)
GO
CREATE TABLE [dbo].[S2_Invoice_Date](
	[Date] [date] NOT NULL,
	[Date_Description] [nvarchar](20) NOT NULL,
	[Month_Of_Year] [tinyint] NOT NULL,
	[Month] [nvarchar](10) NOT NULL,
	[Year] [int] NOT NULL,
	[Year_Month] [nchar](7) NOT NULL,
	[Week_Of_Year] [tinyint] NOT NULL,
 CONSTRAINT [PK_Date] PRIMARY KEY CLUSTERED 
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT INTO [dbo].[S2_Invoice_Date]
           ([Date]
           ,[Date_Description]
           ,[Month_Of_Year]
           ,[Month]
           ,[Year]
           ,[Year_Month]
           ,[Week_Of_Year])
     VALUES
           ('1900/01/01'
           ,'*Unknown date'
           ,1
           ,'January'
           ,1900
           ,'1900-01'
           ,1)
GO

CREATE TABLE [dbo].[S2_Invoice_Lines](
	[Invoice_ID] [int] NOT NULL,
	[Invoice_Line_ID] [int] NOT NULL,
	[Invoice_Date] [date] NOT NULL,
	[Invoice_Line_Customer_ID] [int] NOT NULL,
	[Invoice_Line_Employee_ID] [int] NOT NULL,
	[Invoice_Lines_StockItem_ID] [int] NOT NULL,
	[Invoice_Lines_PackageType_Name] [nvarchar](20) NOT NULL,
	[Invoice_Lines_Quantity] [numeric](10, 2) NULL,
	[Invoice_Lines_UnitPrice] [numeric](10, 2) NULL,
	[Invoice_Lines_TaxRate] [numeric](10, 2) NULL,
	[Invoice_Lines_TaxAmount] [numeric](10, 2) NULL,
	[Invoice_Lines_LineProfit] [numeric](10, 2) NULL,
	[Invoice_Lines_ExtendedPrice] [numeric](10, 2) NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_S2_Invoice_Lines] PRIMARY KEY CLUSTERED 
(
	[Invoice_ID] ASC,
	[Invoice_Line_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S2_Invoice_Lines]  WITH CHECK ADD  CONSTRAINT [FK_S2_Invoice_Lines_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

ALTER TABLE [dbo].[S2_Invoice_Lines]  WITH CHECK ADD  CONSTRAINT [FK_S2_Invoice_Lines_S2_Customer] FOREIGN KEY([Invoice_Line_Customer_ID])
REFERENCES [dbo].[S2_Customer] ([Customer_ID])
GO

ALTER TABLE [dbo].[S2_Invoice_Lines]  WITH CHECK ADD  CONSTRAINT [FK_S2_Invoice_Lines_S2_Employee] FOREIGN KEY([Invoice_Line_Employee_ID])
REFERENCES [dbo].[S2_Employee] ([Employee_ID])
GO

ALTER TABLE [dbo].[S2_Invoice_Lines]  WITH CHECK ADD  CONSTRAINT [FK_S2_Invoice_Lines_S2_Invoice_Lines] FOREIGN KEY([Invoice_Date])
REFERENCES [dbo].[S2_Invoice_Date] ([Date])
GO


ALTER TABLE [dbo].[S2_Invoice_Lines]  WITH CHECK ADD  CONSTRAINT [FK_S2_Invoice_Lines_S2_Stock_Item] FOREIGN KEY([Invoice_Lines_StockItem_ID])
REFERENCES [dbo].[S2_Stock_Item] ([Stock_Item_ID])
GO


CREATE VIEW [dbo].[S2_V_Package_Type]
AS
SELECT        dbo.S2_Invoice_Lines.Invoice_Lines_PackageType_Name, dbo.Import_Batch.IB_Year, dbo.Import_Batch.IB_Month
FROM            dbo.Import_Batch INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch.IB_ID = dbo.Import_Batch_Process.IB_ID INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.Import_Batch_Process.IBP_ID = dbo.Import_Batch_Process_Task.IBP_ID INNER JOIN
                         dbo.S2_Invoice_Lines ON dbo.Import_Batch_Process_Task.IBPT_ID = dbo.S2_Invoice_Lines.IBPT_ID
GROUP BY dbo.S2_Invoice_Lines.Invoice_Lines_PackageType_Name, dbo.Import_Batch.IB_Year, dbo.Import_Batch.IB_Month
GO
CREATE VIEW [dbo].[S2_V_Customer]
AS
SELECT        dbo.S2_Customer.Customer_ID, dbo.S2_Customer.Customer_Name, dbo.S2_Customer_Category_Lookup.Customer_Category, dbo.S2_Customer.Customer_Buying_Group_Name, dbo.S2_Customer.Customer_Credit_Limit, 
                         dbo.S2_Customer.Customer_Account_Opened_Date, dbo.Import_Batch.IB_Year, dbo.Import_Batch.IB_Month
FROM            dbo.S2_Customer INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.S2_Customer.IBPT_ID = dbo.Import_Batch_Process_Task.IBPT_ID INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.Import_Batch_Process.IBP_ID INNER JOIN
                         dbo.Import_Batch ON dbo.Import_Batch_Process.IB_ID = dbo.Import_Batch.IB_ID INNER JOIN
                         dbo.S2_Customer_Category_Lookup ON dbo.S2_Customer.Customer_Category_ID = dbo.S2_Customer_Category_Lookup.Customer_Category_ID
GO

CREATE VIEW [dbo].[S2_V_Employee]
AS
SELECT        dbo.S2_Employee.Employee_ID, dbo.S2_Employee.Employee_Full_Name, dbo.S2_Employee.Employee_Preferred_Name, dbo.S2_Employee.Employee_Indicator, dbo.S2_Employee.Employee_Email_Address, 
                         dbo.S2_Employee.System_User_Indicator, dbo.Import_Batch.IB_Year, dbo.Import_Batch.IB_Month
FROM            dbo.Import_Batch_Process INNER JOIN
                         dbo.Import_Batch ON dbo.Import_Batch_Process.IB_ID = dbo.Import_Batch.IB_ID INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.Import_Batch_Process.IBP_ID = dbo.Import_Batch_Process_Task.IBP_ID INNER JOIN
                         dbo.S2_Employee ON dbo.Import_Batch_Process_Task.IBPT_ID = dbo.S2_Employee.IBPT_ID
GO
CREATE VIEW [dbo].[S2_V_Stock_Item]
AS
SELECT        dbo.S2_Stock_Item.Stock_Item_ID, dbo.S2_Stock_Item.Stock_Item_Name, dbo.S2_Stock_Item.Stock_Item_Supplier_ID, dbo.S2_Stock_Item.Stock_Item_Colour, dbo.S2_Stock_Item.Stock_Item_Brand, 
                         dbo.S2_Stock_Item.Stock_Item_Size, dbo.S2_Stock_Item.ChillerStock_Indicator, dbo.S2_Stock_Item.Stock_Item_Unit_Price, dbo.S2_Stock_Item.Stock_Item_Recommended_Retail_Price, 
                         dbo.S2_Stock_Item.Stock_Item_Marketing_Comments, dbo.S2_Stock_Item.Stock_Item_Tags, dbo.Import_Batch.IB_Year, dbo.Import_Batch.IB_Month
FROM            dbo.Import_Batch_Process INNER JOIN
                         dbo.Import_Batch ON dbo.Import_Batch_Process.IB_ID = dbo.Import_Batch.IB_ID INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.Import_Batch_Process.IBP_ID = dbo.Import_Batch_Process_Task.IBP_ID INNER JOIN
                         dbo.S2_Stock_Item ON dbo.Import_Batch_Process_Task.IBPT_ID = dbo.S2_Stock_Item.IBPT_ID
GO