/****** Object:  Table [dbo].[AncillaryCodes]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AncillaryCodes](
	[Id] [int] NOT NULL,
	[Description] [nvarchar](50) NULL,
	[Code] [nvarchar](6) NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_AncillaryCodes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AncillaryRates]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AncillaryRates](
	[Id] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[AncillaryCodeId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Rate] [decimal](10, 2) NOT NULL,
	[ReceivableGlAccountId] [int] NULL,
	[CoinsurerGlAccountId] [int] NULL,
	[SalesGlAccountId] [int] NULL,
	[BillDescriptionId] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_AncillaryRates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApiRequestLogs]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApiRequestLogs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Endpoint] [nvarchar](255) NULL,
	[Url] [nvarchar](max) NULL,
	[Query] [nvarchar](max) NULL,
	[Headers] [nvarchar](max) NULL,
	[StatusCode] [int] NULL,
	[RequestTime] [datetime2](7) NULL,
	[ResponseTime] [datetime2](7) NULL,
	[Error] [nvarchar](max) NULL,
	[DurationMs] [int] NULL,
	[ResultCount] [int] NULL,
	[Slug] [varchar](60) NULL,
	[Response] [varchar](max) NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Banks]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Banks](
	[Id] [int] NOT NULL,
	[BankName] [nvarchar](40) NULL,
	[AccountDescription] [nvarchar](40) NULL,
	[RoutingNumber] [nvarchar](9) NULL,
	[BankAccountNumber] [nvarchar](20) NULL,
	[GlAccountId] [int] NULL,
	[BranchId] [nvarchar](max) NULL,
	[CompanyName] [nvarchar](75) NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_Banks] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Beds]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Beds](
	[Id] [int] NOT NULL,
	[BedNumber] [nvarchar](10) NULL,
	[Building] [nvarchar](10) NULL,
	[Wing] [nvarchar](6) NULL,
	[Floor] [nvarchar](3) NULL,
	[DistinctUnitId] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_Beds] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BillableEntities]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillableEntities](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Code] [nvarchar](6) NULL,
	[BillingGroupId] [int] NOT NULL,
	[PayorTypeId] [int] NULL,
	[HmoTypeId] [int] NULL,
	[IsIncome] [bit] NOT NULL,
	[CanBeAccommodationPrimary] [bit] NULL,
	[CanBeAncillaryPrimary] [bit] NULL,
	[CanBeAccommodationCoinsurer] [bit] NULL,
	[CanBeAncillaryCoinsurer] [bit] NULL,
	[FeeForService] [bit] NOT NULL,
	[DateBeginUsingPdpm] [datetime2](7) NULL,
	[SalesGlAccountId] [int] NULL,
	[ArGlAccountId] [int] NULL,
	[UsesMedicareCoinsurerDays] [bit] NOT NULL,
	[Display] [bit] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_BillableEntities] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BillingGroups]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillingGroups](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](30) NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_BillingGroups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BillingPreferences]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillingPreferences](
	[Id] [int] NOT NULL,
	[DefaultPnaLiabilityAccountId] [int] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_BillingPreferences] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Capacities]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Capacities](
	[Id] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Value] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_Capacities] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CbsaCodes]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CbsaCodes](
	[Id] [int] NOT NULL,
	[LocationId] [int] NOT NULL,
	[Percentage] [decimal](5, 4) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_CbsaCodes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Companies]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Companies](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](max) NULL,
	[ShortName] [nvarchar](max) NULL,
	[NationalProviderNumber] [bigint] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
	[IsARTrackEnabled] [bit] NULL,
 CONSTRAINT [PK_Companies] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompanyCbsaCodes]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyCbsaCodes](
	[Id] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[CbsaCodeId] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_CompanyCbsaCodes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompanyResetLogs]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyResetLogs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ResetId] [int] NOT NULL,
	[Endpoint] [nvarchar](500) NULL,
	[QueryString] [nvarchar](max) NULL,
	[StatusCode] [int] NULL,
	[ErrorMsg] [nvarchar](max) NULL,
	[RequestTime] [datetime2](7) NOT NULL,
	[ResultCount] [int] NOT NULL,
	[Inserts] [int] NOT NULL,
	[Updates] [int] NOT NULL,
	[Deletes] [int] NOT NULL,
	[Slug] [nvarchar](255) NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompanyResetQueues]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyResetQueues](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CompanyId] [int] NOT NULL,
	[RequestedAt] [datetime2](3) NOT NULL,
	[ResetAt] [datetime2](3) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompanyResets]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyResets](
	[CompanyId] [int] NOT NULL,
	[TimeStamp] [datetime] NOT NULL,
	[CreatedAt] [datetime] NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
	[Id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_CompanyReset] PRIMARY KEY CLUSTERED 
(
	[CompanyId] ASC,
	[TimeStamp] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DataSummarySnapshots]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSummarySnapshots](
	[SnapshotID] [int] IDENTITY(1,1) NOT NULL,
	[SnapshotDate] [datetime] NULL,
	[AncillaryCodesCount] [int] NULL,
	[BillableEntitiesCount] [int] NULL,
	[BillingGroupsCount] [int] NULL,
	[CompaniesCount] [int] NULL,
	[DepositsCount] [int] NULL,
	[DepositsAmountSum] [decimal](18, 2) NULL,
	[ReceiptsCount] [int] NULL,
	[ReceiptsNetSum] [decimal](18, 2) NULL,
	[ResidentAncillariesCount] [int] NULL,
	[ResidentAncillariesGrossSum] [decimal](18, 2) NULL,
	[ResidentAncillaryBillsCount] [int] NULL,
	[ResidentAncillaryBillsGrossSum] [decimal](18, 2) NULL,
	[ResidentBillsCount] [int] NULL,
	[ResidentBillsGrossSum] [decimal](18, 2) NULL,
	[ResidentPayorReferenceNumbersCount] [int] NULL,
	[ResidentsCount] [int] NULL,
	[ResourceValuesCount] [int] NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[SnapshotID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Deposits]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Deposits](
	[Id] [int] NOT NULL,
	[ControlNumber] [int] NOT NULL,
	[TransactionDate] [date] NULL,
	[BankId] [int] NOT NULL,
	[Amount] [decimal](10, 2) NOT NULL,
	[ClearedDate] [date] NULL,
	[WriteOff] [bit] NOT NULL,
	[Comment] [nvarchar](100) NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_Deposits] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DistinctUnits]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistinctUnits](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](10) NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_DistinctUnits] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Doctors]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Doctors](
	[Id] [int] NOT NULL,
	[FirstName] [nvarchar](15) NULL,
	[MiddleName] [nvarchar](10) NULL,
	[LastName] [nvarchar](32) NULL,
	[NationalProviderNumber] [bigint] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_Doctors] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExemptDescriptions]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExemptDescriptions](
	[Id] [int] NOT NULL,
	[Description] [nvarchar](50) NULL,
	[HipaaCode] [nvarchar](6) NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ExemptDescriptions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Facilities]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Facilities](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](75) NULL,
	[FacilityTypeId] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_Facilities] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GeneralLedgerGroupEntries]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GeneralLedgerGroupEntries](
	[Id] [int] NOT NULL,
	[EntryId] [int] NOT NULL,
	[GroupId] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_GeneralLedgerGroupEntries] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GeneralLedgerGroups]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GeneralLedgerGroups](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](max) NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_GeneralLedgerGroups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GlAccounts]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GlAccounts](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](80) NULL,
	[AccountNumber] [nvarchar](25) NULL,
	[AccountTypeId] [int] NOT NULL,
	[ParentAccountId] [int] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_GlAccounts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HcpcRateSchedules]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HcpcRateSchedules](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](32) NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_HcpcRateSchedules] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Hcpcs]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Hcpcs](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](6) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_Hcpcs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LastUpdated]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LastUpdated](
	[CompanyId] [int] NOT NULL,
	[Endpoint] [nvarchar](450) NOT NULL,
	[TimeStamp] [datetime2](7) NOT NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_LastUpdated] PRIMARY KEY CLUSTERED 
(
	[Endpoint] ASC,
	[CompanyId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LinkedPayors]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LinkedPayors](
	[Id] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[ParentPayorId] [int] NOT NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_LinkedPayors] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OpenMonthDates]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OpenMonthDates](
	[Id] [int] NOT NULL,
	[ArBilling] [date] NULL,
	[ArReceipts] [date] NULL,
	[Pna] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[InternalId] [int] IDENTITY(1,1) NOT NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[InternalId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PayorHcpcRateSchedules]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayorHcpcRateSchedules](
	[Id] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[HcpcRateScheduleId] [int] NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_PayorHcpcRateSchedules] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PayorPdpmRates]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayorPdpmRates](
	[Id] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[Rate] [decimal](10, 2) NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_PayorPdpmRates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PayorRateCodes]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayorRateCodes](
	[Id] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[Code] [nvarchar](6) NULL,
	[Description] [nvarchar](30) NULL,
	[Default] [bit] NOT NULL,
	[IsAddonRate] [bit] NOT NULL,
	[RateScheduleId] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_PayorRateCodes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PayorRates]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayorRates](
	[Id] [int] NOT NULL,
	[PayorRateCodeId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Rate] [decimal](10, 2) NOT NULL,
	[BaseRate] [decimal](10, 2) NOT NULL,
	[PayorSpecialRateId] [int] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_PayorRates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PayorRules]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayorRules](
	[Id] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[PaysDayOfDischarge] [bit] NOT NULL,
	[PaysDayOfDeath] [bit] NOT NULL,
	[PaysSameDayOfAdmitAndDischarge] [bit] NOT NULL,
	[BedHoldDaysPaid] [smallint] NOT NULL,
	[BedHoldRateCodeId] [int] NULL,
	[PercentBedHoldCoverage] [decimal](10, 6) NOT NULL,
	[TherapeuticLeaveDaysPaid] [smallint] NOT NULL,
	[TherapeuticLeaveRateCodeId] [int] NULL,
	[PercentTherapeuticLeaveCoverage] [decimal](10, 6) NOT NULL,
	[PercentStayAncillaryCoverage] [decimal](8, 4) NOT NULL,
	[PercentNonStayAncillaryCoverage] [decimal](8, 4) NOT NULL,
	[AncillaryPrimaryWriteOff] [bit] NOT NULL,
	[AncillaryCoinsurerWriteOff] [bit] NOT NULL,
	[AddonBilling] [bit] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_PayorRules] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PayorSpecialRates]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayorSpecialRates](
	[Id] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[Description] [nvarchar](30) NULL,
	[Code] [nvarchar](6) NULL,
	[RevenueCode] [nvarchar](10) NULL,
	[DiagnosisId] [int] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_PayorSpecialRates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReceiptNonArAmounts]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReceiptNonArAmounts](
	[Id] [int] NOT NULL,
	[ReceiptId] [int] NOT NULL,
	[Amount] [decimal](10, 2) NOT NULL,
	[GlAccountId] [int] NOT NULL,
	[Comment] [nvarchar](max) NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ReceiptNonArAmounts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Receipts]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Receipts](
	[Id] [int] NOT NULL,
	[DepositId] [int] NULL,
	[ResidentId] [int] NULL,
	[VendorId] [int] NULL,
	[TransactionNumber] [int] NOT NULL,
	[CheckNumber] [nvarchar](10) NULL,
	[PayDescription] [nvarchar](6) NULL,
	[Comment] [nvarchar](50) NULL,
	[ClaimReferenceNumber] [nvarchar](25) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[Units] [int] NOT NULL,
	[Net] [decimal](10, 2) NOT NULL,
	[Allowance] [decimal](10, 2) NOT NULL,
	[PartABId] [int] NULL,
	[ServiceTypeId] [int] NULL,
	[ServiceDescription] [nvarchar](6) NULL,
	[ServiceDescriptionModifierId] [int] NULL,
	[TypeId] [int] NULL,
	[BillableEntityId] [int] NULL,
	[DistinctUnitId] [int] NOT NULL,
	[ResidentBillDetailId] [int] NULL,
	[ResidentBillAncillaryDetailId] [int] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_Receipts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentAncillaries]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentAncillaries](
	[Id] [int] NOT NULL,
	[ResidentId] [int] NOT NULL,
	[ControlNumber] [int] NOT NULL,
	[TransactionNumber] [int] NOT NULL,
	[PayorNumber] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[DistinctUnitId] [int] NOT NULL,
	[ServiceDescriptionId] [int] NOT NULL,
	[TransactionDate] [datetime2](7) NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[Units] [int] NOT NULL,
	[Rate] [decimal](10, 2) NOT NULL,
	[Gross] [decimal](10, 2) NOT NULL,
	[WriteOff] [bit] NOT NULL,
	[PartABId] [int] NULL,
	[PrimaryResidentAncillaryId] [int] NULL,
	[CoinsurerId] [int] NULL,
	[CoinsurerGross] [decimal](10, 2) NOT NULL,
	[VoidedDate] [datetime2](7) NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentAncillaries] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentAncillaryBills]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentAncillaryBills](
	[Id] [int] NOT NULL,
	[PartABId] [int] NULL,
	[WriteOff] [bit] NOT NULL,
	[ResidentId] [int] NOT NULL,
	[ParentBillId] [int] NULL,
	[DistinctUnitId] [int] NOT NULL,
	[ServiceDescription] [nvarchar](max) NULL,
	[ServiceDescriptionModifierId] [int] NOT NULL,
	[TypeId] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[ControlNumber] [int] NOT NULL,
	[TransactionNumber] [int] NOT NULL,
	[PayorNumber] [int] NOT NULL,
	[Units] [int] NOT NULL,
	[Gross] [decimal](10, 2) NOT NULL,
	[TransactionDate] [datetime2](7) NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[VoidedDate] [datetime2](7) NULL,
	[VoidedControlNumber] [int] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentAncillaryBills] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentBillHists]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentBillHists](
	[Id] [int] NOT NULL,
	[RateCode] [nvarchar](max) NULL,
	[Rate] [decimal](10, 2) NOT NULL,
	[ResidentId] [int] NOT NULL,
	[ParentBillId] [int] NULL,
	[DistinctUnitId] [int] NOT NULL,
	[ServiceDescription] [nvarchar](max) NULL,
	[ServiceDescriptionModifierId] [int] NOT NULL,
	[TypeId] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[ControlNumber] [int] NOT NULL,
	[TransactionNumber] [int] NOT NULL,
	[PayorNumber] [int] NOT NULL,
	[Units] [int] NOT NULL,
	[Gross] [decimal](10, 2) NOT NULL,
	[TransactionDate] [datetime2](7) NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[VoidedDate] [datetime2](7) NULL,
	[VoidedControlNumber] [int] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[RequestId] [varchar](60) NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentBills]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentBills](
	[Id] [int] NOT NULL,
	[RateCode] [nvarchar](max) NULL,
	[Rate] [decimal](10, 2) NOT NULL,
	[ResidentId] [int] NOT NULL,
	[ParentBillId] [int] NULL,
	[DistinctUnitId] [int] NOT NULL,
	[ServiceDescription] [nvarchar](max) NULL,
	[ServiceDescriptionModifierId] [int] NOT NULL,
	[TypeId] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[ControlNumber] [int] NOT NULL,
	[TransactionNumber] [int] NOT NULL,
	[PayorNumber] [int] NOT NULL,
	[Units] [int] NOT NULL,
	[Gross] [decimal](10, 2) NOT NULL,
	[TransactionDate] [datetime2](7) NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[VoidedDate] [datetime2](7) NULL,
	[VoidedControlNumber] [int] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentBills] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentBillsLog]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentBillsLog](
	[Id] [int] NOT NULL,
	[RateCode] [nvarchar](max) NULL,
	[Rate] [decimal](10, 2) NOT NULL,
	[ResidentId] [int] NOT NULL,
	[ParentBillId] [int] NULL,
	[DistinctUnitId] [int] NOT NULL,
	[ServiceDescription] [nvarchar](max) NULL,
	[ServiceDescriptionModifierId] [int] NOT NULL,
	[TypeId] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[ControlNumber] [int] NOT NULL,
	[TransactionNumber] [int] NOT NULL,
	[PayorNumber] [int] NOT NULL,
	[Units] [int] NOT NULL,
	[Gross] [decimal](10, 2) NOT NULL,
	[TransactionDate] [datetime2](7) NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[VoidedDate] [datetime2](7) NULL,
	[VoidedControlNumber] [int] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[RequestId] [varchar](60) NULL,
	[CreatedAt] [datetime] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentContactAddresses]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentContactAddresses](
	[Id] [int] NOT NULL,
	[ResidentContactId] [int] NOT NULL,
	[AddressTypeId] [int] NOT NULL,
	[LineOne] [nvarchar](max) NULL,
	[LineTwo] [nvarchar](max) NULL,
	[LineThree] [nvarchar](max) NULL,
	[City] [nvarchar](max) NULL,
	[State] [nvarchar](max) NULL,
	[Zip] [nvarchar](max) NULL,
	[CountryId] [int] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentContactAddresses] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentContactContactInfos]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentContactContactInfos](
	[Id] [int] NOT NULL,
	[ResidentContactId] [int] NOT NULL,
	[Info] [nvarchar](max) NULL,
	[ContactInfoTypeId] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentContactContactInfos] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentContactRoles]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentContactRoles](
	[Id] [int] NOT NULL,
	[ResidentContactId] [int] NOT NULL,
	[RoleTypeId] [int] NULL,
	[Inactive] [bit] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentContactRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentContacts]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentContacts](
	[Id] [int] NOT NULL,
	[ResidentId] [int] NOT NULL,
	[RelationshipTypeId] [int] NULL,
	[FirstName] [nvarchar](15) NULL,
	[MiddleName] [nvarchar](10) NULL,
	[LastName] [nvarchar](32) NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentContacts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentDepositTypes]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentDepositTypes](
	[Id] [int] NOT NULL,
	[ResidentId] [int] NOT NULL,
	[IncomeId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[DepositTypeId] [int] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentDepositTypes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentDistinctUnits]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentDistinctUnits](
	[Id] [int] NOT NULL,
	[ResidentStayId] [int] NOT NULL,
	[DistinctUnitId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentDistinctUnits] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentIncomeData]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentIncomeData](
	[Id] [int] NOT NULL,
	[ResidentIncomeId] [int] NOT NULL,
	[IncomeId] [int] NOT NULL,
	[Gross] [decimal](10, 2) NOT NULL,
	[Allowance] [decimal](10, 2) NOT NULL,
	[Exempt] [decimal](10, 2) NOT NULL,
	[ExemptOverride] [decimal](10, 2) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentIncomeData] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentIncomeExemptDetails]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentIncomeExemptDetails](
	[Id] [int] NOT NULL,
	[ResidentIncomeId] [int] NOT NULL,
	[ExemptDescriptionId] [int] NOT NULL,
	[Amount] [decimal](10, 2) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentIncomeExemptDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentIncomes]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentIncomes](
	[Id] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[StateNet] [decimal](10, 2) NOT NULL,
	[Memo] [nvarchar](75) NULL,
	[IsActual] [bit] NOT NULL,
	[ResidentId] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentIncomes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentMds]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentMds](
	[Id] [int] NOT NULL,
	[ResidentStayId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[AssessmentDate] [date] NULL,
	[AssessmentTypeId] [int] NOT NULL,
	[Score] [nvarchar](12) NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentMds] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentMedicaidPending]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentMedicaidPending](
	[Id] [int] NOT NULL,
	[ResidentId] [int] NOT NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[ApprovalDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentMedicaidPending] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentPartBEligibilities]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentPartBEligibilities](
	[Id] [int] NOT NULL,
	[ResidentId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentPartBEligibilities] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentPartBPayors]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentPartBPayors](
	[Id] [int] NOT NULL,
	[ResidentId] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentPartBPayors] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentPayorAuthorizationNumbers]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentPayorAuthorizationNumbers](
	[Id] [int] NOT NULL,
	[ResidentPayorId] [int] NOT NULL,
	[AuthorizationNumber] [nvarchar](255) NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentPayorAuthorizationNumbers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentPayorCoinsurers]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentPayorCoinsurers](
	[Id] [int] NOT NULL,
	[ResidentPayorId] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[CoinsurerId] [int] NULL,
	[CoPay] [decimal](10, 2) NOT NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentPayorCoinsurers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentPayorReferenceNumbers]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentPayorReferenceNumbers](
	[Id] [int] NOT NULL,
	[ResidentId] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[ReferenceNumber] [nvarchar](25) NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentPayorReferenceNumbers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Residents]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Residents](
	[Id] [int] NOT NULL,
	[SystemNumber] [int] NOT NULL,
	[FirstName] [nvarchar](15) NULL,
	[MiddleName] [nvarchar](10) NULL,
	[LastName] [nvarchar](32) NULL,
	[SocialSecurityNumber] [nvarchar](9) NULL,
	[Gender] [nvarchar](6) NULL,
	[DateOfBirth] [date] NULL,
	[DateOfDeath] [date] NULL,
	[MaritalStatusId] [int] NULL,
	[EthnicityId] [int] NULL,
	[ReligionId] [int] NULL,
	[LanguageId] [int] NULL,
	[CountryOfBirthId] [int] NULL,
	[IsInCollections] [bit] NOT NULL,
	[PartAEligible] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_Residents] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentStayBeds]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentStayBeds](
	[Id] [int] NOT NULL,
	[ResidentStayId] [int] NOT NULL,
	[BedId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentStayBeds] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentStayDiagnoses]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentStayDiagnoses](
	[Id] [int] NOT NULL,
	[ResidentStayId] [int] NOT NULL,
	[DiagnosisId] [int] NOT NULL,
	[AdmitDiagnosis] [bit] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentStayDiagnoses] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentStayDoctors]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentStayDoctors](
	[Id] [int] NOT NULL,
	[ResidentStayId] [int] NOT NULL,
	[DoctorId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentStayDoctors] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentStayPayorRateCodes]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentStayPayorRateCodes](
	[Id] [int] NOT NULL,
	[ResidentStayPayorId] [int] NOT NULL,
	[PayorRateCode] [nvarchar](6) NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentStayPayorRateCodes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentStayPayors]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentStayPayors](
	[Id] [int] NOT NULL,
	[ResidentStayId] [int] NOT NULL,
	[PayorId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[CoverageEndReasonId] [int] NULL,
	[ExpendedDays] [int] NOT NULL,
	[ExpendedPdpmDays] [int] NOT NULL,
	[IncidentNumber] [int] NOT NULL,
	[EndOfCare] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentStayPayors] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentStayPayorSpecialRates]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentStayPayorSpecialRates](
	[Id] [int] NOT NULL,
	[ResidentStayPayorId] [int] NOT NULL,
	[PayorSpecialRateId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentStayPayorSpecialRates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentStays]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentStays](
	[Id] [int] NOT NULL,
	[ResidentId] [int] NOT NULL,
	[AdmitDate] [datetime2](7) NOT NULL,
	[AdmitFacilityId] [int] NOT NULL,
	[QualifyingStayStart] [date] NULL,
	[QualifyingStayEnd] [date] NULL,
	[DischargeDate] [datetime2](7) NULL,
	[DischargeFacilityId] [int] NULL,
	[DischargeReasonId] [int] NULL,
	[DischargeDoctorId] [int] NULL,
	[DischargeDiagnosisId] [int] NULL,
	[BedHoldDischargeDate] [date] NULL,
	[AdmissionTypeId] [int] NOT NULL,
	[RecordTypeId] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentStays] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResidentStayTypes]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResidentStayTypes](
	[Id] [int] NOT NULL,
	[ResidentStayId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[TypeId] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResidentStayTypes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResourceValues]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResourceValues](
	[Id] [int] NOT NULL,
	[Description] [nvarchar](50) NULL,
	[ShortDescription] [nvarchar](50) NULL,
	[ResourceType] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_ResourceValues] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TherapyBillDetails]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TherapyBillDetails](
	[Id] [int] NOT NULL,
	[TherapyTreatmentId] [int] NOT NULL,
	[Units] [int] NOT NULL,
	[Total] [decimal](10, 2) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_TherapyBillDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TherapyCoursesOfTreatment]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TherapyCoursesOfTreatment](
	[Id] [int] NOT NULL,
	[ResidentId] [int] NOT NULL,
	[TherapyTypeId] [int] NOT NULL,
	[CourseTypeId] [int] NOT NULL,
	[OnsetDate] [date] NULL,
	[EvaluationDate] [date] NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_TherapyCoursesOfTreatment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TherapyTreatments]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TherapyTreatments](
	[Id] [int] NOT NULL,
	[TherapyCourseOfTreatmentId] [int] NOT NULL,
	[HcpcsId] [int] NOT NULL,
	[SessionStartDate] [date] NOT NULL,
	[SessionEndDate] [date] NOT NULL,
	[Units] [int] NOT NULL,
	[Minutes] [int] NOT NULL,
	[Billable] [bit] NOT NULL,
	[Modifier2] [nvarchar](2) NULL,
	[Modifier3] [nvarchar](2) NULL,
	[Modifier4] [nvarchar](2) NULL,
	[CourseTypeId] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_TherapyTreatments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VbpFactors]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VbpFactors](
	[Id] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Factor] [decimal](12, 10) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_VbpFactors] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Vendors]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vendors](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](50) NULL,
	[SystemNumber] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[CompanyId] [int] NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
 CONSTRAINT [PK_Vendors] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [metadata].[LakehouseUpdateBatch]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [metadata].[LakehouseUpdateBatch](
	[CompanyId] [int] NOT NULL,
	[TableName] [varchar](100) NOT NULL,
	[PipelineRunId] [nvarchar](100) NOT NULL,
	[StartValidFromDate] [datetime2](7) NOT NULL,
	[EndValidFromDate] [datetime2](7) NOT NULL,
	[StartUpdateDate] [datetime2](7) NOT NULL,
	[EndUpdateDate] [datetime2](7) NOT NULL,
	[CompleteDate] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[CompanyId] ASC,
	[TableName] ASC,
	[PipelineRunId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [metadata].[LastUpdatedToLakehouse]    Script Date: 4/21/2026 10:46:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [metadata].[LastUpdatedToLakehouse](
	[TableName] [varchar](100) NOT NULL,
	[LastTimestamp] [datetime2](7) NULL,
	[LastLakehouseTimestamp] [datetime2](7) NULL,
	[LastUpdated] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NULL,
	[ApiRequestSlug] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[TableName] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AncillaryCodes] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[AncillaryCodes] ADD  CONSTRAINT [DF_AncillaryCodes_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[AncillaryRates] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[AncillaryRates] ADD  CONSTRAINT [DF_AncillaryRates_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ApiRequestLogs] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ApiRequestLogs] ADD  CONSTRAINT [DF_ApiRequestLogs_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Banks] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[Banks] ADD  CONSTRAINT [DF_Banks_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Beds] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[Beds] ADD  CONSTRAINT [DF_Beds_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[BillableEntities] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[BillableEntities] ADD  CONSTRAINT [DF_BillableEntities_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[BillingGroups] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[BillingGroups] ADD  CONSTRAINT [DF_BillingGroups_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[BillingPreferences] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[BillingPreferences] ADD  CONSTRAINT [DF_BillingPreferences_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Capacities] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[Capacities] ADD  CONSTRAINT [DF_Capacities_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[CbsaCodes] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[CbsaCodes] ADD  CONSTRAINT [DF_CbsaCodes_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Companies] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[Companies] ADD  CONSTRAINT [DF_Companies_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Companies] ADD  DEFAULT ((0)) FOR [IsARTrackEnabled]
GO
ALTER TABLE [dbo].[CompanyCbsaCodes] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[CompanyCbsaCodes] ADD  CONSTRAINT [DF_CompanyCbsaCodes_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[CompanyResetQueues] ADD  DEFAULT (sysutcdatetime()) FOR [RequestedAt]
GO
ALTER TABLE [dbo].[CompanyResets] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[DataSummarySnapshots] ADD  DEFAULT (getdate()) FOR [SnapshotDate]
GO
ALTER TABLE [dbo].[Deposits] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[Deposits] ADD  CONSTRAINT [DF_Deposits_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[DistinctUnits] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[DistinctUnits] ADD  CONSTRAINT [DF_DistinctUnits_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Doctors] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[Doctors] ADD  CONSTRAINT [DF_Doctors_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ExemptDescriptions] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ExemptDescriptions] ADD  CONSTRAINT [DF_ExemptDescriptions_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Facilities] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[Facilities] ADD  CONSTRAINT [DF_Facilities_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[GeneralLedgerGroupEntries] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[GeneralLedgerGroupEntries] ADD  CONSTRAINT [DF_GeneralLedgerGroupEntries_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[GeneralLedgerGroups] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[GeneralLedgerGroups] ADD  CONSTRAINT [DF_GeneralLedgerGroups_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[GlAccounts] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[GlAccounts] ADD  CONSTRAINT [DF_GlAccounts_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[HcpcRateSchedules] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[HcpcRateSchedules] ADD  CONSTRAINT [DF_HcpcRateSchedules_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Hcpcs] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[Hcpcs] ADD  CONSTRAINT [DF_Hcpcs_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[LastUpdated] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[LastUpdated] ADD  CONSTRAINT [DF_LastUpdated_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[LinkedPayors] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[LinkedPayors] ADD  CONSTRAINT [DF_LinkedPayors_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[OpenMonthDates] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[PayorHcpcRateSchedules] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[PayorHcpcRateSchedules] ADD  CONSTRAINT [DF_PayorHcpcRateSchedules_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[PayorPdpmRates] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[PayorPdpmRates] ADD  CONSTRAINT [DF_PayorPdpmRates_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[PayorRateCodes] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[PayorRateCodes] ADD  CONSTRAINT [DF_PayorRateCodes_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[PayorRates] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[PayorRates] ADD  CONSTRAINT [DF_PayorRates_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[PayorRules] ADD  DEFAULT ((1.0)) FOR [PercentBedHoldCoverage]
GO
ALTER TABLE [dbo].[PayorRules] ADD  DEFAULT ((0.0)) FOR [PercentTherapeuticLeaveCoverage]
GO
ALTER TABLE [dbo].[PayorRules] ADD  DEFAULT ((0.0)) FOR [PercentStayAncillaryCoverage]
GO
ALTER TABLE [dbo].[PayorRules] ADD  DEFAULT ((0.0)) FOR [PercentNonStayAncillaryCoverage]
GO
ALTER TABLE [dbo].[PayorRules] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[PayorRules] ADD  CONSTRAINT [DF_PayorRules_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[PayorSpecialRates] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[PayorSpecialRates] ADD  CONSTRAINT [DF_PayorSpecialRates_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ReceiptNonArAmounts] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ReceiptNonArAmounts] ADD  CONSTRAINT [DF_ReceiptNonArAmounts_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Receipts] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[Receipts] ADD  CONSTRAINT [DF_Receipts_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentAncillaries] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentAncillaries] ADD  CONSTRAINT [DF_ResidentAncillaries_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentAncillaryBills] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentAncillaryBills] ADD  CONSTRAINT [DF_ResidentAncillaryBills_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentBillHists] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentBillHists] ADD  CONSTRAINT [DF_ResidentBillHists_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentBills] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentBills] ADD  CONSTRAINT [DF_ResidentBills_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentBillsLog] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentBillsLog] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentContactAddresses] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentContactAddresses] ADD  CONSTRAINT [DF_ResidentContactAddresses_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentContactContactInfos] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentContactContactInfos] ADD  CONSTRAINT [DF_ResidentContactContactInfos_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentContactRoles] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentContactRoles] ADD  CONSTRAINT [DF_ResidentContactRoles_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentContacts] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentContacts] ADD  CONSTRAINT [DF_ResidentContacts_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentDepositTypes] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentDepositTypes] ADD  CONSTRAINT [DF_ResidentDepositTypes_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentDistinctUnits] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentDistinctUnits] ADD  CONSTRAINT [DF_ResidentDistinctUnits_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentIncomeData] ADD  DEFAULT ((0.0)) FOR [Gross]
GO
ALTER TABLE [dbo].[ResidentIncomeData] ADD  DEFAULT ((0.0)) FOR [Allowance]
GO
ALTER TABLE [dbo].[ResidentIncomeData] ADD  DEFAULT ((0.0)) FOR [Exempt]
GO
ALTER TABLE [dbo].[ResidentIncomeData] ADD  DEFAULT ((0.0)) FOR [ExemptOverride]
GO
ALTER TABLE [dbo].[ResidentIncomeData] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentIncomeData] ADD  CONSTRAINT [DF_ResidentIncomeData_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentIncomeExemptDetails] ADD  DEFAULT ((0.0)) FOR [Amount]
GO
ALTER TABLE [dbo].[ResidentIncomeExemptDetails] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentIncomeExemptDetails] ADD  CONSTRAINT [DF_ResidentIncomeExemptDetails_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentIncomes] ADD  DEFAULT ((0.0)) FOR [StateNet]
GO
ALTER TABLE [dbo].[ResidentIncomes] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentIncomes] ADD  CONSTRAINT [DF_ResidentIncomes_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentMds] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentMds] ADD  CONSTRAINT [DF_ResidentMds_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentMedicaidPending] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentMedicaidPending] ADD  CONSTRAINT [DF_ResidentMedicaidPending_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentPartBEligibilities] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentPartBEligibilities] ADD  CONSTRAINT [DF_ResidentPartBEligibilities_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentPartBPayors] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentPartBPayors] ADD  CONSTRAINT [DF_ResidentPartBPayors_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentPayorAuthorizationNumbers] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentPayorAuthorizationNumbers] ADD  CONSTRAINT [DF_ResidentPayorAuthorizationNumbers_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentPayorCoinsurers] ADD  DEFAULT ((0.0)) FOR [CoPay]
GO
ALTER TABLE [dbo].[ResidentPayorCoinsurers] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentPayorCoinsurers] ADD  CONSTRAINT [DF_ResidentPayorCoinsurers_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentPayorReferenceNumbers] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentPayorReferenceNumbers] ADD  CONSTRAINT [DF_ResidentPayorReferenceNumbers_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Residents] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[Residents] ADD  CONSTRAINT [DF_Residents_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentStayBeds] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentStayBeds] ADD  CONSTRAINT [DF_ResidentStayBeds_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentStayDiagnoses] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentStayDiagnoses] ADD  CONSTRAINT [DF_ResidentStayDiagnoses_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentStayDoctors] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentStayDoctors] ADD  CONSTRAINT [DF_ResidentStayDoctors_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentStayPayorRateCodes] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentStayPayorRateCodes] ADD  CONSTRAINT [DF_ResidentStayPayorRateCodes_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentStayPayors] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentStayPayors] ADD  CONSTRAINT [DF_ResidentStayPayors_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentStayPayorSpecialRates] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentStayPayorSpecialRates] ADD  CONSTRAINT [DF_ResidentStayPayorSpecialRates_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentStays] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentStays] ADD  CONSTRAINT [DF_ResidentStays_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResidentStayTypes] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResidentStayTypes] ADD  CONSTRAINT [DF_ResidentStayTypes_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ResourceValues] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[ResourceValues] ADD  CONSTRAINT [DF_ResourceValues_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[TherapyBillDetails] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[TherapyBillDetails] ADD  CONSTRAINT [DF_TherapyBillDetails_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[TherapyCoursesOfTreatment] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[TherapyCoursesOfTreatment] ADD  CONSTRAINT [DF_TherapyCoursesOfTreatment_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[TherapyTreatments] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[TherapyTreatments] ADD  CONSTRAINT [DF_TherapyTreatments_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[VbpFactors] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[VbpFactors] ADD  CONSTRAINT [DF_VbpFactors_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Vendors] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[Vendors] ADD  CONSTRAINT [DF_Vendors_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [metadata].[LastUpdatedToLakehouse] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [metadata].[LastUpdatedToLakehouse] ADD  CONSTRAINT [DF_LastUpdatedToLakehouse_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
