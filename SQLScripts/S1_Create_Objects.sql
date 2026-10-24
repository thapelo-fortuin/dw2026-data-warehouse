USE [Stage1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************Drop Data Objects****************************************/
DROP VIEW IF EXISTS [dbo].[S1_V_Stock_Item]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_SalesPerson]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_Invoice_Line]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_Customer]
GO
DROP TABLE IF EXISTS [dbo].[S1_Customer]
GO
DROP TABLE IF EXISTS [dbo].[S1_Invoice_Line]
GO
DROP TABLE IF EXISTS [dbo].[S1_SalesPerson]
GO
DROP TABLE IF EXISTS [dbo].[S1_Stock_Item]
GO

/***************************Drop Metadata Objects****************************************/

DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch_Process_Task]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch_Process]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch]
GO
DROP VIEW IF EXISTS [dbo].[V_IB_Latest]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch_Process_Task]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch_Process]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch]
GO

/***************************Create metadata Objects******************************/
CREATE TABLE [dbo].[Import_Batch](
	[IB_ID] [int] IDENTITY(1,1) NOT NULL,
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

CREATE TABLE [dbo].[Import_Batch_Process](
	[IBP_ID] [int] IDENTITY(1,1) NOT NULL,
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

CREATE TABLE [dbo].[Import_Batch_Process_Task](
	[IBPT_ID] [int] IDENTITY(1,1) NOT NULL,
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

CREATE VIEW [dbo].[V_IB_Latest]
AS
SELECT        IB_Year, IB_Month, MAX(IB_ID) AS Latest_IB_ID, EOMONTH(DATEFROMPARTS(IB_Year, IB_Month, 1)) AS Last_Day_Of_Month
FROM            dbo.Import_Batch
GROUP BY IB_Year, IB_Month, EOMONTH(DATEFROMPARTS(IB_Year, IB_Month, 1))
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


/***************************Create Data Objects****************************************/

CREATE TABLE [dbo].[S1_Customer](
	[Customer_ID] [int] NOT NULL,
	[Customer_Name] [nvarchar](50) NOT NULL,
	[Customer_Category_ID] [int] NOT NULL,
	[Customer_Buying_Group_Name] [nvarchar](50) NOT NULL,
	[Customer_Credit_Limit] [numeric](10, 2) NOT NULL,
	[Customer_Account_Opened_Date] [date] NOT NULL,
	[IBPT_ID] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S1_Customer]  WITH CHECK ADD  CONSTRAINT [FK_S1_Customer_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

ALTER TABLE [dbo].[S1_Customer] CHECK CONSTRAINT [FK_S1_Customer_Import_Batch_Process_Task]

GO
CREATE TABLE [dbo].[S1_SalesPerson] (
[Person_ID] [int] NOT NULL,
[Person_FullName] [nvarchar](50) NOT NULL,
[Person_PrefferedName] [nvarchar](50) NOT NULL,
[Person_IsSystemUser] [int] NOT NULL,
[Person_IsEmployee] [int] NOT NULL,
[Person_IsSalesperson] [int] NOT NULL,
[Person_EmailAddress] [nvarchar] (100) NOT NULL,
[IBPT_ID] [int] NOT NULL
) ON [PRIMARY]
GO 

ALTER TABLE [dbo].[S1_SalesPerson] WITH CHECK ADD CONSTRAINT [FK_S1_SalesPerson_Import_Batch_Process_Task] FOREIGN KEY ([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])

CREATE TABLE [dbo].[S1_Invoice_Line] (
[Invoice_Lines_ID] [int] NOT NULL,
[Invoice_ID] [int] NOT NULL,
[Invoice_Date] [date],
[Invoice_Customer_ID] [int],
[Invoice_Line_Salesperson_ID] [int],
[Invoice_Line_StockItem_ID] [int],
[Invoice_Line_PackageType_ID] [int],
[Invoice_Line_PackageTypeName] [nvarchar] (20),
[Invoice_Line_Quantity] [int],
[Invoice_Line_UnitPrice] [numeric] (10,2),
[Invoice_Line_TaxRate] [numeric](10,2),
[Invoice_Line_TaxAmount] [numeric](10,2),
[Invoice_Line_LineProfit] [numeric](10,2),
[Invoice_Line_ExtendedPrice] [numeric](10,2),
[IBPT_ID] [int] NOT NULL
) ON [PRIMARY]
GO 

ALTER TABLE [dbo].[S1_Invoice_Line] WITH CHECK ADD CONSTRAINT [FK_S1_Invoice_Line_Import_Batch_Process_Task] FOREIGN KEY ([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])

CREATE TABLE [dbo].[S1_Stock_Item](
[Stock_Item_ID] [int] NOT NULL,
[Stock_Item_Name] [nvarchar](100) NOT NULL,
[Stock_Item_Supplier_ID] [int] NOT NULL,
[Stock_Item_Colour] [nvarchar](20) NOT NULL,
[Stock_Item_Brand] [nvarchar](20) NOT NULL,
[Stock_Item_Size] [nvarchar](20)NOT NULL,
[Stock_Item_IsChillerStock] [int] NOT NULL,
[Stock_Item_UnitPrice] [numeric](10,2) NOT NULL,
[Stock_Item_RecommendedRetailPrice] [numeric] (10,2) NOT NULL,
[Stock_Item_Marketing_Comments] [nvarchar] (100) NOT NULL,
[Stock_Item_Tags] [nvarchar](100) NOT NULL,
[IBPT_ID] [int] NOT NULL
) ON [PRIMARY]
GO 

ALTER TABLE [dbo].[S1_Stock_Item] WITH CHECK ADD CONSTRAINT [FK_S1_Stock_Item_Import_Batch_Process_Task] FOREIGN KEY ([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
Go

/***************************Create Views Objects****************************************/
CREATE VIEW [dbo].[S1_V_Customer]
AS
SELECT        dbo.S1_Customer.Customer_ID, MAX(dbo.S1_Customer.Customer_Name) AS Customer_Name, MAX(dbo.S1_Customer.Customer_Category_ID) AS Customer_Category_ID, MAX(dbo.S1_Customer.Customer_Buying_Group_Name) 
                         AS Customer_Buying_Group_Name, MAX(dbo.S1_Customer.Customer_Credit_Limit) AS Customer_Credit_Limit, MAX(dbo.S1_Customer.Customer_Account_Opened_Date) AS Customer_Account_Opened_Date, 
                         MAX(dbo.S1_Customer.IBPT_ID) AS IBPT_ID, MAX(dbo.V_IB_Latest.IB_Year) AS IB_Year, MAX(dbo.V_IB_Latest.IB_Month) AS IB_Month
FROM            dbo.S1_Customer INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.S1_Customer.IBPT_ID = dbo.Import_Batch_Process_Task.IBPT_ID INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.Import_Batch_Process.IBP_ID INNER JOIN
                         dbo.V_IB_Latest ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.V_IB_Latest.Latest_IB_ID
GROUP BY dbo.S1_Customer.Customer_ID
GO
CREATE VIEW [dbo].[S1_V_Invoice_Line]
AS
SELECT        dbo.S1_Invoice_Line.Invoice_Lines_ID, dbo.S1_Invoice_Line.Invoice_ID, MAX(dbo.S1_Invoice_Line.Invoice_Date) AS Invoice_Date, MAX(dbo.S1_Invoice_Line.Invoice_Customer_ID) AS Invoice_Customer_ID, 
                         MAX(dbo.S1_Invoice_Line.Invoice_Line_Salesperson_ID) AS Invoice_Line_Salesperson_ID, MAX(dbo.S1_Invoice_Line.Invoice_Line_StockItem_ID) AS Invoice_Line_StockItem_ID, 
                         MAX(dbo.S1_Invoice_Line.Invoice_Line_PackageType_ID) AS Invoice_Line_PackageType_ID, MAX(dbo.S1_Invoice_Line.Invoice_Line_PackageTypeName) AS Invoice_Line_PackageTypeName, 
                         MAX(dbo.S1_Invoice_Line.Invoice_Line_Quantity) AS Invoice_Line_Quantity, MAX(dbo.S1_Invoice_Line.Invoice_Line_UnitPrice) AS Invoice_Line_UnitPrice, MAX(dbo.S1_Invoice_Line.Invoice_Line_TaxRate) 
                         AS Invoice_Line_TaxRate, MAX(dbo.S1_Invoice_Line.Invoice_Line_TaxAmount) AS Invoice_Line_TaxAmount, MAX(dbo.S1_Invoice_Line.Invoice_Line_LineProfit) AS Invoice_Line_LineProfit, 
                         MAX(dbo.S1_Invoice_Line.Invoice_Line_ExtendedPrice) AS Invoice_Line_ExtendedPrice, MAX(dbo.S1_Invoice_Line.IBPT_ID) AS IBPT_ID, MAX(dbo.V_IB_Latest.IB_Month) AS IB_Month, MAX(dbo.V_IB_Latest.IB_Year) 
                         AS IB_Year
FROM            dbo.S1_Invoice_Line INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.S1_Invoice_Line.IBPT_ID = dbo.Import_Batch_Process_Task.IBPT_ID INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.Import_Batch_Process.IBP_ID INNER JOIN
                         dbo.V_IB_Latest ON dbo.Import_Batch_Process.IB_ID = dbo.V_IB_Latest.Latest_IB_ID
GROUP BY dbo.S1_Invoice_Line.Invoice_Lines_ID, dbo.S1_Invoice_Line.Invoice_ID
GO

CREATE VIEW [dbo].[S1_V_SalesPerson]
AS
SELECT        dbo.S1_SalesPerson.Person_ID, MAX(dbo.S1_SalesPerson.Person_FullName) AS Person_FullName, MAX(dbo.S1_SalesPerson.Person_PrefferedName) AS Person_PrefferedName, 
                         MAX(dbo.S1_SalesPerson.Person_IsSystemUser) AS Person_IsSystemUser, MAX(dbo.S1_SalesPerson.Person_IsEmployee) AS Person_IsEmployee, MAX(dbo.S1_SalesPerson.Person_IsSalesperson) 
                         AS Person_IsSalesperson, MAX(dbo.S1_SalesPerson.Person_EmailAddress) AS Person_EmailAddress, MAX(dbo.S1_SalesPerson.IBPT_ID) AS IBPT_ID, MAX(dbo.V_IB_Latest.IB_Year) AS IB_Year, 
                         MAX(dbo.V_IB_Latest.IB_Month) AS IB_Month
FROM            dbo.S1_SalesPerson INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.S1_SalesPerson.IBPT_ID = dbo.Import_Batch_Process_Task.IBPT_ID INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.Import_Batch_Process.IBP_ID INNER JOIN
                         dbo.V_IB_Latest ON dbo.Import_Batch_Process.IB_ID = dbo.V_IB_Latest.Latest_IB_ID
GROUP BY dbo.S1_SalesPerson.Person_ID
GO

CREATE VIEW [dbo].[S1_V_Stock_Item]
AS
SELECT        dbo.S1_Stock_Item.Stock_Item_ID, MAX(dbo.S1_Stock_Item.Stock_Item_Name) AS Stock_Item_Name, MAX(dbo.S1_Stock_Item.Stock_Item_Supplier_ID) AS Stock_Item_Supplier_ID, MAX(dbo.S1_Stock_Item.Stock_Item_Colour) 
                         AS Stock_Item_Colour, MAX(dbo.S1_Stock_Item.Stock_Item_Brand) AS Stock_Item_Brand, MAX(dbo.S1_Stock_Item.Stock_Item_Size) AS Stock_Item_Size, MAX(dbo.S1_Stock_Item.Stock_Item_IsChillerStock) 
                         AS Stock_Item_IsChillerStock, MAX(dbo.S1_Stock_Item.Stock_Item_UnitPrice) AS Stock_Item_UnitPrice, MAX(dbo.S1_Stock_Item.Stock_Item_RecommendedRetailPrice) AS Stock_Item_RecommendedRetailPrice, 
                         MAX(dbo.S1_Stock_Item.Stock_Item_Marketing_Comments) AS Stock_Item_Marketing_Comments, MAX(dbo.S1_Stock_Item.Stock_Item_Tags) AS Stock_Item_Tags, MAX(dbo.S1_Stock_Item.IBPT_ID) AS IBPT_ID, 
                         MAX(dbo.V_IB_Latest.IB_Month) AS IB_Month, MAX(dbo.V_IB_Latest.IB_Year) AS IB_Year
FROM            dbo.S1_Stock_Item INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.S1_Stock_Item.IBPT_ID = dbo.Import_Batch_Process_Task.IBPT_ID INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.Import_Batch_Process.IBP_ID INNER JOIN
                         dbo.V_IB_Latest ON dbo.Import_Batch_Process.IB_ID = dbo.V_IB_Latest.Latest_IB_ID
GROUP BY dbo.S1_Stock_Item.Stock_Item_ID
GO