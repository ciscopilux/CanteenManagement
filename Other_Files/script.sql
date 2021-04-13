USE [master]
GO
/****** Object:  Database [CanteenManagement]    Script Date: 4/13/2021 8:42:06 PM ******/
CREATE DATABASE [CanteenManagement]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CanteenManagement', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\CanteenManagement.mdf' , SIZE = 3264KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'CanteenManagement_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\CanteenManagement_log.ldf' , SIZE = 816KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
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
EXEC sys.sp_db_vardecimal_storage_format N'CanteenManagement', N'ON'
GO
USE [CanteenManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[CalculateOrderID]    Script Date: 4/13/2021 8:42:06 PM ******/
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
/****** Object:  Table [dbo].[Customer]    Script Date: 4/13/2021 8:42:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Customer](
	[id] [varchar](15) NOT NULL,
	[VIP] [varchar](3) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomerOrder]    Script Date: 4/13/2021 8:42:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomerOrder](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[order_time] [smalldatetime] NOT NULL,
	[status_now] [int] NULL,
	[staff_id] [varchar](15) NOT NULL,
	[customer_id] [varchar](15) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomerUser]    Script Date: 4/13/2021 8:42:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomerUser](
	[user_id] [varchar](20) NOT NULL,
	[password] [varchar](20) NOT NULL,
	[customer_id] [varchar](15) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Food]    Script Date: 4/13/2021 8:42:06 PM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Menu]    Script Date: 4/13/2021 8:42:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Menu](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[time_start] [smalldatetime] NOT NULL,
	[time_end] [smalldatetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MenuDetail]    Script Date: 4/13/2021 8:42:06 PM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OrderDetail]    Script Date: 4/13/2021 8:42:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDetail](
	[order_id] [int] NOT NULL,
	[food_id] [int] NOT NULL,
	[num_of_food] [int] NULL DEFAULT ((1)),
	[cur_price] [money] NULL,
 CONSTRAINT [PK_Order] PRIMARY KEY CLUSTERED 
(
	[order_id] ASC,
	[food_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Person]    Script Date: 4/13/2021 8:42:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Role]    Script Date: 4/13/2021 8:42:06 PM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Staff]    Script Date: 4/13/2021 8:42:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Staff](
	[id] [varchar](15) NOT NULL,
	[salary] [money] NULL,
 CONSTRAINT [PK__Staff__3213E83FBB15C9E0] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserLogin]    Script Date: 4/13/2021 8:42:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserLogin](
	[user_id] [varchar](20) NOT NULL,
	[password] [varchar](20) NOT NULL,
	[role_id] [int] NOT NULL,
	[staff_id] [varchar](15) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  UserDefinedFunction [dbo].[StatsOrderRevenue]    Script Date: 4/13/2021 8:42:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[StatsOrderRevenue]()
returns table
as
	return select distinct order_id, dbo.CalculateOrderID(order_id) as Revenue from OrderDetail

GO
/****** Object:  UserDefinedFunction [dbo].[InfoOrder]    Script Date: 4/13/2021 8:42:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[InfoOrder]()
returns table
as
	return select * from dbo.StatsOrderRevenue(), CustomerOrder where order_id = CustomerOrder.id

GO
/****** Object:  UserDefinedFunction [dbo].[StatsRevenueByMonth]    Script Date: 4/13/2021 8:42:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[StatsRevenueByMonth]()
returns table
as
	return select CAST(MONTH(order_time) AS VARCHAR(2)) + '-' + CAST(YEAR(order_time) AS VARCHAR(4)) as year_month,
	sum(Revenue) as revenue from dbo.InfoOrder()
	group by CAST(MONTH(order_time) AS VARCHAR(2)) + '-' + CAST(YEAR(order_time) AS VARCHAR(4))

GO
/****** Object:  UserDefinedFunction [dbo].[SelectAllInfoCustomer]    Script Date: 4/13/2021 8:42:06 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[SelectAllInfoStaff]    Script Date: 4/13/2021 8:42:06 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[SelectInfoCustomerByID]    Script Date: 4/13/2021 8:42:06 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[SelectInfoStaffByID]    Script Date: 4/13/2021 8:42:06 PM ******/
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
INSERT [dbo].[Customer] ([id], [VIP]) VALUES (N'KH001', N'yes')
INSERT [dbo].[Customer] ([id], [VIP]) VALUES (N'KH005', N'NO')
SET IDENTITY_INSERT [dbo].[CustomerOrder] ON 

INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [customer_id]) VALUES (2, CAST(N'2020-05-05 11:00:00' AS SmallDateTime), 1, N'NV002', N'KH001')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [customer_id]) VALUES (4, CAST(N'2021-04-12 19:34:00' AS SmallDateTime), 1, N'NV002', N'KH005')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [customer_id]) VALUES (5, CAST(N'2020-04-12 05:34:00' AS SmallDateTime), 1, N'NV003', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [customer_id]) VALUES (6, CAST(N'2020-04-12 05:34:00' AS SmallDateTime), 1, N'NV003', NULL)
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [customer_id]) VALUES (7, CAST(N'2021-03-12 07:34:00' AS SmallDateTime), 0, N'NV002', N'KH005')
INSERT [dbo].[CustomerOrder] ([id], [order_time], [status_now], [staff_id], [customer_id]) VALUES (11, CAST(N'2021-04-13 18:34:00' AS SmallDateTime), 2, N'NV002', NULL)
SET IDENTITY_INSERT [dbo].[CustomerOrder] OFF
INSERT [dbo].[CustomerUser] ([user_id], [password], [customer_id]) VALUES (N'gamelade', N'1234ABCDa', N'KH001')
INSERT [dbo].[CustomerUser] ([user_id], [password], [customer_id]) VALUES (N'mumumu', N'mumumu123A', N'KH005')
SET IDENTITY_INSERT [dbo].[Food] ON 

INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (1, N'Bánh xèo', N'test0', 19000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (2, N'Bánh xèo', N'test1', 20000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (3, N'Bánh xèo', N'test2', 21000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (4, N'Bánh xèo', N'test3', 22000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (5, N'Bánh xèo', N'test4', 23000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (6, N'Bánh xèo', N'test5', 24000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (7, N'Bánh xèo', N'test6', 25000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (8, N'Bánh xèo', N'test7', 26000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (9, N'Bánh xèo', N'test8', 27000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (10, N'Bánh xèo', N'test9', 28000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (11, N'Bánh xèo', N'test10', 29000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (12, N'Bánh xèo', N'test11', 30000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (13, N'Bánh xèo', N'test12', 31000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (14, N'Bánh xèo', N'test13', 32000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (15, N'Bánh xèo', N'test14', 33000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (16, N'Bánh xèo', N'test15', 34000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (17, N'Bánh xèo', N'test16', 35000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (18, N'Bánh xèo', N'test17', 36000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (19, N'Bánh xèo', N'test18', 37000.0000, N'')
INSERT [dbo].[Food] ([id], [name], [describe], [price], [img]) VALUES (20, N'Bánh xèo', N'test19', 38000.0000, N'')
SET IDENTITY_INSERT [dbo].[Food] OFF
SET IDENTITY_INSERT [dbo].[Menu] ON 

INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (1, CAST(N'2021-04-12 16:00:00' AS SmallDateTime), CAST(N'2021-04-12 21:00:00' AS SmallDateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (2, CAST(N'2021-03-12 05:00:00' AS SmallDateTime), CAST(N'2021-03-12 09:45:00' AS SmallDateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (4, CAST(N'2020-05-05 10:00:00' AS SmallDateTime), CAST(N'2020-05-05 14:30:00' AS SmallDateTime))
INSERT [dbo].[Menu] ([id], [time_start], [time_end]) VALUES (5, CAST(N'2021-04-11 20:06:00' AS SmallDateTime), CAST(N'2021-04-12 22:06:00' AS SmallDateTime))
SET IDENTITY_INSERT [dbo].[Menu] OFF
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
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (2, 2, 1, 50000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (2, 3, 5, 15000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (2, 4, 7, 3000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (4, 4, 2, 9000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (4, 7, 2, 60000.0000)
INSERT [dbo].[OrderDetail] ([order_id], [food_id], [num_of_food], [cur_price]) VALUES (7, 13, 6, 15000.0000)
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'KH001', N'Nguyễn Lê Tấn Tài', N'Nam', N'198738192', CAST(N'2000-06-15' AS Date), N'0918231231', N'Quận 7')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'KH005', N'Nguyễn Quốc Thắng', N'Nam', N'123123123', CAST(N'2000-05-03' AS Date), N'0987654432', N'Quận 9')
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'NV002', NULL, NULL, NULL, CAST(N'2000-05-15' AS Date), NULL, NULL)
INSERT [dbo].[Person] ([id], [name], [gender], [identity_card], [day_of_birth], [phone_num], [address]) VALUES (N'NV003', NULL, NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Role] ON 

INSERT [dbo].[Role] ([id], [role_name]) VALUES (1, N'Quản lý')
INSERT [dbo].[Role] ([id], [role_name]) VALUES (2, N'Thu ngân')
INSERT [dbo].[Role] ([id], [role_name]) VALUES (3, N'Phục vụ bàn')
INSERT [dbo].[Role] ([id], [role_name]) VALUES (4, N'Nhân viên giao hàng')
INSERT [dbo].[Role] ([id], [role_name]) VALUES (5, N'Phục vụ bàn')
INSERT [dbo].[Role] ([id], [role_name]) VALUES (6, N'Nhân viên vệ sinh')
SET IDENTITY_INSERT [dbo].[Role] OFF
INSERT [dbo].[Staff] ([id], [salary]) VALUES (N'NV002', 30000000.0000)
INSERT [dbo].[Staff] ([id], [salary]) VALUES (N'NV003', 1500000.0000)
INSERT [dbo].[UserLogin] ([user_id], [password], [role_id], [staff_id]) VALUES (N'Taideeptry2', N'1231234', 1, N'NV002')
INSERT [dbo].[UserLogin] ([user_id], [password], [role_id], [staff_id]) VALUES (N'Taiprosieucapvutru', N'abcd', 2, N'NV003')
SET ANSI_PADDING ON

GO
/****** Object:  Index [UQ__UserLogi__1963DD9D043530D3]    Script Date: 4/13/2021 8:42:06 PM ******/
ALTER TABLE [dbo].[UserLogin] ADD UNIQUE NONCLUSTERED 
(
	[staff_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
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
ALTER TABLE [dbo].[CustomerOrder]  WITH CHECK ADD  CONSTRAINT [CK__CustomerO__statu__34C8D9D1] CHECK  (([status_now]=(1) OR [status_now]=(0) OR [status_now]=(2)))
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
