USE [master]
GO
/****** Object:  Database [CanteenManagement]    Script Date: 6/5/2021 1:06:24 PM ******/
CREATE DATABASE [CanteenManagement]
GO
ALTER DATABASE [CanteenManagement] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CanteenManagement].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [CanteenManagement] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CanteenManagement] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CanteenManagement] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CanteenManagement] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CanteenManagement] SET ARITHABORT OFF 
GO
ALTER DATABASE [CanteenManagement] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CanteenManagement] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CanteenManagement] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CanteenManagement] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CanteenManagement] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CanteenManagement] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CanteenManagement] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CanteenManagement] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CanteenManagement] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CanteenManagement] SET  ENABLE_BROKER 
GO
ALTER DATABASE [CanteenManagement] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CanteenManagement] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CanteenManagement] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [CanteenManagement] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [CanteenManagement] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CanteenManagement] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CanteenManagement] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [CanteenManagement] SET RECOVERY FULL 
GO
ALTER DATABASE [CanteenManagement] SET  MULTI_USER 
GO
ALTER DATABASE [CanteenManagement] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CanteenManagement] SET DB_CHAINING OFF 
GO
ALTER DATABASE [CanteenManagement] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [CanteenManagement] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [CanteenManagement] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [CanteenManagement] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [CanteenManagement] SET QUERY_STORE = OFF
GO
USE [CanteenManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[CalculateOrderID]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[CalculateOrderID](@order_id int)
returns money
as
begin
	declare @ans money
	select @ans = sum(num_of_food * cur_price) from OrderDetail where order_id = @order_id
	declare @customer_id varchar(15)
	select @customer_id = customer_id from CustomerOrder where @order_id = id
	declare @type nvarchar(3)
	select @type = VIP from Customer where id = @customer_id
	if (@type like 'YES')
		set @ans = @ans *0.95
	return @ans
end


GO
/****** Object:  Table [dbo].[OrderDetail]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDetail](
	[order_id] [int] NOT NULL,
	[food_id] [int] NOT NULL,
	[num_of_food] [int] NULL,
	[cur_price] [money] NULL,
 CONSTRAINT [PK_Order] PRIMARY KEY CLUSTERED 
(
	[order_id] ASC,
	[food_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[StatsOrderRevenue]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[StatsOrderRevenue]()
returns table
as
	return select distinct order_id, dbo.CalculateOrderID(order_id) as Revenue from OrderDetail


GO
/****** Object:  Table [dbo].[CustomerOrder]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerOrder](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[order_time] [datetime] NOT NULL
	[status_now] [int] NULL
	[staff_id] [varchar](15) NOT NULL
	[address] [ntext] NULL
	[customer_id] [varchar](15) NULL,
 CONSTRAINT [PK__Customer__3213E83FFE1980F4] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[InfoOrder]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[InfoOrder]()
returns table
as
	return select * from dbo.StatsOrderRevenue(), CustomerOrder where order_id = CustomerOrder.id and status_now = 1
GO
/****** Object:  UserDefinedFunction [dbo].[StatsRevenueByMonth]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[StatsRevenueByMonth](@year int)
returns table
as
	return select CAST(YEAR(order_time) AS VARCHAR(4)) + '-' + CAST(MONTH(order_time) AS VARCHAR(2)) as year_month,
	sum(Revenue) as revenue from dbo.InfoOrder()
	group by CAST(YEAR(order_time) AS VARCHAR(4)) + '-' + CAST(MONTH(order_time) AS VARCHAR(2))
	having Year(convert(date, CAST(YEAR(order_time) AS VARCHAR(4)) + '-' + CAST(MONTH(order_time) AS VARCHAR(2)) + '-01')) = @year
GO
/****** Object:  UserDefinedFunction [dbo].[StatsRevenueByDay]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[StatsRevenueByDay](@day smalldatetime)
returns table
as
	return select CAST(year(order_time) AS VARCHAR(4)) + '-' + CAST(MONTH(order_time) AS VARCHAR(2)) + '-' + 
	CAST(day(order_time) AS VARCHAR(2)) as year_month_day,
	sum(Revenue) as revenue from dbo.InfoOrder()
	group by CAST(year(order_time) AS VARCHAR(4)) + '-' + CAST(MONTH(order_time) AS VARCHAR(2)) + '-' + 
	CAST(day(order_time) AS VARCHAR(2))
	having convert(date, CAST(year(order_time) AS VARCHAR(4)) + '-' + CAST(MONTH(order_time) AS VARCHAR(2)) + '-' + 
	CAST(day(order_time) AS VARCHAR(2))) = convert(date, @day)

GO
/****** Object:  UserDefinedFunction [dbo].[InfoAllOrder]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[InfoAllOrder]()
returns table
as
	return select * from dbo.StatsOrderRevenue(), CustomerOrder where order_id = CustomerOrder.id
GO
/****** Object:  UserDefinedFunction [dbo].[CountSuccessOrder]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[CountSuccessOrder](@day smalldatetime)
returns table
as
	return select CAST(year(order_time) AS VARCHAR(4)) + '-' + CAST(MONTH(order_time) AS VARCHAR(2)) + '-' + 
	CAST(day(order_time) AS VARCHAR(2)) as year_month_day,
	count(*) as revenue from dbo.InfoOrder()
	group by CAST(year(order_time) AS VARCHAR(4)) + '-' + CAST(MONTH(order_time) AS VARCHAR(2)) + '-' + 
	CAST(day(order_time) AS VARCHAR(2))
	having convert(date, CAST(year(order_time) AS VARCHAR(4)) + '-' + CAST(MONTH(order_time) AS VARCHAR(2)) + '-' + 
	CAST(day(order_time) AS VARCHAR(2))) = convert(date, @day)
GO
/****** Object:  UserDefinedFunction [dbo].[CountAllOrder]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[CountAllOrder](@day smalldatetime)
returns table
as
	return select CAST(year(order_time) AS VARCHAR(4)) + '-' + CAST(MONTH(order_time) AS VARCHAR(2)) + '-' + 
	CAST(day(order_time) AS VARCHAR(2)) as year_month_day,
	count(*) as revenue from dbo.InfoAllOrder()
	group by CAST(year(order_time) AS VARCHAR(4)) + '-' + CAST(MONTH(order_time) AS VARCHAR(2)) + '-' + 
	CAST(day(order_time) AS VARCHAR(2))
	having convert(date, CAST(year(order_time) AS VARCHAR(4)) + '-' + CAST(MONTH(order_time) AS VARCHAR(2)) + '-' + 
	CAST(day(order_time) AS VARCHAR(2))) = convert(date, @day)
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
	[id] [varchar](15) NOT NULL,
	[VIP] [varchar](3) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerUser]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerUser](
	[user_id] [varchar](20) NOT NULL,
	[password] [varchar](20) NOT NULL,
	[customer_id] [varchar](15) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Person]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Person](
	[id] [varchar](15) NOT NULL,
	[name] [nvarchar](30) NULL,
	[gender] [nvarchar](3) NULL,
	[identity_card] [nvarchar](10) NULL,
	[day_of_birth] [date] NULL,
	[phone_num] [nvarchar](10) NULL,
	[address] [nvarchar](300) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[SelectAllInfoCustomer]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[SelectAllInfoCustomer]()
returns table
as return select Person.id, name, gender, identity_card, day_of_birth, phone_num, address, VIP, password 
from Person, CustomerUser, Customer
where Customer.id = CustomerUser.customer_id and Person.id = Customer.id



GO
/****** Object:  Table [dbo].[Role]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[role_name] [nvarchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Staff]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Staff](
	[id] [varchar](15) NOT NULL,
	[salary] [money] NULL,
 CONSTRAINT [PK__Staff__3213E83FBB15C9E0] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserLogin]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserLogin](
	[user_id] [varchar](20) NOT NULL,
	[password] [varchar](20) NOT NULL,
	[role_id] [int] NOT NULL,
	[staff_id] [varchar](15) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[SelectAllInfoStaff]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[SelectAllInfoStaff]()
returns table
as return select Person.id, name, gender, identity_card, day_of_birth, phone_num, address,
role_name, salary, password from Person, UserLogin, role, Staff 
where role.id = UserLogin.role_id and UserLogin.staff_id = Staff.id
and Person.id = Staff.id and role.id = UserLogin.role_id


GO
/****** Object:  UserDefinedFunction [dbo].[SelectInfoCustomerByID]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[SelectInfoCustomerByID](@customer_id varchar(15))
returns table
as return select Person.id, name, gender, identity_card, day_of_birth, phone_num, address, VIP, password 
from Person, CustomerUser, Customer
where Customer.id = CustomerUser.customer_id and Person.id = Customer.id and Person.id = @customer_id


GO
/****** Object:  UserDefinedFunction [dbo].[SelectInfoStaffByID]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[SelectInfoStaffByID](@staff_id varchar(15))
returns table
as return select Person.id, name, gender, identity_card, day_of_birth, phone_num, address,
role_name, salary, password from Person, UserLogin, role, Staff 
where role.id = UserLogin.role_id and UserLogin.staff_id = Staff.id
and Person.id = Staff.id and role.id = UserLogin.role_id and Person.id = @staff_id


GO
/****** Object:  Table [dbo].[Food]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Food](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[describe] [ntext] NULL,
	[price] [money] NOT NULL,
	[img] [text] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Menu]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Menu](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[time_start] [datetime] NOT NULL,
	[time_end] [datetime] NOT NULL,
 CONSTRAINT [PK__Menu__3213E83F1951C076] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MenuDetail]    Script Date: 6/5/2021 1:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MenuDetail](
	[menu_id] [int] NOT NULL,
	[food_id] [int] NOT NULL,
 CONSTRAINT [PK_Menu] PRIMARY KEY CLUSTERED 
(
	[menu_id] ASC,
	[food_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[Customer] ([id], [VIP]) VALUES (N'KH001', N'YES')
INSERT [dbo].[Customer] ([id], [VIP]) VALUES (N'KH002', N'YES')
INSERT [dbo].[Customer] ([id], [VIP]) VALUES (N'KH003', N'YES')
INSERT [dbo].[Customer] ([id], [VIP]) VALUES (N'KH005', N'YES')
INSERT [dbo].[Customer] ([id], [VIP]) VALUES (N'KH008', N'NO')
INSERT [dbo].[Customer] ([id], [VIP]) VALUES (N'KH009', N'NO')
INSERT [dbo].[Customer] ([id], [VIP]) VALUES (N'KH010', N'NO')
INSERT [dbo].[Customer] ([id], [VIP]) VALUES (N'KH011', N'NO')
INSERT [dbo].[Customer] ([id], [VIP]) VALUES (N'KH012', N'NO')
INSERT [dbo].[Customer] ([id], [VIP]) VALUES (N'KH013', N'NO')
GO
SET IDENTITY_INSERT [dbo].[CustomerOrder] ON 

INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (97, CAST(N'2021-06-01T13:53:46.000' AS DateTime), 3, N'NV00', N'Quận 9', N'KH001')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (98, CAST(N'2021-06-01T13:53:52.000' AS DateTime), 1, N'NV005', N'Quận 9', N'KH001')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (99, CAST(N'2021-06-01T13:53:57.000' AS DateTime), 1, N'NV005', N'Quận 9', N'KH001')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (100, CAST(N'2021-06-01T13:54:02.000' AS DateTime), 1, N'NV005', N'Quận 9', N'KH001')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (101, CAST(N'2021-06-01T13:54:47.000' AS DateTime), 1, N'NV005', N'Quận 9', N'KH001')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (102, CAST(N'2021-06-01T13:54:53.000' AS DateTime), 3, N'NV00', N'Quận 9', N'KH001')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (103, CAST(N'2021-06-01T13:55:29.000' AS DateTime), 1, N'NV005', N'Quận 8', N'KH010')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (104, CAST(N'2021-06-01T13:55:37.000' AS DateTime), 1, N'NV005', N'Quận 8', N'KH010')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (105, CAST(N'2021-06-01T13:56:04.000' AS DateTime), 1, N'NV005', N'Quận 8', N'KH010')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (106, CAST(N'2021-06-01T13:56:10.000' AS DateTime), 1, N'NV005', N'Quận 8', N'KH010')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (107, CAST(N'2021-06-01T13:56:53.000' AS DateTime), 1, N'NV005', N'Quận 8', N'KH011')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (108, CAST(N'2021-06-01T13:56:57.000' AS DateTime), 1, N'NV007', N'Quận 8', N'KH011')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (109, CAST(N'2021-06-01T13:57:02.000' AS DateTime), 1, N'NV005', N'Quận 8', N'KH011')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (110, CAST(N'2021-06-01T13:57:06.000' AS DateTime), 1, N'NV007', N'Quận 8', N'KH011')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (111, CAST(N'2021-06-01T13:57:29.000' AS DateTime), 1, N'NV007', N'Quận 9', N'KH008')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (112, CAST(N'2021-06-01T13:57:34.000' AS DateTime), 1, N'NV007', N'Quận 9', N'KH008')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (113, CAST(N'2021-06-01T13:57:40.000' AS DateTime), 1, N'NV007', N'Quận 9', N'KH008')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (114, CAST(N'2021-06-01T13:57:51.000' AS DateTime), 1, N'NV007', N'Quận 9', N'KH008')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (115, CAST(N'2021-06-01T17:43:49.000' AS DateTime), 1, N'NV002', N'Quận 9', N'KH003')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (116, CAST(N'2021-06-01T17:43:57.000' AS DateTime), 3, N'NV00', N'Quận 9', N'KH003')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (117, CAST(N'2021-06-01T17:44:05.000' AS DateTime), 1, N'NV002', N'Quận 9', N'KH003')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (118, CAST(N'2021-06-01T17:44:11.000' AS DateTime), 3, N'NV00', N'Quận 9', N'KH003')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (119, CAST(N'2021-06-01T17:47:46.000' AS DateTime), 1, N'NV003', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (120, CAST(N'2021-06-01T17:47:53.000' AS DateTime), 1, N'NV003', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (121, CAST(N'2021-06-01T17:48:00.000' AS DateTime), 1, N'NV003', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (122, CAST(N'2021-06-01T17:48:11.000' AS DateTime), 1, N'NV003', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (123, CAST(N'2021-06-01T17:48:19.000' AS DateTime), 1, N'NV003', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (124, CAST(N'2021-06-02T17:28:56.000' AS DateTime), 1, N'NV005', N'Quận 8', N'KH009')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (125, CAST(N'2021-06-02T17:29:03.000' AS DateTime), 3, N'NV00', N'Quận 8', N'KH009')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (126, CAST(N'2021-06-02T17:29:10.000' AS DateTime), 3, N'NV00', N'Quận 8', N'KH009')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (127, CAST(N'2021-06-02T17:29:15.000' AS DateTime), 1, N'NV005', N'Quận 8', N'KH009')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (128, CAST(N'2021-06-02T17:29:23.000' AS DateTime), 1, N'NV005', N'Quận 8', N'KH009')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (129, CAST(N'2021-06-02T17:29:29.000' AS DateTime), 1, N'NV005', N'Quận 8', N'KH009')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (130, CAST(N'2021-06-02T17:31:07.000' AS DateTime), 1, N'NV006', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (131, CAST(N'2021-06-02T17:31:12.000' AS DateTime), 1, N'NV006', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (132, CAST(N'2021-06-02T17:31:18.000' AS DateTime), 1, N'NV006', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (133, CAST(N'2021-06-02T17:31:26.000' AS DateTime), 1, N'NV006', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (134, CAST(N'2021-06-03T17:31:25.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (135, CAST(N'2021-06-03T17:33:42.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (136, CAST(N'2021-06-03T17:36:40.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (137, CAST(N'2021-06-03T17:37:45.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (138, CAST(N'2021-06-03T17:39:29.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (139, CAST(N'2021-06-03T17:40:48.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (140, CAST(N'2021-06-03T17:44:13.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (141, CAST(N'2021-06-03T17:46:55.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (142, CAST(N'2021-06-03T17:48:41.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (143, CAST(N'2021-06-03T17:50:17.000' AS DateTime), 3, N'NV00', N'Quận 10', N'KH012')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (144, CAST(N'2021-06-03T17:50:25.000' AS DateTime), 1, N'NV005', N'Quận 10', N'KH012')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (145, CAST(N'2021-06-03T17:50:31.000' AS DateTime), 1, N'NV005', N'Quận 10', N'KH012')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (146, CAST(N'2021-06-04T19:48:45.000' AS DateTime), 1, N'NV005', N'Quận 9', N'KH005')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (147, CAST(N'2021-06-04T19:48:51.000' AS DateTime), 1, N'NV005', N'Quận 9', N'KH005')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (148, CAST(N'2021-06-04T19:48:59.000' AS DateTime), 1, N'NV005', N'Quận 9', N'KH005')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (149, CAST(N'2021-06-04T19:49:07.000' AS DateTime), 1, N'NV005', N'Quận 9', N'KH005')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (150, CAST(N'2021-06-05T09:45:25.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (151, CAST(N'2021-06-05T11:13:33.000' AS DateTime), 1, N'NV007', N'123123123123', N'KH013')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (152, CAST(N'2021-06-05T11:13:42.000' AS DateTime), 3, N'NV00', N'123123123123', N'KH013')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (153, CAST(N'2021-06-05T11:13:47.000' AS DateTime), 1, N'NV007', N'123123123123', N'KH013')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (154, CAST(N'2021-06-05T11:24:38.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (155, CAST(N'2021-06-05T11:26:02.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (156, CAST(N'2021-06-05T11:26:18.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (157, CAST(N'2021-06-05T11:38:22.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (158, CAST(N'2021-06-05T11:39:26.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [address], [customer_id]) VALUES (159, CAST(N'2021-06-05T11:40:11.000' AS DateTime), 1, N'NV004', N'Tại chỗ', NULL)
SET IDENTITY_INSERT [dbo].[CustomerOrder] OFF
GO
INSERT [dbo].[CustomerUser] ([user_id], [password], [customer_id]) VALUES (N'gamelade', N'Pro123pro', N'KH001')
INSERT [dbo].[CustomerUser] ([user_id], [password], [customer_id]) VALUES (N'hiensieugay', N'Hienga123', N'KH010')
INSERT [dbo].[CustomerUser] ([user_id], [password], [customer_id]) VALUES (N'khachang789', N'Baopro123', N'KH011')
INSERT [dbo].[CustomerUser] ([user_id], [password], [customer_id]) VALUES (N'loisieugay', N'Loiga123', N'KH008')
INSERT [dbo].[CustomerUser] ([user_id], [password], [customer_id]) VALUES (N'mumumu', N'mumumu123A', N'KH005')
INSERT [dbo].[CustomerUser] ([user_id], [password], [customer_id]) VALUES (N'needgas', N'asd19ASSS', N'KH002')
INSERT [dbo].[CustomerUser] ([user_id], [password], [customer_id]) VALUES (N'simp_chua', N'vatBonS1mp', N'KH003')
INSERT [dbo].[CustomerUser] ([user_id], [password], [customer_id]) VALUES (N'testdangky', N'Longpro123', N'KH013')
INSERT [dbo].[CustomerUser] ([user_id], [password], [customer_id]) VALUES (N'thangsieugay', N'Thangga123', N'KH009')
INSERT [dbo].[CustomerUser] ([user_id], [password], [customer_id]) VALUES (N'toilakhach123', N'Taipro123', N'KH012')
GO
SET IDENTITY_INSERT [dbo].[Food] ON 

INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (1, N'Bánh canh', N'Bánh canh bao gồm nước dùng được nấu từ tôm, cá và giò heo thêm gia vị tùy theo từng loại bánh canh. Sợi bánh canh có thể được làm từ bột gạo, bột mì, bột năng hoặc bột sắn hoặc bột gạo pha bột sắn. aaa', 35000.0000, N'banh_canh.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (2, N'Bánh ướt lòng gà', N'Bánh ướt lòng gà bao gồm bánh ướt nóng hòa cùng lòng gà béo ngậy. Quyện thêm chút nước mắm chua ngọt mang lại hương vị hoàn hảo. a', 20000.0000, N'banh_uot_long_ga.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (3, N'Bánh xèo', N'Bánh xèo có nhân là tôm, thịt, giá đỗ; kim chi, khoai tây, hẹ,; tôm, thịt, cải thảo được rán màu vàng,đúc thành hình tròn hoặc gấp lại thành hình bán nguyệt.', 10000.0000, N'banh_xeo.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (4, N'Bò xào đậu que', N'Bò xào đậu que có thịt bò mềm, đậu que ngọt giòn, sẽ giúp bữa cơm của bạn thêm nhiều dinh dưỡng và năng lượng để tiếp tục công việc.', 20000.0000, N'bo_xao_dau_que.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (5, N'Bún Huế', N'Bún Huế có nguyên liệu chính là bún, thịt bắp bò, giò heo, cùng nước dùng có màu đỏ đặc trưng và vị sả và ruốc.', 30000.0000, N'bun_hue.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (6, N'Bún Nem Nướng', N'Bún Nem Nướng có nem nướng nóng hổi, ăn kèm với bún tươi và rau sống siêu sạch sẽ thoải mãi vị giác của bạn.', 25000.0000, N'bun_nem_nuong.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (7, N'Cá Kho Tộ', N'Cá Kho Tộ thơm ngon bổ dưỡng. Vị thơm của gừng, sả quyệt vào thịt cá thơm mềm khiến cho bữa cơm của bạn trở nên hoàn hảo', 22000.0000, N'ca_kho_to.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (8, N'Cá Ngừ Kho Thơm', N'Cá Ngừ Kho Thơm được kho theo kiểu miền Trung, nước kho rất nhiều để ăn kèm với bún tươi và rau sống, ăn là ghiền.', 22000.0000, N'ca_ngu_kho_thom.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (9, N'Cải thìa sốt dầu hào', N'Cải thìa sốt dầu hào thơm ngon, tươi mát sẽ là một sự lựa chọn tuyệt vời cho bữa cơm của bạn thêm phong phú.', 18000.0000, N'cai_thia_sot_dau_hao.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (10, N'Canh chua cá lóc', N'Canh chua cá lóc là món ăn giàu dinh dưỡng, theo Y học, cá lóc có tính bình không độc, tác dụng trừ phong thấp, chữa trĩ, rất bổ ích.', 27000.0000, N'canh_chua_ca_loc.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (11, N'Canh khổ qua nhồi thịt', N'Canh khổ qua nhồi thịt giúp thanh mát, giúp giảm cân, thanh nhiệt cơ thể, giải nhiệt cuộc sống.', 27000.0000, N'canh_kho_qua_nhoi_thit.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (12, N'Cơm chiên', N'Cơm chiên được chế biến trong chảo hoặc chảo rán và thường được trộn với các thành phần khác như trứng, rau, hải sản hoặc thịt.', 25000.0000, N'com_chien.png')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (13, N'Đậu hủ kho nấm', N'Đậu hủ kho nấm đầy bổ dưỡng và đặc biệt vô cùng thơm ngon, đây là một trong những lựa chọn hoàn hảo cho thực đơn chay, giảm cân.', 15000.0000, N'dau_hu_kho_nam.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (14, N'Đậu hủ sốt cà chua', N'Đậu hủ sốt cà chua là món ăn chay ngon, thanh đạm với giá rẻ nhưng cũng không kém phần ngon miệng.', 15000.0000, N'dau_sot_ca_chua.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (15, N'Ếch xào xả ớt', N'Ếch xào xả ớt là món ngon đậm đà, hương vị thì ngon không cưỡng nổi. Món ăn với vị cay thơm đặc trưng của sả, ớt quyện với thịt ếch xào chín dai ngon tròn vị thích hợp ngày mưa, mát lạnh.', 22000.0000, N'ech_xao_xa_ot.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (16, N'Gà chiên nước mắm', N'Gà chiên nước mắm là món ăn yêu thích đối với tất cả mọi người. Vị cay cay, giòn giòn, quyện gia vị hoàn hảo từ món ăn sẽ mang sức hút khó cưỡng cho bạn', 20000.0000, N'ga_chien_nuoc_mam.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (17, N'Gà kho', N'Gà kho là món ăn chế biến đơn giản. Vị ngọt của gà, vị ấm nồng của nhánh gừng cay cay chắc chắn sẽ khiến cho bạn không thể nào quên.', 20000.0000, N'ga_kho.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (18, N'Hủ tiếu', N'Hủ tiếu  là món ăn đặc trưng của người Nam Bộ. Món ăn cực kì hấp dẫn này sẽ thoải mãi cơn đói của bạn ngay tức thì.', 25000.0000, N'hu_tieu.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (19, N'Măng xào thịt', N'Măng xào thịt là món ăn từ những nguyên liệu quen thuộc, món ăn này sẽ đem lại hương vị thơm ngon đậm đà, ăn kèm với cơm nóng thì ngon hết sảy luôn nhé.', 22000.0000, N'mang_xao_thit.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (20, N'Mì quảng', N'Mì quảng à một món ăn đặc sản đặc trưng của Quảng Nam và Đà Nẵng, Việt Nam. Mì Quảng thường được làm từ bột gạo xay mịn lẫn nước từ hạt dành dành và trứng.', 25000.0000, N'mi_quang.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (21, N'Mực xào', N'Mực xào là một trong những món được chế biến từ mực ngon, hấp dẫn cung cấp nhiều dưỡng chất tốt cho sức khỏe.', 35000.0000, N'muc-xao.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (22, N'Phở bò', N'Phở bò là món ăn với hương thơm đặc trưng của thịt bò hòa quyện cùng nước dùng thanh ngọt, sợi phở mềm dai cực kỳ hấp dẫn vị giác.', 30000.0000, N'pho_bo.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (23, N'Rau luộc kho quẹt', N'Rau luộc kho quẹt là món ăn dân dã của người dân Nam bộ. Món ăn khơi gợi mùi vị nước mắm đật chất vùng miền.', 20000.0000, N'rau_luoc_kho_quet.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (24, N'Rau ngót bò băm ', N'Rau ngót bò băm có vị thơm đặc trưng của rau ngót, ngọt mềm của thịt. Mang lại cảm giác tươi mát cho mùa nóng bức.', 22000.0000, N'rau_ngot_bo_bam.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (25, N'Sườn nướng ', N'Sườn nướng bằng sườn heo và hay dùng với cơm tấm chan mỡ hành ăn cùng với cà chua, đồ chua và dưa leo sẽ tiếp thêm đầy đủ năng lượng cho bạn chiến đấu cả ngày.', 25000.0000, N'suon_nuong.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (26, N'Sườn xào chua ngọt', N'Sườn xào chua ngọt với vị thơm ngon, thịt sườn mềm ngấm đều gia vị chua chua, ngọt ngọt rất đưa cơm trong ngày lạnh.', 25000.0000, N'suon_xao_chua_ngot.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (27, N'Thịt kho tàu', N'Thịt kho tàu là món ăn quen thuộc của người Việt Nam, đặc biệt là người miền Bắc. Món ăn với hương vị đậm đà, trứng bùi bùi và thịt mềm ngon bá cháy sẽ thoải mãi bạn.', 22000.0000, N'thit_kho_tau.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (28, N'Thịt luộc', N'Thịt luộc được luộc mềm, ngon, không hôi hoàn quyện nước mắm sẽ rất tuyệt vời cho bữa ăn của bạn. Thịt luộc là chân ái', 22000.0000, N'thit_luoc.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (29, N'Tôm rang muối', N'Tôm rang muối ngon, vàng giòn, cay cay sẽ đưa bạn lên nấc thang thiên đường trong những ngày buốt giá.', 35000.0000, N'tom_rang_muoi.jpg')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (30, N'Trứng chiên', N'Trứng chiên là món ăn quen thuộc với tất cả mọi người. Trứng được chiên vừa chín, giòn hòa đậm hương vị sẽ tiếp thêm đầy đủ năng lượng cho bạn.', 20000.0000, N'trung_chien.jpg')
SET IDENTITY_INSERT [dbo].[Food] OFF
GO
SET IDENTITY_INSERT [dbo].[Menu] ON 

INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (1, CAST(N'2021-04-12T16:00:00.000' AS DateTime), CAST(N'2021-04-12T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (2, CAST(N'2021-03-12T05:00:00.000' AS DateTime), CAST(N'2021-03-12T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (4, CAST(N'2020-05-05T10:00:00.000' AS DateTime), CAST(N'2020-05-05T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (5, CAST(N'2021-04-12T05:00:00.000' AS DateTime), CAST(N'2021-04-12T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (6, CAST(N'2021-04-13T05:00:00.000' AS DateTime), CAST(N'2021-04-13T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (7, CAST(N'2021-04-13T10:00:00.000' AS DateTime), CAST(N'2021-04-13T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (8, CAST(N'2021-04-13T16:00:00.000' AS DateTime), CAST(N'2021-04-13T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (9, CAST(N'2021-04-21T05:00:00.000' AS DateTime), CAST(N'2021-04-21T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (10, CAST(N'2021-04-21T10:00:00.000' AS DateTime), CAST(N'2021-04-21T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (11, CAST(N'2021-04-21T16:00:00.000' AS DateTime), CAST(N'2021-04-21T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (18, CAST(N'2021-04-12T23:00:00.000' AS DateTime), CAST(N'2021-04-12T23:30:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (19, CAST(N'2021-05-07T05:00:00.000' AS DateTime), CAST(N'2021-05-07T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (20, CAST(N'2021-05-10T05:00:00.000' AS DateTime), CAST(N'2021-05-10T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (21, CAST(N'2021-05-10T10:00:00.000' AS DateTime), CAST(N'2021-05-10T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (22, CAST(N'2021-05-10T16:00:00.000' AS DateTime), CAST(N'2021-05-10T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (23, CAST(N'2021-05-11T05:00:00.000' AS DateTime), CAST(N'2021-05-11T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (24, CAST(N'2021-05-24T05:00:00.000' AS DateTime), CAST(N'2021-05-24T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (25, CAST(N'2021-05-24T10:00:00.000' AS DateTime), CAST(N'2021-05-24T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (26, CAST(N'2021-05-24T16:00:00.000' AS DateTime), CAST(N'2021-05-24T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (27, CAST(N'2021-05-25T05:00:00.000' AS DateTime), CAST(N'2021-05-25T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (28, CAST(N'2021-05-25T10:00:00.000' AS DateTime), CAST(N'2021-05-25T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (29, CAST(N'2021-05-25T16:00:00.000' AS DateTime), CAST(N'2021-05-25T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (30, CAST(N'2021-05-26T05:00:00.000' AS DateTime), CAST(N'2021-05-26T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (31, CAST(N'2021-05-26T10:00:00.000' AS DateTime), CAST(N'2021-05-26T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (32, CAST(N'2021-05-26T16:00:00.000' AS DateTime), CAST(N'2021-05-26T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (33, CAST(N'2021-05-28T05:00:00.000' AS DateTime), CAST(N'2021-05-28T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (34, CAST(N'2021-05-28T10:00:00.000' AS DateTime), CAST(N'2021-05-28T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (35, CAST(N'2021-05-28T16:00:00.000' AS DateTime), CAST(N'2021-05-28T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (36, CAST(N'2021-05-27T05:00:00.000' AS DateTime), CAST(N'2021-05-27T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (37, CAST(N'2021-05-27T10:00:00.000' AS DateTime), CAST(N'2021-05-27T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (38, CAST(N'2021-05-27T16:00:00.000' AS DateTime), CAST(N'2021-05-27T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (39, CAST(N'2021-05-30T05:00:00.000' AS DateTime), CAST(N'2021-05-30T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (40, CAST(N'2021-05-30T10:00:00.000' AS DateTime), CAST(N'2021-05-30T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (41, CAST(N'2021-05-30T16:00:00.000' AS DateTime), CAST(N'2021-05-30T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (42, CAST(N'2021-05-31T05:00:00.000' AS DateTime), CAST(N'2021-05-31T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (43, CAST(N'2021-05-31T10:00:00.000' AS DateTime), CAST(N'2021-05-31T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (44, CAST(N'2021-05-31T16:00:00.000' AS DateTime), CAST(N'2021-05-31T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (45, CAST(N'2021-06-01T16:00:00.000' AS DateTime), CAST(N'2021-06-01T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (46, CAST(N'2021-06-01T10:00:00.000' AS DateTime), CAST(N'2021-06-01T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (47, CAST(N'2021-06-02T05:00:00.000' AS DateTime), CAST(N'2021-06-02T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (48, CAST(N'2021-06-02T10:00:00.000' AS DateTime), CAST(N'2021-06-02T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (49, CAST(N'2021-06-02T16:00:00.000' AS DateTime), CAST(N'2021-06-02T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (50, CAST(N'2021-06-03T16:00:00.000' AS DateTime), CAST(N'2021-06-03T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (51, CAST(N'2021-07-04T16:00:00.000' AS DateTime), CAST(N'2021-07-04T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (52, CAST(N'2021-06-04T16:00:00.000' AS DateTime), CAST(N'2021-06-04T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (53, CAST(N'2021-06-05T05:00:00.000' AS DateTime), CAST(N'2021-06-05T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (54, CAST(N'2021-06-05T10:00:00.000' AS DateTime), CAST(N'2021-06-05T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (55, CAST(N'2021-06-05T16:00:00.000' AS DateTime), CAST(N'2021-06-05T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (56, CAST(N'2021-06-06T05:00:00.000' AS DateTime), CAST(N'2021-06-06T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (57, CAST(N'2021-06-06T16:00:00.000' AS DateTime), CAST(N'2021-06-06T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (58, CAST(N'2021-06-06T10:00:00.000' AS DateTime), CAST(N'2021-06-06T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (59, CAST(N'2021-06-07T05:00:00.000' AS DateTime), CAST(N'2021-06-07T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (60, CAST(N'2021-06-07T10:00:00.000' AS DateTime), CAST(N'2021-06-07T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (61, CAST(N'2021-06-07T16:00:00.000' AS DateTime), CAST(N'2021-06-07T21:00:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (62, CAST(N'2021-06-08T05:00:00.000' AS DateTime), CAST(N'2021-06-08T09:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (63, CAST(N'2021-06-08T10:00:00.000' AS DateTime), CAST(N'2021-06-08T15:59:00.000' AS DateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (64, CAST(N'2021-06-08T16:00:00.000' AS DateTime), CAST(N'2021-06-08T21:00:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[Menu] OFF
GO
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (1, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (1, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (1, 3)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (1, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (1, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (2, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (2, 7)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (2, 8)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (2, 9)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (2, 10)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (2, 11)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (2, 12)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (2, 13)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (2, 14)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (4, 3)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (4, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (4, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (4, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (4, 7)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (5, 20)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (5, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (5, 22)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (5, 23)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (5, 24)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (5, 26)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (5, 27)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (5, 28)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (5, 29)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (5, 30)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 3)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 9)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 10)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 11)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 15)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 17)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 19)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 20)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 23)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 26)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (6, 30)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 8)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 10)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 11)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 12)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 15)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 17)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 19)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 20)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 22)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 23)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 26)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 28)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (7, 29)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (8, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (8, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (8, 7)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (8, 10)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (8, 13)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (8, 16)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (8, 19)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (8, 22)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (8, 25)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (8, 28)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (9, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (9, 3)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (9, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (9, 7)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (9, 9)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (9, 11)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (9, 13)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (9, 15)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (9, 17)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (9, 19)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (9, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (9, 23)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (10, 18)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (10, 20)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (10, 22)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (10, 24)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (10, 26)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (10, 28)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 8)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 10)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 14)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 15)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 20)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 22)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 23)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 24)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 27)
GO
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 29)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (11, 30)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (18, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (19, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (19, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (19, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (19, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (19, 7)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (20, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (20, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (20, 3)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (20, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (20, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (21, 15)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (21, 16)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (21, 17)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (21, 20)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (21, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (21, 24)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (21, 27)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (21, 28)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (21, 29)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (21, 30)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (22, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (22, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (22, 7)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (22, 8)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (22, 10)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (22, 19)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (22, 20)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (22, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (23, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (23, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (23, 3)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (23, 8)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (24, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (24, 3)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (24, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (24, 7)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (24, 8)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (25, 25)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (25, 27)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (25, 28)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (25, 29)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (25, 30)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (26, 10)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (26, 11)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (26, 12)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (26, 14)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (26, 15)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (27, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (27, 7)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (27, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (27, 22)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (27, 23)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (28, 3)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (28, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (28, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (28, 8)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (28, 9)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (29, 17)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (29, 18)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (29, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (29, 27)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (29, 28)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (30, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (30, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (30, 28)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (30, 29)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (30, 30)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (31, 17)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (31, 18)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (31, 19)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (31, 20)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (31, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (32, 10)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (32, 11)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (32, 12)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (32, 13)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (32, 14)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (33, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (33, 7)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (33, 8)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (33, 22)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (33, 23)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (34, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (34, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (34, 17)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (34, 18)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (34, 19)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (35, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (35, 14)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (35, 15)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (35, 27)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (35, 28)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (36, 24)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (36, 28)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (36, 29)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (36, 30)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (37, 4)
GO
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (37, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (37, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (37, 7)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (37, 8)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (38, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (38, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (38, 9)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (38, 10)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (38, 11)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (39, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (39, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (39, 28)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (39, 29)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (39, 30)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (40, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (40, 3)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (40, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (40, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (40, 7)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (41, 19)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (41, 20)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (41, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (41, 22)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (41, 30)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (42, 15)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (42, 16)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (42, 17)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (42, 18)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (42, 19)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (43, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (43, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (43, 3)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (43, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (43, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (44, 18)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (44, 19)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (44, 20)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (44, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (44, 22)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (45, 11)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (45, 12)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (45, 23)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (45, 24)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (45, 25)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (45, 26)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (45, 27)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (45, 28)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (45, 29)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (45, 30)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (46, 10)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (46, 11)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (46, 12)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (46, 13)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (46, 14)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (47, 18)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (47, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (47, 29)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (47, 30)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (48, 17)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (48, 18)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (48, 19)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (48, 29)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (48, 30)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (49, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (49, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (49, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (49, 7)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (49, 8)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (49, 9)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (50, 15)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (50, 16)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (50, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (50, 22)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (50, 23)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (51, 14)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (51, 15)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (51, 16)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (51, 17)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (51, 18)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (52, 8)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (52, 9)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (52, 10)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (52, 11)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (52, 23)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (53, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (53, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (53, 3)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (53, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (53, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (54, 20)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (54, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (54, 28)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (54, 29)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (54, 30)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (55, 20)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (55, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (55, 26)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (55, 29)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (55, 30)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (56, 1)
GO
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (56, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (56, 14)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (56, 15)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (56, 16)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (57, 14)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (57, 15)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (57, 16)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (57, 23)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (57, 24)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (58, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (58, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (59, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (59, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (59, 14)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (59, 15)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (59, 16)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (60, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (60, 3)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (60, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (60, 22)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (60, 23)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (61, 9)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (61, 10)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (61, 11)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (61, 12)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (61, 13)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (62, 1)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (62, 2)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (62, 3)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (62, 5)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (62, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (62, 12)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (62, 18)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (62, 20)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (62, 22)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (62, 25)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (63, 7)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (63, 8)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (63, 10)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (63, 11)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (63, 13)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (63, 14)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (63, 17)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (63, 19)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (63, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (63, 27)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (64, 3)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (64, 4)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (64, 6)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (64, 7)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (64, 10)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (64, 16)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (64, 19)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (64, 21)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (64, 24)
INSERT [dbo].[MenuDetail] ([menu_id], [food_id]) VALUES (64, 26)
GO
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (97, 10, 5, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (97, 11, 5, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (97, 12, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (97, 13, 3, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (97, 14, 3, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (98, 12, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (98, 13, 3, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (99, 11, 3, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (99, 12, 5, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (100, 13, 3, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (100, 14, 3, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (101, 10, 4, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (101, 12, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (101, 13, 2, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (102, 12, 2, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (102, 14, 4, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (103, 12, 4, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (103, 13, 4, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (104, 11, 3, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (104, 12, 4, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (104, 14, 4, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (105, 10, 4, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (105, 11, 4, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (105, 14, 4, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (106, 12, 4, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (106, 13, 3, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (107, 12, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (107, 13, 3, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (108, 13, 2, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (108, 14, 4, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (109, 11, 3, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (109, 12, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (110, 10, 4, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (110, 11, 3, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (111, 11, 2, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (111, 12, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (111, 14, 5, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (112, 10, 2, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (112, 13, 5, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (113, 11, 3, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (113, 12, 2, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (113, 14, 4, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (114, 10, 4, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (114, 12, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (114, 13, 4, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (115, 11, 3, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (115, 12, 2, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (115, 23, 2, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (116, 29, 2, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (116, 30, 2, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (117, 12, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (117, 24, 3, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (117, 27, 2, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (118, 26, 2, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (118, 28, 2, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (119, 12, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (119, 23, 3, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (120, 27, 3, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (120, 28, 3, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (121, 24, 3, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (121, 29, 3, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (122, 12, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (122, 23, 3, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (123, 11, 3, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (123, 25, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (124, 5, 3, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (124, 6, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (124, 9, 2, 18000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (125, 6, 2, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (125, 7, 2, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (125, 8, 2, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (126, 4, 2, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (126, 5, 2, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (126, 9, 2, 18000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (127, 7, 3, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (127, 8, 4, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (128, 4, 3, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (128, 5, 3, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (128, 6, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (128, 9, 3, 18000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (129, 7, 3, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (129, 8, 3, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (130, 5, 3, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (130, 6, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (131, 7, 3, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (131, 8, 3, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (132, 4, 3, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (132, 5, 3, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (132, 6, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (133, 5, 4, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (133, 6, 3, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (133, 9, 3, 18000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (134, 21, 2, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (134, 22, 2, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (135, 22, 2, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (135, 23, 3, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (136, 22, 2, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (136, 23, 3, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (137, 16, 2, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (137, 21, 3, 35000.0000)
GO
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (138, 21, 3, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (138, 22, 2, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (139, 22, 3, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (139, 23, 3, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (140, 15, 2, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (140, 16, 3, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (141, 21, 2, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (141, 22, 3, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (142, 22, 2, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (142, 23, 3, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (143, 21, 2, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (143, 22, 2, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (144, 15, 4, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (144, 16, 3, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (145, 22, 2, 30000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (145, 23, 3, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (146, 9, 3, 18000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (146, 10, 3, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (147, 10, 2, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (147, 11, 3, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (147, 23, 3, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (148, 8, 2, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (148, 9, 3, 18000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (148, 10, 2, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (149, 10, 2, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (149, 11, 2, 27000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (149, 23, 2, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (150, 2, 2, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (150, 3, 2, 6000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (151, 20, 2, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (151, 21, 2, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (152, 28, 2, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (152, 30, 2, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (153, 21, 2, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (153, 29, 2, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (154, 20, 2, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (154, 28, 2, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (155, 29, 2, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (155, 30, 2, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (156, 20, 2, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (156, 21, 2, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (157, 29, 2, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (157, 30, 2, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (158, 29, 2, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (158, 30, 2, 20000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (159, 20, 1, 25000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (159, 21, 1, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (159, 28, 1, 22000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (159, 29, 1, 35000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (159, 30, 1, 20000.0000)
GO
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'KH001', N'Nguyễn Ngọc Nữ', N'nữ', N'198738192', CAST(N'2000-06-15' AS Date), N'0918231232', N'Quận 9')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'KH002', N'Trần Quốc Bảo', N'Nam', N'1231122223', CAST(N'2000-05-23' AS Date), N'0911009922', N'Huyện Bình Chánh')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'KH003', N'Nguyễn Lê Tấn Tài', N'Nam', N'123999999', CAST(N'2000-04-13' AS Date), N'0909123456', N'Quận 9')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'KH005', N'Võ Hoàng Long', N'Nam', N'123123123', CAST(N'2000-05-03' AS Date), N'0987654432', N'Quận 9')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'KH008', N'Cao Thành Lợn', N'Nam', N'123456789', CAST(N'2000-07-12' AS Date), N'0795095048', N'Quận 9')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'KH009', N'Nguyễn Quốc Thắng', N'Nam', N'123456789', CAST(N'1994-04-10' AS Date), N'0795095048', N'Quận 8')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'KH010', N'Nguyễn Thanh Hiền', N'Nam', N'123456789', CAST(N'1994-04-10' AS Date), N'0795095048', N'Quận 8')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'KH011', N'Đỗ Duy Khang', N'nam', N'123456789', CAST(N'1994-04-10' AS Date), N'0795095048', N'Quận 8')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'KH012', N'Ngô Quang Phú', N'Nam', N'123456789', CAST(N'2000-04-10' AS Date), N'0795095048', N'Quận 10')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'KH013', N'Nguyễn Văn BBB', N'nam', N'123456789', CAST(N'2000-04-12' AS Date), N'0795095047', N'Quận 8')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'NV00', N'Lãnh Tụ Tối Cao', N'Nam', N'123456789', CAST(N'1995-11-12' AS Date), N'0795095048', N'Quận 9')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'NV002', N'Lãnh Tụ Xém Cao', N'Nam', N'198299328', CAST(N'2000-03-21' AS Date), N'0987287187', N'Thành phố Thủ Đức')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'NV003', N'Trần Thị Anh', N'Nữ', N'191109328', CAST(N'2000-06-12' AS Date), N'0917287177', N'Quận 8')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'NV004', N'Trần Thị Bích', N'nữ', N'181200328', CAST(N'1995-04-19' AS Date), N'0917285182', N'Quận 6')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'NV005', N'Phạm Văn Đồng', N'Nam', N'181299328', CAST(N'1990-03-21' AS Date), N'0987287187', N'Quận 12')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'NV006', N'Hồ Công Mạnh', N'Nam', N'9876543212', CAST(N'2000-04-07' AS Date), N'0795095048', N'Quận 9')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'NV007', N'Đinh Công Mạnh', N'Nam', N'1234567897', CAST(N'2000-04-01' AS Date), N'0795095048', N'Quận 9')
GO
SET IDENTITY_INSERT [dbo].[Role] ON 

INSERT [dbo].[Role] ([id], [role_name]) VALUES (1, N'Quản lý')
INSERT [dbo].[Role] ([id], [role_name]) VALUES (2, N'Thu ngân')
INSERT [dbo].[Role] ([id], [role_name]) VALUES (3, N'Phục vụ bàn')
INSERT [dbo].[Role] ([id], [role_name]) VALUES (4, N'Nhân viên giao hàng')
INSERT [dbo].[Role] ([id], [role_name]) VALUES (5, N'Phục vụ bàn')
INSERT [dbo].[Role] ([id], [role_name]) VALUES (6, N'Nhân viên vệ sinh')
SET IDENTITY_INSERT [dbo].[Role] OFF
GO
INSERT [dbo].[Staff] ([id], [salary]) VALUES (N'NV00', NULL)
INSERT [dbo].[Staff] ([id], [salary]) VALUES (N'NV002', 3000000.0000)
INSERT [dbo].[Staff] ([id], [salary]) VALUES (N'NV003', 1500000.0000)
INSERT [dbo].[Staff] ([id], [salary]) VALUES (N'NV004', 2300000.0000)
INSERT [dbo].[Staff] ([id], [salary]) VALUES (N'NV005', 1500000.0000)
INSERT [dbo].[Staff] ([id], [salary]) VALUES (N'NV006', 1000000.0000)
INSERT [dbo].[Staff] ([id], [salary]) VALUES (N'NV007', 100000.0000)
GO
INSERT [dbo].[UserLogin] ([user_id], [password], [role_id], [staff_id]) VALUES (N'admin', N'doAnhBatDuocEm1', 1, N'NV00')
INSERT [dbo].[UserLogin] ([user_id], [password], [role_id], [staff_id]) VALUES (N'hello_teacher', N'123AbcASD', 4, N'NV005')
INSERT [dbo].[UserLogin] ([user_id], [password], [role_id], [staff_id]) VALUES (N'hello_world', N'Tienpro123', 2, N'NV004')
INSERT [dbo].[UserLogin] ([user_id], [password], [role_id], [staff_id]) VALUES (N'nhanvien123456789', N'Taipro123', 4, N'NV007')
INSERT [dbo].[UserLogin] ([user_id], [password], [role_id], [staff_id]) VALUES (N'nhanvien123qwee', N'Propro123', 2, N'NV006')
INSERT [dbo].[UserLogin] ([user_id], [password], [role_id], [staff_id]) VALUES (N'Taideeptry2', N'conAiDepTraiHonTai1', 4, N'NV002')
INSERT [dbo].[UserLogin] ([user_id], [password], [role_id], [staff_id]) VALUES (N'Taiprosieucapvutru', N'Taipro123', 2, N'NV003')
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__UserLogi__1963DD9D0808FD1E]    Script Date: 6/5/2021 1:06:24 PM ******/
ALTER TABLE [dbo].[UserLogin] ADD UNIQUE NONCLUSTERED 
(
	[staff_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OrderDetail] ADD  DEFAULT ((1)) FOR [num_of_food]
GO
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer] FOREIGN KEY([id])
REFERENCES [dbo].[Person] ([id])
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer]
GO
ALTER TABLE [dbo].[CustomerOrder]  WITH CHECK ADD  CONSTRAINT [FK_Cus] FOREIGN KEY([staff_id])
REFERENCES [dbo].[Staff] ([id])
GO
ALTER TABLE [dbo].[CustomerOrder] CHECK CONSTRAINT [FK_Cus]
GO
ALTER TABLE [dbo].[CustomerOrder]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Order] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customer] ([id])
GO
ALTER TABLE [dbo].[CustomerOrder] CHECK CONSTRAINT [FK_Customer_Order]
GO
ALTER TABLE [dbo].[CustomerUser]  WITH CHECK ADD  CONSTRAINT [FK_User_Customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customer] ([id])
GO
ALTER TABLE [dbo].[CustomerUser] CHECK CONSTRAINT [FK_User_Customer]
GO
ALTER TABLE [dbo].[MenuDetail]  WITH CHECK ADD  CONSTRAINT [FK_Menu_Food] FOREIGN KEY([food_id])
REFERENCES [dbo].[Food] ([id])
GO
ALTER TABLE [dbo].[MenuDetail] CHECK CONSTRAINT [FK_Menu_Food]
GO
ALTER TABLE [dbo].[MenuDetail]  WITH CHECK ADD  CONSTRAINT [FK_Menu_Id] FOREIGN KEY([menu_id])
REFERENCES [dbo].[Menu] ([id])
GO
ALTER TABLE [dbo].[MenuDetail] CHECK CONSTRAINT [FK_Menu_Id]
GO
ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_Order_Food] FOREIGN KEY([food_id])
REFERENCES [dbo].[Food] ([id])
GO
ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_Order_Food]
GO
ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_Order_Id] FOREIGN KEY([order_id])
REFERENCES [dbo].[CustomerOrder] ([id])
GO
ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_Order_Id]
GO
ALTER TABLE [dbo].[Staff]  WITH CHECK ADD  CONSTRAINT [FK_Staff] FOREIGN KEY([id])
REFERENCES [dbo].[Person] ([id])
GO
ALTER TABLE [dbo].[Staff] CHECK CONSTRAINT [FK_Staff]
GO
ALTER TABLE [dbo].[UserLogin]  WITH CHECK ADD  CONSTRAINT [FK_User_Role] FOREIGN KEY([role_id])
REFERENCES [dbo].[Role] ([id])
GO
ALTER TABLE [dbo].[UserLogin] CHECK CONSTRAINT [FK_User_Role]
GO
ALTER TABLE [dbo].[UserLogin]  WITH CHECK ADD  CONSTRAINT [FK_User_Staff] FOREIGN KEY([staff_id])
REFERENCES [dbo].[Staff] ([id])
GO
ALTER TABLE [dbo].[UserLogin] CHECK CONSTRAINT [FK_User_Staff]
GO
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD CHECK  (([VIP]='NO' OR [VIP]='YES'))
GO
ALTER TABLE [dbo].[CustomerOrder]  WITH CHECK ADD  CONSTRAINT [CK__CustomerO__statu__34C8D9D1] CHECK  (([status_now]=(1) OR [status_now]=(0) OR [status_now]=(2) OR [status_now]=(3)))
GO
ALTER TABLE [dbo].[CustomerOrder] CHECK CONSTRAINT [CK__CustomerO__statu__34C8D9D1]
GO
ALTER TABLE [dbo].[Food]  WITH CHECK ADD  CONSTRAINT [CheckPositiveFoodPrice] CHECK  (([price]>(0)))
GO
ALTER TABLE [dbo].[Food] CHECK CONSTRAINT [CheckPositiveFoodPrice]
GO
ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD  CONSTRAINT [CheckPositiveNumFood] CHECK  (([num_of_food]>(0)))
GO
ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [CheckPositiveNumFood]
GO
ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD  CONSTRAINT [CheckPositiveOrderPrice] CHECK  (([cur_price]>(0)))
GO
ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [CheckPositiveOrderPrice]
GO
ALTER TABLE [dbo].[Person]  WITH CHECK ADD CHECK  (([gender]=N'Nữ' OR [gender]=N'Nam'))
GO
ALTER TABLE [dbo].[Staff]  WITH CHECK ADD  CONSTRAINT [CheckPositiveSalary] CHECK  (([salary]>(0)))
GO
ALTER TABLE [dbo].[Staff] CHECK CONSTRAINT [CheckPositiveSalary]
GO
USE [master]
GO
ALTER DATABASE [CanteenManagement] SET  READ_WRITE 
GO
