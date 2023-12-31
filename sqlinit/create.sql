USE [C127_sjbjohn_gmail]
GO
/****** Object:  UserDefinedTableType [dbo].[BatchFriendIds]    Script Date: 6/21/2023 5:25:40 PM ******/
CREATE TYPE [dbo].[BatchFriendIds] AS TABLE(
	[id] [int] NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[BatchImages]    Script Date: 6/21/2023 5:25:40 PM ******/
CREATE TYPE [dbo].[BatchImages] AS TABLE(
	[imageTypeId] [int] NULL,
	[imageUrl] [nvarchar](256) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[BatchSkills]    Script Date: 6/21/2023 5:25:40 PM ******/
CREATE TYPE [dbo].[BatchSkills] AS TABLE(
	[Name] [nvarchar](128) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[BatchTags]    Script Date: 6/21/2023 5:25:40 PM ******/
CREATE TYPE [dbo].[BatchTags] AS TABLE(
	[name] [nvarchar](30) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[BatchUrls]    Script Date: 6/21/2023 5:25:40 PM ******/
CREATE TYPE [dbo].[BatchUrls] AS TABLE(
	[Url] [nvarchar](500) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[SkillsTemp]    Script Date: 6/21/2023 5:25:40 PM ******/
CREATE TYPE [dbo].[SkillsTemp] AS TABLE(
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[TechCompanies_GetById_JSON]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[TechCompanies_GetById_JSON](@Id int) RETURNS NVARCHAR(max)


/*

	declare @techCompany table ([json] nvarchar(max)) 

	insert @techCompany ([json])
	exec dbo.techcompanies_selectbyid 10
	
	select [json] from @techCompany

*/



as

BEGIN

declare @ReturnValue nvarchar(max)

--This outer select with the followup AS JSON
--ensures that the entire rsult will appear
--in one column
set @ReturnValue = (select (

--select only from TechCompanies with all references
--to other tables in subqueries
select	techCompanies.id
		,techCompanies.slug
		,techCompanies.statusId
		,techCompanies.name
		,techCompanies.headline
		,techCompanies.profile
		,techCompanies.summary
		,techCompanies.entityTypeId
		,contactInformation = JSON_QUERY((select contactinformation.id   --REQUIRED to remove array wrapper
									,contactinformation.entityId
									,contactinformation.[data]
									,contactinformation.dateCreated
									,contactinformation.dateModified 
								from contactInformation 
								inner join techcompanies tc1
								on tc1.contactinformation = contactinformation.id
								where tc1.id = techCompanies.id
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))   --REQUIRED to remove array wrapper
		,images = (Select	images.id
							,images.entityId
							,images.typeId imageTypeId
							,images.url imageUrl
						from images 
						inner join techcompaniesimages tci
						on images.id = tci.imageid
						where  tci.techcompanyid = techCompanies.id 
						FOR JSON AUTO)
		,urls = (Select	urls.id
							,urls.entityId
							,urls.url
						from urls 
						inner join techcompaniesurls tcu
						on urls.id = tcu.urlid
						where  tcu.techcompanyid = techCompanies.id 
						FOR JSON AUTO)

		,friends = (Select	friends.id
							,friends.bio
							,friends.title
							,friends.Summary
							,Friends.Headline
							,friends.entityTypeId
							,friends.StatusId
							,friends.Slug
							,skills = (Select	skills.id
												,skills.name
										from skills
										inner join friendskills fs
										on skills.id = fs.skillid
										where fs.friendid = friends.id
										FOR JSON AUTO)
							,primaryImage = JSON_QUERY((Select		images.id   --REQUIRED to remove array wrapper
														,images.entityid
														,images.TypeId imageTypeId
														,images.url imageUrl
												from images
												inner join FriendsV2 f2
												on images.id = f2.PrimaryImageId
												where f2.Id = friends.id
												FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))   --REQUIRED to remove array wrapper
							,Friends.DateCreated
							,Friends.DateModified
						from FriendsV2 friends
						inner join techcompaniesfriends tcf
						on friends.id = tcf.friendid
						where tcf.techcompanyid = techCompanies.id
						for JSON auto)
		,tags = (Select		tags.id
							,tags.entityId
							,tags.name tagName
					from	tags
					inner join techcompaniestags tct
					on tags.id = tct.tagid
					where tct.techcompanyid = techCompanies.id
					for JSON auto)
		,techCompanies.dateCreated
		,techCompanies.dateModified
FROM TechCompanies 
WHERE TechCompanies.id = @Id

ORDER BY techCompanies.id

FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

) AS JSON)

return @ReturnValue

END
GO
/****** Object:  Table [dbo].[AbstractValues]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AbstractValues](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[someValue] [int] NOT NULL,
 CONSTRAINT [PK_AbstractValues] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cars]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cars](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Make] [nvarchar](50) NOT NULL,
	[Model] [nvarchar](50) NOT NULL,
	[Year] [int] NOT NULL,
	[IsUsed] [bit] NOT NULL,
	[ManufacturerId] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateModified] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Cars] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CarsFeatures]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CarsFeatures](
	[CarId] [int] NOT NULL,
	[FeatureId] [int] NOT NULL,
 CONSTRAINT [PK_CarsFeatures] PRIMARY KEY CLUSTERED 
(
	[CarId] ASC,
	[FeatureId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Concerts]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Concerts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](500) NOT NULL,
	[Description] [nvarchar](500) NOT NULL,
	[IsFree] [bit] NOT NULL,
	[Address] [nvarchar](500) NOT NULL,
	[Cost] [int] NOT NULL,
	[DateOfEvent] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Concerts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContactInformation]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContactInformation](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[EntityId] [int] NOT NULL,
	[Data] [nvarchar](256) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateModified] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_ContactInformation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Courses]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Courses](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Description] [nvarchar](200) NOT NULL,
	[SeasonTermId] [int] NULL,
	[TeacherId] [int] NULL,
 CONSTRAINT [PK_Courses] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Events]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Events](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](700) NULL,
	[Summary] [nvarchar](256) NULL,
	[Headline] [nvarchar](128) NULL,
	[Slug] [nvarchar](50) NULL,
	[StatusId] [nvarchar](10) NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateModified] [datetime2](7) NOT NULL,
	[UserId] [int] NOT NULL,
	[DateStart] [datetime2](7) NOT NULL,
	[DateEnd] [datetime2](7) NOT NULL,
	[Latitude] [float] NOT NULL,
	[Longitude] [float] NOT NULL,
	[ZipCode] [nvarchar](20) NULL,
	[Address] [nvarchar](256) NULL,
 CONSTRAINT [PK_Events] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Features]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Features](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateModified] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Features] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Friends]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Friends](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](120) NOT NULL,
	[Bio] [nvarchar](700) NOT NULL,
	[Summary] [nvarchar](255) NOT NULL,
	[Headline] [nvarchar](80) NOT NULL,
	[Slug] [nvarchar](100) NOT NULL,
	[StatusId] [int] NOT NULL,
	[PrimaryImageUrl] [nvarchar](256) NOT NULL,
	[UserId] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateModified] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Friends] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FriendSkills]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FriendSkills](
	[FriendId] [int] NOT NULL,
	[SkillId] [int] NOT NULL,
 CONSTRAINT [PK_FriendSkills] PRIMARY KEY CLUSTERED 
(
	[FriendId] ASC,
	[SkillId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FriendsV2]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FriendsV2](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](120) NOT NULL,
	[Bio] [nvarchar](700) NOT NULL,
	[Summary] [nvarchar](255) NOT NULL,
	[Headline] [nvarchar](80) NOT NULL,
	[Slug] [nvarchar](100) NOT NULL,
	[StatusId] [int] NOT NULL,
	[PrimaryImageId] [int] NULL,
	[UserId] [int] NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateModified] [datetime2](7) NOT NULL,
	[EntityTypeId] [int] NOT NULL,
 CONSTRAINT [PK_FriendsV2] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Images]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Images](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TypeId] [int] NOT NULL,
	[Url] [nvarchar](256) NOT NULL,
	[UserId] [int] NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateModified] [datetime2](7) NOT NULL,
	[EntityId] [int] NOT NULL,
 CONSTRAINT [PK_Images] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Jobs]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Jobs](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](100) NOT NULL,
	[Pay] [nvarchar](10) NOT NULL,
	[Summary] [nvarchar](256) NULL,
	[Description] [nvarchar](500) NULL,
	[ShortDescription] [nvarchar](256) NULL,
	[ShortTitle] [nvarchar](50) NULL,
	[Content] [nvarchar](256) NULL,
	[CreatedBy] [int] NOT NULL,
	[ModifiedBy] [int] NOT NULL,
	[Slug] [nchar](50) NULL,
	[EntityTypeId] [int] NOT NULL,
	[StatusId] [nchar](10) NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateModified] [datetime2](7) NOT NULL,
	[Site] [int] NULL,
	[BaseMetaDataId] [int] NULL,
	[TechCompanyId] [int] NOT NULL,
 CONSTRAINT [PK_Jobs] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[JobsSkills]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JobsSkills](
	[JobId] [int] NOT NULL,
	[SkillId] [int] NOT NULL,
 CONSTRAINT [PK_JobsSkills] PRIMARY KEY CLUSTERED 
(
	[JobId] ASC,
	[SkillId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Manufacturers]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Manufacturers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Country] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateModified] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Manufacturers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[People]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[People](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Age] [int] NULL,
	[IsSmoker] [bit] NULL,
	[DateAdded] [datetime2](7) NOT NULL,
	[DateModified] [datetime2](7) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PetImages]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PetImages](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PetId] [int] NOT NULL,
	[Url] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_PetImages] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Pets]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pets](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Breed] [nvarchar](100) NOT NULL,
	[Size] [nvarchar](20) NOT NULL,
	[Color] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_Pets] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sabio_Addresses]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sabio_Addresses](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LineOne] [nvarchar](50) NOT NULL,
	[SuiteNumber] [int] NULL,
	[City] [nvarchar](50) NOT NULL,
	[State] [nvarchar](50) NOT NULL,
	[PostalCode] [nvarchar](50) NULL,
	[IsActive] [bit] NULL,
	[Lat] [float] NULL,
	[Long] [float] NULL,
 CONSTRAINT [PK_Sabio_Addresses] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SeasonTerms]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SeasonTerms](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Term] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_SeasonTerms] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Skills]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Skills](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[UserId] [int] NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateModified] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Starter] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StudentCourses]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudentCourses](
	[StudentId] [int] NOT NULL,
	[CourseId] [int] NOT NULL,
 CONSTRAINT [PK_StudentCourses] PRIMARY KEY CLUSTERED 
(
	[StudentId] ASC,
	[CourseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Students]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Students](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[DOB] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Students] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tags]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tags](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[EntityId] [int] NOT NULL,
	[Name] [nvarchar](30) NULL,
	[UserId] [int] NULL,
	[DateCreated] [datetime2](7) NULL,
	[DateModified] [datetime2](7) NULL,
 CONSTRAINT [PK_Tags] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Teachers]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Teachers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_Teachers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TechCompanies]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TechCompanies](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateModified] [datetime2](7) NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Profile] [nvarchar](700) NULL,
	[Summary] [nvarchar](256) NULL,
	[Headline] [nvarchar](100) NULL,
	[ContactInformation] [int] NULL,
	[ShortTitle] [nvarchar](50) NULL,
	[Title] [nvarchar](100) NULL,
	[ShortDescription] [nvarchar](256) NULL,
	[Content] [nvarchar](256) NULL,
	[CreatedBy] [int] NOT NULL,
	[ModifiedBy] [int] NOT NULL,
	[Slug] [nvarchar](50) NULL,
	[EntityTypeId] [int] NULL,
	[StatusId] [nvarchar](10) NOT NULL,
	[BaseMetaData] [int] NULL,
	[Site] [int] NULL,
 CONSTRAINT [PK_@TableName] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TechCompaniesFriends]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TechCompaniesFriends](
	[TechCompanyId] [int] NOT NULL,
	[FriendId] [int] NOT NULL,
 CONSTRAINT [PK_TechCompaniesFriends] PRIMARY KEY CLUSTERED 
(
	[TechCompanyId] ASC,
	[FriendId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TechCompaniesImages]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TechCompaniesImages](
	[TechCompanyId] [int] NOT NULL,
	[ImageId] [int] NOT NULL,
 CONSTRAINT [PK_TechCompaniesImages] PRIMARY KEY CLUSTERED 
(
	[TechCompanyId] ASC,
	[ImageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TechCompaniesTags]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TechCompaniesTags](
	[TechCompanyId] [int] NOT NULL,
	[TagId] [int] NOT NULL,
 CONSTRAINT [PK_TechCompaniesTags] PRIMARY KEY CLUSTERED 
(
	[TechCompanyId] ASC,
	[TagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TechCompaniesUrls]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TechCompaniesUrls](
	[TechCompanyId] [int] NOT NULL,
	[UrlId] [int] NOT NULL,
 CONSTRAINT [PK_TechCompaniesUrls] PRIMARY KEY CLUSTERED 
(
	[TechCompanyId] ASC,
	[UrlId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Urls]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Urls](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[EntityId] [int] NOT NULL,
	[Url] [nvarchar](500) NOT NULL,
	[UserId] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateModified] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Urls] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[Password] [nvarchar](64) NOT NULL,
	[AvatarUrl] [nvarchar](256) NOT NULL,
	[TenantId] [nvarchar](30) NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateModified] [datetime2](7) NOT NULL,
	[Roles] [nvarchar](50) NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [flat].[InstructorsOffices]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [flat].[InstructorsOffices](
	[PersonId] [int] NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[HireDate] [datetime] NOT NULL,
	[Id] [int] NULL,
	[Name] [nvarchar](50) NULL,
	[Number] [nvarchar](10) NULL,
	[DateAssigned] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [flat].[InstructorsOfficesCourses]    Script Date: 6/21/2023 5:25:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [flat].[InstructorsOfficesCourses](
	[PersonId] [int] NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[HireDate] [datetime] NOT NULL,
	[Id] [int] NULL,
	[Name] [nvarchar](50) NULL,
	[Number] [nvarchar](10) NULL,
	[DateAssigned] [datetime] NULL,
	[CourseId] [int] NULL,
	[Title] [nvarchar](100) NULL,
	[Credits] [int] NULL,
	[DepartmentId] [int] NULL
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[AbstractValues] ON 

INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (1, 1)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (2, 44)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (3, 66)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (4, 55)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (5, 88)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (6, 99)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (7, 123)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (8, 143)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (9, 178)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (10, 37)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (11, 89)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (12, 36)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (13, 223)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (14, 310)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (15, 175)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (16, 209)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (17, 333)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (18, 118)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (19, 66)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (20, 77)
INSERT [dbo].[AbstractValues] ([id], [someValue]) VALUES (21, 86)
SET IDENTITY_INSERT [dbo].[AbstractValues] OFF
GO
SET IDENTITY_INSERT [dbo].[Cars] ON 

INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (1, N'Toyota', N'Celica', 2008, 1, 1, CAST(N'2023-04-17T17:58:54.9833333' AS DateTime2), CAST(N'2023-04-17T17:58:54.9833333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (2, N'Toyota', N'Camry', 2005, 1, 1, CAST(N'2023-04-17T17:59:13.3333333' AS DateTime2), CAST(N'2023-04-17T17:59:13.3333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (3, N'Toyota', N'Tacoma', 2023, 0, 1, CAST(N'2023-04-17T17:59:33.2066667' AS DateTime2), CAST(N'2023-04-17T17:59:33.2066667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (4, N'Nissan', N'Altima', 2012, 1, 2, CAST(N'2023-04-17T17:59:59.0766667' AS DateTime2), CAST(N'2023-04-17T17:59:59.0766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (5, N'Ford', N'Taurus', 2023, 0, 3, CAST(N'2023-04-17T18:00:19.0600000' AS DateTime2), CAST(N'2023-04-17T18:00:19.0600000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (6, N'Ford', N'Ranger', 2001, 1, 3, CAST(N'2023-04-17T18:00:32.3000000' AS DateTime2), CAST(N'2023-04-17T18:00:32.3000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (7, N'Chevrolet', N'Suburban', 2007, 1, 4, CAST(N'2023-04-17T18:00:56.2300000' AS DateTime2), CAST(N'2023-04-17T18:00:56.2300000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (8, N'Chevrolet', N'Spark', 2017, 1, 4, CAST(N'2023-04-17T18:01:10.9733333' AS DateTime2), CAST(N'2023-04-17T18:01:10.9733333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (9, N'Chevy', N'Tahoe LTD', 2023, 1, 4, CAST(N'2023-04-17T18:01:24.1966667' AS DateTime2), CAST(N'2023-04-17T18:33:57.6700000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (11, N'Sabio Make', N'Sabio Model', 2022, 0, 6, CAST(N'2023-04-17T18:32:19.6366667' AS DateTime2), CAST(N'2023-04-17T18:32:19.6366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (12, N'Sabio Make', N'Sabio Model', 1926, 0, 7, CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2), CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (13, N'Sabio Make', N'Sabio Model', 1926, 0, 7, CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2), CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (14, N'Sabio Make', N'Sabio Model', 1926, 0, 7, CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2), CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (15, N'Sabio Make', N'Sabio Model', 1926, 0, 7, CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2), CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (16, N'Sabio Make', N'Sabio Model', 1926, 0, 7, CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2), CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (17, N'Sabio Make4162', N'Sabio Model', 2022, 0, 8, CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2), CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (18, N'Sabio Make4162', N'Sabio Model', 2022, 0, 8, CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2), CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (19, N'Sabio Make4162', N'Sabio Model', 2022, 0, 8, CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2), CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (20, N'Sabio Make4162', N'Sabio Model', 2022, 0, 8, CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2), CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (22, N'Sabio Make4373', N'Sabio Model4373', 1911, 0, 9, CAST(N'2023-04-17T18:32:19.6666667' AS DateTime2), CAST(N'2023-04-17T18:32:20.6833333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (24, N'Sabio Make', N'Sabio Model', 2022, 0, 11, CAST(N'2023-04-17T18:33:02.9566667' AS DateTime2), CAST(N'2023-04-17T18:33:02.9566667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (25, N'Sabio Make', N'Sabio Model', 1906, 0, 12, CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2), CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (26, N'Sabio Make', N'Sabio Model', 1906, 0, 12, CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2), CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (27, N'Sabio Make', N'Sabio Model', 1906, 0, 12, CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2), CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (28, N'Sabio Make', N'Sabio Model', 1906, 0, 12, CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2), CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (29, N'Sabio Make', N'Sabio Model', 1906, 0, 12, CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2), CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (30, N'Sabio Make5464', N'Sabio Model', 2022, 0, 13, CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2), CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (31, N'Sabio Make5464', N'Sabio Model', 2022, 0, 13, CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2), CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (32, N'Sabio Make5464', N'Sabio Model', 2022, 0, 13, CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2), CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (33, N'Sabio Make5464', N'Sabio Model', 2022, 0, 13, CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2), CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (34, N'Sabio Make5464', N'Sabio Model', 2022, 0, 13, CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2), CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (35, N'Sabio Make3854', N'Sabio Model3854', 2000, 0, 14, CAST(N'2023-04-17T18:33:02.9866667' AS DateTime2), CAST(N'2023-04-17T18:33:04.0000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (37, N'Sabio Make', N'Sabio Model', 2022, 0, 16, CAST(N'2023-04-17T18:34:06.8900000' AS DateTime2), CAST(N'2023-04-17T18:34:06.8900000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (38, N'Sabio Make', N'Sabio Model', 1971, 0, 17, CAST(N'2023-04-17T18:34:06.8900000' AS DateTime2), CAST(N'2023-04-17T18:34:06.8900000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (39, N'Sabio Make', N'Sabio Model', 1971, 0, 17, CAST(N'2023-04-17T18:34:06.8900000' AS DateTime2), CAST(N'2023-04-17T18:34:06.8900000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (40, N'Sabio Make', N'Sabio Model', 1971, 0, 17, CAST(N'2023-04-17T18:34:06.8900000' AS DateTime2), CAST(N'2023-04-17T18:34:06.8900000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (41, N'Sabio Make', N'Sabio Model', 1971, 0, 17, CAST(N'2023-04-17T18:34:06.8900000' AS DateTime2), CAST(N'2023-04-17T18:34:06.8900000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (42, N'Sabio Make', N'Sabio Model', 1971, 0, 17, CAST(N'2023-04-17T18:34:06.8900000' AS DateTime2), CAST(N'2023-04-17T18:34:06.8900000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (43, N'Sabio Make4919', N'Sabio Model', 2022, 0, 18, CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2), CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (44, N'Sabio Make4919', N'Sabio Model', 2022, 0, 18, CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2), CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (45, N'Sabio Make4919', N'Sabio Model', 2022, 0, 18, CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2), CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (46, N'Sabio Make4919', N'Sabio Model', 2022, 0, 18, CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2), CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (47, N'Sabio Make4919', N'Sabio Model', 2022, 0, 18, CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2), CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (48, N'Sabio Make1034', N'Sabio Model1034', 1990, 0, 19, CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2), CAST(N'2023-04-17T18:34:07.9233333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (49, N'Sabio Make', N'Sabio Model', 2022, 1, 20, CAST(N'2023-04-17T18:34:07.9233333' AS DateTime2), CAST(N'2023-04-17T18:34:08.9400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (51, N'Sabio Make', N'Sabio Model', 2022, 0, 22, CAST(N'2023-04-17T18:36:32.4100000' AS DateTime2), CAST(N'2023-04-17T18:36:32.4100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (52, N'Sabio Make', N'Sabio Model', 1912, 0, 23, CAST(N'2023-04-17T18:36:32.4266667' AS DateTime2), CAST(N'2023-04-17T18:36:32.4266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (53, N'Sabio Make', N'Sabio Model', 1912, 0, 23, CAST(N'2023-04-17T18:36:32.4266667' AS DateTime2), CAST(N'2023-04-17T18:36:32.4266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (54, N'Sabio Make', N'Sabio Model', 1912, 0, 23, CAST(N'2023-04-17T18:36:32.4266667' AS DateTime2), CAST(N'2023-04-17T18:36:32.4266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (55, N'Sabio Make', N'Sabio Model', 1912, 0, 23, CAST(N'2023-04-17T18:36:32.4266667' AS DateTime2), CAST(N'2023-04-17T18:36:32.4266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (56, N'Sabio Make', N'Sabio Model', 1912, 0, 23, CAST(N'2023-04-17T18:36:32.4266667' AS DateTime2), CAST(N'2023-04-17T18:36:32.4266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (57, N'Sabio Make1543', N'Sabio Model', 2022, 0, 24, CAST(N'2023-04-17T18:36:32.4433333' AS DateTime2), CAST(N'2023-04-17T18:36:32.4433333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (58, N'Sabio Make1543', N'Sabio Model', 2022, 0, 24, CAST(N'2023-04-17T18:36:32.4433333' AS DateTime2), CAST(N'2023-04-17T18:36:32.4433333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (59, N'Sabio Make1543', N'Sabio Model', 2022, 0, 24, CAST(N'2023-04-17T18:36:32.4433333' AS DateTime2), CAST(N'2023-04-17T18:36:32.4433333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (60, N'Sabio Make1543', N'Sabio Model', 2022, 0, 24, CAST(N'2023-04-17T18:36:32.4433333' AS DateTime2), CAST(N'2023-04-17T18:36:32.4433333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (61, N'Sabio Make1543', N'Sabio Model', 2022, 0, 24, CAST(N'2023-04-17T18:36:32.4433333' AS DateTime2), CAST(N'2023-04-17T18:36:32.4433333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (62, N'Sabio Make4684', N'Sabio Model4684', 1943, 0, 25, CAST(N'2023-04-17T18:36:32.4433333' AS DateTime2), CAST(N'2023-04-17T18:36:33.4600000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (63, N'Sabio Make', N'Sabio Model', 2022, 1, 26, CAST(N'2023-04-17T18:36:33.4766667' AS DateTime2), CAST(N'2023-04-17T18:36:34.4766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (66, N'Sabio Make', N'Sabio Model', 2022, 0, 29, CAST(N'2023-04-17T18:42:11.8400000' AS DateTime2), CAST(N'2023-04-17T18:42:11.8400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (67, N'Sabio Make', N'Sabio Model', 1964, 0, 30, CAST(N'2023-04-17T18:42:11.8400000' AS DateTime2), CAST(N'2023-04-17T18:42:11.8400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (68, N'Sabio Make', N'Sabio Model', 1964, 0, 30, CAST(N'2023-04-17T18:42:11.8400000' AS DateTime2), CAST(N'2023-04-17T18:42:11.8400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (69, N'Sabio Make', N'Sabio Model', 1964, 0, 30, CAST(N'2023-04-17T18:42:11.8400000' AS DateTime2), CAST(N'2023-04-17T18:42:11.8400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (70, N'Sabio Make', N'Sabio Model', 1964, 0, 30, CAST(N'2023-04-17T18:42:11.8400000' AS DateTime2), CAST(N'2023-04-17T18:42:11.8400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (71, N'Sabio Make', N'Sabio Model', 1964, 0, 30, CAST(N'2023-04-17T18:42:11.8400000' AS DateTime2), CAST(N'2023-04-17T18:42:11.8400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (72, N'Sabio Make3571', N'Sabio Model', 2022, 0, 31, CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2), CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (73, N'Sabio Make3571', N'Sabio Model', 2022, 0, 31, CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2), CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (74, N'Sabio Make3571', N'Sabio Model', 2022, 0, 31, CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2), CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (75, N'Sabio Make3571', N'Sabio Model', 2022, 0, 31, CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2), CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (76, N'Sabio Make3571', N'Sabio Model', 2022, 0, 31, CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2), CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (77, N'Sabio Make4636', N'Sabio Model4636', 1954, 0, 32, CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2), CAST(N'2023-04-17T18:42:12.8800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (78, N'Sabio Make', N'Sabio Model', 2022, 1, 33, CAST(N'2023-04-17T18:42:12.8800000' AS DateTime2), CAST(N'2023-04-17T18:42:13.8933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (81, N'Sabio Make', N'Sabio Model', 2022, 0, 36, CAST(N'2023-04-17T18:42:45.3000000' AS DateTime2), CAST(N'2023-04-17T18:42:45.3000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (82, N'Sabio Make', N'Sabio Model', 2003, 0, 37, CAST(N'2023-04-17T18:42:45.3000000' AS DateTime2), CAST(N'2023-04-17T18:42:45.3000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (83, N'Sabio Make', N'Sabio Model', 2003, 0, 37, CAST(N'2023-04-17T18:42:45.3000000' AS DateTime2), CAST(N'2023-04-17T18:42:45.3000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (84, N'Sabio Make', N'Sabio Model', 2003, 0, 37, CAST(N'2023-04-17T18:42:45.3000000' AS DateTime2), CAST(N'2023-04-17T18:42:45.3000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (85, N'Sabio Make', N'Sabio Model', 2003, 0, 37, CAST(N'2023-04-17T18:42:45.3000000' AS DateTime2), CAST(N'2023-04-17T18:42:45.3000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (86, N'Sabio Make', N'Sabio Model', 2003, 0, 37, CAST(N'2023-04-17T18:42:45.3000000' AS DateTime2), CAST(N'2023-04-17T18:42:45.3000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (87, N'Sabio Make4884', N'Sabio Model', 2022, 0, 38, CAST(N'2023-04-17T18:42:45.3166667' AS DateTime2), CAST(N'2023-04-17T18:42:45.3166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (88, N'Sabio Make4884', N'Sabio Model', 2022, 0, 38, CAST(N'2023-04-17T18:42:45.3166667' AS DateTime2), CAST(N'2023-04-17T18:42:45.3166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (89, N'Sabio Make4884', N'Sabio Model', 2022, 0, 38, CAST(N'2023-04-17T18:42:45.3166667' AS DateTime2), CAST(N'2023-04-17T18:42:45.3166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (90, N'Sabio Make4884', N'Sabio Model', 2022, 0, 38, CAST(N'2023-04-17T18:42:45.3166667' AS DateTime2), CAST(N'2023-04-17T18:42:45.3166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (91, N'Sabio Make4884', N'Sabio Model', 2022, 0, 38, CAST(N'2023-04-17T18:42:45.3166667' AS DateTime2), CAST(N'2023-04-17T18:42:45.3166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (92, N'Sabio Make4828', N'Sabio Model4828', 1922, 0, 39, CAST(N'2023-04-17T18:42:45.3300000' AS DateTime2), CAST(N'2023-04-17T18:42:46.3466667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (93, N'Sabio Make', N'Sabio Model', 2022, 1, 40, CAST(N'2023-04-17T18:42:46.3466667' AS DateTime2), CAST(N'2023-04-17T18:42:47.3666667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (95, N'Sabio Make', N'Sabio Model', 2022, 0, 42, CAST(N'2023-04-17T18:42:47.4000000' AS DateTime2), CAST(N'2023-04-17T18:42:47.4000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (96, N'Sabio Make', N'Sabio Model', 2022, 0, 42, CAST(N'2023-04-17T18:42:47.4000000' AS DateTime2), CAST(N'2023-04-17T18:42:47.4000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (97, N'Sabio Make', N'Sabio Model', 2022, 0, 42, CAST(N'2023-04-17T18:42:47.4000000' AS DateTime2), CAST(N'2023-04-17T18:42:47.4000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (98, N'Sabio Make', N'Sabio Model', 2022, 0, 42, CAST(N'2023-04-17T18:42:47.4000000' AS DateTime2), CAST(N'2023-04-17T18:42:47.4000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (99, N'Sabio Make', N'Sabio Model', 2022, 0, 42, CAST(N'2023-04-17T18:42:47.4000000' AS DateTime2), CAST(N'2023-04-17T18:42:47.4000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (101, N'Sabio Make', N'Sabio Model', 2022, 0, 44, CAST(N'2023-04-17T18:45:57.8433333' AS DateTime2), CAST(N'2023-04-17T18:45:57.8433333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (102, N'Sabio Make', N'Sabio Model', 2003, 0, 45, CAST(N'2023-04-17T18:45:57.8600000' AS DateTime2), CAST(N'2023-04-17T18:45:57.8600000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (103, N'Sabio Make', N'Sabio Model', 2003, 0, 45, CAST(N'2023-04-17T18:45:57.8600000' AS DateTime2), CAST(N'2023-04-17T18:45:57.8600000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (104, N'Sabio Make', N'Sabio Model', 2003, 0, 45, CAST(N'2023-04-17T18:45:57.8600000' AS DateTime2), CAST(N'2023-04-17T18:45:57.8600000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (105, N'Sabio Make', N'Sabio Model', 2003, 0, 45, CAST(N'2023-04-17T18:45:57.8600000' AS DateTime2), CAST(N'2023-04-17T18:45:57.8600000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (106, N'Sabio Make', N'Sabio Model', 2003, 0, 45, CAST(N'2023-04-17T18:45:57.8600000' AS DateTime2), CAST(N'2023-04-17T18:45:57.8600000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (107, N'Sabio Make5641', N'Sabio Model', 2022, 0, 46, CAST(N'2023-04-17T18:45:57.8766667' AS DateTime2), CAST(N'2023-04-17T18:45:57.8766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (108, N'Sabio Make5641', N'Sabio Model', 2022, 0, 46, CAST(N'2023-04-17T18:45:57.8766667' AS DateTime2), CAST(N'2023-04-17T18:45:57.8766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (109, N'Sabio Make5641', N'Sabio Model', 2022, 0, 46, CAST(N'2023-04-17T18:45:57.8766667' AS DateTime2), CAST(N'2023-04-17T18:45:57.8766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (110, N'Sabio Make5641', N'Sabio Model', 2022, 0, 46, CAST(N'2023-04-17T18:45:57.8766667' AS DateTime2), CAST(N'2023-04-17T18:45:57.8766667' AS DateTime2))
GO
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (111, N'Sabio Make5641', N'Sabio Model', 2022, 0, 46, CAST(N'2023-04-17T18:45:57.8766667' AS DateTime2), CAST(N'2023-04-17T18:45:57.8766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (112, N'Sabio Make5511', N'Sabio Model5511', 1940, 0, 47, CAST(N'2023-04-17T18:45:57.8900000' AS DateTime2), CAST(N'2023-04-17T18:45:58.8900000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (113, N'Sabio Make', N'Sabio Model', 2022, 1, 48, CAST(N'2023-04-17T18:45:58.9066667' AS DateTime2), CAST(N'2023-04-17T18:45:59.9233333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (115, N'Sabio Make', N'Sabio Model', 2022, 0, 50, CAST(N'2023-04-17T18:45:59.9366667' AS DateTime2), CAST(N'2023-04-17T18:45:59.9366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (116, N'Sabio Make', N'Sabio Model', 2022, 0, 50, CAST(N'2023-04-17T18:45:59.9366667' AS DateTime2), CAST(N'2023-04-17T18:45:59.9366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (117, N'Sabio Make', N'Sabio Model', 2022, 0, 50, CAST(N'2023-04-17T18:45:59.9366667' AS DateTime2), CAST(N'2023-04-17T18:45:59.9366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (118, N'Sabio Make', N'Sabio Model', 2022, 0, 50, CAST(N'2023-04-17T18:45:59.9366667' AS DateTime2), CAST(N'2023-04-17T18:45:59.9366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (119, N'Sabio Make', N'Sabio Model', 2022, 0, 50, CAST(N'2023-04-17T18:45:59.9366667' AS DateTime2), CAST(N'2023-04-17T18:45:59.9366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (120, N'Sabio Make', N'Sabio Model', 2022, 0, 51, CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2), CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (121, N'Sabio Make', N'Sabio Model', 2022, 0, 51, CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2), CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (122, N'Sabio Make', N'Sabio Model', 2022, 0, 51, CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2), CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (123, N'Sabio Make', N'Sabio Model', 2022, 0, 51, CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2), CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (124, N'Sabio Make', N'Sabio Model', 2022, 0, 51, CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2), CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (125, N'Sabio Make', N'Sabio Model', 2022, 1, 51, CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2), CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (126, N'Sabio Make', N'Sabio Model', 2022, 1, 51, CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2), CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (127, N'Sabio Make', N'Sabio Model', 2022, 1, 51, CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2), CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (128, N'Sabio Make', N'Sabio Model', 2022, 1, 51, CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2), CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (129, N'Sabio Make', N'Sabio Model', 2022, 1, 51, CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2), CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (131, N'Sabio Make', N'Sabio Model', 2022, 0, 53, CAST(N'2023-04-17T18:53:22.7000000' AS DateTime2), CAST(N'2023-04-17T18:53:22.7000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (132, N'Sabio Make', N'Sabio Model', 2004, 0, 54, CAST(N'2023-04-17T18:53:22.7166667' AS DateTime2), CAST(N'2023-04-17T18:53:22.7166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (133, N'Sabio Make', N'Sabio Model', 2004, 0, 54, CAST(N'2023-04-17T18:53:22.7166667' AS DateTime2), CAST(N'2023-04-17T18:53:22.7166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (134, N'Sabio Make', N'Sabio Model', 2004, 0, 54, CAST(N'2023-04-17T18:53:22.7166667' AS DateTime2), CAST(N'2023-04-17T18:53:22.7166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (135, N'Sabio Make', N'Sabio Model', 2004, 0, 54, CAST(N'2023-04-17T18:53:22.7166667' AS DateTime2), CAST(N'2023-04-17T18:53:22.7166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (136, N'Sabio Make', N'Sabio Model', 2004, 0, 54, CAST(N'2023-04-17T18:53:22.7166667' AS DateTime2), CAST(N'2023-04-17T18:53:22.7166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (137, N'Sabio Make1750', N'Sabio Model', 2022, 0, 55, CAST(N'2023-04-17T18:53:22.7300000' AS DateTime2), CAST(N'2023-04-17T18:53:22.7300000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (138, N'Sabio Make1750', N'Sabio Model', 2022, 0, 55, CAST(N'2023-04-17T18:53:22.7300000' AS DateTime2), CAST(N'2023-04-17T18:53:22.7300000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (139, N'Sabio Make1750', N'Sabio Model', 2022, 0, 55, CAST(N'2023-04-17T18:53:22.7300000' AS DateTime2), CAST(N'2023-04-17T18:53:22.7300000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (140, N'Sabio Make1750', N'Sabio Model', 2022, 0, 55, CAST(N'2023-04-17T18:53:22.7300000' AS DateTime2), CAST(N'2023-04-17T18:53:22.7300000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (141, N'Sabio Make1750', N'Sabio Model', 2022, 0, 55, CAST(N'2023-04-17T18:53:22.7300000' AS DateTime2), CAST(N'2023-04-17T18:53:22.7300000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (142, N'Sabio Make7012', N'Sabio Model7012', 1926, 0, 56, CAST(N'2023-04-17T18:53:22.7466667' AS DateTime2), CAST(N'2023-04-17T18:53:23.7733333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (143, N'Sabio Make', N'Sabio Model', 2022, 1, 57, CAST(N'2023-04-17T18:53:23.7733333' AS DateTime2), CAST(N'2023-04-17T18:53:24.8033333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (145, N'Sabio Make', N'Sabio Model', 2022, 0, 59, CAST(N'2023-04-17T18:53:24.8200000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (146, N'Sabio Make', N'Sabio Model', 2022, 0, 59, CAST(N'2023-04-17T18:53:24.8200000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (147, N'Sabio Make', N'Sabio Model', 2022, 0, 59, CAST(N'2023-04-17T18:53:24.8200000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (148, N'Sabio Make', N'Sabio Model', 2022, 0, 59, CAST(N'2023-04-17T18:53:24.8200000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (149, N'Sabio Make', N'Sabio Model', 2022, 0, 59, CAST(N'2023-04-17T18:53:24.8200000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (150, N'Sabio Make', N'Sabio Model', 2022, 0, 60, CAST(N'2023-04-17T18:53:24.8366667' AS DateTime2), CAST(N'2023-04-17T18:53:24.8366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (151, N'Sabio Make', N'Sabio Model', 2022, 0, 60, CAST(N'2023-04-17T18:53:24.8366667' AS DateTime2), CAST(N'2023-04-17T18:53:24.8366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (152, N'Sabio Make', N'Sabio Model', 2022, 0, 60, CAST(N'2023-04-17T18:53:24.8366667' AS DateTime2), CAST(N'2023-04-17T18:53:24.8366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (153, N'Sabio Make', N'Sabio Model', 2022, 0, 60, CAST(N'2023-04-17T18:53:24.8366667' AS DateTime2), CAST(N'2023-04-17T18:53:24.8366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (154, N'Sabio Make', N'Sabio Model', 2022, 0, 60, CAST(N'2023-04-17T18:53:24.8366667' AS DateTime2), CAST(N'2023-04-17T18:53:24.8366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (155, N'Sabio Make', N'Sabio Model', 2022, 1, 60, CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (156, N'Sabio Make', N'Sabio Model', 2022, 1, 60, CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (157, N'Sabio Make', N'Sabio Model', 2022, 1, 60, CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (158, N'Sabio Make', N'Sabio Model', 2022, 1, 60, CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (159, N'Sabio Make', N'Sabio Model', 2022, 1, 60, CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (160, N'Sabio Make', N'Sabio Model', 2022, 0, 61, CAST(N'2023-04-17T18:53:24.8666667' AS DateTime2), CAST(N'2023-04-17T18:53:24.8666667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (162, N'Sabio Make', N'Sabio Model', 2022, 0, 63, CAST(N'2023-04-17T18:54:29.9800000' AS DateTime2), CAST(N'2023-04-17T18:54:29.9800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (163, N'Sabio Make', N'Sabio Model', 1954, 0, 64, CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2), CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (164, N'Sabio Make', N'Sabio Model', 1954, 0, 64, CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2), CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (165, N'Sabio Make', N'Sabio Model', 1954, 0, 64, CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2), CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (166, N'Sabio Make', N'Sabio Model', 1954, 0, 64, CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2), CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (167, N'Sabio Make', N'Sabio Model', 1954, 0, 64, CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2), CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (168, N'Sabio Make7073', N'Sabio Model', 2022, 0, 65, CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2), CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (169, N'Sabio Make7073', N'Sabio Model', 2022, 0, 65, CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2), CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (170, N'Sabio Make7073', N'Sabio Model', 2022, 0, 65, CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2), CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (171, N'Sabio Make7073', N'Sabio Model', 2022, 0, 65, CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2), CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (172, N'Sabio Make7073', N'Sabio Model', 2022, 0, 65, CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2), CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (173, N'Sabio Make2363', N'Sabio Model2363', 1911, 0, 66, CAST(N'2023-04-17T18:54:30.0166667' AS DateTime2), CAST(N'2023-04-17T18:54:31.0333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (174, N'Sabio Make', N'Sabio Model', 2022, 1, 67, CAST(N'2023-04-17T18:54:31.0500000' AS DateTime2), CAST(N'2023-04-17T18:54:32.0500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (176, N'Sabio Make', N'Sabio Model', 2022, 0, 69, CAST(N'2023-04-17T18:54:32.0800000' AS DateTime2), CAST(N'2023-04-17T18:54:32.0800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (177, N'Sabio Make', N'Sabio Model', 2022, 0, 69, CAST(N'2023-04-17T18:54:32.0800000' AS DateTime2), CAST(N'2023-04-17T18:54:32.0800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (178, N'Sabio Make', N'Sabio Model', 2022, 0, 69, CAST(N'2023-04-17T18:54:32.0800000' AS DateTime2), CAST(N'2023-04-17T18:54:32.0800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (179, N'Sabio Make', N'Sabio Model', 2022, 0, 69, CAST(N'2023-04-17T18:54:32.0800000' AS DateTime2), CAST(N'2023-04-17T18:54:32.0800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (180, N'Sabio Make', N'Sabio Model', 2022, 0, 69, CAST(N'2023-04-17T18:54:32.0800000' AS DateTime2), CAST(N'2023-04-17T18:54:32.0800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (181, N'Sabio Make', N'Sabio Model', 2022, 0, 70, CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2), CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (182, N'Sabio Make', N'Sabio Model', 2022, 0, 70, CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2), CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (183, N'Sabio Make', N'Sabio Model', 2022, 0, 70, CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2), CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (184, N'Sabio Make', N'Sabio Model', 2022, 0, 70, CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2), CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (185, N'Sabio Make', N'Sabio Model', 2022, 0, 70, CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2), CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (186, N'Sabio Make', N'Sabio Model', 2022, 1, 70, CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2), CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (187, N'Sabio Make', N'Sabio Model', 2022, 1, 70, CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2), CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (188, N'Sabio Make', N'Sabio Model', 2022, 1, 70, CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2), CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (189, N'Sabio Make', N'Sabio Model', 2022, 1, 70, CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2), CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (190, N'Sabio Make', N'Sabio Model', 2022, 1, 70, CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2), CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (191, N'Sabio Make', N'Sabio Model', 2022, 0, 71, CAST(N'2023-04-17T18:54:32.1100000' AS DateTime2), CAST(N'2023-04-17T18:54:32.1100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (193, N'Sabio Make', N'Sabio Model', 2022, 0, 73, CAST(N'2023-04-17T18:55:18.9866667' AS DateTime2), CAST(N'2023-04-17T18:55:18.9866667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (194, N'Sabio Make', N'Sabio Model', 1989, 0, 74, CAST(N'2023-04-17T18:55:18.9866667' AS DateTime2), CAST(N'2023-04-17T18:55:18.9866667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (195, N'Sabio Make', N'Sabio Model', 1989, 0, 74, CAST(N'2023-04-17T18:55:18.9866667' AS DateTime2), CAST(N'2023-04-17T18:55:18.9866667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (196, N'Sabio Make', N'Sabio Model', 1989, 0, 74, CAST(N'2023-04-17T18:55:18.9866667' AS DateTime2), CAST(N'2023-04-17T18:55:18.9866667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (197, N'Sabio Make', N'Sabio Model', 1989, 0, 74, CAST(N'2023-04-17T18:55:18.9866667' AS DateTime2), CAST(N'2023-04-17T18:55:18.9866667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (198, N'Sabio Make', N'Sabio Model', 1989, 0, 74, CAST(N'2023-04-17T18:55:18.9866667' AS DateTime2), CAST(N'2023-04-17T18:55:18.9866667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (199, N'Sabio Make7381', N'Sabio Model', 2022, 0, 75, CAST(N'2023-04-17T18:55:19.0033333' AS DateTime2), CAST(N'2023-04-17T18:55:19.0033333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (200, N'Sabio Make7381', N'Sabio Model', 2022, 0, 75, CAST(N'2023-04-17T18:55:19.0033333' AS DateTime2), CAST(N'2023-04-17T18:55:19.0033333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (201, N'Sabio Make7381', N'Sabio Model', 2022, 0, 75, CAST(N'2023-04-17T18:55:19.0033333' AS DateTime2), CAST(N'2023-04-17T18:55:19.0033333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (202, N'Sabio Make7381', N'Sabio Model', 2022, 0, 75, CAST(N'2023-04-17T18:55:19.0033333' AS DateTime2), CAST(N'2023-04-17T18:55:19.0033333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (203, N'Sabio Make7381', N'Sabio Model', 2022, 0, 75, CAST(N'2023-04-17T18:55:19.0033333' AS DateTime2), CAST(N'2023-04-17T18:55:19.0033333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (204, N'Sabio Make9891', N'Sabio Model9891', 1949, 0, 76, CAST(N'2023-04-17T18:55:19.0200000' AS DateTime2), CAST(N'2023-04-17T18:55:20.0333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (205, N'Sabio Make', N'Sabio Model', 2022, 1, 77, CAST(N'2023-04-17T18:55:20.0333333' AS DateTime2), CAST(N'2023-04-17T18:55:21.0666667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (207, N'Sabio Make', N'Sabio Model', 2022, 0, 79, CAST(N'2023-04-17T18:55:21.0800000' AS DateTime2), CAST(N'2023-04-17T18:55:21.0800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (208, N'Sabio Make', N'Sabio Model', 2022, 0, 79, CAST(N'2023-04-17T18:55:21.0800000' AS DateTime2), CAST(N'2023-04-17T18:55:21.0800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (209, N'Sabio Make', N'Sabio Model', 2022, 0, 79, CAST(N'2023-04-17T18:55:21.0800000' AS DateTime2), CAST(N'2023-04-17T18:55:21.0800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (210, N'Sabio Make', N'Sabio Model', 2022, 0, 79, CAST(N'2023-04-17T18:55:21.0800000' AS DateTime2), CAST(N'2023-04-17T18:55:21.0800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (211, N'Sabio Make', N'Sabio Model', 2022, 0, 79, CAST(N'2023-04-17T18:55:21.0800000' AS DateTime2), CAST(N'2023-04-17T18:55:21.0800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (212, N'Sabio Make', N'Sabio Model', 2022, 0, 80, CAST(N'2023-04-17T18:55:21.0966667' AS DateTime2), CAST(N'2023-04-17T18:55:21.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (213, N'Sabio Make', N'Sabio Model', 2022, 0, 80, CAST(N'2023-04-17T18:55:21.0966667' AS DateTime2), CAST(N'2023-04-17T18:55:21.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (214, N'Sabio Make', N'Sabio Model', 2022, 0, 80, CAST(N'2023-04-17T18:55:21.0966667' AS DateTime2), CAST(N'2023-04-17T18:55:21.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (215, N'Sabio Make', N'Sabio Model', 2022, 0, 80, CAST(N'2023-04-17T18:55:21.0966667' AS DateTime2), CAST(N'2023-04-17T18:55:21.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (216, N'Sabio Make', N'Sabio Model', 2022, 0, 80, CAST(N'2023-04-17T18:55:21.0966667' AS DateTime2), CAST(N'2023-04-17T18:55:21.0966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (217, N'Sabio Make', N'Sabio Model', 2022, 1, 80, CAST(N'2023-04-17T18:55:21.1133333' AS DateTime2), CAST(N'2023-04-17T18:55:21.1133333' AS DateTime2))
GO
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (218, N'Sabio Make', N'Sabio Model', 2022, 1, 80, CAST(N'2023-04-17T18:55:21.1133333' AS DateTime2), CAST(N'2023-04-17T18:55:21.1133333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (219, N'Sabio Make', N'Sabio Model', 2022, 1, 80, CAST(N'2023-04-17T18:55:21.1133333' AS DateTime2), CAST(N'2023-04-17T18:55:21.1133333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (220, N'Sabio Make', N'Sabio Model', 2022, 1, 80, CAST(N'2023-04-17T18:55:21.1133333' AS DateTime2), CAST(N'2023-04-17T18:55:21.1133333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (221, N'Sabio Make', N'Sabio Model', 2022, 1, 80, CAST(N'2023-04-17T18:55:21.1133333' AS DateTime2), CAST(N'2023-04-17T18:55:21.1133333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (222, N'Sabio Make', N'Sabio Model', 2022, 0, 81, CAST(N'2023-04-17T18:55:21.1300000' AS DateTime2), CAST(N'2023-04-17T18:55:21.1300000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (224, N'Sabio Make', N'Sabio Model', 2022, 0, 83, CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2), CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (225, N'Sabio Make', N'Sabio Model', 1956, 0, 84, CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2), CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (226, N'Sabio Make', N'Sabio Model', 1956, 0, 84, CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2), CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (227, N'Sabio Make', N'Sabio Model', 1956, 0, 84, CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2), CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (228, N'Sabio Make', N'Sabio Model', 1956, 0, 84, CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2), CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (229, N'Sabio Make', N'Sabio Model', 1956, 0, 84, CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2), CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (230, N'Sabio Make1019', N'Sabio Model', 2022, 0, 85, CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2), CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (231, N'Sabio Make1019', N'Sabio Model', 2022, 0, 85, CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2), CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (232, N'Sabio Make1019', N'Sabio Model', 2022, 0, 85, CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2), CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (233, N'Sabio Make1019', N'Sabio Model', 2022, 0, 85, CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2), CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (234, N'Sabio Make1019', N'Sabio Model', 2022, 0, 85, CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2), CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (235, N'Sabio Make2628', N'Sabio Model2628', 2004, 0, 86, CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2), CAST(N'2023-04-17T18:57:27.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (236, N'Sabio Make', N'Sabio Model', 2022, 1, 87, CAST(N'2023-04-17T18:57:27.2100000' AS DateTime2), CAST(N'2023-04-17T18:57:28.2266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (238, N'Sabio Make', N'Sabio Model', 2022, 0, 89, CAST(N'2023-04-17T18:57:28.2566667' AS DateTime2), CAST(N'2023-04-17T18:57:28.2566667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (239, N'Sabio Make', N'Sabio Model', 2022, 0, 89, CAST(N'2023-04-17T18:57:28.2566667' AS DateTime2), CAST(N'2023-04-17T18:57:28.2566667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (240, N'Sabio Make', N'Sabio Model', 2022, 0, 89, CAST(N'2023-04-17T18:57:28.2566667' AS DateTime2), CAST(N'2023-04-17T18:57:28.2566667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (241, N'Sabio Make', N'Sabio Model', 2022, 0, 89, CAST(N'2023-04-17T18:57:28.2566667' AS DateTime2), CAST(N'2023-04-17T18:57:28.2566667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (242, N'Sabio Make', N'Sabio Model', 2022, 0, 89, CAST(N'2023-04-17T18:57:28.2566667' AS DateTime2), CAST(N'2023-04-17T18:57:28.2566667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (243, N'Sabio Make', N'Sabio Model', 2022, 0, 90, CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2), CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (244, N'Sabio Make', N'Sabio Model', 2022, 0, 90, CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2), CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (245, N'Sabio Make', N'Sabio Model', 2022, 0, 90, CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2), CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (246, N'Sabio Make', N'Sabio Model', 2022, 0, 90, CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2), CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (247, N'Sabio Make', N'Sabio Model', 2022, 0, 90, CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2), CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (248, N'Sabio Make', N'Sabio Model', 2022, 1, 90, CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2), CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (249, N'Sabio Make', N'Sabio Model', 2022, 1, 90, CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2), CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (250, N'Sabio Make', N'Sabio Model', 2022, 1, 90, CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2), CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (251, N'Sabio Make', N'Sabio Model', 2022, 1, 90, CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2), CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (252, N'Sabio Make', N'Sabio Model', 2022, 1, 90, CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2), CAST(N'2023-04-17T18:57:28.2733333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (253, N'Sabio Make', N'Sabio Model', 2022, 0, 91, CAST(N'2023-04-17T18:57:28.3033333' AS DateTime2), CAST(N'2023-04-17T18:57:28.3033333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (255, N'Sabio Make', N'Sabio Model', 2022, 0, 93, CAST(N'2023-04-17T18:59:05.5033333' AS DateTime2), CAST(N'2023-04-17T18:59:05.5033333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (256, N'Sabio Make', N'Sabio Model', 1969, 0, 94, CAST(N'2023-04-17T18:59:05.5200000' AS DateTime2), CAST(N'2023-04-17T18:59:05.5200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (257, N'Sabio Make', N'Sabio Model', 1969, 0, 94, CAST(N'2023-04-17T18:59:05.5200000' AS DateTime2), CAST(N'2023-04-17T18:59:05.5200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (258, N'Sabio Make', N'Sabio Model', 1969, 0, 94, CAST(N'2023-04-17T18:59:05.5200000' AS DateTime2), CAST(N'2023-04-17T18:59:05.5200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (259, N'Sabio Make', N'Sabio Model', 1969, 0, 94, CAST(N'2023-04-17T18:59:05.5200000' AS DateTime2), CAST(N'2023-04-17T18:59:05.5200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (260, N'Sabio Make', N'Sabio Model', 1969, 0, 94, CAST(N'2023-04-17T18:59:05.5200000' AS DateTime2), CAST(N'2023-04-17T18:59:05.5200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (261, N'Sabio Make9895', N'Sabio Model', 2022, 0, 95, CAST(N'2023-04-17T18:59:05.5366667' AS DateTime2), CAST(N'2023-04-17T18:59:05.5366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (262, N'Sabio Make9895', N'Sabio Model', 2022, 0, 95, CAST(N'2023-04-17T18:59:05.5366667' AS DateTime2), CAST(N'2023-04-17T18:59:05.5366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (263, N'Sabio Make9895', N'Sabio Model', 2022, 0, 95, CAST(N'2023-04-17T18:59:05.5366667' AS DateTime2), CAST(N'2023-04-17T18:59:05.5366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (264, N'Sabio Make9895', N'Sabio Model', 2022, 0, 95, CAST(N'2023-04-17T18:59:05.5366667' AS DateTime2), CAST(N'2023-04-17T18:59:05.5366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (265, N'Sabio Make9895', N'Sabio Model', 2022, 0, 95, CAST(N'2023-04-17T18:59:05.5366667' AS DateTime2), CAST(N'2023-04-17T18:59:05.5366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (266, N'Sabio Make5291', N'Sabio Model5291', 2000, 0, 96, CAST(N'2023-04-17T18:59:05.5366667' AS DateTime2), CAST(N'2023-04-17T18:59:06.5366667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (267, N'Sabio Make', N'Sabio Model', 2022, 1, 97, CAST(N'2023-04-17T18:59:06.5500000' AS DateTime2), CAST(N'2023-04-17T18:59:07.5600000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (269, N'Sabio Make', N'Sabio Model', 2022, 0, 99, CAST(N'2023-04-17T18:59:07.5766667' AS DateTime2), CAST(N'2023-04-17T18:59:07.5766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (270, N'Sabio Make', N'Sabio Model', 2022, 0, 99, CAST(N'2023-04-17T18:59:07.5766667' AS DateTime2), CAST(N'2023-04-17T18:59:07.5766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (271, N'Sabio Make', N'Sabio Model', 2022, 0, 99, CAST(N'2023-04-17T18:59:07.5766667' AS DateTime2), CAST(N'2023-04-17T18:59:07.5766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (272, N'Sabio Make', N'Sabio Model', 2022, 0, 99, CAST(N'2023-04-17T18:59:07.5766667' AS DateTime2), CAST(N'2023-04-17T18:59:07.5766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (273, N'Sabio Make', N'Sabio Model', 2022, 0, 99, CAST(N'2023-04-17T18:59:07.5766667' AS DateTime2), CAST(N'2023-04-17T18:59:07.5766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (274, N'Sabio Make', N'Sabio Model', 2022, 0, 100, CAST(N'2023-04-17T18:59:07.5933333' AS DateTime2), CAST(N'2023-04-17T18:59:07.5933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (275, N'Sabio Make', N'Sabio Model', 2022, 0, 100, CAST(N'2023-04-17T18:59:07.5933333' AS DateTime2), CAST(N'2023-04-17T18:59:07.5933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (276, N'Sabio Make', N'Sabio Model', 2022, 0, 100, CAST(N'2023-04-17T18:59:07.5933333' AS DateTime2), CAST(N'2023-04-17T18:59:07.5933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (277, N'Sabio Make', N'Sabio Model', 2022, 0, 100, CAST(N'2023-04-17T18:59:07.5933333' AS DateTime2), CAST(N'2023-04-17T18:59:07.5933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (278, N'Sabio Make', N'Sabio Model', 2022, 0, 100, CAST(N'2023-04-17T18:59:07.5933333' AS DateTime2), CAST(N'2023-04-17T18:59:07.5933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (279, N'Sabio Make', N'Sabio Model', 2022, 1, 100, CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2), CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (280, N'Sabio Make', N'Sabio Model', 2022, 1, 100, CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2), CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (281, N'Sabio Make', N'Sabio Model', 2022, 1, 100, CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2), CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (282, N'Sabio Make', N'Sabio Model', 2022, 1, 100, CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2), CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (283, N'Sabio Make', N'Sabio Model', 2022, 1, 100, CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2), CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (284, N'Sabio Make', N'Sabio Model', 2022, 0, 101, CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2), CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (286, N'Sabio Make', N'Sabio Model', 2022, 0, 103, CAST(N'2023-04-17T19:00:47.6933333' AS DateTime2), CAST(N'2023-04-17T19:00:47.6933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (287, N'Sabio Make', N'Sabio Model', 1910, 0, 104, CAST(N'2023-04-17T19:00:47.7100000' AS DateTime2), CAST(N'2023-04-17T19:00:47.7100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (288, N'Sabio Make', N'Sabio Model', 1910, 0, 104, CAST(N'2023-04-17T19:00:47.7100000' AS DateTime2), CAST(N'2023-04-17T19:00:47.7100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (289, N'Sabio Make', N'Sabio Model', 1910, 0, 104, CAST(N'2023-04-17T19:00:47.7100000' AS DateTime2), CAST(N'2023-04-17T19:00:47.7100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (290, N'Sabio Make', N'Sabio Model', 1910, 0, 104, CAST(N'2023-04-17T19:00:47.7100000' AS DateTime2), CAST(N'2023-04-17T19:00:47.7100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (291, N'Sabio Make', N'Sabio Model', 1910, 0, 104, CAST(N'2023-04-17T19:00:47.7100000' AS DateTime2), CAST(N'2023-04-17T19:00:47.7100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (292, N'Sabio Make7753', N'Sabio Model', 2022, 0, 105, CAST(N'2023-04-17T19:00:47.7233333' AS DateTime2), CAST(N'2023-04-17T19:00:47.7233333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (293, N'Sabio Make7753', N'Sabio Model', 2022, 0, 105, CAST(N'2023-04-17T19:00:47.7233333' AS DateTime2), CAST(N'2023-04-17T19:00:47.7233333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (294, N'Sabio Make7753', N'Sabio Model', 2022, 0, 105, CAST(N'2023-04-17T19:00:47.7233333' AS DateTime2), CAST(N'2023-04-17T19:00:47.7233333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (295, N'Sabio Make7753', N'Sabio Model', 2022, 0, 105, CAST(N'2023-04-17T19:00:47.7233333' AS DateTime2), CAST(N'2023-04-17T19:00:47.7233333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (296, N'Sabio Make7753', N'Sabio Model', 2022, 0, 105, CAST(N'2023-04-17T19:00:47.7233333' AS DateTime2), CAST(N'2023-04-17T19:00:47.7233333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (297, N'Sabio Make9039', N'Sabio Model9039', 1907, 0, 106, CAST(N'2023-04-17T19:00:47.7400000' AS DateTime2), CAST(N'2023-04-17T19:00:48.7566667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (298, N'Sabio Make', N'Sabio Model', 2022, 1, 107, CAST(N'2023-04-17T19:00:48.7733333' AS DateTime2), CAST(N'2023-04-17T19:00:49.7866667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (300, N'Sabio Make', N'Sabio Model', 2022, 0, 109, CAST(N'2023-04-17T19:00:49.8033333' AS DateTime2), CAST(N'2023-04-17T19:00:49.8033333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (301, N'Sabio Make', N'Sabio Model', 2022, 0, 109, CAST(N'2023-04-17T19:00:49.8033333' AS DateTime2), CAST(N'2023-04-17T19:00:49.8033333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (302, N'Sabio Make', N'Sabio Model', 2022, 0, 109, CAST(N'2023-04-17T19:00:49.8033333' AS DateTime2), CAST(N'2023-04-17T19:00:49.8033333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (303, N'Sabio Make', N'Sabio Model', 2022, 0, 109, CAST(N'2023-04-17T19:00:49.8033333' AS DateTime2), CAST(N'2023-04-17T19:00:49.8033333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (304, N'Sabio Make', N'Sabio Model', 2022, 0, 109, CAST(N'2023-04-17T19:00:49.8033333' AS DateTime2), CAST(N'2023-04-17T19:00:49.8033333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (305, N'Sabio Make', N'Sabio Model', 2022, 0, 110, CAST(N'2023-04-17T19:00:49.8166667' AS DateTime2), CAST(N'2023-04-17T19:00:49.8166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (306, N'Sabio Make', N'Sabio Model', 2022, 0, 110, CAST(N'2023-04-17T19:00:49.8166667' AS DateTime2), CAST(N'2023-04-17T19:00:49.8166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (307, N'Sabio Make', N'Sabio Model', 2022, 0, 110, CAST(N'2023-04-17T19:00:49.8166667' AS DateTime2), CAST(N'2023-04-17T19:00:49.8166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (308, N'Sabio Make', N'Sabio Model', 2022, 0, 110, CAST(N'2023-04-17T19:00:49.8166667' AS DateTime2), CAST(N'2023-04-17T19:00:49.8166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (309, N'Sabio Make', N'Sabio Model', 2022, 0, 110, CAST(N'2023-04-17T19:00:49.8166667' AS DateTime2), CAST(N'2023-04-17T19:00:49.8166667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (310, N'Sabio Make', N'Sabio Model', 2022, 1, 110, CAST(N'2023-04-17T19:00:49.8333333' AS DateTime2), CAST(N'2023-04-17T19:00:49.8333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (311, N'Sabio Make', N'Sabio Model', 2022, 1, 110, CAST(N'2023-04-17T19:00:49.8333333' AS DateTime2), CAST(N'2023-04-17T19:00:49.8333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (312, N'Sabio Make', N'Sabio Model', 2022, 1, 110, CAST(N'2023-04-17T19:00:49.8333333' AS DateTime2), CAST(N'2023-04-17T19:00:49.8333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (313, N'Sabio Make', N'Sabio Model', 2022, 1, 110, CAST(N'2023-04-17T19:00:49.8333333' AS DateTime2), CAST(N'2023-04-17T19:00:49.8333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (314, N'Sabio Make', N'Sabio Model', 2022, 1, 110, CAST(N'2023-04-17T19:00:49.8333333' AS DateTime2), CAST(N'2023-04-17T19:00:49.8333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (315, N'Sabio Make', N'Sabio Model', 2022, 0, 111, CAST(N'2023-04-17T19:00:49.8500000' AS DateTime2), CAST(N'2023-04-17T19:00:49.8500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (317, N'Sabio Make', N'Sabio Model', 2022, 0, 113, CAST(N'2023-04-17T19:01:46.5500000' AS DateTime2), CAST(N'2023-04-17T19:01:46.5500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (318, N'Sabio Make', N'Sabio Model', 1913, 0, 114, CAST(N'2023-04-17T19:01:46.5666667' AS DateTime2), CAST(N'2023-04-17T19:01:46.5666667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (319, N'Sabio Make', N'Sabio Model', 1913, 0, 114, CAST(N'2023-04-17T19:01:46.5666667' AS DateTime2), CAST(N'2023-04-17T19:01:46.5666667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (320, N'Sabio Make', N'Sabio Model', 1913, 0, 114, CAST(N'2023-04-17T19:01:46.5666667' AS DateTime2), CAST(N'2023-04-17T19:01:46.5666667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (321, N'Sabio Make', N'Sabio Model', 1913, 0, 114, CAST(N'2023-04-17T19:01:46.5666667' AS DateTime2), CAST(N'2023-04-17T19:01:46.5666667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (322, N'Sabio Make', N'Sabio Model', 1913, 0, 114, CAST(N'2023-04-17T19:01:46.5666667' AS DateTime2), CAST(N'2023-04-17T19:01:46.5666667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (323, N'Sabio Make2218', N'Sabio Model', 2022, 0, 115, CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2), CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (324, N'Sabio Make2218', N'Sabio Model', 2022, 0, 115, CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2), CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2))
GO
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (325, N'Sabio Make2218', N'Sabio Model', 2022, 0, 115, CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2), CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (326, N'Sabio Make2218', N'Sabio Model', 2022, 0, 115, CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2), CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (327, N'Sabio Make2218', N'Sabio Model', 2022, 0, 115, CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2), CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (328, N'Sabio Make3030', N'Sabio Model3030', 1941, 0, 116, CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2), CAST(N'2023-04-17T19:01:47.6000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (329, N'Sabio Make', N'Sabio Model', 2022, 1, 117, CAST(N'2023-04-17T19:01:47.6166667' AS DateTime2), CAST(N'2023-04-17T19:01:48.6333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (331, N'Sabio Make', N'Sabio Model', 2022, 0, 119, CAST(N'2023-04-17T19:01:48.6500000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (332, N'Sabio Make', N'Sabio Model', 2022, 0, 119, CAST(N'2023-04-17T19:01:48.6500000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (333, N'Sabio Make', N'Sabio Model', 2022, 0, 119, CAST(N'2023-04-17T19:01:48.6500000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (334, N'Sabio Make', N'Sabio Model', 2022, 0, 119, CAST(N'2023-04-17T19:01:48.6500000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (335, N'Sabio Make', N'Sabio Model', 2022, 0, 119, CAST(N'2023-04-17T19:01:48.6500000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (336, N'Sabio Make', N'Sabio Model', 2022, 0, 120, CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (337, N'Sabio Make', N'Sabio Model', 2022, 0, 120, CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (338, N'Sabio Make', N'Sabio Model', 2022, 0, 120, CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (339, N'Sabio Make', N'Sabio Model', 2022, 0, 120, CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (340, N'Sabio Make', N'Sabio Model', 2022, 0, 120, CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (341, N'Sabio Make', N'Sabio Model', 2022, 1, 120, CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (342, N'Sabio Make', N'Sabio Model', 2022, 1, 120, CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (343, N'Sabio Make', N'Sabio Model', 2022, 1, 120, CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (344, N'Sabio Make', N'Sabio Model', 2022, 1, 120, CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (345, N'Sabio Make', N'Sabio Model', 2022, 1, 120, CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (346, N'Sabio Make', N'Sabio Model', 2022, 0, 121, CAST(N'2023-04-17T19:01:48.6966667' AS DateTime2), CAST(N'2023-04-17T19:01:48.6966667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (348, N'Sabio Make', N'Sabio Model', 2022, 0, 123, CAST(N'2023-04-17T19:02:00.1233333' AS DateTime2), CAST(N'2023-04-17T19:02:00.1233333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (349, N'Sabio Make', N'Sabio Model', 2001, 0, 124, CAST(N'2023-04-17T19:02:00.1233333' AS DateTime2), CAST(N'2023-04-17T19:02:00.1233333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (350, N'Sabio Make', N'Sabio Model', 2001, 0, 124, CAST(N'2023-04-17T19:02:00.1233333' AS DateTime2), CAST(N'2023-04-17T19:02:00.1233333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (351, N'Sabio Make', N'Sabio Model', 2001, 0, 124, CAST(N'2023-04-17T19:02:00.1233333' AS DateTime2), CAST(N'2023-04-17T19:02:00.1233333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (352, N'Sabio Make', N'Sabio Model', 2001, 0, 124, CAST(N'2023-04-17T19:02:00.1233333' AS DateTime2), CAST(N'2023-04-17T19:02:00.1233333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (353, N'Sabio Make', N'Sabio Model', 2001, 0, 124, CAST(N'2023-04-17T19:02:00.1233333' AS DateTime2), CAST(N'2023-04-17T19:02:00.1233333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (354, N'Sabio Make9641', N'Sabio Model', 2022, 0, 125, CAST(N'2023-04-17T19:02:00.1400000' AS DateTime2), CAST(N'2023-04-17T19:02:00.1400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (355, N'Sabio Make9641', N'Sabio Model', 2022, 0, 125, CAST(N'2023-04-17T19:02:00.1400000' AS DateTime2), CAST(N'2023-04-17T19:02:00.1400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (356, N'Sabio Make9641', N'Sabio Model', 2022, 0, 125, CAST(N'2023-04-17T19:02:00.1400000' AS DateTime2), CAST(N'2023-04-17T19:02:00.1400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (357, N'Sabio Make9641', N'Sabio Model', 2022, 0, 125, CAST(N'2023-04-17T19:02:00.1400000' AS DateTime2), CAST(N'2023-04-17T19:02:00.1400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (358, N'Sabio Make9641', N'Sabio Model', 2022, 0, 125, CAST(N'2023-04-17T19:02:00.1400000' AS DateTime2), CAST(N'2023-04-17T19:02:00.1400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (359, N'Sabio Make1620', N'Sabio Model1620', 1978, 0, 126, CAST(N'2023-04-17T19:02:00.1533333' AS DateTime2), CAST(N'2023-04-17T19:02:01.1633333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (360, N'Sabio Make', N'Sabio Model', 2022, 1, 127, CAST(N'2023-04-17T19:02:01.1633333' AS DateTime2), CAST(N'2023-04-17T19:02:02.1800000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (362, N'Sabio Make', N'Sabio Model', 2022, 0, 129, CAST(N'2023-04-17T19:02:02.1933333' AS DateTime2), CAST(N'2023-04-17T19:02:02.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (363, N'Sabio Make', N'Sabio Model', 2022, 0, 129, CAST(N'2023-04-17T19:02:02.1933333' AS DateTime2), CAST(N'2023-04-17T19:02:02.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (364, N'Sabio Make', N'Sabio Model', 2022, 0, 129, CAST(N'2023-04-17T19:02:02.1933333' AS DateTime2), CAST(N'2023-04-17T19:02:02.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (365, N'Sabio Make', N'Sabio Model', 2022, 0, 129, CAST(N'2023-04-17T19:02:02.1933333' AS DateTime2), CAST(N'2023-04-17T19:02:02.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (366, N'Sabio Make', N'Sabio Model', 2022, 0, 129, CAST(N'2023-04-17T19:02:02.1933333' AS DateTime2), CAST(N'2023-04-17T19:02:02.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (367, N'Sabio Make', N'Sabio Model', 2022, 0, 130, CAST(N'2023-04-17T19:02:02.2100000' AS DateTime2), CAST(N'2023-04-17T19:02:02.2100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (368, N'Sabio Make', N'Sabio Model', 2022, 0, 130, CAST(N'2023-04-17T19:02:02.2100000' AS DateTime2), CAST(N'2023-04-17T19:02:02.2100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (369, N'Sabio Make', N'Sabio Model', 2022, 0, 130, CAST(N'2023-04-17T19:02:02.2100000' AS DateTime2), CAST(N'2023-04-17T19:02:02.2100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (370, N'Sabio Make', N'Sabio Model', 2022, 0, 130, CAST(N'2023-04-17T19:02:02.2100000' AS DateTime2), CAST(N'2023-04-17T19:02:02.2100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (371, N'Sabio Make', N'Sabio Model', 2022, 0, 130, CAST(N'2023-04-17T19:02:02.2100000' AS DateTime2), CAST(N'2023-04-17T19:02:02.2100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (372, N'Sabio Make', N'Sabio Model', 2022, 1, 130, CAST(N'2023-04-17T19:02:02.2266667' AS DateTime2), CAST(N'2023-04-17T19:02:02.2266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (373, N'Sabio Make', N'Sabio Model', 2022, 1, 130, CAST(N'2023-04-17T19:02:02.2266667' AS DateTime2), CAST(N'2023-04-17T19:02:02.2266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (374, N'Sabio Make', N'Sabio Model', 2022, 1, 130, CAST(N'2023-04-17T19:02:02.2266667' AS DateTime2), CAST(N'2023-04-17T19:02:02.2266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (375, N'Sabio Make', N'Sabio Model', 2022, 1, 130, CAST(N'2023-04-17T19:02:02.2266667' AS DateTime2), CAST(N'2023-04-17T19:02:02.2266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (376, N'Sabio Make', N'Sabio Model', 2022, 1, 130, CAST(N'2023-04-17T19:02:02.2266667' AS DateTime2), CAST(N'2023-04-17T19:02:02.2266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (377, N'Sabio Make', N'Sabio Model', 2022, 0, 131, CAST(N'2023-04-17T19:02:02.2400000' AS DateTime2), CAST(N'2023-04-17T19:02:02.2400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (379, N'Sabio Make', N'Sabio Model', 2022, 0, 133, CAST(N'2023-04-17T19:03:29.1000000' AS DateTime2), CAST(N'2023-04-17T19:03:29.1000000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (380, N'Sabio Make', N'Sabio Model', 2004, 0, 134, CAST(N'2023-04-17T19:03:29.1133333' AS DateTime2), CAST(N'2023-04-17T19:03:29.1133333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (381, N'Sabio Make', N'Sabio Model', 2004, 0, 134, CAST(N'2023-04-17T19:03:29.1133333' AS DateTime2), CAST(N'2023-04-17T19:03:29.1133333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (382, N'Sabio Make', N'Sabio Model', 2004, 0, 134, CAST(N'2023-04-17T19:03:29.1133333' AS DateTime2), CAST(N'2023-04-17T19:03:29.1133333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (383, N'Sabio Make', N'Sabio Model', 2004, 0, 134, CAST(N'2023-04-17T19:03:29.1133333' AS DateTime2), CAST(N'2023-04-17T19:03:29.1133333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (384, N'Sabio Make', N'Sabio Model', 2004, 0, 134, CAST(N'2023-04-17T19:03:29.1133333' AS DateTime2), CAST(N'2023-04-17T19:03:29.1133333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (385, N'Sabio Make5299', N'Sabio Model', 2022, 0, 135, CAST(N'2023-04-17T19:03:29.1300000' AS DateTime2), CAST(N'2023-04-17T19:03:29.1300000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (386, N'Sabio Make5299', N'Sabio Model', 2022, 0, 135, CAST(N'2023-04-17T19:03:29.1300000' AS DateTime2), CAST(N'2023-04-17T19:03:29.1300000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (387, N'Sabio Make5299', N'Sabio Model', 2022, 0, 135, CAST(N'2023-04-17T19:03:29.1300000' AS DateTime2), CAST(N'2023-04-17T19:03:29.1300000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (388, N'Sabio Make5299', N'Sabio Model', 2022, 0, 135, CAST(N'2023-04-17T19:03:29.1300000' AS DateTime2), CAST(N'2023-04-17T19:03:29.1300000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (389, N'Sabio Make5299', N'Sabio Model', 2022, 0, 135, CAST(N'2023-04-17T19:03:29.1300000' AS DateTime2), CAST(N'2023-04-17T19:03:29.1300000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (390, N'Sabio Make4345', N'Sabio Model4345', 1949, 0, 136, CAST(N'2023-04-17T19:03:29.1300000' AS DateTime2), CAST(N'2023-04-17T19:03:30.1466667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (391, N'Sabio Make', N'Sabio Model', 2022, 1, 137, CAST(N'2023-04-17T19:03:30.1600000' AS DateTime2), CAST(N'2023-04-17T19:03:31.1600000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (393, N'Sabio Make', N'Sabio Model', 2022, 0, 139, CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2), CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (394, N'Sabio Make', N'Sabio Model', 2022, 0, 139, CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2), CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (395, N'Sabio Make', N'Sabio Model', 2022, 0, 139, CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2), CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (396, N'Sabio Make', N'Sabio Model', 2022, 0, 139, CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2), CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (397, N'Sabio Make', N'Sabio Model', 2022, 0, 139, CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2), CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (398, N'Sabio Make', N'Sabio Model', 2022, 0, 140, CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2), CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (399, N'Sabio Make', N'Sabio Model', 2022, 0, 140, CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2), CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (400, N'Sabio Make', N'Sabio Model', 2022, 0, 140, CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2), CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (401, N'Sabio Make', N'Sabio Model', 2022, 0, 140, CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2), CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (402, N'Sabio Make', N'Sabio Model', 2022, 0, 140, CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2), CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (403, N'Sabio Make', N'Sabio Model', 2022, 1, 140, CAST(N'2023-04-17T19:03:31.2100000' AS DateTime2), CAST(N'2023-04-17T19:03:31.2100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (404, N'Sabio Make', N'Sabio Model', 2022, 1, 140, CAST(N'2023-04-17T19:03:31.2100000' AS DateTime2), CAST(N'2023-04-17T19:03:31.2100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (405, N'Sabio Make', N'Sabio Model', 2022, 1, 140, CAST(N'2023-04-17T19:03:31.2100000' AS DateTime2), CAST(N'2023-04-17T19:03:31.2100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (406, N'Sabio Make', N'Sabio Model', 2022, 1, 140, CAST(N'2023-04-17T19:03:31.2100000' AS DateTime2), CAST(N'2023-04-17T19:03:31.2100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (407, N'Sabio Make', N'Sabio Model', 2022, 1, 140, CAST(N'2023-04-17T19:03:31.2100000' AS DateTime2), CAST(N'2023-04-17T19:03:31.2100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (408, N'Sabio Make', N'Sabio Model', 2022, 0, 141, CAST(N'2023-04-17T19:03:31.2233333' AS DateTime2), CAST(N'2023-04-17T19:03:31.2233333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (410, N'Sabio Make', N'Sabio Model', 2022, 0, 143, CAST(N'2023-04-17T19:04:14.2100000' AS DateTime2), CAST(N'2023-04-17T19:04:14.2100000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (411, N'Sabio Make', N'Sabio Model', 1932, 0, 144, CAST(N'2023-04-17T19:04:14.2266667' AS DateTime2), CAST(N'2023-04-17T19:04:14.2266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (412, N'Sabio Make', N'Sabio Model', 1932, 0, 144, CAST(N'2023-04-17T19:04:14.2266667' AS DateTime2), CAST(N'2023-04-17T19:04:14.2266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (413, N'Sabio Make', N'Sabio Model', 1932, 0, 144, CAST(N'2023-04-17T19:04:14.2266667' AS DateTime2), CAST(N'2023-04-17T19:04:14.2266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (414, N'Sabio Make', N'Sabio Model', 1932, 0, 144, CAST(N'2023-04-17T19:04:14.2266667' AS DateTime2), CAST(N'2023-04-17T19:04:14.2266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (415, N'Sabio Make', N'Sabio Model', 1932, 0, 144, CAST(N'2023-04-17T19:04:14.2266667' AS DateTime2), CAST(N'2023-04-17T19:04:14.2266667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (416, N'Sabio Make9142', N'Sabio Model', 2022, 0, 145, CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2), CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (417, N'Sabio Make9142', N'Sabio Model', 2022, 0, 145, CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2), CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (418, N'Sabio Make9142', N'Sabio Model', 2022, 0, 145, CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2), CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (419, N'Sabio Make9142', N'Sabio Model', 2022, 0, 145, CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2), CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (420, N'Sabio Make9142', N'Sabio Model', 2022, 0, 145, CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2), CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (421, N'Sabio Make4096', N'Sabio Model4096', 1915, 0, 146, CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2), CAST(N'2023-04-17T19:04:15.2533333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (422, N'Sabio Make', N'Sabio Model', 2022, 1, 147, CAST(N'2023-04-17T19:04:15.2700000' AS DateTime2), CAST(N'2023-04-17T19:04:16.2866667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (424, N'Sabio Make', N'Sabio Model', 2022, 0, 149, CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (425, N'Sabio Make', N'Sabio Model', 2022, 0, 149, CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (426, N'Sabio Make', N'Sabio Model', 2022, 0, 149, CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (427, N'Sabio Make', N'Sabio Model', 2022, 0, 149, CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (428, N'Sabio Make', N'Sabio Model', 2022, 0, 149, CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (429, N'Sabio Make', N'Sabio Model', 2022, 0, 150, CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (430, N'Sabio Make', N'Sabio Model', 2022, 0, 150, CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (431, N'Sabio Make', N'Sabio Model', 2022, 0, 150, CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2))
GO
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (432, N'Sabio Make', N'Sabio Model', 2022, 0, 150, CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (433, N'Sabio Make', N'Sabio Model', 2022, 0, 150, CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (434, N'Sabio Make', N'Sabio Model', 2022, 1, 150, CAST(N'2023-04-17T19:04:16.3333333' AS DateTime2), CAST(N'2023-04-17T19:04:16.3333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (435, N'Sabio Make', N'Sabio Model', 2022, 1, 150, CAST(N'2023-04-17T19:04:16.3333333' AS DateTime2), CAST(N'2023-04-17T19:04:16.3333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (436, N'Sabio Make', N'Sabio Model', 2022, 1, 150, CAST(N'2023-04-17T19:04:16.3333333' AS DateTime2), CAST(N'2023-04-17T19:04:16.3333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (437, N'Sabio Make', N'Sabio Model', 2022, 1, 150, CAST(N'2023-04-17T19:04:16.3333333' AS DateTime2), CAST(N'2023-04-17T19:04:16.3333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (438, N'Sabio Make', N'Sabio Model', 2022, 1, 150, CAST(N'2023-04-17T19:04:16.3333333' AS DateTime2), CAST(N'2023-04-17T19:04:16.3333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (439, N'Sabio Make', N'Sabio Model', 2022, 0, 151, CAST(N'2023-04-17T19:04:16.3666667' AS DateTime2), CAST(N'2023-04-17T19:04:16.3666667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (441, N'Sabio Make', N'Sabio Model', 2022, 0, 153, CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (442, N'Sabio Make', N'Sabio Model', 1942, 0, 154, CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (443, N'Sabio Make', N'Sabio Model', 1942, 0, 154, CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (444, N'Sabio Make', N'Sabio Model', 1942, 0, 154, CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (445, N'Sabio Make', N'Sabio Model', 1942, 0, 154, CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (446, N'Sabio Make', N'Sabio Model', 1942, 0, 154, CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (447, N'Sabio Make1993', N'Sabio Model', 2022, 0, 155, CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2), CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (448, N'Sabio Make1993', N'Sabio Model', 2022, 0, 155, CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2), CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (449, N'Sabio Make1993', N'Sabio Model', 2022, 0, 155, CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2), CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (450, N'Sabio Make1993', N'Sabio Model', 2022, 0, 155, CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2), CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (451, N'Sabio Make1993', N'Sabio Model', 2022, 0, 155, CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2), CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (452, N'Sabio Make9362', N'Sabio Model9362', 1962, 0, 156, CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2), CAST(N'2023-04-17T19:04:48.3500000' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (453, N'Sabio Make', N'Sabio Model', 2022, 1, 157, CAST(N'2023-04-17T19:04:48.3500000' AS DateTime2), CAST(N'2023-04-17T19:04:49.3633333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (455, N'Sabio Make', N'Sabio Model', 2022, 0, 159, CAST(N'2023-04-17T19:04:49.3766667' AS DateTime2), CAST(N'2023-04-17T19:04:49.3766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (456, N'Sabio Make', N'Sabio Model', 2022, 0, 159, CAST(N'2023-04-17T19:04:49.3766667' AS DateTime2), CAST(N'2023-04-17T19:04:49.3766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (457, N'Sabio Make', N'Sabio Model', 2022, 0, 159, CAST(N'2023-04-17T19:04:49.3766667' AS DateTime2), CAST(N'2023-04-17T19:04:49.3766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (458, N'Sabio Make', N'Sabio Model', 2022, 0, 159, CAST(N'2023-04-17T19:04:49.3766667' AS DateTime2), CAST(N'2023-04-17T19:04:49.3766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (459, N'Sabio Make', N'Sabio Model', 2022, 0, 159, CAST(N'2023-04-17T19:04:49.3766667' AS DateTime2), CAST(N'2023-04-17T19:04:49.3766667' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (460, N'Sabio Make', N'Sabio Model', 2022, 0, 160, CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2), CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (461, N'Sabio Make', N'Sabio Model', 2022, 0, 160, CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2), CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (462, N'Sabio Make', N'Sabio Model', 2022, 0, 160, CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2), CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (463, N'Sabio Make', N'Sabio Model', 2022, 0, 160, CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2), CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (464, N'Sabio Make', N'Sabio Model', 2022, 0, 160, CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2), CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (465, N'Sabio Make', N'Sabio Model', 2022, 1, 160, CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2), CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (466, N'Sabio Make', N'Sabio Model', 2022, 1, 160, CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2), CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (467, N'Sabio Make', N'Sabio Model', 2022, 1, 160, CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2), CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (468, N'Sabio Make', N'Sabio Model', 2022, 1, 160, CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2), CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (469, N'Sabio Make', N'Sabio Model', 2022, 1, 160, CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2), CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2))
INSERT [dbo].[Cars] ([Id], [Make], [Model], [Year], [IsUsed], [ManufacturerId], [DateCreated], [DateModified]) VALUES (470, N'Sabio Make', N'Sabio Model', 2022, 0, 161, CAST(N'2023-04-17T19:04:49.4233333' AS DateTime2), CAST(N'2023-04-17T19:04:49.4233333' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Cars] OFF
GO
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (1, 1)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (1, 3)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (1, 8)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (2, 3)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (2, 8)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (3, 2)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (3, 3)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (3, 4)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (3, 8)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (4, 3)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (4, 8)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (5, 3)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (5, 4)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (5, 8)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (6, 2)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (6, 3)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (6, 8)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (7, 2)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (7, 3)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (7, 8)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (8, 3)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (8, 8)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (9, 2)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (9, 3)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (9, 4)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (9, 6)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (9, 8)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (160, 18)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (160, 19)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (160, 20)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (191, 22)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (191, 23)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (191, 24)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (222, 26)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (222, 27)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (222, 28)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (253, 30)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (253, 31)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (253, 32)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (284, 34)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (284, 35)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (284, 36)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (315, 38)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (315, 39)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (315, 40)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (346, 42)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (346, 43)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (346, 44)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (377, 46)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (377, 47)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (377, 48)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (408, 50)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (408, 51)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (408, 52)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (439, 54)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (439, 55)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (439, 56)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (470, 58)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (470, 59)
INSERT [dbo].[CarsFeatures] ([CarId], [FeatureId]) VALUES (470, 60)
GO
SET IDENTITY_INSERT [dbo].[Concerts] ON 

INSERT [dbo].[Concerts] ([Id], [Name], [Description], [IsFree], [Address], [Cost], [DateOfEvent]) VALUES (1, N'Luxemborg', N'Come grab a bite with cool music', 0, N'1853 Sauce Ave. Los Angeles, CA', 28, CAST(N'2022-10-12T07:30:20.0000000' AS DateTime2))
INSERT [dbo].[Concerts] ([Id], [Name], [Description], [IsFree], [Address], [Cost], [DateOfEvent]) VALUES (2, N'Rock Festival of the Ages', N'Come grab a bite with rock music', 0, N'1853 Potato Ave. Los Angeles, CA', 65, CAST(N'2022-11-12T07:30:20.0000000' AS DateTime2))
INSERT [dbo].[Concerts] ([Id], [Name], [Description], [IsFree], [Address], [Cost], [DateOfEvent]) VALUES (3, N'Country Festival of the Ages', N'Come grab a bite with country music', 0, N'1853 Rock Ave. Los Angeles, CA', 65, CAST(N'2022-11-15T07:30:20.0000000' AS DateTime2))
INSERT [dbo].[Concerts] ([Id], [Name], [Description], [IsFree], [Address], [Cost], [DateOfEvent]) VALUES (4, N'Punk Rock Festival of the Ages', N'Come grab a bite with punk rock music', 0, N'1853 Punk Rock Ave. Los Angeles, CA', 65, CAST(N'2022-11-21T07:30:20.0000000' AS DateTime2))
INSERT [dbo].[Concerts] ([Id], [Name], [Description], [IsFree], [Address], [Cost], [DateOfEvent]) VALUES (5, N'Pop Festival of the Ages', N'Come grab a bite with pop music', 0, N'1853 Tomato Ave. Los Angeles, CA', 65, CAST(N'2022-12-12T07:30:20.0000000' AS DateTime2))
INSERT [dbo].[Concerts] ([Id], [Name], [Description], [IsFree], [Address], [Cost], [DateOfEvent]) VALUES (6, N'EDM Festival of the Ages', N'Come grab a bite with EDM music', 1, N'1853 EDM Ave. Los Angeles, CA', 0, CAST(N'2022-11-24T07:30:20.0000000' AS DateTime2))
INSERT [dbo].[Concerts] ([Id], [Name], [Description], [IsFree], [Address], [Cost], [DateOfEvent]) VALUES (7, N'Potato Festival of the Ages', N'Come grab a bite with potato music', 1, N'1853 Shoe Ave. Los Angeles, CA', 0, CAST(N'2022-12-14T07:30:20.0000000' AS DateTime2))
INSERT [dbo].[Concerts] ([Id], [Name], [Description], [IsFree], [Address], [Cost], [DateOfEvent]) VALUES (8, N'KISS', N'Concert at Midnight!', 0, N'Central Park, NYC', 100, CAST(N'2023-04-24T12:08:50.8066667' AS DateTime2))
INSERT [dbo].[Concerts] ([Id], [Name], [Description], [IsFree], [Address], [Cost], [DateOfEvent]) VALUES (9, N'KISS 2', N'Concert at Midnight! 2', 1, N'123 Central Park, NYC', 0, CAST(N'2023-04-24T12:13:57.9033333' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Concerts] OFF
GO
SET IDENTITY_INSERT [dbo].[ContactInformation] ON 

INSERT [dbo].[ContactInformation] ([id], [UserId], [EntityId], [Data], [DateCreated], [DateModified]) VALUES (5, 4, 0, N'James Smithers (800) 292-2121', CAST(N'2023-04-04T00:00:00.0000000' AS DateTime2), CAST(N'2023-04-04T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[ContactInformation] ([id], [UserId], [EntityId], [Data], [DateCreated], [DateModified]) VALUES (6, 1008, 0, N'Marcy Bean 878-909-8971 Ext 123', CAST(N'2023-04-04T01:49:55.0233333' AS DateTime2), CAST(N'2023-04-19T22:38:12.9833333' AS DateTime2))
INSERT [dbo].[ContactInformation] ([id], [UserId], [EntityId], [Data], [DateCreated], [DateModified]) VALUES (7, 4, 0, N'Acme Contact 123', CAST(N'2023-04-04T22:51:05.5933333' AS DateTime2), CAST(N'2023-04-04T22:51:05.5933333' AS DateTime2))
INSERT [dbo].[ContactInformation] ([id], [UserId], [EntityId], [Data], [DateCreated], [DateModified]) VALUES (8, 4, 0, N'Acme Contact 124', CAST(N'2023-04-04T22:53:11.4933333' AS DateTime2), CAST(N'2023-04-04T22:53:11.4933333' AS DateTime2))
INSERT [dbo].[ContactInformation] ([id], [UserId], [EntityId], [Data], [DateCreated], [DateModified]) VALUES (9, 4, 0, N'Acme Contact 125', CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2))
INSERT [dbo].[ContactInformation] ([id], [UserId], [EntityId], [Data], [DateCreated], [DateModified]) VALUES (10, 1008, 0, N'Acme Contact 126', CAST(N'2023-04-05T00:10:32.9766667' AS DateTime2), CAST(N'2023-04-18T19:55:57.7600000' AS DateTime2))
INSERT [dbo].[ContactInformation] ([id], [UserId], [EntityId], [Data], [DateCreated], [DateModified]) VALUES (11, 4, 0, N'Acme Contact 127', CAST(N'2023-04-05T00:51:08.5700000' AS DateTime2), CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2))
INSERT [dbo].[ContactInformation] ([id], [UserId], [EntityId], [Data], [DateCreated], [DateModified]) VALUES (12, 4, 0, N'Acme Contact 128', CAST(N'2023-04-05T00:52:02.7466667' AS DateTime2), CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2))
INSERT [dbo].[ContactInformation] ([id], [UserId], [EntityId], [Data], [DateCreated], [DateModified]) VALUES (13, 4, 0, N'Acme Contact 129', CAST(N'2023-04-05T00:53:13.9266667' AS DateTime2), CAST(N'2023-04-05T15:17:59.5200000' AS DateTime2))
INSERT [dbo].[ContactInformation] ([id], [UserId], [EntityId], [Data], [DateCreated], [DateModified]) VALUES (14, 4, 0, N'Acme Contact 130', CAST(N'2023-04-05T00:53:31.5900000' AS DateTime2), CAST(N'2023-04-05T15:18:26.1600000' AS DateTime2))
INSERT [dbo].[ContactInformation] ([id], [UserId], [EntityId], [Data], [DateCreated], [DateModified]) VALUES (15, 8, 0, N'Marcy Bean 878-909-8971', CAST(N'2023-04-18T01:34:04.7233333' AS DateTime2), CAST(N'2023-04-18T19:47:11.6466667' AS DateTime2))
INSERT [dbo].[ContactInformation] ([id], [UserId], [EntityId], [Data], [DateCreated], [DateModified]) VALUES (16, 1008, 0, N'(888) 518-3752', CAST(N'2023-04-18T20:23:10.0833333' AS DateTime2), CAST(N'2023-04-18T20:24:13.5800000' AS DateTime2))
INSERT [dbo].[ContactInformation] ([id], [UserId], [EntityId], [Data], [DateCreated], [DateModified]) VALUES (17, 1008, 0, N'phone: 408', CAST(N'2023-04-18T21:51:25.4566667' AS DateTime2), CAST(N'2023-04-18T21:51:25.4566667' AS DateTime2))
SET IDENTITY_INSERT [dbo].[ContactInformation] OFF
GO
SET IDENTITY_INSERT [dbo].[Courses] ON 

INSERT [dbo].[Courses] ([Id], [Name], [Description], [SeasonTermId], [TeacherId]) VALUES (1, N'Math 101', N'Remedial Math', 1, 1)
INSERT [dbo].[Courses] ([Id], [Name], [Description], [SeasonTermId], [TeacherId]) VALUES (2, N'English 101', N'Remedial English', 1, 2)
INSERT [dbo].[Courses] ([Id], [Name], [Description], [SeasonTermId], [TeacherId]) VALUES (3, N'PE 101', N'Remedial PE', 1, 3)
INSERT [dbo].[Courses] ([Id], [Name], [Description], [SeasonTermId], [TeacherId]) VALUES (4, N'Science 101', N'Remedial Science', 1, 4)
INSERT [dbo].[Courses] ([Id], [Name], [Description], [SeasonTermId], [TeacherId]) VALUES (5, N'English 1A', N'Composition', 1, 5)
INSERT [dbo].[Courses] ([Id], [Name], [Description], [SeasonTermId], [TeacherId]) VALUES (6, N'Math 1A', N'College Algebra', 1, 6)
INSERT [dbo].[Courses] ([Id], [Name], [Description], [SeasonTermId], [TeacherId]) VALUES (21, N'Updated Name76603', N'Updated Description76603', 4, 25)
INSERT [dbo].[Courses] ([Id], [Name], [Description], [SeasonTermId], [TeacherId]) VALUES (26, N'Math 220', N'Very Very Remedial Math', 3, 6)
SET IDENTITY_INSERT [dbo].[Courses] OFF
GO
SET IDENTITY_INSERT [dbo].[Events] ON 

INSERT [dbo].[Events] ([id], [Name], [Description], [Summary], [Headline], [Slug], [StatusId], [DateCreated], [DateModified], [UserId], [DateStart], [DateEnd], [Latitude], [Longitude], [ZipCode], [Address]) VALUES (1, N'Hollister Biker Rally 123', N'HBR Description', N'HBR Summary', N'https://shorturl.at/anKQ3', N'HBR Slug', N'Active', CAST(N'2023-04-06T01:51:16.2100000' AS DateTime2), CAST(N'2023-04-20T03:37:55.5500000' AS DateTime2), 1008, CAST(N'2023-04-09T01:51:16.2100000' AS DateTime2), CAST(N'2023-04-12T01:51:16.2100000' AS DateTime2), 0, 0, N'95023', N'123 Main Street, Hollister, CA')
INSERT [dbo].[Events] ([id], [Name], [Description], [Summary], [Headline], [Slug], [StatusId], [DateCreated], [DateModified], [UserId], [DateStart], [DateEnd], [Latitude], [Longitude], [ZipCode], [Address]) VALUES (2, N'Readathon', N'Read Desc', N'Read Summary', N'https://shorturl.at/wEW06', N'Read Slug', N'Active', CAST(N'2023-04-06T01:52:22.5266667' AS DateTime2), CAST(N'2023-04-20T03:38:43.0966667' AS DateTime2), 1008, CAST(N'2023-05-01T01:52:22.5266667' AS DateTime2), CAST(N'2023-05-06T01:52:22.5266667' AS DateTime2), 0, 0, N'93901', N'31 Meadow Drive, Salinas, CA')
INSERT [dbo].[Events] ([id], [Name], [Description], [Summary], [Headline], [Slug], [StatusId], [DateCreated], [DateModified], [UserId], [DateStart], [DateEnd], [Latitude], [Longitude], [ZipCode], [Address]) VALUES (3, N'Gold Panning', N'Gold Desc', N'Gold Summary', N'https://shorturl.at/apBT5', N'Gold Slug', N'Active', CAST(N'2023-04-06T01:53:59.5133333' AS DateTime2), CAST(N'2023-04-20T03:39:44.0700000' AS DateTime2), 1008, CAST(N'2023-06-26T01:53:59.5133333' AS DateTime2), CAST(N'2023-07-06T01:53:59.5133333' AS DateTime2), 0, 0, N'93456', N'55 West Broad, Sacramento, CA')
INSERT [dbo].[Events] ([id], [Name], [Description], [Summary], [Headline], [Slug], [StatusId], [DateCreated], [DateModified], [UserId], [DateStart], [DateEnd], [Latitude], [Longitude], [ZipCode], [Address]) VALUES (5, N'HBR Description 124', N'Hollister Biker Rally 124', N'HBR Summary 124', N'https://shorturl.at/bksN7', N'HBR Slug 124', N'Active 124', CAST(N'2023-04-06T02:46:21.0500000' AS DateTime2), CAST(N'2023-04-20T16:34:17.2633333' AS DateTime2), 1008, CAST(N'2023-05-26T01:51:16.2100000' AS DateTime2), CAST(N'2023-05-28T01:51:16.2100000' AS DateTime2), 120.0001, 120.0001, N'95023-124', N'123 Main Street 124, Hollister, CA')
INSERT [dbo].[Events] ([id], [Name], [Description], [Summary], [Headline], [Slug], [StatusId], [DateCreated], [DateModified], [UserId], [DateStart], [DateEnd], [Latitude], [Longitude], [ZipCode], [Address]) VALUES (6, N'Big Event 123', N'Big Event Desc 123', N'BE Summary', N'https://shorturl.at/aijoC', N'BE SLUG 1001', N'Active', CAST(N'2023-04-06T02:46:51.6400000' AS DateTime2), CAST(N'2023-04-20T16:33:38.3200000' AS DateTime2), 1008, CAST(N'2023-05-05T00:00:00.0000000' AS DateTime2), CAST(N'2023-05-09T00:00:00.0000000' AS DateTime2), 120.199988987, 120.199988987, N'33334', N'123 Main Street')
INSERT [dbo].[Events] ([id], [Name], [Description], [Summary], [Headline], [Slug], [StatusId], [DateCreated], [DateModified], [UserId], [DateStart], [DateEnd], [Latitude], [Longitude], [ZipCode], [Address]) VALUES (7, N'HBR Description 123', N'Hollister Biker Rally 123', N'HBR Summary 123', N'https://shorturl.at/anKQ3', N'HBR Slug 123', N'Active 123', CAST(N'2023-04-20T02:42:05.2833333' AS DateTime2), CAST(N'2023-04-20T03:55:58.3633333' AS DateTime2), 1008, CAST(N'2023-04-26T01:51:16.2100000' AS DateTime2), CAST(N'2023-04-28T01:51:16.2100000' AS DateTime2), 120.0001, 120.0001, N'95023-123', N'123 Main Street 123, Hollister, CA')
INSERT [dbo].[Events] ([id], [Name], [Description], [Summary], [Headline], [Slug], [StatusId], [DateCreated], [DateModified], [UserId], [DateStart], [DateEnd], [Latitude], [Longitude], [ZipCode], [Address]) VALUES (8, N'Cherry Festival', N'Desc', N'Summ', N'https://shorturl.at/nwDKU', N'SLUG!@#$', N'Active', CAST(N'2023-04-20T03:42:43.7133333' AS DateTime2), CAST(N'2023-04-20T03:42:43.7133333' AS DateTime2), 1008, CAST(N'2023-05-06T20:41:00.0000000' AS DateTime2), CAST(N'2023-05-11T20:41:00.0000000' AS DateTime2), 0, 0, N'94577', N'384 W Estudillo Ave, San Leandro, CA, USA')
SET IDENTITY_INSERT [dbo].[Events] OFF
GO
SET IDENTITY_INSERT [dbo].[Features] ON 

INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (1, N'AWD', CAST(N'2023-04-17T18:02:53.5000000' AS DateTime2), CAST(N'2023-04-17T18:02:53.5000000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (2, N'4WD', CAST(N'2023-04-17T18:02:57.4533333' AS DateTime2), CAST(N'2023-04-17T18:02:57.4533333' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (3, N'Power Steering', CAST(N'2023-04-17T18:03:03.6900000' AS DateTime2), CAST(N'2023-04-17T18:03:03.6900000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (4, N'Rear Camera', CAST(N'2023-04-17T18:03:08.1200000' AS DateTime2), CAST(N'2023-04-17T18:03:08.1200000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (5, N'GPS', CAST(N'2023-04-17T18:03:17.9233333' AS DateTime2), CAST(N'2023-04-17T18:03:17.9233333' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (6, N'Apple', CAST(N'2023-04-17T18:03:22.2366667' AS DateTime2), CAST(N'2023-04-17T18:03:22.2366667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (7, N'Self Steering', CAST(N'2023-04-17T18:03:32.8733333' AS DateTime2), CAST(N'2023-04-17T18:03:32.8733333' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (8, N'Anti-lock Brakes', CAST(N'2023-04-17T18:03:41.5633333' AS DateTime2), CAST(N'2023-04-17T18:03:41.5633333' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (9, N'Power Windows', CAST(N'2023-04-17T18:03:47.8366667' AS DateTime2), CAST(N'2023-04-17T18:03:47.8366667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (10, N'Sabio Feature7390', CAST(N'2023-04-17T18:32:19.6366667' AS DateTime2), CAST(N'2023-04-17T18:32:19.6366667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (11, N'Sabio Feature7069', CAST(N'2023-04-17T18:33:02.9566667' AS DateTime2), CAST(N'2023-04-17T18:33:02.9566667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (12, N'Sabio Feature9557', CAST(N'2023-04-17T18:34:06.8766667' AS DateTime2), CAST(N'2023-04-17T18:34:06.8766667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (13, N'Sabio Feature2142', CAST(N'2023-04-17T18:36:32.4100000' AS DateTime2), CAST(N'2023-04-17T18:36:32.4100000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (14, N'Sabio Feature9370', CAST(N'2023-04-17T18:42:11.8233333' AS DateTime2), CAST(N'2023-04-17T18:42:11.8233333' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (15, N'Sabio Feature7309', CAST(N'2023-04-17T18:42:45.2833333' AS DateTime2), CAST(N'2023-04-17T18:42:45.2833333' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (16, N'Sabio Feature5011', CAST(N'2023-04-17T18:45:57.8433333' AS DateTime2), CAST(N'2023-04-17T18:45:57.8433333' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (17, N'Sabio Feature5987', CAST(N'2023-04-17T18:53:22.7000000' AS DateTime2), CAST(N'2023-04-17T18:53:22.7000000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (18, N'Sabio Feature1185', CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (19, N'Sabio Feature1185', CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (20, N'Sabio Feature1185', CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (21, N'Sabio Feature4505', CAST(N'2023-04-17T18:54:29.9800000' AS DateTime2), CAST(N'2023-04-17T18:54:29.9800000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (22, N'Sabio Feature1381', CAST(N'2023-04-17T18:54:32.1100000' AS DateTime2), CAST(N'2023-04-17T18:54:32.1100000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (23, N'Sabio Feature1381', CAST(N'2023-04-17T18:54:32.1100000' AS DateTime2), CAST(N'2023-04-17T18:54:32.1100000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (24, N'Sabio Feature1381', CAST(N'2023-04-17T18:54:32.1100000' AS DateTime2), CAST(N'2023-04-17T18:54:32.1100000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (25, N'Sabio Feature9647', CAST(N'2023-04-17T18:55:18.9700000' AS DateTime2), CAST(N'2023-04-17T18:55:18.9700000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (26, N'Sabio Feature3269', CAST(N'2023-04-17T18:55:21.1300000' AS DateTime2), CAST(N'2023-04-17T18:55:21.1300000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (27, N'Sabio Feature3269', CAST(N'2023-04-17T18:55:21.1300000' AS DateTime2), CAST(N'2023-04-17T18:55:21.1300000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (28, N'Sabio Feature3269', CAST(N'2023-04-17T18:55:21.1300000' AS DateTime2), CAST(N'2023-04-17T18:55:21.1300000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (29, N'Sabio Feature2640', CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2), CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (30, N'Sabio Feature1492', CAST(N'2023-04-17T18:57:28.2866667' AS DateTime2), CAST(N'2023-04-17T18:57:28.2866667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (31, N'Sabio Feature1492', CAST(N'2023-04-17T18:57:28.2866667' AS DateTime2), CAST(N'2023-04-17T18:57:28.2866667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (32, N'Sabio Feature1492', CAST(N'2023-04-17T18:57:28.2866667' AS DateTime2), CAST(N'2023-04-17T18:57:28.2866667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (33, N'Sabio Feature5187', CAST(N'2023-04-17T18:59:05.5033333' AS DateTime2), CAST(N'2023-04-17T18:59:05.5033333' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (34, N'Sabio Feature5779', CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2), CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (35, N'Sabio Feature5779', CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2), CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (36, N'Sabio Feature5779', CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2), CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (37, N'Sabio Feature6355', CAST(N'2023-04-17T19:00:47.6933333' AS DateTime2), CAST(N'2023-04-17T19:00:47.6933333' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (38, N'Sabio Feature5709', CAST(N'2023-04-17T19:00:49.8500000' AS DateTime2), CAST(N'2023-04-17T19:00:49.8500000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (39, N'Sabio Feature5709', CAST(N'2023-04-17T19:00:49.8500000' AS DateTime2), CAST(N'2023-04-17T19:00:49.8500000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (40, N'Sabio Feature5709', CAST(N'2023-04-17T19:00:49.8500000' AS DateTime2), CAST(N'2023-04-17T19:00:49.8500000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (41, N'Sabio Feature3548', CAST(N'2023-04-17T19:01:46.5500000' AS DateTime2), CAST(N'2023-04-17T19:01:46.5500000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (42, N'Sabio Feature2962', CAST(N'2023-04-17T19:01:48.6966667' AS DateTime2), CAST(N'2023-04-17T19:01:48.6966667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (43, N'Sabio Feature2962', CAST(N'2023-04-17T19:01:48.6966667' AS DateTime2), CAST(N'2023-04-17T19:01:48.6966667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (44, N'Sabio Feature2962', CAST(N'2023-04-17T19:01:48.6966667' AS DateTime2), CAST(N'2023-04-17T19:01:48.6966667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (45, N'Sabio Feature1315', CAST(N'2023-04-17T19:02:00.1066667' AS DateTime2), CAST(N'2023-04-17T19:02:00.1066667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (46, N'Sabio Feature6457', CAST(N'2023-04-17T19:02:02.2400000' AS DateTime2), CAST(N'2023-04-17T19:02:02.2400000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (47, N'Sabio Feature6457', CAST(N'2023-04-17T19:02:02.2400000' AS DateTime2), CAST(N'2023-04-17T19:02:02.2400000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (48, N'Sabio Feature6457', CAST(N'2023-04-17T19:02:02.2400000' AS DateTime2), CAST(N'2023-04-17T19:02:02.2400000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (49, N'Sabio Feature9896', CAST(N'2023-04-17T19:03:29.1000000' AS DateTime2), CAST(N'2023-04-17T19:03:29.1000000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (50, N'Sabio Feature9686', CAST(N'2023-04-17T19:03:31.2233333' AS DateTime2), CAST(N'2023-04-17T19:03:31.2233333' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (51, N'Sabio Feature9686', CAST(N'2023-04-17T19:03:31.2233333' AS DateTime2), CAST(N'2023-04-17T19:03:31.2233333' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (52, N'Sabio Feature9686', CAST(N'2023-04-17T19:03:31.2233333' AS DateTime2), CAST(N'2023-04-17T19:03:31.2233333' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (53, N'Sabio Feature3069', CAST(N'2023-04-17T19:04:14.2100000' AS DateTime2), CAST(N'2023-04-17T19:04:14.2100000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (54, N'Sabio Feature1283', CAST(N'2023-04-17T19:04:16.3666667' AS DateTime2), CAST(N'2023-04-17T19:04:16.3666667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (55, N'Sabio Feature1283', CAST(N'2023-04-17T19:04:16.3666667' AS DateTime2), CAST(N'2023-04-17T19:04:16.3666667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (56, N'Sabio Feature1283', CAST(N'2023-04-17T19:04:16.3666667' AS DateTime2), CAST(N'2023-04-17T19:04:16.3666667' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (57, N'Sabio Feature4464', CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (58, N'Sabio Feature8522', CAST(N'2023-04-17T19:04:49.4100000' AS DateTime2), CAST(N'2023-04-17T19:04:49.4100000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (59, N'Sabio Feature8522', CAST(N'2023-04-17T19:04:49.4100000' AS DateTime2), CAST(N'2023-04-17T19:04:49.4100000' AS DateTime2))
INSERT [dbo].[Features] ([Id], [Name], [DateCreated], [DateModified]) VALUES (60, N'Sabio Feature8522', CAST(N'2023-04-17T19:04:49.4100000' AS DateTime2), CAST(N'2023-04-17T19:04:49.4100000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Features] OFF
GO
SET IDENTITY_INSERT [dbo].[Friends] ON 

INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (31, N'Best Friend 1', N'Biography 1', N'Summary 1', N'Headline 1', N'Slug 1', 1, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1001, CAST(N'2023-03-29T03:26:20.2266667' AS DateTime2), CAST(N'2023-03-29T03:26:20.2266667' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (32, N'Best Friend 2', N'Biography 2', N'Summary 2', N'Headline 2', N'Slug 2', 2, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1002, CAST(N'2023-03-29T03:26:20.7266667' AS DateTime2), CAST(N'2023-03-29T03:26:20.7266667' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (33, N'Best Friend 3', N'Biography 3', N'Summary 3', N'Headline 3', N'Slug 3', 3, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1003, CAST(N'2023-03-29T03:26:21.1933333' AS DateTime2), CAST(N'2023-03-29T03:26:21.1933333' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (34, N'Best Friend 4', N'Biography 4', N'Summary 4', N'Headline 4', N'Slug 4', 4, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1004, CAST(N'2023-03-29T03:26:21.7100000' AS DateTime2), CAST(N'2023-03-29T03:26:21.7100000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (35, N'Best Friend 5', N'Biography 5', N'Summary 5', N'Headline 5', N'Slug 5', 5, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1005, CAST(N'2023-03-29T03:26:22.1633333' AS DateTime2), CAST(N'2023-03-29T03:26:22.1633333' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (36, N'Best Friend 6', N'Biography 6', N'Summary 6', N'Headline 6', N'Slug 6', 6, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1006, CAST(N'2023-03-29T03:26:22.6466667' AS DateTime2), CAST(N'2023-03-29T03:26:22.6466667' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (37, N'Best Friend 7', N'Biography 7', N'Summary 7', N'Headline 7', N'Slug 7', 7, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1007, CAST(N'2023-03-29T03:26:23.1000000' AS DateTime2), CAST(N'2023-03-29T03:26:23.1000000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (38, N'Best Friend 8', N'Biography 8', N'Summary 8', N'Headline 8', N'Slug 8', 8, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1008, CAST(N'2023-03-29T03:26:23.5533333' AS DateTime2), CAST(N'2023-03-29T03:26:23.5533333' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (39, N'Best Friend 9', N'Biography 9', N'Summary 9', N'Headline 9', N'Slug 9', 9, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1009, CAST(N'2023-03-29T03:26:24.0066667' AS DateTime2), CAST(N'2023-03-29T03:26:24.0066667' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (42, N'Best Friend 12', N'Biography 12', N'Summary 12', N'Headline 12', N'Slug 12', 12, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1012, CAST(N'2023-03-29T03:26:25.3833333' AS DateTime2), CAST(N'2023-03-29T03:26:25.3833333' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (43, N'Best Friend 13', N'Biography 13', N'Summary 13', N'Headline 13', N'Slug 13', 13, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1013, CAST(N'2023-03-29T03:26:25.8500000' AS DateTime2), CAST(N'2023-03-29T03:26:25.8500000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (44, N'Best Friend 14', N'Biography 14', N'Summary 14', N'Headline 14', N'Slug 14', 14, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1014, CAST(N'2023-03-29T03:26:26.3033333' AS DateTime2), CAST(N'2023-03-29T03:26:26.3033333' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (45, N'Jason the Leader', N'This is my bio', N'My summary', N'My headline', N'SLUgHyHytGrF', 1, N'somecrazyavatar.bmp', 4, CAST(N'2023-03-29T03:26:26.7566667' AS DateTime2), CAST(N'2023-04-14T03:51:55.3500000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (46, N'Best Friend 16', N'Biography 16', N'Summary 16', N'Headline 16', N'Slug 16', 16, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1016, CAST(N'2023-03-29T03:26:27.2400000' AS DateTime2), CAST(N'2023-03-29T03:26:27.2400000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (47, N'Best Friend 17', N'Biography 17', N'Summary 17', N'Headline 17', N'Slug 17', 17, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1017, CAST(N'2023-03-29T03:26:27.7266667' AS DateTime2), CAST(N'2023-03-29T03:26:27.7266667' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (48, N'Best Friend 18', N'Biography 18', N'Summary 18', N'Headline 18', N'Slug 18', 18, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1018, CAST(N'2023-03-29T03:26:28.2100000' AS DateTime2), CAST(N'2023-03-29T03:26:28.2100000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (49, N'Title_Update88618', N'Bio_Update88618', N'Summary_Update88618', N'Headline_Update88618', N'Slug_Update88618', 2, N'https://updated_image.png88618', 8, CAST(N'2023-03-29T03:26:28.6800000' AS DateTime2), CAST(N'2023-04-13T17:21:29.2200000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (50, N'Best Friend 20', N'Biography 20', N'Summary 20', N'Headline 20', N'Slug 20', 20, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1020, CAST(N'2023-03-29T03:26:29.1333333' AS DateTime2), CAST(N'2023-03-29T03:26:29.1333333' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (51, N'Best Friend 21', N'Biography 21', N'Summary 21', N'Headline 21', N'Slug 21', 21, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1021, CAST(N'2023-03-29T03:26:29.6066667' AS DateTime2), CAST(N'2023-03-29T03:26:29.6066667' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (52, N'Best Friend 22', N'Biography 22', N'Summary 22', N'Headline 22', N'Slug 22', 22, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1022, CAST(N'2023-03-29T03:26:30.0600000' AS DateTime2), CAST(N'2023-03-29T03:26:30.0600000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (53, N'Best Friend 23', N'Biography 23', N'Summary 23', N'Headline 23', N'Slug 23', 23, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1023, CAST(N'2023-03-29T03:26:30.5266667' AS DateTime2), CAST(N'2023-03-29T03:26:30.5266667' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (54, N'Best Friend 24', N'Biography 24', N'Summary 24', N'Headline 24', N'Slug 24', 24, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1024, CAST(N'2023-03-29T03:26:30.9966667' AS DateTime2), CAST(N'2023-03-29T03:26:30.9966667' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (55, N'Best Friend 25', N'Biography 25', N'Summary 25', N'Headline 25', N'Slug 25', 25, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1025, CAST(N'2023-03-29T03:26:31.4633333' AS DateTime2), CAST(N'2023-03-29T03:26:31.4633333' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (56, N'Best Friend 26', N'Biography 26', N'Summary 26', N'Headline 26', N'Slug 26', 26, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1026, CAST(N'2023-03-29T03:26:31.9200000' AS DateTime2), CAST(N'2023-03-29T03:26:31.9200000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (57, N'Best Friend 27', N'Biography 27', N'Summary 27', N'Headline 27', N'Slug 27', 27, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1027, CAST(N'2023-03-29T03:26:32.3866667' AS DateTime2), CAST(N'2023-03-29T03:26:32.3866667' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (58, N'Best Friend 28', N'Biography 28', N'Summary 28', N'Headline 28', N'Slug 28', 28, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1028, CAST(N'2023-03-29T03:26:32.8400000' AS DateTime2), CAST(N'2023-03-29T03:26:32.8400000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (59, N'Best Friend 29', N'Biography 29', N'Summary 29', N'Headline 29', N'Slug 29', 29, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1029, CAST(N'2023-03-29T03:26:33.3100000' AS DateTime2), CAST(N'2023-03-29T03:26:33.3100000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (60, N'Best Friend 30', N'Biography 30', N'Summary 30', N'Headline 30', N'Slug 30', 30, N'https://www.gamespot.com/a/uploads/scale_medium/1593/15930215/3534316-box01.jpg', 1030, CAST(N'2023-03-29T03:26:33.7766667' AS DateTime2), CAST(N'2023-03-29T03:26:33.7766667' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (62, N'Jason the Leader', N'This is my bio', N'My summary', N'My headline', N'SLUgHyHytGrF', 1, N'somecrazyavatar.bmp', 5665, CAST(N'2023-03-29T05:13:43.6233333' AS DateTime2), CAST(N'2023-03-29T05:13:43.6233333' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (63, N'Jason the Leader', N'This is my bio', N'My summary', N'My headline', N'SLUgHyHytGrF', 1, N'somecrazyavatar.bmp', 5665, CAST(N'2023-03-29T05:13:48.4433333' AS DateTime2), CAST(N'2023-03-29T05:13:48.4433333' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (64, N'Jason the Leader', N'This is my bio', N'My summary', N'My headline', N'SLUgHyHytGrF', 1, N'somecrazyavatar.bmp', 5665, CAST(N'2023-03-29T05:13:50.2700000' AS DateTime2), CAST(N'2023-03-29T05:13:50.2700000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (65, N'Jason the Leader', N'This is my bio', N'My summary', N'My headline', N'SLUgHyHytGrF', 1, N'somecrazyavatar.bmp', 5665, CAST(N'2023-03-29T05:13:51.3166667' AS DateTime2), CAST(N'2023-03-29T05:13:51.3166667' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (66, N'Jason the Leader', N'This is my bio', N'My summary', N'My headline', N'SLUgHyHytGrF', 1, N'somecrazyavatar.bmp', 5665, CAST(N'2023-03-29T05:13:53.2100000' AS DateTime2), CAST(N'2023-03-29T05:13:53.2100000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (93, N'Unique2801', N'bio', N'summary', N'headline', N'slug', 1, N'url', 1, CAST(N'2023-03-29T13:25:44.2300000' AS DateTime2), CAST(N'2023-03-29T13:25:44.2300000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (94, N'Unique2801', N'bio', N'summary', N'headline', N'slug', 2, N'url', 1, CAST(N'2023-03-29T13:25:44.2300000' AS DateTime2), CAST(N'2023-03-29T13:25:44.2300000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (95, N'Unique2801', N'bio', N'summary', N'headline', N'slug', 1, N'url', 1, CAST(N'2023-03-29T13:25:44.2300000' AS DateTime2), CAST(N'2023-03-29T13:25:44.2300000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (96, N'Title_Update', N'Bio_Update', N'Summary_Update', N'Headline_Update', N'Slug_Update', 0, N'https://updated_image.png', 8, CAST(N'2023-03-29T13:25:44.2300000' AS DateTime2), CAST(N'2023-04-13T16:10:20.5600000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (97, N'Unique2801', N'bio', N'summary', N'headline', N'slug', 1, N'url', 1, CAST(N'2023-03-29T13:25:44.2300000' AS DateTime2), CAST(N'2023-03-29T13:25:44.2300000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (98, N'Unique2801', N'bio', N'summary', N'headline', N'slug', 1, N'url', 1, CAST(N'2023-03-29T13:25:44.2300000' AS DateTime2), CAST(N'2023-03-29T13:25:44.2300000' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (102, N'Title_Insert', N'Bio_Insert', N'Summary_Insert', N'Headline_Insert', N'Slug_Insert', 2, N'https://insert_image.png', 8, CAST(N'2023-04-13T16:10:12.9233333' AS DateTime2), CAST(N'2023-04-13T16:10:12.9233333' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (104, N'Title_Insert', N'Bio_Insert', N'Summary_Insert', N'Headline_Insert', N'Slug_Insert', 2, N'https://insert_image.png', 8, CAST(N'2023-04-13T17:11:35.6333333' AS DateTime2), CAST(N'2023-04-13T17:11:35.6333333' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (105, N'Title_Insert', N'Bio_Insert', N'Summary_Insert', N'Headline_Insert', N'Slug_Insert', 2, N'https://insert_image.png', 8, CAST(N'2023-04-13T17:12:52.2333333' AS DateTime2), CAST(N'2023-04-13T17:12:52.2333333' AS DateTime2))
INSERT [dbo].[Friends] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageUrl], [UserId], [DateCreated], [DateModified]) VALUES (107, N'John112', N'Nelson112', N'user@example.com112', N'string122', N'string1230000122', 2, N'image2.jpg', 9, CAST(N'2023-04-14T03:42:54.5000000' AS DateTime2), CAST(N'2023-04-14T03:47:03.8533333' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Friends] OFF
GO
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (476, 1)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (477, 2)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (478, 3)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (481, 5)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (482, 6)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (483, 7)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (486, 14)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (487, 15)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (488, 16)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (489, 17)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (491, 19)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (492, 20)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (493, 21)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (494, 22)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (495, 23)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (496, 24)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (497, 25)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (498, 26)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (499, 75)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (500, 6)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (500, 7)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (500, 76)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (500, 112)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (500, 113)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (500, 117)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (500, 402)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (500, 406)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (500, 407)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (501, 77)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (502, 78)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (503, 19)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (504, 80)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (505, 81)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (506, 82)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (507, 83)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (508, 84)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (509, 1)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (510, 2)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (511, 3)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (512, 4)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (513, 5)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (513, 311)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (514, 6)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (515, 7)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (516, 8)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (517, 14)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (518, 13)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (519, 15)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (520, 16)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (521, 17)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (522, 18)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (523, 19)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (524, 20)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (658, 6)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (658, 7)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (658, 107)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (658, 108)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (679, 6)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (679, 7)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (679, 118)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (679, 119)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1047, 6)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1047, 7)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1047, 107)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1047, 108)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1084, 311)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1084, 312)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1084, 313)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1084, 314)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1121, 311)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1121, 312)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1121, 313)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1121, 314)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1122, 311)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1122, 312)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1122, 313)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1122, 314)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1147, 313)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1147, 314)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1147, 355)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1147, 356)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1148, 313)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1148, 314)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1148, 355)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1148, 356)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1161, 313)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1161, 314)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1161, 355)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1161, 356)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1207, 313)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1207, 314)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1207, 355)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1207, 356)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1220, 7)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1220, 399)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1224, 313)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1224, 314)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1224, 355)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1224, 356)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1224, 398)
GO
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1224, 401)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1226, 401)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1226, 408)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1227, 1)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1227, 7)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1227, 399)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1228, 399)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1228, 400)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1229, 389)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1229, 403)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1229, 404)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1229, 405)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1230, 409)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1230, 410)
INSERT [dbo].[FriendSkills] ([FriendId], [SkillId]) VALUES (1230, 411)
GO
SET IDENTITY_INSERT [dbo].[FriendsV2] ON 

INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (476, N'Best Friend 1', N'Bio 1', N'Summary 1', N'Headline 1', N'Slig 1', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (477, N'Best Friend 2', N'Bio 2', N'Summary 2', N'Headline 2', N'Slig 2', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (478, N'Best Friend 3', N'Bio 3', N'Summary 3', N'Headline 3', N'Slig 3', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (481, N'Best Friend 6', N'Bio 6', N'Summary 6', N'Headline 6', N'Slig 6', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (482, N'Best Friend 7', N'Bio 7', N'Summary 7', N'Headline 7', N'Slig 7', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (483, N'Best Friend 8', N'Bio 8', N'Summary 8', N'Headline 8', N'Slig 8', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (486, N'Best Friend 11', N'Bio 11', N'Summary 11', N'Headline 11', N'Slig 11', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (487, N'Best Friend 12', N'Bio 12', N'Summary 12', N'Headline 12', N'Slig 12', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (488, N'Best Friend 13', N'Bio 13', N'Summary 13', N'Headline 13', N'Slig 13', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), CAST(N'2023-03-31T02:48:18.8833333' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (489, N'Best Friend 14', N'Bio 14', N'Summary 14', N'Headline 14', N'Slig 14', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (491, N'Best Friend 16', N'Bio 16', N'Summary 16', N'Headline 16', N'Slig 16', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (492, N'Best Friend 17', N'Bio 17', N'Summary 17', N'Headline 17', N'Slig 17', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (493, N'Best Friend 18', N'Bio 18', N'Summary 18', N'Headline 18', N'Slig 18', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (494, N'Best Friend 19', N'Bio 19', N'Summary 19', N'Headline 19', N'Slig 19', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (495, N'Best Friend 20', N'Bio 20', N'Summary 20', N'Headline 20', N'Slig 20', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (496, N'Best Friend 21', N'Bio 21', N'Summary 21', N'Headline 21', N'Slig 21', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (497, N'Best Friend 22', N'Bio 22', N'Summary 22', N'Headline 22', N'Slig 22', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (498, N'Best Friend 23', N'Bio 23', N'Summary 23', N'Headline 23', N'Slig 23', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (499, N'Best Friend 24', N'Bio 24', N'Summary 24', N'Headline 24', N'Slig 24', 1, 31, 5667, CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9000000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (500, N'500 Friend 005', N'This is my bio 500', N'My summary 500', N'My headline 500', N'SLUgHyHytGrF500', 1, 31, 1008, CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), CAST(N'2023-04-17T16:24:40.4800000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (501, N'Best Friend 26', N'Bio 26', N'Summary 26', N'Headline 26', N'Slig 26', 1, 40, 5667, CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (502, N'Best Friend 27', N'Bio 27', N'Summary 27', N'Headline 27', N'Slig 27', 1, 42, 1008, CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), CAST(N'2023-04-15T02:31:31.7533333' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (503, N'Best Friend 28', N'Bio 28', N'Summary 28', N'Headline 28', N'Slig 28', 1, 44, 5667, CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (504, N'Best Friend 29', N'Bio 29', N'Summary 29', N'Headline 29', N'Slig 29', 1, 46, 5667, CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (505, N'Best Friend 30', N'Bio 30', N'Summary 30', N'Headline 30', N'Slig 30', 1, 48, 5667, CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (506, N'Best Friend 31', N'Bio 31', N'Summary 31', N'Headline 31', N'Slig 31', 1, 50, 5667, CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (507, N'Best Friend 32', N'Bio 32', N'Summary 32', N'Headline 32', N'Slig 32', 1, 52, 5667, CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (508, N'Best Friend 33', N'Bio 33', N'Summary 33', N'Headline 33', N'Slig 33', 1, 54, 5667, CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (509, N'Best Friend 34', N'Bio 34', N'Summary 34', N'Headline 34', N'Slig 34', 1, 56, 5667, CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (510, N'Best Friend 35', N'Bio 35', N'Summary 35', N'Headline 35', N'Slig 35', 1, 58, 5667, CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), CAST(N'2023-03-31T02:48:18.9166667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (511, N'Best Friend 36', N'Bio 36', N'Summary 36', N'Headline 36', N'Slig 36', 1, 60, 5667, CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (512, N'Best Friend 37', N'Bio 37', N'Summary 37', N'Headline 37', N'Slig 37', 1, 62, 5667, CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (513, N'Best Friend 38', N'Bio 38', N'Summary 38', N'Headline 38', N'Slig 38', 1, 64, 5667, CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (514, N'Best Friend 39', N'Bio 39', N'Summary 39', N'Headline 39', N'Slig 39', 1, 66, 5667, CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (515, N'Best Friend 40', N'Bio 40', N'Summary 40', N'Headline 40', N'Slig 40', 1, 68, 5667, CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (516, N'Best Friend 41', N'Bio 41', N'Summary 41', N'Headline 41', N'Slig 41', 1, 70, 5667, CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (517, N'Best Friend 42', N'Bio 42', N'Summary 42', N'Headline 42', N'Slig 42', 1, 72, 5667, CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (518, N'Best Friend 43', N'Bio 43', N'Summary 43', N'Headline 43', N'Slig 43', 1, 74, 5667, CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (519, N'Best Friend 44', N'Bio 44', N'Summary 44', N'Headline 44', N'Slig 44', 1, 76, 5667, CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (520, N'Best Friend 45', N'Bio 45', N'Summary 45', N'Headline 45', N'Slig 45', 1, 78, 5667, CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (521, N'Best Friend 46', N'Bio 46', N'Summary 46', N'Headline 46', N'Slig 46', 1, 80, 5667, CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (522, N'Best Friend 47', N'Bio 47', N'Summary 47', N'Headline 47', N'Slig 47', 1, 82, 5667, CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (523, N'Best Friend 48', N'Bio 48', N'Summary 48', N'Headline 48', N'Slig 48', 1, 84, 5667, CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), CAST(N'2023-03-31T02:48:18.9300000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (524, N'Best Friend 49', N'Bio 49', N'Summary 49', N'Headline 49', N'Slig 49', 1, 86, 5667, CAST(N'2023-03-31T02:48:18.9466667' AS DateTime2), CAST(N'2023-03-31T02:48:18.9466667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (658, N'Bogie', N'This is my bio', N'My summary', N'My headline', N'SLUgHyHytGrF', 1, 124, 4, CAST(N'2023-03-31T17:20:05.1866667' AS DateTime2), CAST(N'2023-03-31T17:20:05.1866667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (679, N'Bogie', N'This is my bio', N'My summary', N'My headline', N'SLUgHyHytGrF', 1, 133, 4, CAST(N'2023-04-01T19:45:35.8033333' AS DateTime2), CAST(N'2023-04-01T19:45:35.8033333' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1047, N'Bogie', N'This is my bio', N'My summary', N'My headline', N'SLUgHyHytGrF', 1, 310, 4, CAST(N'2023-04-01T22:39:48.4966667' AS DateTime2), CAST(N'2023-04-01T22:39:48.4966667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1084, N'Bogie', N'This is my bio', N'My summary', N'My headline', N'SLUgHyHytGrF', 1, 329, 4, CAST(N'2023-04-03T13:11:37.6166667' AS DateTime2), CAST(N'2023-04-03T13:11:37.6166667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1121, N'Bogie', N'This is my bio', N'My summary', N'My headline', N'SLUgHyHytGrF1112', 1, 348, 4, CAST(N'2023-04-03T15:51:35.2000000' AS DateTime2), CAST(N'2023-04-03T15:51:35.2000000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1122, N'Bogie', N'This is my bio', N'My summary', N'My headline', N'SLUgHyHytGrF1112', 1, 349, 4, CAST(N'2023-04-03T22:46:02.9233333' AS DateTime2), CAST(N'2023-04-03T22:46:02.9233333' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1147, N'Hey!!!!', N'This is my bio', N'My summary', N'My headline', N'hghghghg1234', 1, 362, 4, CAST(N'2023-04-03T22:59:27.5433333' AS DateTime2), CAST(N'2023-04-03T22:59:27.5433333' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1148, N'Hey!!!!', N'This is my bio', N'My summary', N'My headline', N'hghghghg1234', 1, 363, 4, CAST(N'2023-04-03T23:12:32.7533333' AS DateTime2), CAST(N'2023-04-03T23:12:32.7533333' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1161, N'Hey!!!!', N'This is my bio', N'My summary', N'My headline', N'hghghghg1234', 1, 370, 4, CAST(N'2023-04-03T23:42:15.4366667' AS DateTime2), CAST(N'2023-04-03T23:42:15.4366667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1207, N'Hey!!!!', N'This is my bio', N'My summary', N'My headline', N'hghghghg1234', 1, 392, 4, CAST(N'2023-04-03T23:52:57.9266667' AS DateTime2), CAST(N'2023-04-03T23:52:57.9266667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1220, N'John111', N'Nelson111', N'user@example.com111', N'string123', N'string1230000123', 1, 476, 8, CAST(N'2023-04-11T03:06:46.6900000' AS DateTime2), CAST(N'2023-04-14T21:02:07.9100000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1221, N'Title_Insert', N'Bio_Insert', N'Summary_Insert', N'Headline_Insert', N'Slug_Insert', 2, 477, 8, CAST(N'2023-04-14T19:39:59.5066667' AS DateTime2), CAST(N'2023-04-14T19:39:59.5066667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1222, N'John111', N'Nelson111', N'user@example.com111', N'string123', N'string1230000123', 1, 478, 8, CAST(N'2023-04-14T19:45:26.4300000' AS DateTime2), CAST(N'2023-04-14T19:45:26.4300000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1223, N'John111', N'Nelson111', N'user@example.com111', N'string123', N'string1230000123', 1, 479, 8, CAST(N'2023-04-14T19:46:38.4400000' AS DateTime2), CAST(N'2023-04-14T19:46:38.4400000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1224, N'Title_Update58078', N'Bio_Update58078', N'Summary_Update58078', N'Headline_Update58078', N'Slug_Update58078', 2, 480, 8, CAST(N'2023-04-14T19:52:00.5266667' AS DateTime2), CAST(N'2023-04-14T20:37:58.0700000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1226, N'Title_Insert', N'Bio_Insert', N'Summary_Insert', N'Headline_Insert', N'Slug_Insert', 2, 482, 1008, CAST(N'2023-04-14T20:27:27.9966667' AS DateTime2), CAST(N'2023-04-15T16:26:31.5866667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1227, N'John111', N'Nelson111', N'user@example.com111', N'string123', N'string1230000123', 1, 483, 8, CAST(N'2023-04-14T21:08:59.6800000' AS DateTime2), CAST(N'2023-04-14T21:09:59.2866667' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1228, N'Johnggggggg', N'hhhhh', N'user@example.com5555', N'string123', N'string1230000123', 1, 484, 1008, CAST(N'2023-04-15T01:58:03.0300000' AS DateTime2), CAST(N'2023-04-15T02:04:57.6600000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1229, N'ONE', N'FOUR', N'THREE', N'TWO', N'FIVE', 1, 485, 1008, CAST(N'2023-04-15T02:03:54.6566667' AS DateTime2), CAST(N'2023-04-15T02:04:45.3900000' AS DateTime2), 0)
INSERT [dbo].[FriendsV2] ([Id], [Title], [Bio], [Summary], [Headline], [Slug], [StatusId], [PrimaryImageId], [UserId], [DateCreated], [DateModified], [EntityTypeId]) VALUES (1230, N'uifukfff', N'jkb;kjgbk;lg', N'hjfjjfjfufk', N'gjfkgjfkfghf', N'hklghklghklg', 1, 486, 1008, CAST(N'2023-04-17T16:24:20.0500000' AS DateTime2), CAST(N'2023-04-17T16:24:20.0500000' AS DateTime2), 0)
SET IDENTITY_INSERT [dbo].[FriendsV2] OFF
GO
SET IDENTITY_INSERT [dbo].[Images] ON 

INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (2, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 6, CAST(N'2023-03-29T20:40:46.9900000' AS DateTime2), CAST(N'2023-03-29T20:40:46.9900000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (3, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 7, CAST(N'2023-03-29T20:41:26.9333333' AS DateTime2), CAST(N'2023-03-29T20:41:26.9333333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (5, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 9, CAST(N'2023-03-29T20:41:55.0333333' AS DateTime2), CAST(N'2023-03-29T20:41:55.0333333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (6, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5665, CAST(N'2023-03-29T23:45:16.0300000' AS DateTime2), CAST(N'2023-03-29T23:45:16.0300000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (7, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5665, CAST(N'2023-03-30T00:07:38.6300000' AS DateTime2), CAST(N'2023-03-30T00:07:38.6300000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (8, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5665, CAST(N'2023-03-30T00:09:35.0933333' AS DateTime2), CAST(N'2023-03-30T00:09:35.0933333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (15, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5665, CAST(N'2023-03-30T20:13:32.0200000' AS DateTime2), CAST(N'2023-03-30T20:13:32.0200000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (16, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5665, CAST(N'2023-03-30T20:31:09.5500000' AS DateTime2), CAST(N'2023-03-30T20:31:09.5500000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (17, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5667, CAST(N'2023-03-30T20:32:44.8466667' AS DateTime2), CAST(N'2023-03-30T20:32:44.8466667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (18, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5667, CAST(N'2023-03-30T20:42:58.4300000' AS DateTime2), CAST(N'2023-03-30T20:42:58.4300000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (20, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5667, CAST(N'2023-03-30T21:02:45.7433333' AS DateTime2), CAST(N'2023-03-30T21:02:45.7433333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (21, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5667, CAST(N'2023-03-30T21:03:36.2733333' AS DateTime2), CAST(N'2023-03-30T21:03:36.2733333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (26, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5667, CAST(N'2023-03-30T22:17:39.2000000' AS DateTime2), CAST(N'2023-03-30T22:17:39.2000000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (27, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5667, CAST(N'2023-03-30T22:22:15.2333333' AS DateTime2), CAST(N'2023-03-30T22:22:15.2333333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (29, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5667, CAST(N'2023-03-30T22:25:00.1700000' AS DateTime2), CAST(N'2023-03-30T22:25:00.1700000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (31, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 8164, CAST(N'2023-03-30T22:25:07.0666667' AS DateTime2), CAST(N'2023-03-30T22:25:07.0666667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (33, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 7356, CAST(N'2023-03-30T22:47:10.8133333' AS DateTime2), CAST(N'2023-03-30T22:47:10.8133333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (35, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 3465, CAST(N'2023-03-30T22:56:14.6133333' AS DateTime2), CAST(N'2023-03-30T22:56:14.6133333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (36, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5667, CAST(N'2023-03-30T23:14:41.5666667' AS DateTime2), CAST(N'2023-03-30T23:14:41.5666667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (38, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 1008, CAST(N'2023-03-30T23:16:15.8133333' AS DateTime2), CAST(N'2023-04-17T16:24:40.4800000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (40, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 7058, CAST(N'2023-03-30T23:18:37.0933333' AS DateTime2), CAST(N'2023-03-30T23:18:37.0933333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (42, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 1008, CAST(N'2023-03-30T23:19:01.0533333' AS DateTime2), CAST(N'2023-04-15T02:31:31.7533333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (44, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 7580, CAST(N'2023-03-30T23:23:56.1100000' AS DateTime2), CAST(N'2023-03-30T23:23:56.1100000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (46, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5809, CAST(N'2023-03-31T00:03:54.1666667' AS DateTime2), CAST(N'2023-03-31T00:03:54.1666667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (48, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 2006, CAST(N'2023-03-31T00:06:32.6800000' AS DateTime2), CAST(N'2023-03-31T00:06:32.6800000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (50, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 8449, CAST(N'2023-03-31T00:10:48.4800000' AS DateTime2), CAST(N'2023-03-31T00:10:48.4800000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (52, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5790, CAST(N'2023-03-31T00:17:13.8133333' AS DateTime2), CAST(N'2023-03-31T00:17:13.8133333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (54, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 1537, CAST(N'2023-03-31T00:19:25.1400000' AS DateTime2), CAST(N'2023-03-31T00:19:25.1400000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (56, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 2235, CAST(N'2023-03-31T00:21:22.3300000' AS DateTime2), CAST(N'2023-03-31T00:21:22.3300000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (58, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 6894, CAST(N'2023-03-31T00:23:51.3766667' AS DateTime2), CAST(N'2023-03-31T00:23:51.3766667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (60, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 9268, CAST(N'2023-03-31T00:28:58.3866667' AS DateTime2), CAST(N'2023-03-31T00:28:58.3866667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (62, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 9320, CAST(N'2023-03-31T00:29:54.9200000' AS DateTime2), CAST(N'2023-03-31T00:29:54.9200000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (64, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4250, CAST(N'2023-03-31T00:31:20.9066667' AS DateTime2), CAST(N'2023-03-31T00:31:20.9066667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (66, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5379, CAST(N'2023-03-31T00:52:02.1200000' AS DateTime2), CAST(N'2023-03-31T00:52:02.1200000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (68, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 5100, CAST(N'2023-03-31T00:53:21.5366667' AS DateTime2), CAST(N'2023-03-31T00:53:21.5366667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (70, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 987, CAST(N'2023-03-31T00:59:00.2433333' AS DateTime2), CAST(N'2023-03-31T00:59:00.2433333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (72, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 6386, CAST(N'2023-03-31T01:03:05.4833333' AS DateTime2), CAST(N'2023-03-31T01:03:05.4833333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (74, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 9246, CAST(N'2023-03-31T01:27:53.9500000' AS DateTime2), CAST(N'2023-03-31T01:27:53.9500000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (76, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 3582, CAST(N'2023-03-31T01:32:05.0166667' AS DateTime2), CAST(N'2023-03-31T01:32:05.0166667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (78, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 8465, CAST(N'2023-03-31T01:33:02.7733333' AS DateTime2), CAST(N'2023-03-31T01:33:02.7733333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (80, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 1972, CAST(N'2023-03-31T01:38:57.5766667' AS DateTime2), CAST(N'2023-03-31T01:38:57.5766667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (82, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 8084, CAST(N'2023-03-31T01:40:15.2833333' AS DateTime2), CAST(N'2023-03-31T01:40:15.2833333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (84, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 8807, CAST(N'2023-03-31T02:19:17.6633333' AS DateTime2), CAST(N'2023-03-31T02:19:17.6633333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (86, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 6410, CAST(N'2023-03-31T02:19:57.2733333' AS DateTime2), CAST(N'2023-03-31T02:19:57.2733333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (124, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-03-31T17:20:05.1866667' AS DateTime2), CAST(N'2023-03-31T17:20:05.1866667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (133, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-01T19:45:35.8033333' AS DateTime2), CAST(N'2023-04-01T19:45:35.8033333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (310, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-01T22:39:48.4966667' AS DateTime2), CAST(N'2023-04-01T22:39:48.4966667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (329, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-03T13:11:37.6166667' AS DateTime2), CAST(N'2023-04-03T13:11:37.6166667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (348, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-03T15:51:35.2000000' AS DateTime2), CAST(N'2023-04-03T15:51:35.2000000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (349, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-03T22:46:02.9233333' AS DateTime2), CAST(N'2023-04-03T22:46:02.9233333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (362, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-03T22:59:27.5266667' AS DateTime2), CAST(N'2023-04-03T22:59:27.5266667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (363, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-03T23:12:32.7533333' AS DateTime2), CAST(N'2023-04-03T23:12:32.7533333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (370, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-03T23:42:15.4366667' AS DateTime2), CAST(N'2023-04-03T23:42:15.4366667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (392, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-03T23:52:57.9266667' AS DateTime2), CAST(N'2023-04-03T23:52:57.9266667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (400, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-04T03:23:37.9700000' AS DateTime2), CAST(N'2023-04-04T03:23:37.9700000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (401, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-04T03:23:58.4700000' AS DateTime2), CAST(N'2023-04-04T03:23:58.4700000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (412, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (413, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (414, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (415, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (460, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2), CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (461, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2), CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (462, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2), CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (463, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2), CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (464, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2), CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (465, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2), CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (466, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2), CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (467, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2), CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (468, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (469, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (470, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (471, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (472, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (473, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (474, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (475, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 4, CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (476, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 8, CAST(N'2023-04-11T03:06:46.6900000' AS DateTime2), CAST(N'2023-04-14T21:02:07.9100000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (477, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 8, CAST(N'2023-04-14T19:39:59.5066667' AS DateTime2), CAST(N'2023-04-14T19:39:59.5066667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (478, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 8, CAST(N'2023-04-14T19:45:26.4300000' AS DateTime2), CAST(N'2023-04-14T19:45:26.4300000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (479, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 8, CAST(N'2023-04-14T19:46:38.4400000' AS DateTime2), CAST(N'2023-04-14T19:46:38.4400000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (480, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 8, CAST(N'2023-04-14T19:52:00.5266667' AS DateTime2), CAST(N'2023-04-14T20:37:58.0700000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (482, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 1008, CAST(N'2023-04-14T20:27:27.9966667' AS DateTime2), CAST(N'2023-04-15T16:26:31.5866667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (483, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 8, CAST(N'2023-04-14T21:08:59.6800000' AS DateTime2), CAST(N'2023-04-14T21:09:59.2866667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (484, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 1008, CAST(N'2023-04-15T01:58:03.0133333' AS DateTime2), CAST(N'2023-04-15T02:04:57.6600000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (485, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 1008, CAST(N'2023-04-15T02:03:54.6566667' AS DateTime2), CAST(N'2023-04-15T02:04:45.3900000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (486, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 1008, CAST(N'2023-04-17T16:24:20.0500000' AS DateTime2), CAST(N'2023-04-17T16:24:20.0500000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (491, 1, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 8, CAST(N'2023-04-18T19:47:11.6600000' AS DateTime2), CAST(N'2023-04-18T19:47:11.6600000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (495, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx2T2zq5M9mr6QJa6OCBzfbqKF6o1F547Dfw&usqp=CAU', 1008, CAST(N'2023-04-18T19:55:57.7600000' AS DateTime2), CAST(N'2023-04-18T19:55:57.7600000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (497, 3, N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ3NLANRa_iKXs9LX0c_wLRk-0sr0QaRvwMAMhCoFBTSA&s', 1008, CAST(N'2023-04-18T20:24:13.5800000' AS DateTime2), CAST(N'2023-04-18T20:24:13.5800000' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (499, 3, N'image.jpg', 1008, CAST(N'2023-04-18T21:51:25.4566667' AS DateTime2), CAST(N'2023-04-18T21:51:25.4566667' AS DateTime2), 0)
INSERT [dbo].[Images] ([Id], [TypeId], [Url], [UserId], [DateCreated], [DateModified], [EntityId]) VALUES (501, 1, N'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxMTgwOTN8MHwxfHNlYXJjaHwxfHxhcHBsZXxlbnwwfHx8fDE2ODE5NDM4ODM&ixlib=rb-4.0.3&q=80&w=1080', 1008, CAST(N'2023-04-19T22:38:12.9833333' AS DateTime2), CAST(N'2023-04-19T22:38:12.9833333' AS DateTime2), 0)
SET IDENTITY_INSERT [dbo].[Images] OFF
GO
SET IDENTITY_INSERT [dbo].[Jobs] ON 

INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (2, N'Software Developer', N'92,000.00', N'Software Dev Summary', N'Software Dev Description', N'Software Dev Short Description', N'Software Dev Short Title', NULL, 4, 4, N'SOFTWAREDEV100001                                 ', 0, N'Active    ', CAST(N'2023-04-05T18:01:58.7666667' AS DateTime2), CAST(N'2023-04-05T18:01:58.7666667' AS DateTime2), 0, NULL, 1)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (4, N'Software Developer WHAT? 123', N'89,000 W', N'SD Summary WHAT?', N'SD Desc WHAT?', N'SD Short Desc', N'SD Short Title', NULL, 4, 202, N'SOFTWAREDEV100002 WHAT?                           ', 0, N'Active    ', CAST(N'2023-04-05T18:06:12.9200000' AS DateTime2), CAST(N'2023-04-05T18:06:12.9200000' AS DateTime2), 0, NULL, 2)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (5, N'Software Dev 1', N'100,000.00', N'Summary 123', N'Description 123', N'Short Description 123', N'Short Title 123', NULL, 4, 4, N'SLUG123456                                        ', 0, N'Active    ', CAST(N'2023-04-05T18:10:50.1666667' AS DateTime2), CAST(N'2023-04-05T18:10:50.1666667' AS DateTime2), 0, NULL, 5)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (6, N'Software Dev 2', N'100,000.00', N'Summary 124', N'Description 124', N'Short Description 124', N'Short Title 124', NULL, 4, 4, N'SLUG123457                                        ', 0, N'Active    ', CAST(N'2023-04-05T18:11:10.5766667' AS DateTime2), CAST(N'2023-04-05T18:11:10.5766667' AS DateTime2), 0, NULL, 6)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (7, N'Software Dev 3', N'100,000.01', N'Summary 125', N'Description 125', N'Short Description 125', N'Short Title 125', NULL, 4, 4, N'SLUG123458                                        ', 0, N'Active    ', CAST(N'2023-04-05T18:11:33.3966667' AS DateTime2), CAST(N'2023-04-05T18:11:33.3966667' AS DateTime2), 0, NULL, 6)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (8, N'Legacy Engineer 123', N'126,000.00', N'Summary 433', N'Description 433', N'Short Description 126', N'Short Title 126', NULL, 4, 4, N'SLUGINSERT10002                                   ', 0, N'Active    ', CAST(N'2023-04-05T18:11:50.4600000' AS DateTime2), CAST(N'2023-04-05T18:11:50.4600000' AS DateTime2), 0, NULL, 9)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (9, N'Software Dev 5', N'100,000.03', N'Summary 127', N'Description 127', N'Short Description 127', N'Short Title 127', NULL, 4, 4, N'SLUG123460                                        ', 0, N'Active    ', CAST(N'2023-04-05T18:12:15.4266667' AS DateTime2), CAST(N'2023-04-05T18:12:15.4266667' AS DateTime2), 0, NULL, 7)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (10, N'Software Dev 6', N'100,000.04', N'Summary 128', N'Description 128', N'Short Description 128', N'Short Title 128', NULL, 4, 4, N'SLUG123461                                        ', 0, N'Active    ', CAST(N'2023-04-05T18:12:33.2633333' AS DateTime2), CAST(N'2023-04-05T18:12:33.2633333' AS DateTime2), 0, NULL, 8)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (11, N'Software Dev 7', N'100,000.05', N'Summary 129', N'Description 129', N'Short Description 129', N'Short Title 129', NULL, 4, 4, N'SLUG123462                                        ', 0, N'Active    ', CAST(N'2023-04-05T18:12:54.4000000' AS DateTime2), CAST(N'2023-04-05T18:12:54.4000000' AS DateTime2), 0, NULL, 9)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (12, N'Software Dev 8', N'100,000.07', N'Summary 130', N'Description 130', N'Short Description 130', N'Short Title 130', NULL, 4, 4, N'SLUG123463                                        ', 0, N'Active    ', CAST(N'2023-04-05T18:13:21.6766667' AS DateTime2), CAST(N'2023-04-05T18:13:21.6766667' AS DateTime2), 0, NULL, 10)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (14, N'Dog Food Tester', N'125,000.00', N'Summary 432', N'Description 432', NULL, NULL, NULL, 4, 4, N'SLUGINSERT10001                                   ', 0, N'Active    ', CAST(N'2023-04-05T22:15:33.4433333' AS DateTime2), CAST(N'2023-04-05T22:15:33.4433333' AS DateTime2), 0, NULL, 10)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (15, N'Dog Food Tester 123', N'126,000.00', N'Summary 433', N'Description 433', NULL, NULL, NULL, 4, 4, N'SLUGINSERT10002                                   ', 0, N'Active    ', CAST(N'2023-04-05T22:18:44.3466667' AS DateTime2), CAST(N'2023-04-05T22:18:44.3466667' AS DateTime2), 0, NULL, 9)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (16, N'Street Sweeper', N'125,000', N'Summary', N'Descr', NULL, NULL, NULL, 8, 8, N'1000AAA1000                                       ', 0, N'Active    ', CAST(N'2023-04-19T20:48:57.4400000' AS DateTime2), CAST(N'2023-04-19T20:48:57.4400000' AS DateTime2), 0, NULL, 2)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (17, N'Street Sweeper II', N'125,000', N'Summary', N'Descr', NULL, NULL, NULL, 8, 8, N'1000AAA1000                                       ', 0, N'Active    ', CAST(N'2023-04-19T20:51:06.7433333' AS DateTime2), CAST(N'2023-04-19T20:51:06.7433333' AS DateTime2), 0, NULL, 2)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (18, N'Street Sweeper V', N'125,000', N'Summary', N'Descr', NULL, NULL, NULL, 8, 8, N'1000AAA1000                                       ', 0, N'Active    ', CAST(N'2023-04-19T20:52:15.5700000' AS DateTime2), CAST(N'2023-04-19T20:52:15.5700000' AS DateTime2), 0, NULL, 2)
INSERT [dbo].[Jobs] ([id], [Title], [Pay], [Summary], [Description], [ShortDescription], [ShortTitle], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [DateCreated], [DateModified], [Site], [BaseMetaDataId], [TechCompanyId]) VALUES (19, N'Toilet Bowl Cleaner', N'100,000', N'SUMMARY', N'HEY YOU!', NULL, NULL, NULL, 1008, 1008, N'SLUG10101010101                                   ', 0, N'Active    ', CAST(N'2023-04-19T21:16:56.7966667' AS DateTime2), CAST(N'2023-04-19T21:16:56.7966667' AS DateTime2), 0, NULL, 12)
SET IDENTITY_INSERT [dbo].[Jobs] OFF
GO
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (2, 2)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (2, 5)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (4, 5)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (4, 107)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (4, 414)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (5, 2)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (5, 4)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (6, 2)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (6, 23)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (6, 117)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (7, 1)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (7, 4)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (7, 5)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (8, 391)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (8, 395)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (8, 396)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (8, 397)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (9, 5)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (10, 2)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (10, 4)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (10, 5)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (11, 5)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (11, 6)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (12, 1)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (12, 2)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (12, 4)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (14, 355)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (14, 356)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (14, 389)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (14, 390)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (15, 391)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (15, 392)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (15, 393)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (15, 394)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (16, 412)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (16, 413)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (17, 412)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (17, 413)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (18, 1)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (18, 412)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (18, 414)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (19, 2)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (19, 15)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (19, 391)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (19, 401)
INSERT [dbo].[JobsSkills] ([JobId], [SkillId]) VALUES (19, 415)
GO
SET IDENTITY_INSERT [dbo].[Manufacturers] ON 

INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (1, N'Toyota', N'Japan', CAST(N'2023-04-17T17:52:40.4766667' AS DateTime2), CAST(N'2023-04-17T17:52:40.4766667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (2, N'Nissan', N'Japan', CAST(N'2023-04-17T17:52:46.0566667' AS DateTime2), CAST(N'2023-04-17T17:52:46.0566667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (3, N'Ford', N'USA', CAST(N'2023-04-17T17:52:52.4100000' AS DateTime2), CAST(N'2023-04-17T17:52:52.4100000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (4, N'Chevrolet', N'USE', CAST(N'2023-04-17T17:53:05.1133333' AS DateTime2), CAST(N'2023-04-17T17:53:05.1133333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (5, N'Sabio Manufacturer5924', N'Sabio USA5924', CAST(N'2023-04-17T18:32:19.6033333' AS DateTime2), CAST(N'2023-04-17T18:32:19.6033333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (6, N'Sabio Manufacturer7390', N'Sabio USA7390', CAST(N'2023-04-17T18:32:19.6200000' AS DateTime2), CAST(N'2023-04-17T18:32:19.6200000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (7, N'Sabio Manufacturer6635', N'Sabio USA6635', CAST(N'2023-04-17T18:32:19.6366667' AS DateTime2), CAST(N'2023-04-17T18:32:19.6366667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (8, N'Sabio Manufacturer4162', N'Sabio USA4162', CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2), CAST(N'2023-04-17T18:32:19.6500000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (9, N'Sabio Manufacturer9972', N'Sabio USA9972', CAST(N'2023-04-17T18:32:19.6666667' AS DateTime2), CAST(N'2023-04-17T18:32:19.6666667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (10, N'Sabio Manufacturer9537', N'Sabio USA9537', CAST(N'2023-04-17T18:33:02.9233333' AS DateTime2), CAST(N'2023-04-17T18:33:02.9233333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (11, N'Sabio Manufacturer7069', N'Sabio USA7069', CAST(N'2023-04-17T18:33:02.9566667' AS DateTime2), CAST(N'2023-04-17T18:33:02.9566667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (12, N'Sabio Manufacturer2328', N'Sabio USA2328', CAST(N'2023-04-17T18:33:02.9566667' AS DateTime2), CAST(N'2023-04-17T18:33:02.9566667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (13, N'Sabio Manufacturer5464', N'Sabio USA5464', CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2), CAST(N'2023-04-17T18:33:02.9700000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (14, N'Sabio Manufacturer7024', N'Sabio USA7024', CAST(N'2023-04-17T18:33:02.9866667' AS DateTime2), CAST(N'2023-04-17T18:33:02.9866667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (15, N'Sabio Manufacturer1808', N'Sabio USA1808', CAST(N'2023-04-17T18:34:06.8600000' AS DateTime2), CAST(N'2023-04-17T18:34:06.8600000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (16, N'Sabio Manufacturer9557', N'Sabio USA9557', CAST(N'2023-04-17T18:34:06.8766667' AS DateTime2), CAST(N'2023-04-17T18:34:06.8766667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (17, N'Sabio Manufacturer1206', N'Sabio USA1206', CAST(N'2023-04-17T18:34:06.8900000' AS DateTime2), CAST(N'2023-04-17T18:34:06.8900000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (18, N'Sabio Manufacturer4919', N'Sabio USA4919', CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2), CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (19, N'Sabio Manufacturer3716', N'Sabio USA3716', CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2), CAST(N'2023-04-17T18:34:06.9066667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (20, N'Sabio Manufacturer3792', N'Sabio USA3792', CAST(N'2023-04-17T18:34:07.9233333' AS DateTime2), CAST(N'2023-04-17T18:34:07.9233333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (21, N'Sabio Manufacturer9982', N'Sabio USA9982', CAST(N'2023-04-17T18:36:32.3966667' AS DateTime2), CAST(N'2023-04-17T18:36:32.3966667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (22, N'Sabio Manufacturer2142', N'Sabio USA2142', CAST(N'2023-04-17T18:36:32.4100000' AS DateTime2), CAST(N'2023-04-17T18:36:32.4100000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (23, N'Sabio Manufacturer8482', N'Sabio USA8482', CAST(N'2023-04-17T18:36:32.4100000' AS DateTime2), CAST(N'2023-04-17T18:36:32.4100000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (24, N'Sabio Manufacturer1543', N'Sabio USA1543', CAST(N'2023-04-17T18:36:32.4266667' AS DateTime2), CAST(N'2023-04-17T18:36:32.4266667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (25, N'Sabio Manufacturer9379', N'Sabio USA9379', CAST(N'2023-04-17T18:36:32.4433333' AS DateTime2), CAST(N'2023-04-17T18:36:32.4433333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (26, N'Sabio Manufacturer5853', N'Sabio USA5853', CAST(N'2023-04-17T18:36:33.4766667' AS DateTime2), CAST(N'2023-04-17T18:36:33.4766667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (27, N'Sabio Manufacturer2265', N'Sabio USA2265', CAST(N'2023-04-17T18:36:34.4900000' AS DateTime2), CAST(N'2023-04-17T18:36:34.4900000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (28, N'Sabio Manufacturer2998', N'Sabio USA2998', CAST(N'2023-04-17T18:42:11.8100000' AS DateTime2), CAST(N'2023-04-17T18:42:11.8100000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (29, N'Sabio Manufacturer9370', N'Sabio USA9370', CAST(N'2023-04-17T18:42:11.8233333' AS DateTime2), CAST(N'2023-04-17T18:42:11.8233333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (30, N'Sabio Manufacturer4840', N'Sabio USA4840', CAST(N'2023-04-17T18:42:11.8400000' AS DateTime2), CAST(N'2023-04-17T18:42:11.8400000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (31, N'Sabio Manufacturer3571', N'Sabio USA3571', CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2), CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (32, N'Sabio Manufacturer1540', N'Sabio USA1540', CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2), CAST(N'2023-04-17T18:42:11.8566667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (33, N'Sabio Manufacturer5908', N'Sabio USA5908', CAST(N'2023-04-17T18:42:12.8800000' AS DateTime2), CAST(N'2023-04-17T18:42:12.8800000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (34, N'Sabio Manufacturer6349', N'Sabio USA6349', CAST(N'2023-04-17T18:42:13.8933333' AS DateTime2), CAST(N'2023-04-17T18:42:13.8933333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (35, N'Sabio Manufacturer7036', N'Sabio USA7036', CAST(N'2023-04-17T18:42:45.2666667' AS DateTime2), CAST(N'2023-04-17T18:42:45.2666667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (36, N'Sabio Manufacturer7309', N'Sabio USA7309', CAST(N'2023-04-17T18:42:45.2833333' AS DateTime2), CAST(N'2023-04-17T18:42:45.2833333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (37, N'Sabio Manufacturer2886', N'Sabio USA2886', CAST(N'2023-04-17T18:42:45.3000000' AS DateTime2), CAST(N'2023-04-17T18:42:45.3000000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (38, N'Sabio Manufacturer4884', N'Sabio USA4884', CAST(N'2023-04-17T18:42:45.3166667' AS DateTime2), CAST(N'2023-04-17T18:42:45.3166667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (39, N'Sabio Manufacturer5631', N'Sabio USA5631', CAST(N'2023-04-17T18:42:45.3300000' AS DateTime2), CAST(N'2023-04-17T18:42:45.3300000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (40, N'Sabio Manufacturer3831', N'Sabio USA3831', CAST(N'2023-04-17T18:42:46.3466667' AS DateTime2), CAST(N'2023-04-17T18:42:46.3466667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (41, N'Sabio Manufacturer7938', N'Sabio USA7938', CAST(N'2023-04-17T18:42:47.3833333' AS DateTime2), CAST(N'2023-04-17T18:42:47.3833333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (42, N'Sabio Manufacturer6068', N'Sabio USA6068', CAST(N'2023-04-17T18:42:47.4000000' AS DateTime2), CAST(N'2023-04-17T18:42:47.4000000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (43, N'Sabio Manufacturer8925', N'Sabio USA8925', CAST(N'2023-04-17T18:45:57.8300000' AS DateTime2), CAST(N'2023-04-17T18:45:57.8300000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (44, N'Sabio Manufacturer5011', N'Sabio USA5011', CAST(N'2023-04-17T18:45:57.8433333' AS DateTime2), CAST(N'2023-04-17T18:45:57.8433333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (45, N'Sabio Manufacturer2949', N'Sabio USA2949', CAST(N'2023-04-17T18:45:57.8600000' AS DateTime2), CAST(N'2023-04-17T18:45:57.8600000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (46, N'Sabio Manufacturer5641', N'Sabio USA5641', CAST(N'2023-04-17T18:45:57.8766667' AS DateTime2), CAST(N'2023-04-17T18:45:57.8766667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (47, N'Sabio Manufacturer8237', N'Sabio USA8237', CAST(N'2023-04-17T18:45:57.8766667' AS DateTime2), CAST(N'2023-04-17T18:45:57.8766667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (48, N'Sabio Manufacturer3573', N'Sabio USA3573', CAST(N'2023-04-17T18:45:58.9066667' AS DateTime2), CAST(N'2023-04-17T18:45:58.9066667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (49, N'Sabio Manufacturer4543', N'Sabio USA4543', CAST(N'2023-04-17T18:45:59.9366667' AS DateTime2), CAST(N'2023-04-17T18:45:59.9366667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (50, N'Sabio Manufacturer6035', N'Sabio USA6035', CAST(N'2023-04-17T18:45:59.9366667' AS DateTime2), CAST(N'2023-04-17T18:45:59.9366667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (51, N'Sabio Manufacturer5428', N'Sabio USA5428', CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2), CAST(N'2023-04-17T18:45:59.9533333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (52, N'Sabio Manufacturer1281', N'Sabio USA1281', CAST(N'2023-04-17T18:53:22.6833333' AS DateTime2), CAST(N'2023-04-17T18:53:22.6833333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (53, N'Sabio Manufacturer5987', N'Sabio USA5987', CAST(N'2023-04-17T18:53:22.7000000' AS DateTime2), CAST(N'2023-04-17T18:53:22.7000000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (54, N'Sabio Manufacturer2583', N'Sabio USA2583', CAST(N'2023-04-17T18:53:22.7166667' AS DateTime2), CAST(N'2023-04-17T18:53:22.7166667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (55, N'Sabio Manufacturer1750', N'Sabio USA1750', CAST(N'2023-04-17T18:53:22.7300000' AS DateTime2), CAST(N'2023-04-17T18:53:22.7300000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (56, N'Sabio Manufacturer6883', N'Sabio USA6883', CAST(N'2023-04-17T18:53:22.7466667' AS DateTime2), CAST(N'2023-04-17T18:53:22.7466667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (57, N'Sabio Manufacturer7577', N'Sabio USA7577', CAST(N'2023-04-17T18:53:23.7733333' AS DateTime2), CAST(N'2023-04-17T18:53:23.7733333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (58, N'Sabio Manufacturer4522', N'Sabio USA4522', CAST(N'2023-04-17T18:53:24.8033333' AS DateTime2), CAST(N'2023-04-17T18:53:24.8033333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (59, N'Sabio Manufacturer1346', N'Sabio USA1346', CAST(N'2023-04-17T18:53:24.8200000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8200000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (60, N'Sabio Manufacturer3481', N'Sabio USA3481', CAST(N'2023-04-17T18:53:24.8366667' AS DateTime2), CAST(N'2023-04-17T18:53:24.8366667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (61, N'Sabio Manufacturer1185', N'Sabio USA1185', CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2), CAST(N'2023-04-17T18:53:24.8500000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (62, N'Sabio Manufacturer7021', N'Sabio USA7021', CAST(N'2023-04-17T18:54:29.9633333' AS DateTime2), CAST(N'2023-04-17T18:54:29.9633333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (63, N'Sabio Manufacturer4505', N'Sabio USA4505', CAST(N'2023-04-17T18:54:29.9800000' AS DateTime2), CAST(N'2023-04-17T18:54:29.9800000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (64, N'Sabio Manufacturer9102', N'Sabio USA9102', CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2), CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (65, N'Sabio Manufacturer7073', N'Sabio USA7073', CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2), CAST(N'2023-04-17T18:54:29.9933333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (66, N'Sabio Manufacturer5564', N'Sabio USA5564', CAST(N'2023-04-17T18:54:30.0166667' AS DateTime2), CAST(N'2023-04-17T18:54:30.0166667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (67, N'Sabio Manufacturer1525', N'Sabio USA1525', CAST(N'2023-04-17T18:54:31.0500000' AS DateTime2), CAST(N'2023-04-17T18:54:31.0500000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (68, N'Sabio Manufacturer4110', N'Sabio USA4110', CAST(N'2023-04-17T18:54:32.0633333' AS DateTime2), CAST(N'2023-04-17T18:54:32.0633333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (69, N'Sabio Manufacturer8051', N'Sabio USA8051', CAST(N'2023-04-17T18:54:32.0800000' AS DateTime2), CAST(N'2023-04-17T18:54:32.0800000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (70, N'Sabio Manufacturer9452', N'Sabio USA9452', CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2), CAST(N'2023-04-17T18:54:32.0966667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (71, N'Sabio Manufacturer1381', N'Sabio USA1381', CAST(N'2023-04-17T18:54:32.1100000' AS DateTime2), CAST(N'2023-04-17T18:54:32.1100000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (72, N'Sabio Manufacturer5196', N'Sabio USA5196', CAST(N'2023-04-17T18:55:18.9566667' AS DateTime2), CAST(N'2023-04-17T18:55:18.9566667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (73, N'Sabio Manufacturer9647', N'Sabio USA9647', CAST(N'2023-04-17T18:55:18.9700000' AS DateTime2), CAST(N'2023-04-17T18:55:18.9700000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (74, N'Sabio Manufacturer7909', N'Sabio USA7909', CAST(N'2023-04-17T18:55:18.9866667' AS DateTime2), CAST(N'2023-04-17T18:55:18.9866667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (75, N'Sabio Manufacturer7381', N'Sabio USA7381', CAST(N'2023-04-17T18:55:19.0033333' AS DateTime2), CAST(N'2023-04-17T18:55:19.0033333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (76, N'Sabio Manufacturer1227', N'Sabio USA1227', CAST(N'2023-04-17T18:55:19.0200000' AS DateTime2), CAST(N'2023-04-17T18:55:19.0200000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (77, N'Sabio Manufacturer4857', N'Sabio USA4857', CAST(N'2023-04-17T18:55:20.0333333' AS DateTime2), CAST(N'2023-04-17T18:55:20.0333333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (78, N'Sabio Manufacturer2355', N'Sabio USA2355', CAST(N'2023-04-17T18:55:21.0666667' AS DateTime2), CAST(N'2023-04-17T18:55:21.0666667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (79, N'Sabio Manufacturer6558', N'Sabio USA6558', CAST(N'2023-04-17T18:55:21.0800000' AS DateTime2), CAST(N'2023-04-17T18:55:21.0800000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (80, N'Sabio Manufacturer9846', N'Sabio USA9846', CAST(N'2023-04-17T18:55:21.0966667' AS DateTime2), CAST(N'2023-04-17T18:55:21.0966667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (81, N'Sabio Manufacturer3269', N'Sabio USA3269', CAST(N'2023-04-17T18:55:21.1300000' AS DateTime2), CAST(N'2023-04-17T18:55:21.1300000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (82, N'Sabio Manufacturer3421', N'Sabio USA3421', CAST(N'2023-04-17T18:57:26.1300000' AS DateTime2), CAST(N'2023-04-17T18:57:26.1300000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (83, N'Sabio Manufacturer2640', N'Sabio USA2640', CAST(N'2023-04-17T18:57:26.1466667' AS DateTime2), CAST(N'2023-04-17T18:57:26.1466667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (84, N'Sabio Manufacturer9546', N'Sabio USA9546', CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2), CAST(N'2023-04-17T18:57:26.1633333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (85, N'Sabio Manufacturer1019', N'Sabio USA1019', CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2), CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (86, N'Sabio Manufacturer3924', N'Sabio USA3924', CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2), CAST(N'2023-04-17T18:57:26.1800000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (87, N'Sabio Manufacturer6238', N'Sabio USA6238', CAST(N'2023-04-17T18:57:27.2100000' AS DateTime2), CAST(N'2023-04-17T18:57:27.2100000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (88, N'Sabio Manufacturer5925', N'Sabio USA5925', CAST(N'2023-04-17T18:57:28.2400000' AS DateTime2), CAST(N'2023-04-17T18:57:28.2400000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (89, N'Sabio Manufacturer4640', N'Sabio USA4640', CAST(N'2023-04-17T18:57:28.2400000' AS DateTime2), CAST(N'2023-04-17T18:57:28.2400000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (90, N'Sabio Manufacturer4660', N'Sabio USA4660', CAST(N'2023-04-17T18:57:28.2566667' AS DateTime2), CAST(N'2023-04-17T18:57:28.2566667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (91, N'Sabio Manufacturer1492', N'Sabio USA1492', CAST(N'2023-04-17T18:57:28.2866667' AS DateTime2), CAST(N'2023-04-17T18:57:28.2866667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (92, N'Sabio Manufacturer5795', N'Sabio USA5795', CAST(N'2023-04-17T18:59:05.4900000' AS DateTime2), CAST(N'2023-04-17T18:59:05.4900000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (93, N'Sabio Manufacturer5187', N'Sabio USA5187', CAST(N'2023-04-17T18:59:05.5033333' AS DateTime2), CAST(N'2023-04-17T18:59:05.5033333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (94, N'Sabio Manufacturer7441', N'Sabio USA7441', CAST(N'2023-04-17T18:59:05.5200000' AS DateTime2), CAST(N'2023-04-17T18:59:05.5200000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (95, N'Sabio Manufacturer9895', N'Sabio USA9895', CAST(N'2023-04-17T18:59:05.5200000' AS DateTime2), CAST(N'2023-04-17T18:59:05.5200000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (96, N'Sabio Manufacturer1449', N'Sabio USA1449', CAST(N'2023-04-17T18:59:05.5366667' AS DateTime2), CAST(N'2023-04-17T18:59:05.5366667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (97, N'Sabio Manufacturer1589', N'Sabio USA1589', CAST(N'2023-04-17T18:59:06.5500000' AS DateTime2), CAST(N'2023-04-17T18:59:06.5500000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (98, N'Sabio Manufacturer5048', N'Sabio USA5048', CAST(N'2023-04-17T18:59:07.5600000' AS DateTime2), CAST(N'2023-04-17T18:59:07.5600000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (99, N'Sabio Manufacturer3514', N'Sabio USA3514', CAST(N'2023-04-17T18:59:07.5766667' AS DateTime2), CAST(N'2023-04-17T18:59:07.5766667' AS DateTime2))
GO
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (100, N'Sabio Manufacturer4767', N'Sabio USA4767', CAST(N'2023-04-17T18:59:07.5933333' AS DateTime2), CAST(N'2023-04-17T18:59:07.5933333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (101, N'Sabio Manufacturer5779', N'Sabio USA5779', CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2), CAST(N'2023-04-17T18:59:07.6100000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (102, N'Sabio Manufacturer2011', N'Sabio USA2011', CAST(N'2023-04-17T19:00:47.6766667' AS DateTime2), CAST(N'2023-04-17T19:00:47.6766667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (103, N'Sabio Manufacturer6355', N'Sabio USA6355', CAST(N'2023-04-17T19:00:47.6933333' AS DateTime2), CAST(N'2023-04-17T19:00:47.6933333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (104, N'Sabio Manufacturer2095', N'Sabio USA2095', CAST(N'2023-04-17T19:00:47.7100000' AS DateTime2), CAST(N'2023-04-17T19:00:47.7100000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (105, N'Sabio Manufacturer7753', N'Sabio USA7753', CAST(N'2023-04-17T19:00:47.7233333' AS DateTime2), CAST(N'2023-04-17T19:00:47.7233333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (106, N'Sabio Manufacturer5619', N'Sabio USA5619', CAST(N'2023-04-17T19:00:47.7233333' AS DateTime2), CAST(N'2023-04-17T19:00:47.7233333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (107, N'Sabio Manufacturer4168', N'Sabio USA4168', CAST(N'2023-04-17T19:00:48.7733333' AS DateTime2), CAST(N'2023-04-17T19:00:48.7733333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (108, N'Sabio Manufacturer4820', N'Sabio USA4820', CAST(N'2023-04-17T19:00:49.7866667' AS DateTime2), CAST(N'2023-04-17T19:00:49.7866667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (109, N'Sabio Manufacturer4045', N'Sabio USA4045', CAST(N'2023-04-17T19:00:49.8033333' AS DateTime2), CAST(N'2023-04-17T19:00:49.8033333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (110, N'Sabio Manufacturer8850', N'Sabio USA8850', CAST(N'2023-04-17T19:00:49.8166667' AS DateTime2), CAST(N'2023-04-17T19:00:49.8166667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (111, N'Sabio Manufacturer5709', N'Sabio USA5709', CAST(N'2023-04-17T19:00:49.8500000' AS DateTime2), CAST(N'2023-04-17T19:00:49.8500000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (112, N'Sabio Manufacturer9554', N'Sabio USA9554', CAST(N'2023-04-17T19:01:46.5366667' AS DateTime2), CAST(N'2023-04-17T19:01:46.5366667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (113, N'Sabio Manufacturer3548', N'Sabio USA3548', CAST(N'2023-04-17T19:01:46.5500000' AS DateTime2), CAST(N'2023-04-17T19:01:46.5500000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (114, N'Sabio Manufacturer7205', N'Sabio USA7205', CAST(N'2023-04-17T19:01:46.5666667' AS DateTime2), CAST(N'2023-04-17T19:01:46.5666667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (115, N'Sabio Manufacturer2218', N'Sabio USA2218', CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2), CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (116, N'Sabio Manufacturer4642', N'Sabio USA4642', CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2), CAST(N'2023-04-17T19:01:46.5833333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (117, N'Sabio Manufacturer9437', N'Sabio USA9437', CAST(N'2023-04-17T19:01:47.6166667' AS DateTime2), CAST(N'2023-04-17T19:01:47.6166667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (118, N'Sabio Manufacturer1413', N'Sabio USA1413', CAST(N'2023-04-17T19:01:48.6333333' AS DateTime2), CAST(N'2023-04-17T19:01:48.6333333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (119, N'Sabio Manufacturer1112', N'Sabio USA1112', CAST(N'2023-04-17T19:01:48.6500000' AS DateTime2), CAST(N'2023-04-17T19:01:48.6500000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (120, N'Sabio Manufacturer6057', N'Sabio USA6057', CAST(N'2023-04-17T19:01:48.6633333' AS DateTime2), CAST(N'2023-04-17T19:01:48.6633333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (121, N'Sabio Manufacturer2962', N'Sabio USA2962', CAST(N'2023-04-17T19:01:48.6966667' AS DateTime2), CAST(N'2023-04-17T19:01:48.6966667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (122, N'Sabio Manufacturer4074', N'Sabio USA4074', CAST(N'2023-04-17T19:02:00.0900000' AS DateTime2), CAST(N'2023-04-17T19:02:00.0900000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (123, N'Sabio Manufacturer1315', N'Sabio USA1315', CAST(N'2023-04-17T19:02:00.1066667' AS DateTime2), CAST(N'2023-04-17T19:02:00.1066667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (124, N'Sabio Manufacturer4398', N'Sabio USA4398', CAST(N'2023-04-17T19:02:00.1233333' AS DateTime2), CAST(N'2023-04-17T19:02:00.1233333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (125, N'Sabio Manufacturer9641', N'Sabio USA9641', CAST(N'2023-04-17T19:02:00.1400000' AS DateTime2), CAST(N'2023-04-17T19:02:00.1400000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (126, N'Sabio Manufacturer9502', N'Sabio USA9502', CAST(N'2023-04-17T19:02:00.1533333' AS DateTime2), CAST(N'2023-04-17T19:02:00.1533333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (127, N'Sabio Manufacturer7059', N'Sabio USA7059', CAST(N'2023-04-17T19:02:01.1633333' AS DateTime2), CAST(N'2023-04-17T19:02:01.1633333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (128, N'Sabio Manufacturer7808', N'Sabio USA7808', CAST(N'2023-04-17T19:02:02.1800000' AS DateTime2), CAST(N'2023-04-17T19:02:02.1800000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (129, N'Sabio Manufacturer4036', N'Sabio USA4036', CAST(N'2023-04-17T19:02:02.1933333' AS DateTime2), CAST(N'2023-04-17T19:02:02.1933333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (130, N'Sabio Manufacturer4183', N'Sabio USA4183', CAST(N'2023-04-17T19:02:02.2100000' AS DateTime2), CAST(N'2023-04-17T19:02:02.2100000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (131, N'Sabio Manufacturer6457', N'Sabio USA6457', CAST(N'2023-04-17T19:02:02.2400000' AS DateTime2), CAST(N'2023-04-17T19:02:02.2400000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (132, N'Sabio Manufacturer6698', N'Sabio USA6698', CAST(N'2023-04-17T19:03:29.0833333' AS DateTime2), CAST(N'2023-04-17T19:03:29.0833333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (133, N'Sabio Manufacturer9896', N'Sabio USA9896', CAST(N'2023-04-17T19:03:29.1000000' AS DateTime2), CAST(N'2023-04-17T19:03:29.1000000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (134, N'Sabio Manufacturer7823', N'Sabio USA7823', CAST(N'2023-04-17T19:03:29.1133333' AS DateTime2), CAST(N'2023-04-17T19:03:29.1133333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (135, N'Sabio Manufacturer5299', N'Sabio USA5299', CAST(N'2023-04-17T19:03:29.1133333' AS DateTime2), CAST(N'2023-04-17T19:03:29.1133333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (136, N'Sabio Manufacturer8799', N'Sabio USA8799', CAST(N'2023-04-17T19:03:29.1300000' AS DateTime2), CAST(N'2023-04-17T19:03:29.1300000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (137, N'Sabio Manufacturer6840', N'Sabio USA6840', CAST(N'2023-04-17T19:03:30.1600000' AS DateTime2), CAST(N'2023-04-17T19:03:30.1600000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (138, N'Sabio Manufacturer2188', N'Sabio USA2188', CAST(N'2023-04-17T19:03:31.1766667' AS DateTime2), CAST(N'2023-04-17T19:03:31.1766667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (139, N'Sabio Manufacturer6936', N'Sabio USA6936', CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2), CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (140, N'Sabio Manufacturer6524', N'Sabio USA6524', CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2), CAST(N'2023-04-17T19:03:31.1933333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (141, N'Sabio Manufacturer9686', N'Sabio USA9686', CAST(N'2023-04-17T19:03:31.2233333' AS DateTime2), CAST(N'2023-04-17T19:03:31.2233333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (142, N'Sabio Manufacturer9156', N'Sabio USA9156', CAST(N'2023-04-17T19:04:14.1800000' AS DateTime2), CAST(N'2023-04-17T19:04:14.1800000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (143, N'Sabio Manufacturer3069', N'Sabio USA3069', CAST(N'2023-04-17T19:04:14.2100000' AS DateTime2), CAST(N'2023-04-17T19:04:14.2100000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (144, N'Sabio Manufacturer5548', N'Sabio USA5548', CAST(N'2023-04-17T19:04:14.2266667' AS DateTime2), CAST(N'2023-04-17T19:04:14.2266667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (145, N'Sabio Manufacturer9142', N'Sabio USA9142', CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2), CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (146, N'Sabio Manufacturer1844', N'Sabio USA1844', CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2), CAST(N'2023-04-17T19:04:14.2400000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (147, N'Sabio Manufacturer5903', N'Sabio USA5903', CAST(N'2023-04-17T19:04:15.2700000' AS DateTime2), CAST(N'2023-04-17T19:04:15.2700000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (148, N'Sabio Manufacturer1684', N'Sabio USA1684', CAST(N'2023-04-17T19:04:16.3033333' AS DateTime2), CAST(N'2023-04-17T19:04:16.3033333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (149, N'Sabio Manufacturer2622', N'Sabio USA2622', CAST(N'2023-04-17T19:04:16.3033333' AS DateTime2), CAST(N'2023-04-17T19:04:16.3033333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (150, N'Sabio Manufacturer6761', N'Sabio USA6761', CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:16.3200000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (151, N'Sabio Manufacturer1283', N'Sabio USA1283', CAST(N'2023-04-17T19:04:16.3500000' AS DateTime2), CAST(N'2023-04-17T19:04:16.3500000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (152, N'Sabio Manufacturer2529', N'Sabio USA2529', CAST(N'2023-04-17T19:04:47.2866667' AS DateTime2), CAST(N'2023-04-17T19:04:47.2866667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (153, N'Sabio Manufacturer4464', N'Sabio USA4464', CAST(N'2023-04-17T19:04:47.3033333' AS DateTime2), CAST(N'2023-04-17T19:04:47.3033333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (154, N'Sabio Manufacturer9042', N'Sabio USA9042', CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2), CAST(N'2023-04-17T19:04:47.3200000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (155, N'Sabio Manufacturer1993', N'Sabio USA1993', CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2), CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (156, N'Sabio Manufacturer2662', N'Sabio USA2662', CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2), CAST(N'2023-04-17T19:04:47.3333333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (157, N'Sabio Manufacturer3774', N'Sabio USA3774', CAST(N'2023-04-17T19:04:48.3500000' AS DateTime2), CAST(N'2023-04-17T19:04:48.3500000' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (158, N'Sabio Manufacturer9051', N'Sabio USA9051', CAST(N'2023-04-17T19:04:49.3633333' AS DateTime2), CAST(N'2023-04-17T19:04:49.3633333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (159, N'Sabio Manufacturer2488', N'Sabio USA2488', CAST(N'2023-04-17T19:04:49.3766667' AS DateTime2), CAST(N'2023-04-17T19:04:49.3766667' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (160, N'Sabio Manufacturer7093', N'Sabio USA7093', CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2), CAST(N'2023-04-17T19:04:49.3933333' AS DateTime2))
INSERT [dbo].[Manufacturers] ([Id], [Name], [Country], [DateCreated], [DateModified]) VALUES (161, N'Sabio Manufacturer8522', N'Sabio USA8522', CAST(N'2023-04-17T19:04:49.4100000' AS DateTime2), CAST(N'2023-04-17T19:04:49.4100000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Manufacturers] OFF
GO
SET IDENTITY_INSERT [dbo].[People] ON 

INSERT [dbo].[People] ([Id], [Name], [Age], [IsSmoker], [DateAdded], [DateModified], [UserId]) VALUES (2, NULL, 20, NULL, CAST(N'2023-03-28T20:57:14.0933333' AS DateTime2), CAST(N'2023-03-28T21:04:53.7833333' AS DateTime2), N'12344321AQQQQ')
INSERT [dbo].[People] ([Id], [Name], [Age], [IsSmoker], [DateAdded], [DateModified], [UserId]) VALUES (3, NULL, 23, NULL, CAST(N'2023-03-28T21:01:07.3000000' AS DateTime2), CAST(N'2023-03-28T21:01:07.3000000' AS DateTime2), N'12344321AQQQQ')
INSERT [dbo].[People] ([Id], [Name], [Age], [IsSmoker], [DateAdded], [DateModified], [UserId]) VALUES (4, N'John', 54, 0, CAST(N'2023-03-28T21:12:26.8633333' AS DateTime2), CAST(N'2023-03-28T21:12:26.8633333' AS DateTime2), N'SOMEID0001')
INSERT [dbo].[People] ([Id], [Name], [Age], [IsSmoker], [DateAdded], [DateModified], [UserId]) VALUES (5, N'Buster', 34, 1, CAST(N'2023-03-28T21:15:21.0866667' AS DateTime2), CAST(N'2023-03-28T21:15:21.0866667' AS DateTime2), N'SOMEID0002')
INSERT [dbo].[People] ([Id], [Name], [Age], [IsSmoker], [DateAdded], [DateModified], [UserId]) VALUES (6, N'Peter', 19, 0, CAST(N'2023-03-28T21:20:06.9633333' AS DateTime2), CAST(N'2023-03-28T21:20:06.9633333' AS DateTime2), N'hghghjg')
INSERT [dbo].[People] ([Id], [Name], [Age], [IsSmoker], [DateAdded], [DateModified], [UserId]) VALUES (8, N'Buster', 44, 0, CAST(N'2023-03-28T21:30:30.6566667' AS DateTime2), CAST(N'2023-03-29T00:38:50.9833333' AS DateTime2), N'HESTER2223')
INSERT [dbo].[People] ([Id], [Name], [Age], [IsSmoker], [DateAdded], [DateModified], [UserId]) VALUES (9, N'Peter', 19, 0, CAST(N'2023-03-28T21:30:32.8433333' AS DateTime2), CAST(N'2023-03-28T21:30:32.8433333' AS DateTime2), N'hghghjg')
INSERT [dbo].[People] ([Id], [Name], [Age], [IsSmoker], [DateAdded], [DateModified], [UserId]) VALUES (11, N'Peter', 19, 0, CAST(N'2023-03-28T21:30:34.6566667' AS DateTime2), CAST(N'2023-03-28T21:30:34.6566667' AS DateTime2), N'hghghjg')
INSERT [dbo].[People] ([Id], [Name], [Age], [IsSmoker], [DateAdded], [DateModified], [UserId]) VALUES (12, N'Todd', 66, 0, CAST(N'2023-03-29T00:15:54.9433333' AS DateTime2), CAST(N'2023-03-29T01:06:21.2600000' AS DateTime2), N'HHHHRRRRTTTT')
INSERT [dbo].[People] ([Id], [Name], [Age], [IsSmoker], [DateAdded], [DateModified], [UserId]) VALUES (13, N'Johnny', 54, 1, CAST(N'2023-03-29T00:21:59.2900000' AS DateTime2), CAST(N'2023-03-29T00:21:59.2900000' AS DateTime2), N'JOHNNY0001')
SET IDENTITY_INSERT [dbo].[People] OFF
GO
SET IDENTITY_INSERT [dbo].[PetImages] ON 

INSERT [dbo].[PetImages] ([Id], [PetId], [Url]) VALUES (1, 6, N'dobie1.jpg')
INSERT [dbo].[PetImages] ([Id], [PetId], [Url]) VALUES (2, 6, N'dobie2.jpg')
INSERT [dbo].[PetImages] ([Id], [PetId], [Url]) VALUES (3, 7, N'gs1.jpg')
INSERT [dbo].[PetImages] ([Id], [PetId], [Url]) VALUES (4, 8, N'a1.gif')
INSERT [dbo].[PetImages] ([Id], [PetId], [Url]) VALUES (5, 8, N'a2.pmg')
INSERT [dbo].[PetImages] ([Id], [PetId], [Url]) VALUES (6, 9, N'chichi.jpg')
SET IDENTITY_INSERT [dbo].[PetImages] OFF
GO
SET IDENTITY_INSERT [dbo].[Pets] ON 

INSERT [dbo].[Pets] ([Id], [Breed], [Size], [Color]) VALUES (6, N'Doberman', N'Large', N'Black')
INSERT [dbo].[Pets] ([Id], [Breed], [Size], [Color]) VALUES (7, N'German Shepherd', N'Large', N'Brown')
INSERT [dbo].[Pets] ([Id], [Breed], [Size], [Color]) VALUES (8, N'Aussie', N'Medium', N'Merle')
INSERT [dbo].[Pets] ([Id], [Breed], [Size], [Color]) VALUES (9, N'chihuahua', N'toy', N'white')
SET IDENTITY_INSERT [dbo].[Pets] OFF
GO
SET IDENTITY_INSERT [dbo].[Sabio_Addresses] ON 

INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1, N'090 Luster Plaza', 94, N'Boston', N'Massachusetts', N'02298', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (2, N'2 New Castle Circle', 26, N'Irvine', N'California', N'92717', 1, 33.6462, -117.8398)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (3, N'64 Village Crossing', 74, N'Atlanta', N'Georgia', N'31136', 1, 33.7473, -84.3824)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (4, N'5 Harper Street', 69, N'Hartford', N'Connecticut', N'06105', 1, 41.7691, -72.701)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (5, N'82864 Prentice Park', 46, N'Elmira', N'New York', N'14905', 0, 42.0869, -76.8397)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (6, N'569 Merry Point', 33, N'Provo', N'Utah', N'84605', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (7, N'63 Lyons Place', 85, N'Dallas', N'Texas', N'75260', 0, 32.7673, -96.7776)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (8, N'56 Blue Bill Park Hill', NULL, N'Tulsa', N'Oklahoma', N'74149', 1, 36.1398, -96.0297)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (9, N'0355 Kipling Street', NULL, N'Washington', N'District of Columbia', N'20380', 0, 38.8933, -77.0146)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (10, N'497 Hudson Crossing', 34, N'New York City', N'New York', N'10175', 1, 40.7543, -73.9798)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (11, N'7987 Transport Center', 77, N'Montgomery', N'Alabama', N'36134', 0, 32.2334, -86.2085)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (12, N'9 Heath Avenue', 11, N'Detroit', N'Michigan', N'48217', 1, 42.2719, -83.1545)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (13, N'06721 Westridge Point', 69, N'Chicago', N'Illinois', N'60624', 1, 41.8804, -87.7223)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (14, N'7947 Graedel Circle', 93, N'Charlotte', N'North Carolina', N'28205', 0, 35.22, -80.7881)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (15, N'972 Magdeline Point', NULL, N'Dallas', N'Texas', N'75379', 1, 32.7673, -96.7776)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (16, N'33672 Sunnyside Pass', 19, N'Little Rock', N'Arkansas', N'72204', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (17, N'879 Fisk Park', NULL, N'Littleton', N'Colorado', N'80161', 0, 39.7388, -104.4083)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (18, N'6 Buell Avenue', 12, N'San Antonio', N'Texas', N'78220', 0, 29.4106, -98.4128)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (19, N'118 Porter Alley', NULL, N'Charleston', N'West Virginia', N'25389', 0, 38.354, -81.6394)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (20, N'60884 1st Pass', 98, N'Arlington', N'Texas', N'76004', 1, 32.7714, -97.2915)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (21, N'7418 Kingsford Plaza', NULL, N'Metairie', N'Louisiana', N'70005', 0, 30.0005, -90.1331)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (22, N'27731 Shelley Park', NULL, N'Austin', N'Texas', N'78721', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (23, N'787 Sherman Trail', 80, N'Chicago', N'Illinois', N'60657', 0, 41.9399, -87.6528)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (24, N'476 La Follette Crossing', 30, N'Cleveland', N'Ohio', N'44185', 1, 41.6857, -81.6728)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (25, N'6 East Hill', 78, N'Detroit', N'Michigan', N'48275', 0, 42.2399, -83.1508)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (26, N'489 Melvin Avenue', NULL, N'Jefferson City', N'Missouri', N'65105', 1, 38.5309, -92.2493)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (27, N'0057 Luster Circle', NULL, N'Orlando', N'Florida', N'32830', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (28, N'2 Nobel Lane', 47, N'Boulder', N'Colorado', N'80328', 1, 40.0878, -105.3735)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (29, N'67 Division Avenue', NULL, N'Washington', N'District of Columbia', N'20073', 0, 38.897, -77.0251)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (30, N'5903 Green Ridge Court', NULL, N'Winston Salem', N'North Carolina', N'27105', 1, 36.144, -80.2376)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (31, N'93061 Dryden Junction', NULL, N'Fargo', N'North Dakota', N'58122', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (32, N'78371 Rieder Court', NULL, N'Fayetteville', N'North Carolina', N'28314', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (33, N'53 Charing Cross Court', 98, N'Brooklyn', N'New York', N'11231', 0, 40.6794, -74.0014)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (34, N'5 Carey Park', NULL, N'Brooklyn', N'New York', N'11254', 0, 40.6451, -73.945)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (35, N'47 Graceland Parkway', 10, N'New York City', N'New York', N'10120', 1, 40.7506, -73.9894)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (36, N'615 Division Avenue', NULL, N'Des Moines', N'Iowa', N'50310', 0, 41.6255, -93.6736)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (37, N'38 Florence Hill', NULL, N'Fredericksburg', N'Virginia', N'22405', 0, 38.3365, -77.4366)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (38, N'22348 Moland Court', 90, N'New York City', N'New York', N'10110', 1, 40.754, -73.9808)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (39, N'96 Westerfield Drive', NULL, N'Charlotte', N'North Carolina', N'28225', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (40, N'376 Drewry Hill', 22, N'Trenton', N'New Jersey', N'08638', 0, 40.251, -74.7627)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (41, N'62126 Merry Road', NULL, N'Durham', N'North Carolina', N'27705', 0, 36.0218, -78.9478)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (42, N'84168 Pleasure Pass', 52, N'Detroit', N'Michigan', N'48267', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (43, N'0 Swallow Alley', 17, N'Louisville', N'Kentucky', N'40280', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (44, N'38201 Lindbergh Crossing', 6, N'Houston', N'Texas', N'77040', 1, 29.8744, -95.5278)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (45, N'338 Kings Junction', 88, N'Cleveland', N'Ohio', N'44105', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (46, N'07864 Oak Valley Way', 78, N'Minneapolis', N'Minnesota', N'55423', 1, 44.8756, -93.2553)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (47, N'6 Pond Drive', 95, N'Maple Plain', N'Minnesota', N'55572', 0, 45.0159, -93.4719)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (48, N'4 Sundown Way', 56, N'Norfolk', N'Virginia', N'23551', 0, 36.9312, -76.2397)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (49, N'503 Katie Place', 41, N'Stockton', N'California', N'95205', 1, 37.9625, -121.2624)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (50, N'513 Nancy Alley', NULL, N'Portland', N'Oregon', N'97221', 0, 45.4918, -122.7267)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (51, N'1087 Harper Lane', 55, N'Columbus', N'Ohio', N'43204', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (52, N'73611 Anderson Center', 24, N'Lexington', N'Kentucky', N'40596', 1, 38.0283, -84.4715)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (53, N'0 Kipling Place', NULL, N'Providence', N'Rhode Island', N'02912', 1, 41.8267, -71.3977)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (54, N'16 Bunting Place', 46, N'Tulsa', N'Oklahoma', N'74184', 0, 36.1398, -96.0297)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (55, N'4 Drewry Street', 32, N'Boise', N'Idaho', N'83722', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (56, N'672 Continental Way', 75, N'Washington', N'District of Columbia', N'20551', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (57, N'847 Sutteridge Circle', NULL, N'San Jose', N'California', N'95155', 0, 37.31, -121.9011)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (58, N'6205 Di Loreto Hill', NULL, N'Hampton', N'Virginia', N'23663', 1, 37.0318, -76.3199)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (59, N'5 Delaware Point', 50, N'Bethesda', N'Maryland', N'20892', 1, 39.0024, -77.1034)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (60, N'7 Buell Terrace', 37, N'Detroit', N'Michigan', N'48275', 1, 42.2399, -83.1508)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (61, N'7 Forest Road', 57, N'Odessa', N'Texas', N'79769', 1, 31.7466, -102.567)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (62, N'0010 Warbler Court', NULL, N'Fort Worth', N'Texas', N'76192', 0, 32.7714, -97.2915)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (63, N'663 Bayside Parkway', NULL, N'Ocala', N'Florida', N'34479', 1, 29.2541, -82.1095)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (64, N'36090 Goodland Trail', NULL, N'Reno', N'Nevada', N'89510', 0, 39.7699, -119.6027)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (65, N'8804 Northport Circle', 81, N'Lansing', N'Michigan', N'48956', 0, 42.7325, -84.5587)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (66, N'3 Dawn Way', NULL, N'Fort Pierce', N'Florida', N'34981', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (67, N'064 Di Loreto Lane', 1, N'Riverside', N'California', N'92505', 0, 33.9228, -117.4867)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (68, N'0 Derek Drive', 35, N'Salinas', N'California', N'93907', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (69, N'7 Lakewood Park', 17, N'Tulsa', N'Oklahoma', N'74141', 1, 36.1398, -96.0297)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (70, N'16175 Loeprich Terrace', NULL, N'El Paso', N'Texas', N'79911', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (71, N'8 Dwight Court', 50, N'Jacksonville', N'Florida', N'32230', 1, 30.3449, -81.6831)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (72, N'51150 Anderson Place', 92, N'Wichita', N'Kansas', N'67210', 1, 37.6379, -97.2613)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (73, N'56022 Cascade Street', 46, N'Berkeley', N'California', N'94705', 0, 37.8571, -122.25)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (74, N'8 Debs Avenue', 100, N'Colorado Springs', N'Colorado', N'80935', 1, 38.8247, -104.562)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (75, N'18003 Main Road', 41, N'Toledo', N'Ohio', N'43635', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (76, N'29600 Northport Street', 96, N'Washington', N'District of Columbia', N'20078', 1, 38.8933, -77.0146)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (77, N'84366 Calypso Circle', 20, N'Saint Joseph', N'Missouri', N'64504', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (78, N'277 Lyons Avenue', 1, N'San Luis Obispo', N'California', N'93407', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (79, N'3490 Corscot Hill', 45, N'Charlotte', N'North Carolina', N'28272', 1, 35.26, -80.8042)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (80, N'467 1st Road', 62, N'Des Moines', N'Iowa', N'50330', 0, 41.6727, -93.5722)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (81, N'4598 Buena Vista Place', NULL, N'Tucson', N'Arizona', N'85725', 0, 31.9701, -111.8907)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (82, N'9 Burrows Pass', NULL, N'Arlington', N'Texas', N'76096', 0, 32.7714, -97.2915)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (83, N'42 Canary Place', 100, N'Hialeah', N'Florida', N'33018', 1, 25.9098, -80.3889)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (84, N'475 Riverside Park', 31, N'Toledo', N'Ohio', N'43656', 0, 41.6782, -83.4972)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (85, N'62753 Di Loreto Road', 42, N'Louisville', N'Kentucky', N'40205', 0, 38.2222, -85.6885)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (86, N'8660 Columbus Alley', NULL, N'York', N'Pennsylvania', N'17405', 1, 40.0086, -76.5972)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (87, N'09495 Steensland Avenue', 56, N'San Diego', N'California', N'92105', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (88, N'5405 Laurel Terrace', NULL, N'Detroit', N'Michigan', N'48206', 1, 42.3749, -83.1087)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (89, N'3071 Helena Circle', NULL, N'Salt Lake City', N'Utah', N'84135', 0, 40.6681, -111.9083)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (90, N'8 Prentice Place', NULL, N'Melbourne', N'Florida', N'32941', 0, 27.9246, -80.5235)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (91, N'50 Rutledge Point', 55, N'El Paso', N'Texas', N'79984', 0, 31.6948, -106.3)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (92, N'551 Hansons Drive', NULL, N'Cincinnati', N'Ohio', N'45264', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (93, N'4200 Hayes Avenue', 30, N'Houston', N'Texas', N'77095', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (94, N'75105 Heath Trail', NULL, N'Minneapolis', N'Minnesota', N'55417', 1, 44.9054, -93.2361)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (95, N'411 Florence Parkway', 54, N'Pensacola', N'Florida', N'32526', 0, 30.4756, -87.3179)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (96, N'298 Haas Trail', NULL, N'Washington', N'District of Columbia', N'20226', 0, 38.8933, -77.0146)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (97, N'45 Esch Pass', 13, N'Mansfield', N'Ohio', N'44905', 0, 40.7779, -82.4613)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (98, N'133 Colorado Drive', 29, N'Charleston', N'West Virginia', N'25389', 0, 38.354, -81.6394)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (99, N'623 Canary Terrace', NULL, N'Indianapolis', N'Indiana', N'46231', 0, 39.7038, -86.3029)
GO
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (100, N'868 Riverside Circle', NULL, N'Arlington', N'Texas', N'76011', 1, 32.7582, -97.1003)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (101, N'774 Evergreen Alley', NULL, N'Denver', N'Colorado', N'80217', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (102, N'83 Florence Junction', 30, N'Dallas', N'Texas', N'75379', 1, 32.7673, -96.7776)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (103, N'6037 Melvin Junction', 26, N'Ridgely', N'Maryland', N'21684', 0, 38.8893, -75.8612)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (104, N'41178 Jenna Trail', NULL, N'Honolulu', N'Hawaii', N'96815', 1, 21.2811, -157.8266)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (105, N'12 Hauk Trail', NULL, N'Los Angeles', N'California', N'90189', 1, 34.0515, -118.2559)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (106, N'172 Clyde Gallagher Circle', NULL, N'Atlanta', N'Georgia', N'31196', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (107, N'561 Spenser Parkway', 11, N'Tampa', N'Florida', N'33694', 0, 27.872, -82.4388)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (108, N'47 Messerschmidt Road', 46, N'Seattle', N'Washington', N'98133', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (109, N'7 Kings Way', 43, N'Atlanta', N'Georgia', N'30340', 0, 33.8932, -84.2539)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (110, N'045 Melvin Parkway', NULL, N'Rockville', N'Maryland', N'20851', 0, 39.0763, -77.1234)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (111, N'2 Hooker Road', 22, N'Louisville', N'Kentucky', N'40210', 1, 38.2306, -85.7905)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (112, N'3161 Vermont Road', 79, N'Canton', N'Ohio', N'44705', 0, 40.8259, -81.3399)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (113, N'38356 Pierstorff Pass', 74, N'Orlando', N'Florida', N'32808', 0, 28.5803, -81.4396)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (114, N'56 Hoard Road', 14, N'Loretto', N'Minnesota', N'55598', 0, 45.0159, -93.4719)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (115, N'405 Del Sol Junction', 1, N'Cincinnati', N'Ohio', N'45271', 0, 39.1668, -84.5382)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (116, N'82033 Commercial Crossing', 15, N'Louisville', N'Kentucky', N'40298', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (117, N'8741 Dovetail Road', 86, N'San Diego', N'California', N'92127', 0, 33.0279, -117.0856)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (118, N'861 Vidon Circle', NULL, N'Portland', N'Oregon', N'97229', 0, 45.5483, -122.8276)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (119, N'27 Shasta Trail', NULL, N'Hartford', N'Connecticut', N'06145', 0, 41.7918, -72.7188)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (120, N'92368 Brown Street', NULL, N'Baltimore', N'Maryland', N'21203', 1, 39.2847, -76.6205)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (121, N'99461 Stuart Pass', NULL, N'Hampton', N'Virginia', N'23668', 1, 37.0206, -76.3377)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (122, N'9 Spaight Crossing', 57, N'Rochester', N'New York', N'14609', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (123, N'12876 Manley Way', 13, N'Austin', N'Texas', N'78783', 1, 30.3264, -97.7713)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (124, N'45280 Fairview Crossing', 49, N'Dayton', N'Ohio', N'45426', 1, 39.7982, -84.3211)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (125, N'2866 Farwell Lane', 94, N'Grand Junction', N'Colorado', N'81505', 1, 39.1071, -108.5968)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (126, N'9781 Emmet Junction', NULL, N'Provo', N'Utah', N'84605', 0, 40.177, -111.536)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (127, N'02249 Barby Street', NULL, N'Athens', N'Georgia', N'30605', 0, 33.9321, -83.3525)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (128, N'4305 Maple Wood Park', NULL, N'Sacramento', N'California', N'94286', 1, 38.3774, -121.4444)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (129, N'16160 Tomscot Trail', 77, N'Fort Worth', N'Texas', N'76162', 1, 32.7714, -97.2915)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (130, N'0891 Oakridge Junction', 100, N'Portland', N'Oregon', N'97286', 0, 45.5806, -122.3748)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (131, N'3 Veith Street', 86, N'Seattle', N'Washington', N'98166', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (132, N'01854 Hanover Way', 64, N'Chattanooga', N'Tennessee', N'37416', 1, 35.0942, -85.1757)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (133, N'18 Darwin Court', 56, N'El Paso', N'Texas', N'88569', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (134, N'269 Daystar Plaza', 4, N'Saint Paul', N'Minnesota', N'55172', 1, 45.0059, -93.1059)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (135, N'7606 Lotheville Center', 58, N'Columbia', N'South Carolina', N'29215', 1, 34.006, -80.9708)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (136, N'52714 Claremont Crossing', NULL, N'Trenton', N'New Jersey', N'08619', 0, 40.2418, -74.6962)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (137, N'2 Lunder Way', 71, N'Chicago', N'Illinois', N'60686', 0, 41.8756, -87.6378)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (138, N'1 Banding Center', NULL, N'Fort Wayne', N'Indiana', N'46805', 0, 41.0977, -85.1189)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (139, N'3931 Jenifer Parkway', 46, N'Helena', N'Montana', N'59623', 1, 46.5901, -112.0402)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (140, N'17413 Reindahl Court', 39, N'Cleveland', N'Ohio', N'44111', 0, 41.4571, -81.7844)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (141, N'6 John Wall Street', 64, N'Mobile', N'Alabama', N'36605', 1, 30.6341, -88.0846)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (142, N'432 Roth Way', 93, N'Fayetteville', N'North Carolina', N'28305', 1, 35.056, -78.9047)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (143, N'5469 Eastwood Alley', 97, N'Charlotte', N'North Carolina', N'28235', 1, 35.26, -80.8042)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (144, N'65 Clove Circle', 6, N'Jacksonville', N'Florida', N'32215', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (145, N'33928 Basil Lane', 44, N'Knoxville', N'Tennessee', N'37914', 0, 35.9918, -83.8496)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (146, N'47926 Melby Place', 87, N'Cincinnati', N'Ohio', N'45999', 1, 39.1668, -84.5382)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (147, N'2384 Vahlen Park', NULL, N'Kansas City', N'Missouri', N'64130', 0, 39.0351, -94.5467)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (148, N'946 Hoepker Parkway', 44, N'West Palm Beach', N'Florida', N'33411', 1, 26.6644, -80.1741)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (149, N'69414 Blackbird Hill', 42, N'Punta Gorda', N'Florida', N'33982', 0, 26.9668, -81.9545)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (150, N'944 Grayhawk Plaza', 51, N'Lincoln', N'Nebraska', N'68583', 1, 40.7845, -96.6888)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (151, N'74900 Mallard Court', NULL, N'Richmond', N'Virginia', N'23277', 0, 37.5535, -77.4604)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (152, N'359 Badeau Way', 74, N'Kissimmee', N'Florida', N'34745', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (153, N'1 Vidon Avenue', NULL, N'San Francisco', N'California', N'94116', 0, 37.7441, -122.4863)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (154, N'5405 Ludington Circle', NULL, N'Austin', N'Texas', N'78749', 1, 30.2166, -97.8508)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (155, N'7264 Village Parkway', NULL, N'Charleston', N'West Virginia', N'25321', 1, 38.2968, -81.5547)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (156, N'3450 Logan Trail', 67, N'Cape Coral', N'Florida', N'33915', 1, 26.6599, -81.8934)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (157, N'1 Daystar Circle', 15, N'Montgomery', N'Alabama', N'36109', 1, 32.3834, -86.2434)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (158, N'354 Comanche Parkway', 46, N'Louisville', N'Kentucky', N'40287', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (159, N'927 Mendota Road', 13, N'Santa Monica', N'California', N'90405', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (160, N'5 Transport Hill', 48, N'Burbank', N'California', N'91520', 0, 34.1869, -118.348)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (161, N'46 Morningstar Place', 11, N'Canton', N'Ohio', N'44760', 0, 40.854, -81.4278)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (162, N'50942 Banding Parkway', 25, N'Grand Forks', N'North Dakota', N'58207', 1, 47.9335, -97.3944)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (163, N'0950 Miller Pass', 60, N'Mansfield', N'Ohio', N'44905', 1, 40.7779, -82.4613)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (164, N'4 Kennedy Drive', 32, N'Paterson', N'New Jersey', N'07505', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (165, N'75238 Hoffman Parkway', 94, N'Colorado Springs', N'Colorado', N'80920', 0, 38.9497, -104.767)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (166, N'0 Fairfield Parkway', 51, N'Oklahoma City', N'Oklahoma', N'73167', 1, 35.5514, -97.4075)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (167, N'606 Brickson Park Drive', NULL, N'Knoxville', N'Tennessee', N'37931', 1, 35.9924, -84.1201)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (168, N'151 David Place', 50, N'Houston', N'Texas', N'77276', 0, 29.7575, -95.3668)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (169, N'3 Blue Bill Park Street', NULL, N'New York City', N'New York', N'10039', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (170, N'9070 Columbus Plaza', 66, N'Des Moines', N'Iowa', N'50936', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (171, N'084 Westridge Junction', 100, N'Dallas', N'Texas', N'75367', 1, 32.7673, -96.7776)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (172, N'56 Commercial Hill', 68, N'Monticello', N'Minnesota', N'55585', 1, 45.2009, -93.8881)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (173, N'9289 Summerview Avenue', NULL, N'Miami', N'Florida', N'33261', 0, 25.5584, -80.4582)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (174, N'8764 South Lane', 37, N'Phoenix', N'Arizona', N'85005', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (175, N'48188 Boyd Terrace', 4, N'Miami', N'Florida', N'33142', 1, 25.813, -80.232)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (176, N'83452 Kenwood Circle', 96, N'Midland', N'Texas', N'79705', 0, 32.0295, -102.0915)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (177, N'3823 Hoffman Terrace', 12, N'Birmingham', N'Alabama', N'35285', 0, 33.5446, -86.9292)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (178, N'536 Bartelt Junction', NULL, N'Cedar Rapids', N'Iowa', N'52405', 1, 41.9804, -91.7098)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (179, N'4 Derek Point', NULL, N'Trenton', N'New Jersey', N'08608', 0, 40.2204, -74.7622)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (180, N'536 Sachs Court', NULL, N'Omaha', N'Nebraska', N'68105', 0, 41.2435, -95.9629)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (181, N'81 Randy Park', 82, N'Scranton', N'Pennsylvania', N'18505', 0, 41.3914, -75.6657)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (182, N'0823 Starling Junction', 93, N'Escondido', N'California', N'92030', 1, 33.0169, -116.846)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (183, N'61814 Wayridge Court', 19, N'Des Moines', N'Iowa', N'50305', 1, 41.6727, -93.5722)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (184, N'733 Carberry Trail', 3, N'Riverside', N'California', N'92519', 1, 33.7529, -116.0556)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (185, N'71266 Hayes Street', NULL, N'Columbia', N'Missouri', N'65211', 1, 38.9033, -92.1022)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (186, N'83673 Alpine Pass', 60, N'Corpus Christi', N'Texas', N'78405', 0, 27.7762, -97.4271)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (187, N'97651 Hermina Center', NULL, N'Kansas City', N'Missouri', N'64114', 0, 38.9621, -94.5959)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (188, N'4969 Esch Crossing', NULL, N'Oklahoma City', N'Oklahoma', N'73104', 0, 35.4794, -97.5017)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (189, N'32231 Eggendart Plaza', 52, N'Aurora', N'Colorado', N'80045', 0, 39.7467, -104.8384)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (190, N'8 Carey Drive', 76, N'Salt Lake City', N'Utah', N'84152', 0, 40.7286, -111.6627)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (191, N'679 Delladonna Plaza', 82, N'San Diego', N'California', N'92132', 1, 32.6437, -117.1384)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (192, N'24201 Sunfield Way', 77, N'Salt Lake City', N'Utah', N'84120', 0, 40.695, -112.0001)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (193, N'0 Saint Paul Circle', 60, N'Shawnee Mission', N'Kansas', N'66205', 1, 39.0312, -94.6308)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (194, N'1407 Harbort Drive', 27, N'Indianapolis', N'Indiana', N'46226', 0, 39.8326, -86.0836)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (195, N'13 Hoepker Road', 91, N'Saint Petersburg', N'Florida', N'33715', 1, 27.6705, -82.7119)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (196, N'90 8th Plaza', NULL, N'Youngstown', N'Ohio', N'44555', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (197, N'66972 Union Junction', 8, N'Reading', N'Pennsylvania', N'19610', 0, 40.338, -75.978)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (198, N'994 Lukken Park', 53, N'Ogden', N'Utah', N'84409', 1, 41.2553, -111.9567)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (199, N'87 Lunder Trail', NULL, N'Independence', N'Missouri', N'64054', 0, 39.11, -94.4401)
GO
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (200, N'7 Sunbrook Lane', NULL, N'Vancouver', N'Washington', N'98687', 0, 45.8016, -122.5203)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (201, N'89 Bunker Hill Crossing', 50, N'Albuquerque', N'New Mexico', N'87105', 1, 35.0448, -106.6893)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (202, N'37 Lunder Street', 18, N'Hartford', N'Connecticut', N'06120', 0, 41.786, -72.6758)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (203, N'04717 Fisk Pass', 32, N'Houston', N'Texas', N'77228', 1, 29.834, -95.4342)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (204, N'7406 Merrick Junction', 39, N'Salt Lake City', N'Utah', N'84199', 1, 40.7259, -111.9394)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (205, N'38 Elka Park', NULL, N'Richmond', N'Virginia', N'23293', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (206, N'6488 Thierer Trail', NULL, N'Battle Creek', N'Michigan', N'49018', 1, 42.2464, -85.0045)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (207, N'98 Fieldstone Trail', 21, N'Stamford', N'Connecticut', N'06922', 1, 41.0516, -73.5143)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (208, N'26158 Becker Trail', 55, N'Montgomery', N'Alabama', N'36177', 0, 32.2334, -86.2085)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (209, N'829 Mesta Plaza', 4, N'Stamford', N'Connecticut', N'06912', 1, 41.3089, -73.3637)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (210, N'526 Bellgrove Street', 22, N'Washington', N'District of Columbia', N'20503', 1, 38.9007, -77.0431)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (211, N'488 Dawn Road', 29, N'Arlington', N'Virginia', N'22205', 0, 38.8836, -77.1395)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (212, N'35754 Onsgard Avenue', 30, N'Paterson', N'New Jersey', N'07505', 1, 40.9166, -74.174)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (213, N'8052 Truax Street', 53, N'Shreveport', N'Louisiana', N'71105', 1, 32.4589, -93.7143)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (214, N'250 Weeping Birch Junction', 16, N'Spokane', N'Washington', N'99220', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (215, N'7541 Steensland Center', NULL, N'Glendale', N'Arizona', N'85311', 1, 33.2765, -112.1872)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (216, N'846 Russell Park', 85, N'Ocala', N'Florida', N'34474', 1, 29.1565, -82.2095)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (217, N'1457 Springs Court', NULL, N'Fresno', N'California', N'93762', 1, 36.7464, -119.6397)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (218, N'82747 Melody Road', 16, N'Stamford', N'Connecticut', N'06912', 1, 41.3089, -73.3637)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (219, N'1 Grasskamp Crossing', 100, N'San Bernardino', N'California', N'92424', 0, 34.84, -115.9671)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (220, N'00 Superior Court', 76, N'Van Nuys', N'California', N'91411', 0, 34.1781, -118.4574)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (221, N'988 Scofield Center', 41, N'Richmond', N'Virginia', N'23220', 1, 37.5498, -77.4588)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (222, N'77 Lakewood Way', NULL, N'Lexington', N'Kentucky', N'40546', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (223, N'37 Annamark Alley', 37, N'Roanoke', N'Virginia', N'24009', 1, 37.2742, -79.9579)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (224, N'4 Brickson Park Drive', 19, N'Knoxville', N'Tennessee', N'37914', 0, 35.9918, -83.8496)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (225, N'22588 Moulton Junction', 46, N'Littleton', N'Colorado', N'80161', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (226, N'392 Brickson Park Park', 16, N'El Paso', N'Texas', N'79905', 1, 31.7674, -106.4304)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (227, N'50721 Calypso Court', 44, N'Youngstown', N'Ohio', N'44511', 0, 41.0704, -80.6931)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (228, N'3 Havey Center', 30, N'Spartanburg', N'South Carolina', N'29305', 1, 35.1114, -82.1055)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (229, N'8 Fuller Junction', 21, N'Spokane', N'Washington', N'99205', 0, 47.6964, -117.4399)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (230, N'0753 Novick Avenue', 33, N'Cincinnati', N'Ohio', N'45233', 0, 39.111, -84.6594)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (231, N'802 Debs Pass', 71, N'Phoenix', N'Arizona', N'85010', 1, 33.2765, -112.1872)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (232, N'1945 Comanche Place', 15, N'Battle Creek', N'Michigan', N'49018', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (233, N'736 Lindbergh Center', 45, N'Washington', N'District of Columbia', N'20036', 0, 38.9087, -77.0414)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (234, N'980 Springview Trail', NULL, N'North Las Vegas', N'Nevada', N'89036', 1, 35.9279, -114.9721)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (235, N'53084 Mendota Center', 78, N'San Diego', N'California', N'92191', 0, 33.0169, -116.846)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (236, N'324 Del Sol Circle', 97, N'New Hyde Park', N'New York', N'11044', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (237, N'3 Upham Hill', NULL, N'Seattle', N'Washington', N'98195', 0, 47.6564, -122.3048)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (238, N'28164 Sugar Place', NULL, N'Charlotte', N'North Carolina', N'28210', 0, 35.1316, -80.8577)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (239, N'378 Columbus Street', 89, N'Roanoke', N'Virginia', N'24040', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (240, N'2 Anniversary Park', 6, N'Canton', N'Ohio', N'44720', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (241, N'44470 Riverside Hill', NULL, N'Sacramento', N'California', N'94245', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (242, N'27581 Marquette Point', 99, N'Reno', N'Nevada', N'89595', 1, 40.5412, -119.5869)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (243, N'92529 Center Junction', 25, N'North Las Vegas', N'Nevada', N'89087', 0, 36.2204, -115.1458)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (244, N'5 Northwestern Place', NULL, N'El Paso', N'Texas', N'88558', 0, 31.6948, -106.3)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (245, N'958 Upham Road', NULL, N'Washington', N'District of Columbia', N'20337', 1, 38.8933, -77.0146)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (246, N'4 Burrows Junction', 2, N'Philadelphia', N'Pennsylvania', N'19093', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (247, N'2267 Blackbird Pass', 99, N'Houston', N'Texas', N'77260', 1, 29.7687, -95.3867)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (248, N'5 Shopko Plaza', 27, N'Los Angeles', N'California', N'90060', 1, 33.7866, -118.2987)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (249, N'45303 Fairview Drive', NULL, N'York', N'Pennsylvania', N'17405', 1, 40.0086, -76.5972)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (250, N'014 Alpine Alley', NULL, N'Saint Cloud', N'Minnesota', N'56372', 0, 45.5289, -94.5933)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (251, N'73 Waywood Center', 63, N'Seattle', N'Washington', N'98185', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (252, N'5 Bay Drive', NULL, N'Charlotte', N'North Carolina', N'28263', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (253, N'318 Warrior Road', 81, N'Sioux Falls', N'South Dakota', N'57110', 0, 43.5486, -96.6332)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (254, N'5298 Hoard Avenue', 59, N'Hartford', N'Connecticut', N'06183', 0, 41.7638, -72.673)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (255, N'93702 Petterle Court', NULL, N'Melbourne', N'Florida', N'32919', 1, 28.3067, -80.6862)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (256, N'0212 Mitchell Point', 36, N'Detroit', N'Michigan', N'48258', 1, 42.2399, -83.1508)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (257, N'79266 Talisman Pass', 61, N'Fort Lauderdale', N'Florida', N'33315', 1, 26.0989, -80.1541)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (258, N'68802 Pennsylvania Way', 43, N'Long Beach', N'California', N'90810', 0, 33.8193, -118.2325)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (259, N'465 Dwight Street', 30, N'Little Rock', N'Arkansas', N'72204', 0, 34.7269, -92.344)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (260, N'82 Loomis Point', NULL, N'Charlotte', N'North Carolina', N'28205', 1, 35.22, -80.7881)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (261, N'15443 Grim Alley', 86, N'San Jose', N'California', N'95128', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (262, N'955 Tennessee Place', 3, N'Lake Worth', N'Florida', N'33467', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (263, N'0274 Monterey Way', 9, N'Greensboro', N'North Carolina', N'27455', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (264, N'882 Hudson Crossing', NULL, N'Louisville', N'Kentucky', N'40225', 1, 38.189, -85.6768)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (265, N'654 Kropf Plaza', NULL, N'Baton Rouge', N'Louisiana', N'70883', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (266, N'0983 Anniversary Street', NULL, N'Bloomington', N'Indiana', N'47405', 0, 39.1682, -86.5186)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (267, N'856 Lerdahl Terrace', NULL, N'San Antonio', N'Texas', N'78205', 0, 29.4237, -98.4925)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (268, N'27 Namekagon Point', 84, N'Salinas', N'California', N'93907', 1, 36.7563, -121.6703)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (269, N'0030 Mockingbird Park', 84, N'Montgomery', N'Alabama', N'36195', 0, 32.3544, -86.2843)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (270, N'04558 Hoepker Avenue', 12, N'Birmingham', N'Alabama', N'35242', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (271, N'50436 Montana Road', 17, N'Fort Smith', N'Arkansas', N'72916', 0, 35.2502, -94.3703)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (272, N'3949 Rutledge Place', 13, N'Washington', N'District of Columbia', N'20425', 1, 38.8933, -77.0146)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (273, N'583 Ryan Crossing', NULL, N'Louisville', N'Kentucky', N'40293', 0, 38.189, -85.6768)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (274, N'82 Thompson Street', 18, N'Los Angeles', N'California', N'90060', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (275, N'80357 Carey Lane', 69, N'Grand Rapids', N'Michigan', N'49510', 0, 43.0314, -85.5503)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (276, N'850 Delaware Drive', 3, N'Charleston', N'West Virginia', N'25362', 1, 38.2968, -81.5547)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (277, N'891 Forest Dale Court', NULL, N'Bakersfield', N'California', N'93305', 0, 35.3855, -118.986)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (278, N'94751 Grim Drive', 34, N'Spokane', N'Washington', N'99260', 1, 47.6536, -117.4317)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (279, N'17 Delladonna Trail', 23, N'New York City', N'New York', N'10125', 1, 40.7808, -73.9772)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (280, N'863 Chinook Terrace', 17, N'Albuquerque', N'New Mexico', N'87105', 1, 35.0448, -106.6893)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (281, N'2967 American Way', NULL, N'Albany', N'New York', N'12262', 0, 42.6149, -73.9708)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (282, N'21 Barnett Street', NULL, N'Indianapolis', N'Indiana', N'46247', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (283, N'3 Dottie Pass', NULL, N'Dallas', N'Texas', N'75287', 1, 33.0005, -96.8314)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (284, N'7 Bobwhite Place', 73, N'Corpus Christi', N'Texas', N'78475', 0, 27.777, -97.4632)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (285, N'08850 Anthes Way', 11, N'Honolulu', N'Hawaii', N'96805', 0, 21.3062, -157.8585)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (286, N'6 Beilfuss Road', 69, N'Kansas City', N'Missouri', N'64179', 0, 39.035, -94.3567)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (287, N'90 Brown Court', NULL, N'Charlotte', N'North Carolina', N'28210', 1, 35.1316, -80.8577)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (288, N'2 Summerview Drive', 65, N'Little Rock', N'Arkansas', N'72209', 1, 34.6725, -92.3529)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (289, N'062 Talmadge Court', 89, N'Honolulu', N'Hawaii', N'96835', 1, 21.3278, -157.8294)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (290, N'66298 Village Junction', 24, N'Miami Beach', N'Florida', N'33141', 1, 25.8486, -80.1446)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (291, N'0 Lindbergh Circle', 23, N'Jamaica', N'New York', N'11480', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (292, N'251 MyStreet Update25943', 25943, N'City Update25943', N'State Update25943', N'25943', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (293, N'1364 John Wall Place', 50, N'New York City', N'New York', N'10249', 0, 40.7808, -73.9772)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (294, N'5 Buena Vista Junction', NULL, N'Huntsville', N'Alabama', N'35810', 1, 34.7784, -86.6091)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (295, N'93859 Mosinee Alley', NULL, N'Whittier', N'California', N'90605', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (296, N'88 Independence Avenue', 88, N'Lake Charles', N'Louisiana', N'70616', 0, 30.2642, -93.3265)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (297, N'12126 Moose Court', 83, N'Birmingham', N'Alabama', N'35295', 1, 33.5446, -86.9292)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (298, N'23 Manley Terrace', 15, N'Erie', N'Pennsylvania', N'16550', 1, 42.1827, -80.0649)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (299, N'4737 Kinsman Street', 90, N'Clearwater', N'Florida', N'33763', 1, 28.0173, -82.7461)
GO
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (300, N'5589 Center Way', NULL, N'Anaheim', N'California', N'92825', 1, 33.8356, -117.9132)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (301, N'091 Vernon Court', 37, N'Olympia', N'Washington', N'98516', 1, 47.1126, -122.7794)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (302, N'80647 Sachs Point', 59, N'Hartford', N'Connecticut', N'06140', 1, 41.7918, -72.7188)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (303, N'6827 Barby Alley', 59, N'Saint Paul', N'Minnesota', N'55188', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (304, N'5351 Dexter Circle', 60, N'Spartanburg', N'South Carolina', N'29305', 1, 35.1114, -82.1055)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (305, N'08 Rowland Point', NULL, N'Raleigh', N'North Carolina', N'27635', 0, 35.7977, -78.6253)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (306, N'3508 Bellgrove Alley', 21, N'Bozeman', N'Montana', N'59771', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (307, N'6 Hagan Street', 27, N'Dearborn', N'Michigan', N'48126', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (308, N'33 Fremont Terrace', 84, N'Miami', N'Florida', N'33134', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (309, N'813 Butterfield Hill', 86, N'Stockton', N'California', N'95298', 1, 37.9577, -121.2897)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (310, N'00511 New Castle Trail', 28, N'Sacramento', N'California', N'94273', 1, 38.3774, -121.4444)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (311, N'2 Westridge Road', NULL, N'Rockville', N'Maryland', N'20851', 0, 39.0763, -77.1234)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (312, N'1332 Summerview Junction', 15, N'Austin', N'Texas', N'78715', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (313, N'6037 Jana Place', NULL, N'Appleton', N'Wisconsin', N'54915', 1, 44.2425, -88.3564)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (314, N'24 Rigney Crossing', 46, N'San Antonio', N'Texas', N'78250', 0, 29.5054, -98.6688)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (315, N'21432 Cherokee Trail', 58, N'Spokane', N'Washington', N'99260', 0, 47.6536, -117.4317)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (316, N'46195 Di Loreto Park', 79, N'York', N'Pennsylvania', N'17405', 0, 40.0086, -76.5972)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (317, N'18 Blue Bill Park Trail', 62, N'Memphis', N'Tennessee', N'38197', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (318, N'657 Southridge Lane', NULL, N'Buffalo', N'New York', N'14205', 0, 42.7684, -78.8871)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (319, N'48038 Nevada Lane', 60, N'Buffalo', N'New York', N'14210', 0, 42.8614, -78.8206)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (320, N'180 Hallows Road', 3, N'Greenville', N'South Carolina', N'29610', 1, 34.8497, -82.4538)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (321, N'0 Northwestern Plaza', 33, N'Punta Gorda', N'Florida', N'33982', 1, 26.9668, -81.9545)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (322, N'1415 Steensland Road', 40, N'Sacramento', N'California', N'94286', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (323, N'62 Sunfield Alley', 22, N'Chicago', N'Illinois', N'60630', 1, 41.9699, -87.7603)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (324, N'32 Commercial Road', NULL, N'Memphis', N'Tennessee', N'38126', 1, 35.1255, -90.0424)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (325, N'31527 International Center', NULL, N'Boulder', N'Colorado', N'80328', 0, 40.0878, -105.3735)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (326, N'66 Eastwood Road', 28, N'Lansing', N'Michigan', N'48919', 0, 42.7286, -84.5517)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (327, N'235 Twin Pines Plaza', 33, N'Virginia Beach', N'Virginia', N'23464', 1, 36.7978, -76.1759)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (328, N'084 Utah Alley', 68, N'Lake Worth', N'Florida', N'33462', 0, 26.5747, -80.0794)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (329, N'62153 Kensington Court', NULL, N'Memphis', N'Tennessee', N'38119', 0, 35.0821, -89.8501)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (330, N'359 David Trail', 42, N'Dallas', N'Texas', N'75287', 1, 33.0005, -96.8314)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (331, N'33700 Old Gate Center', 18, N'Des Moines', N'Iowa', N'50936', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (332, N'859 Butternut Terrace', 31, N'El Paso', N'Texas', N'79968', 1, 31.7705, -106.5048)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (333, N'4547 American Circle', 84, N'Lafayette', N'Indiana', N'47905', 1, 40.4001, -86.8602)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (334, N'2 Sutherland Alley', NULL, N'Arvada', N'Colorado', N'80005', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (335, N'3249 Macpherson Crossing', 55, N'Shreveport', N'Louisiana', N'71130', 0, 32.6076, -93.7526)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (336, N'551 Claremont Park', NULL, N'Wichita', N'Kansas', N'67260', 1, 37.7194, -97.2936)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (337, N'82220 Vernon Alley', 8, N'Washington', N'District of Columbia', N'20551', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (338, N'17977 Mitchell Avenue', 83, N'Dallas', N'Texas', N'75353', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (339, N'605 Rutledge Trail', NULL, N'Fort Pierce', N'Florida', N'34949', 0, 27.3896, -80.2615)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (340, N'92616 Pleasure Pass', NULL, N'Sacramento', N'California', N'95865', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (341, N'0167 Parkside Park', 21, N'Tampa', N'Florida', N'33647', 1, 28.1147, -82.3678)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (342, N'78 Northfield Pass', 4, N'Kissimmee', N'Florida', N'34745', 1, 27.9953, -81.2593)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (343, N'3 Mariners Cove Junction', NULL, N'Trenton', N'New Jersey', N'08603', 0, 40.2805, -74.712)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (344, N'90 Mariners Cove Junction', 25, N'Bronx', N'New York', N'10459', 0, 40.8247, -73.894)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (345, N'79 Elgar Place', 17, N'Marietta', N'Georgia', N'30066', 0, 34.0378, -84.5038)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (346, N'20399 Derek Alley', 74, N'Harrisburg', N'Pennsylvania', N'17126', 0, 40.2618, -76.88)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (347, N'5 Grayhawk Parkway', 25, N'Philadelphia', N'Pennsylvania', N'19093', 0, 40.0018, -75.1179)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (348, N'7595 Mariners Cove Pass', 33, N'Houston', N'Texas', N'77240', 1, 29.834, -95.4342)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (349, N'86366 Comanche Alley', 93, N'Phoenix', N'Arizona', N'85015', 1, 33.5082, -112.1011)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (350, N'2940 Havey Road', 6, N'Boston', N'Massachusetts', N'02298', 0, 42.3823, -71.0323)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (351, N'11 Monument Plaza', NULL, N'Miami', N'Florida', N'33142', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (352, N'3848 Washington Terrace', 50, N'Washington', N'District of Columbia', N'20546', 0, 38.891, -77.0211)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (353, N'895 Oneill Lane', NULL, N'Birmingham', N'Alabama', N'35231', 1, 33.5446, -86.9292)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (354, N'420 Corben Way', 70, N'Portland', N'Oregon', N'97216', 1, 45.5137, -122.5569)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (355, N'6609 Fallview Avenue', 93, N'Spokane', N'Washington', N'99220', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (356, N'00 Kennedy Road', 32, N'Virginia Beach', N'Virginia', N'23464', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (357, N'57941 Corscot Place', NULL, N'Seattle', N'Washington', N'98166', 0, 47.4511, -122.353)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (358, N'7 Arapahoe Alley', NULL, N'Saint Cloud', N'Minnesota', N'56398', 0, 45.5289, -94.5933)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (359, N'558 Birchwood Street', 95, N'San Antonio', N'Texas', N'78225', 0, 29.3875, -98.5245)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (360, N'13 Sunnyside Point', NULL, N'Austin', N'Texas', N'78721', 1, 30.2721, -97.6868)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (361, N'03 Myrtle Trail', 87, N'New York City', N'New York', N'10060', 0, 40.7808, -73.9772)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (362, N'8314 Bay Road', 51, N'Pittsburgh', N'Pennsylvania', N'15230', 1, 40.4344, -80.0248)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (363, N'1 Becker Way', 37, N'Minneapolis', N'Minnesota', N'55441', 1, 45.0058, -93.4193)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (364, N'727 Muir Park', NULL, N'Baltimore', N'Maryland', N'21203', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (365, N'2065 Debra Pass', 99, N'Birmingham', N'Alabama', N'35295', 1, 33.5446, -86.9292)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (366, N'5 Kinsman Pass', 36, N'Odessa', N'Texas', N'79764', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (367, N'9 Melby Hill', 98, N'Fairfax', N'Virginia', N'22036', 0, 38.7351, -77.0796)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (368, N'9444 Spohn Pass', 47, N'Portland', N'Oregon', N'97211', 1, 45.5653, -122.6448)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (369, N'969 Oriole Alley', 69, N'Mobile', N'Alabama', N'36616', 1, 30.671, -88.1267)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (370, N'34 2nd Circle', 41, N'Long Beach', N'California', N'90831', 0, 33.7678, -118.1994)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (371, N'499 Spenser Circle', 85, N'Madison', N'Wisconsin', N'53710', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (372, N'704 Ridgeview Junction', NULL, N'Canton', N'Ohio', N'44705', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (373, N'1520 Walton Terrace', 83, N'Detroit', N'Michigan', N'48242', 0, 42.2166, -83.3532)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (374, N'7764 Hanover Center', 87, N'New York City', N'New York', N'10170', 1, 40.7526, -73.9755)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (375, N'3 Amoth Trail', 82, N'Colorado Springs', N'Colorado', N'80925', 0, 38.7378, -104.6459)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (376, N'83003 Goodland Circle', NULL, N'Jacksonville', N'Florida', N'32215', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (377, N'72918 Monica Center', 97, N'Lexington', N'Kentucky', N'40576', 1, 38.0283, -84.4715)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (378, N'36 Dixon Street', NULL, N'Lancaster', N'Pennsylvania', N'17622', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (379, N'09 Drewry Hill', NULL, N'Columbus', N'Ohio', N'43231', 1, 40.081, -82.9383)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (380, N'2 Northland Way', 82, N'Dayton', N'Ohio', N'45408', 1, 39.7395, -84.229)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (381, N'23395 Shasta Alley', 92, N'Cleveland', N'Ohio', N'44105', 1, 41.4509, -81.619)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (382, N'40782 Menomonie Circle', 91, N'Boston', N'Massachusetts', N'02114', 0, 42.3611, -71.0682)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (383, N'250 Tomscot Trail', 9, N'White Plains', N'New York', N'10606', 0, 41.0247, -73.7781)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (384, N'038 Southridge Drive', 61, N'Marietta', N'Georgia', N'30066', 0, 34.0378, -84.5038)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (385, N'620 Chive Point', NULL, N'Los Angeles', N'California', N'90005', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (386, N'0704 Crescent Oaks Park', 85, N'Kansas City', N'Kansas', N'66160', 1, 39.0966, -94.7495)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (387, N'082 Arapahoe Point', 21, N'Albany', N'New York', N'12237', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (388, N'3 Burning Wood Street', 79, N'Alexandria', N'Virginia', N'22313', 1, 38.8158, -77.09)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (389, N'3 Straubel Trail', 98, N'Carson City', N'Nevada', N'89706', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (390, N'6 Elka Trail', 95, N'Tucson', N'Arizona', N'85732', 0, 32.0848, -110.7122)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (391, N'8455 Sachtjen Point', 12, N'San Antonio', N'Texas', N'78265', 1, 29.4375, -98.4616)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (392, N'0165 Ohio Road', 72, N'Indianapolis', N'Indiana', N'46202', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (393, N'8 Lawn Street', 5, N'Indianapolis', N'Indiana', N'46247', 0, 39.7795, -86.1328)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (394, N'875 Duke Junction', 6, N'Cleveland', N'Ohio', N'44177', 0, 41.6857, -81.6728)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (395, N'57 Atwood Avenue', NULL, N'Cleveland', N'Ohio', N'44105', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (396, N'89 Prairieview Alley', 36, N'Kansas City', N'Missouri', N'64136', 1, 39.0187, -94.4008)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (397, N'279 Shopko Circle', 70, N'Aurora', N'Colorado', N'80044', 1, 39.7388, -104.4083)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (398, N'867 Everett Plaza', 10, N'Sacramento', N'California', N'94257', 0, 38.3774, -121.4444)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (399, N'58 Schiller Hill', 38, N'Dallas', N'Texas', N'75226', 1, 32.7887, -96.7676)
GO
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (400, N'3 Bonner Drive', NULL, N'Flushing', N'New York', N'11388', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (401, N'71 Sommers Point', 12, N'Philadelphia', N'Pennsylvania', N'19115', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (402, N'0157 Derek Terrace', 59, N'Vero Beach', N'Florida', N'32969', 1, 27.709, -80.5726)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (403, N'51 Aberg Crossing', 81, N'Lincoln', N'Nebraska', N'68524', 0, 40.8529, -96.7943)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (404, N'2 Anhalt Lane', 36, N'Saginaw', N'Michigan', N'48604', 1, 43.4732, -83.9514)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (405, N'6316 South Crossing', 63, N'Bonita Springs', N'Florida', N'34135', 1, 26.3771, -81.7334)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (406, N'07774 Elka Pass', NULL, N'Pasadena', N'California', N'91109', 1, 33.7866, -118.2987)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (407, N'124 East Court', 44, N'Los Angeles', N'California', N'90050', 0, 33.7866, -118.2987)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (408, N'116 Rigney Alley', NULL, N'Honolulu', N'Hawaii', N'96815', 0, 21.2811, -157.8266)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (409, N'85997 Sloan Plaza', 59, N'Mobile', N'Alabama', N'36689', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (410, N'9992 Golden Leaf Alley', 53, N'Garden Grove', N'California', N'92844', 0, 33.7661, -117.9738)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (411, N'863 Stuart Place', NULL, N'Pinellas Park', N'Florida', N'34665', 0, 27.8402, -82.7125)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (412, N'946 Summer Ridge Alley', NULL, N'Irving', N'Texas', N'75037', 0, 32.7673, -96.7776)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (413, N'39783 Vernon Crossing', 39, N'Sarasota', N'Florida', N'34276', 1, 27.1675, -82.381)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (414, N'37438 Hintze Parkway', 65, N'Lexington', N'Kentucky', N'40581', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (415, N'375 Cottonwood Pass', 55, N'Los Angeles', N'California', N'90060', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (416, N'6188 Talisman Pass', NULL, N'Fort Lauderdale', N'Florida', N'33315', 1, 26.0989, -80.1541)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (417, N'422 Everett Parkway', 60, N'Grand Rapids', N'Michigan', N'49510', 0, 43.0314, -85.5503)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (418, N'6934 Dovetail Way', NULL, N'Salt Lake City', N'Utah', N'84145', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (419, N'7 Nelson Circle', 51, N'Des Moines', N'Iowa', N'50320', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (420, N'07 Hallows Junction', 1, N'Washington', N'District of Columbia', N'20005', 0, 38.9067, -77.0312)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (421, N'85 Meadow Valley Circle', 13, N'Tampa', N'Florida', N'33633', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (422, N'19 Sauthoff Circle', NULL, N'Lawrenceville', N'Georgia', N'30045', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (423, N'924 Almo Center', 62, N'Boulder', N'Colorado', N'80328', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (424, N'10 Spenser Crossing', NULL, N'Phoenix', N'Arizona', N'85083', 0, 33.7352, -112.1294)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (425, N'251 MyStreet Update46034', 46034, N'City Update46034', N'State Update46034', N'46034', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (426, N'8 Steensland Place', NULL, N'Stockton', N'California', N'95205', 0, 37.9625, -121.2624)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (427, N'4 Marquette Place', NULL, N'Burbank', N'California', N'91505', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (428, N'6579 Mcguire Avenue', 1, N'San Diego', N'California', N'92145', 0, 32.8891, -117.1005)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (429, N'04 Superior Trail', 87, N'Houston', N'Texas', N'77030', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (430, N'945 Rockefeller Park', 97, N'Texarkana', N'Texas', N'75507', 0, 33.3934, -94.3404)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (431, N'433 Rieder Junction', 38, N'Cincinnati', N'Ohio', N'45208', 0, 39.1361, -84.4355)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (432, N'8571 Milwaukee Junction', 92, N'Toledo', N'Ohio', N'43605', 1, 41.6525, -83.5085)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (433, N'59352 Towne Way', NULL, N'Miami', N'Florida', N'33124', 1, 25.5584, -80.4582)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (434, N'7 Maple Drive', 63, N'Washington', N'District of Columbia', N'20310', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (435, N'042 Shoshone Junction', NULL, N'Montpelier', N'Vermont', N'05609', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (436, N'4 Golf View Circle', NULL, N'Odessa', N'Texas', N'79769', 1, 31.7466, -102.567)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (437, N'983 Lakewood Gardens Drive', 42, N'Shreveport', N'Louisiana', N'71151', 1, 32.6076, -93.7526)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (438, N'377 Southridge Center', 98, N'Ocala', N'Florida', N'34474', 0, 29.1565, -82.2095)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (439, N'84641 Veith Park', 93, N'Newark', N'Delaware', N'19725', 0, 39.5645, -75.597)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (440, N'79795 Acker Lane', 61, N'Los Angeles', N'California', N'90030', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (441, N'4694 Redwing Junction', NULL, N'San Bernardino', N'California', N'92424', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (442, N'529 Badeau Way', NULL, N'Pasadena', N'California', N'91186', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (443, N'880 Old Shore Place', 55, N'Santa Ana', N'California', N'92705', 1, 33.754, -117.7919)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (444, N'35070 Loftsgordon Road', 83, N'Boston', N'Massachusetts', N'02203', 0, 42.3615, -71.0604)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (445, N'8039 Ludington Road', 50, N'Cleveland', N'Ohio', N'44111', 1, 41.4571, -81.7844)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (446, N'24851 Dorton Lane', 58, N'Oakland', N'California', N'94660', 1, 37.6802, -121.9215)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (447, N'65055 Brickson Park Point', 37, N'Colorado Springs', N'Colorado', N'80905', 0, 38.8377, -104.837)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (448, N'08 Namekagon Street', 34, N'Edmond', N'Oklahoma', N'73034', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (449, N'61253 Colorado Plaza', 87, N'Torrance', N'California', N'90510', 0, 33.7866, -118.2987)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (450, N'72 Meadow Vale Drive', 38, N'Washington', N'District of Columbia', N'20036', 0, 38.9087, -77.0414)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (451, N'57 Village Green Circle', 14, N'Hartford', N'Connecticut', N'06105', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (452, N'0911 Jana Junction', 58, N'Pomona', N'California', N'91797', 0, 33.7866, -118.2987)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (453, N'4 Stoughton Parkway', 13, N'Rochester', N'New York', N'14683', 1, 43.286, -77.6843)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (454, N'7 Summer Ridge Plaza', 38, N'Monroe', N'Louisiana', N'71213', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (455, N'52 Truax Way', 61, N'Wichita', N'Kansas', N'67205', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (456, N'04 Walton Hill', NULL, N'Amarillo', N'Texas', N'79171', 1, 35.4015, -101.8951)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (457, N'31837 Kim Center', 91, N'Memphis', N'Tennessee', N'38136', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (458, N'6 Corben Avenue', 39, N'Austin', N'Texas', N'78721', 1, 30.2721, -97.6868)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (459, N'6 Schiller Way', 93, N'San Antonio', N'Texas', N'78205', 0, 29.4237, -98.4925)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (460, N'44653 Fieldstone Lane', 28, N'Des Moines', N'Iowa', N'50310', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (461, N'548 Arrowood Park', NULL, N'El Paso', N'Texas', N'88579', 1, 31.6948, -106.3)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (462, N'93779 Northview Park', NULL, N'Young America', N'Minnesota', N'55557', 1, 44.8055, -93.7665)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (463, N'9009 Chive Point', 41, N'Waterbury', N'Connecticut', N'06721', 1, 41.3657, -72.9275)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (464, N'2873 North Crossing', 21, N'Des Moines', N'Iowa', N'50310', 1, 41.6255, -93.6736)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (465, N'917 Hoffman Road', 67, N'Waterbury', N'Connecticut', N'06721', 1, 41.3657, -72.9275)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (466, N'53 Columbus Road', 5, N'Wilmington', N'Delaware', N'19805', 0, 39.7434, -75.5827)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (467, N'804 Hermina Pass', NULL, N'Huntington Beach', N'California', N'92648', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (468, N'82779 Buhler Trail', 59, N'Toledo', N'Ohio', N'43656', 1, 41.6782, -83.4972)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (469, N'063 Weeping Birch Circle', 19, N'Saint Louis', N'Missouri', N'63196', 0, 38.6531, -90.2435)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (470, N'11869 Westridge Park', NULL, N'Panama City', N'Florida', N'32405', 1, 30.1949, -85.6727)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (471, N'20429 Corben Hill', 36, N'Sarasota', N'Florida', N'34238', 1, 27.2427, -82.4751)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (472, N'0 Pierstorff Center', 23, N'Fairfield', N'Connecticut', N'06825', 0, 41.1928, -73.2402)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (473, N'21334 West Center', NULL, N'Woburn', N'Massachusetts', N'01813', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (474, N'76 Daystar Circle', 32, N'Wilmington', N'Delaware', N'19897', 0, 39.5645, -75.597)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (475, N'722 Calypso Terrace', 94, N'Buffalo', N'New York', N'14210', 1, 42.8614, -78.8206)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (476, N'61 Hoffman Crossing', 17, N'New York City', N'New York', N'10131', 1, 40.7808, -73.9772)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (477, N'30261 Old Shore Avenue', 78, N'Jefferson City', N'Missouri', N'65110', 1, 38.5309, -92.2493)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (478, N'01 Fuller Trail', 46, N'Houston', N'Texas', N'77005', 1, 29.7179, -95.4263)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (479, N'26 Butternut Lane', 9, N'Elmira', N'New York', N'14905', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (480, N'2 Aberg Street', 27, N'Birmingham', N'Alabama', N'35225', 0, 33.5446, -86.9292)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (481, N'08415 Sunnyside Street', 38, N'Columbus', N'Ohio', N'43240', 1, 40.1454, -82.9817)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (482, N'88579 Darwin Road', 84, N'Charlotte', N'North Carolina', N'28225', 1, 35.26, -80.8042)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (483, N'45573 Hauk Pass', 29, N'Pittsburgh', N'Pennsylvania', N'15235', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (484, N'1 Grover Court', 57, N'Washington', N'District of Columbia', N'20078', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (485, N'5893 Banding Drive', 41, N'San Diego', N'California', N'92186', 1, 33.0169, -116.846)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (486, N'82397 Emmet Park', 28, N'Beaverton', N'Oregon', N'97075', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (487, N'56 Carioca Park', 59, N'Las Vegas', N'Nevada', N'89125', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (488, N'7 Starling Park', NULL, N'New York City', N'New York', N'10090', 1, 40.7808, -73.9772)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (489, N'45 Columbus Hill', 27, N'Hartford', N'Connecticut', N'06152', 1, 41.7918, -72.7188)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (490, N'42068 Surrey Court', 33, N'Indianapolis', N'Indiana', N'46207', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (491, N'15 Kropf Way', 53, N'Denver', N'Colorado', N'80223', 1, 39.7002, -105.0028)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (492, N'3 Loftsgordon Park', NULL, N'Washington', N'District of Columbia', N'20535', 0, 38.8941, -77.0251)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (493, N'16231 Wayridge Court', NULL, N'Washington', N'District of Columbia', N'20238', 1, 38.8933, -77.0146)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (494, N'3 Mcbride Trail', 83, N'Boise', N'Idaho', N'83727', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (495, N'4540 Mallory Junction', 23, N'Santa Fe', N'New Mexico', N'87592', 1, 35.5212, -105.9818)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (496, N'9 Dexter Road', 64, N'Montpelier', N'Vermont', N'05609', 1, 44.2595, -72.585)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (497, N'50986 4th Park', NULL, N'Boston', N'Massachusetts', N'02298', 1, 42.3823, -71.0323)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (498, N'348 Grasskamp Avenue', 47, N'Akron', N'Ohio', N'44393', 1, 41.1287, -81.54)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (499, N'738 Little Fleur Drive', 69, N'Midland', N'Michigan', N'48670', 0, 43.6375, -84.2568)
GO
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (500, N'5 Sycamore Drive', 36, N'Cleveland', N'Ohio', N'44125', 1, 41.4335, -81.6323)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (501, N'77 Hagan Pass', NULL, N'Dayton', N'Ohio', N'45408', 0, 39.7395, -84.229)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (502, N'363 Melby Way', 77, N'Louisville', N'Kentucky', N'40266', 1, 38.189, -85.6768)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (503, N'66 Drewry Street', 27, N'Memphis', N'Tennessee', N'38181', 1, 35.2017, -89.9715)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (504, N'2658 Waxwing Parkway', NULL, N'Saint Paul', N'Minnesota', N'55127', 0, 45.0803, -93.0875)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (505, N'60228 Tennessee Plaza', 51, N'Panama City', N'Florida', N'32405', 1, 30.1949, -85.6727)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (506, N'6936 Comanche Way', 39, N'Fort Worth', N'Texas', N'76129', 0, 32.7714, -97.2915)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (507, N'3 Carpenter Junction', 64, N'Scranton', N'Pennsylvania', N'18514', 0, 41.4019, -75.6376)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (508, N'06962 Derek Plaza', NULL, N'Detroit', N'Michigan', N'48258', 1, 42.2399, -83.1508)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (509, N'676 Kenwood Street', 51, N'Fresno', N'California', N'93762', 0, 36.7464, -119.6397)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (510, N'0594 American Ash Way', 26, N'Woburn', N'Massachusetts', N'01813', 0, 42.4464, -71.4594)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (511, N'1 Saint Paul Place', 5, N'Corpus Christi', N'Texas', N'78426', 0, 27.777, -97.4632)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (512, N'66914 Talmadge Road', 7, N'New Orleans', N'Louisiana', N'70142', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (513, N'704 American Terrace', 5, N'Des Moines', N'Iowa', N'50315', 0, 41.5444, -93.6192)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (514, N'14 Walton Alley', 35, N'Grand Rapids', N'Michigan', N'49510', 0, 43.0314, -85.5503)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (515, N'2281 Prentice Center', 42, N'Saint Paul', N'Minnesota', N'55127', 0, 45.0803, -93.0875)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (516, N'018 Larry Road', 79, N'Dayton', N'Ohio', N'45470', 1, 39.7505, -84.2686)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (517, N'100 Main Lane', 57, N'San Antonio', N'Texas', N'78240', 1, 29.5189, -98.6006)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (518, N'34 Del Sol Hill', 54, N'San Antonio', N'Texas', N'78240', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (519, N'9 Eastlawn Crossing', 88, N'Valdosta', N'Georgia', N'31605', 0, 30.946, -83.2474)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (520, N'4195 Bonner Plaza', 5, N'Nashville', N'Tennessee', N'37205', 0, 36.1114, -86.869)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (521, N'132 Porter Parkway', NULL, N'Fort Wayne', N'Indiana', N'46814', 1, 41.0456, -85.3058)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (522, N'3457 Rusk Plaza', 28, N'Trenton', N'New Jersey', N'08619', 0, 40.2418, -74.6962)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (523, N'193 Commercial Parkway', 82, N'San Jose', N'California', N'95160', 0, 37.2187, -121.8601)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (524, N'6632 Bartillon Terrace', 22, N'Montgomery', N'Alabama', N'36177', 1, 32.2334, -86.2085)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (525, N'94259 Browning Junction', 63, N'Sarasota', N'Florida', N'34276', 0, 27.1675, -82.381)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (526, N'3148 International Road', 81, N'Phoenix', N'Arizona', N'85099', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (527, N'35413 Golf Trail', NULL, N'Albuquerque', N'New Mexico', N'87121', 1, 35.0512, -106.7269)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (528, N'23 Fremont Avenue', 21, N'Atlanta', N'Georgia', N'30323', 0, 33.8444, -84.474)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (529, N'211 Novick Lane', 90, N'Fort Worth', N'Texas', N'76198', 1, 32.7714, -97.2915)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (530, N'3 Ridge Oak Terrace', 38, N'El Paso', N'Texas', N'88530', 0, 31.6948, -106.3)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (531, N'313 Village Green Avenue', 35, N'Rochester', N'New York', N'14646', 1, 43.286, -77.6843)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (532, N'57590 Porter Plaza', 44, N'Gaithersburg', N'Maryland', N'20883', 1, 39.0883, -77.1568)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (533, N'85827 Manitowish Place', 62, N'Seattle', N'Washington', N'98140', 1, 47.4323, -121.8034)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (534, N'8763 Pierstorff Court', 66, N'Toledo', N'Ohio', N'43615', 0, 41.6492, -83.6706)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (535, N'4704 Veith Avenue', NULL, N'Reading', N'Pennsylvania', N'19605', 0, 40.3886, -75.9328)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (536, N'05361 Anzinger Alley', 69, N'Fresno', N'California', N'93726', 0, 36.7949, -119.7604)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (537, N'9502 Aberg Junction', NULL, N'Richmond', N'Virginia', N'23237', 0, 37.4011, -77.4615)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (538, N'941 Green Ridge Road', NULL, N'Albuquerque', N'New Mexico', N'87180', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (539, N'48 Meadow Valley Way', 31, N'Amarillo', N'Texas', N'79118', 1, 35.0763, -101.8349)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (540, N'9 Haas Lane', 20, N'Orange', N'California', N'92862', 1, 33.7915, -117.714)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (541, N'48 Carioca Circle', NULL, N'Kansas City', N'Missouri', N'64109', 0, 39.0663, -94.5674)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (542, N'001 Northland Avenue', 23, N'Long Beach', N'California', N'90840', 1, 33.7843, -118.1157)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (543, N'51995 Butterfield Park', NULL, N'New York City', N'New York', N'10275', 1, 40.7808, -73.9772)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (544, N'57091 Sutherland Junction', 41, N'Atlanta', N'Georgia', N'30356', 1, 33.8913, -84.0746)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (545, N'39 Butterfield Park', 33, N'Riverside', N'California', N'92519', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (546, N'572 Shelley Terrace', 72, N'Mobile', N'Alabama', N'36605', 0, 30.6341, -88.0846)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (547, N'37 Clyde Gallagher Plaza', 9, N'Irvine', N'California', N'92619', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (548, N'8156 Reinke Street', NULL, N'Pasadena', N'California', N'91103', 1, 34.1669, -118.1551)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (549, N'5968 Dovetail Junction', 38, N'Flint', N'Michigan', N'48555', 0, 43.0113, -83.7108)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (550, N'20 Prairieview Plaza', NULL, N'Montgomery', N'Alabama', N'36114', 0, 32.404, -86.2539)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (551, N'122 Jenifer Alley', 3, N'Richmond', N'California', N'94807', 1, 37.7772, -121.9554)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (552, N'008 Golf Way', NULL, N'Colorado Springs', N'Colorado', N'80930', 0, 38.8289, -104.5269)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (553, N'3 Toban Point', 53, N'North Port', N'Florida', N'34290', 0, 27.0459, -82.2491)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (554, N'1 Golf Avenue', 62, N'New York City', N'New York', N'10090', 1, 40.7808, -73.9772)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (555, N'4 Randy Center', NULL, N'Huntington', N'West Virginia', N'25775', 0, 38.4134, -82.2774)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (556, N'934 Sunfield Avenue', 14, N'Honolulu', N'Hawaii', N'96805', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (557, N'87165 Cambridge Parkway', 79, N'Tacoma', N'Washington', N'98405', 1, 47.2484, -122.4644)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (558, N'74 Sherman Crossing', 31, N'Oakland', N'California', N'94622', 1, 37.799, -122.2337)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (559, N'81 Goodland Road', 85, N'Warren', N'Ohio', N'44485', 1, 41.2405, -80.8441)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (560, N'654 Roth Trail', 45, N'San Antonio', N'Texas', N'78260', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (561, N'922 Crest Line Plaza', 74, N'Phoenix', N'Arizona', N'85067', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (562, N'7872 Forster Road', 11, N'Flushing', N'New York', N'11355', 0, 40.7536, -73.8226)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (563, N'2891 Victoria Park', 55, N'Sacramento', N'California', N'95818', 1, 38.5568, -121.4929)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (564, N'42 Crownhardt Point', 8, N'Philadelphia', N'Pennsylvania', N'19160', 0, 40.0018, -75.1179)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (565, N'66067 Kensington Lane', 46, N'Saint Louis', N'Missouri', N'63126', 0, 38.5495, -90.3811)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (566, N'618 Valley Edge Crossing', NULL, N'Oklahoma City', N'Oklahoma', N'73104', 0, 35.4794, -97.5017)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (567, N'9 Prairie Rose Center', 49, N'Houston', N'Texas', N'77030', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (568, N'39347 Gale Junction', 96, N'Rochester', N'New York', N'14619', 0, 43.1367, -77.6481)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (569, N'31448 Straubel Point', NULL, N'Morgantown', N'West Virginia', N'26505', 1, 39.6505, -79.944)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (570, N'9 Scoville Parkway', NULL, N'Chicago', N'Illinois', N'60641', 1, 41.9453, -87.7474)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (571, N'9600 Graedel Way', 10, N'Honolulu', N'Hawaii', N'96815', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (572, N'84 Basil Plaza', NULL, N'Miami', N'Florida', N'33147', 1, 25.8507, -80.2366)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (573, N'4170 Fulton Point', 36, N'Des Moines', N'Iowa', N'50393', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (574, N'1106 Jenifer Circle', 95, N'El Paso', N'Texas', N'79916', 0, 31.7444, -106.2879)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (575, N'50 Logan Parkway', NULL, N'Warren', N'Michigan', N'48092', 1, 42.5125, -83.0643)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (576, N'5809 Brown Alley', 38, N'San Antonio', N'Texas', N'78255', 1, 29.6701, -98.6873)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (577, N'504 Upham Road', NULL, N'Los Angeles', N'California', N'90050', 0, 33.7866, -118.2987)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (578, N'24 Delaware Road', NULL, N'Boston', N'Massachusetts', N'02109', 0, 42.36, -71.0545)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (579, N'7 Fisk Place', 50, N'Salt Lake City', N'Utah', N'84199', 1, 40.7259, -111.9394)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (580, N'65553 Laurel Way', 66, N'Sacramento', N'California', N'94230', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (581, N'1 Redwing Place', 85, N'Louisville', N'Kentucky', N'40250', 0, 38.189, -85.6768)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (582, N'3 Anhalt Junction', 24, N'Lancaster', N'California', N'93584', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (583, N'52 West Trail', NULL, N'Rockville', N'Maryland', N'20851', 1, 39.0763, -77.1234)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (584, N'1 Springview Plaza', 9, N'Ogden', N'Utah', N'84403', 1, 41.1894, -111.9489)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (585, N'6318 Debs Circle', 41, N'Aurora', N'Colorado', N'80044', 0, 39.7388, -104.4083)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (586, N'2425 East Court', 70, N'Orlando', N'Florida', N'32819', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (587, N'803 Cambridge Junction', 89, N'Indianapolis', N'Indiana', N'46254', 0, 39.849, -86.272)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (588, N'53441 Derek Crossing', 46, N'Cincinnati', N'Ohio', N'45296', 1, 39.1668, -84.5382)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (589, N'9776 Saint Paul Court', NULL, N'Houston', N'Texas', N'77281', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (590, N'94275 Utah Place', 80, N'Charlotte', N'North Carolina', N'28220', 1, 35.26, -80.8042)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (591, N'5718 Myrtle Center', NULL, N'Hicksville', N'New York', N'11854', 1, 40.7548, -73.6018)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (592, N'53420 Straubel Center', NULL, N'Saginaw', N'Michigan', N'48604', 1, 43.4732, -83.9514)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (593, N'8 Artisan Drive', 30, N'Houston', N'Texas', N'77020', 0, 29.7758, -95.3121)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (594, N'9 New Castle Pass', 43, N'San Jose', N'California', N'95128', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (595, N'5062 2nd Road', NULL, N'Cincinnati', N'Ohio', N'45249', 0, 39.2692, -84.3307)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (596, N'04045 East Circle', NULL, N'Bozeman', N'Montana', N'59771', 1, 45.7246, -111.1238)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (597, N'804 Delladonna Crossing', 31, N'Lubbock', N'Texas', N'79491', 1, 33.61, -101.8213)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (598, N'3479 Welch Parkway', NULL, N'Henderson', N'Nevada', N'89074', 0, 36.0384, -115.0857)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (599, N'2045 Brentwood Plaza', 74, N'Jamaica', N'New York', N'11407', 0, 40.6913, -73.8059)
GO
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (600, N'17 Mccormick Junction', 59, N'Salt Lake City', N'Utah', N'84170', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (601, N'1456 Summit Drive', 22, N'Charlotte', N'North Carolina', N'28272', 0, 35.26, -80.8042)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (602, N'968 Dunning Place', NULL, N'Atlanta', N'Georgia', N'30392', 0, 33.8444, -84.474)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (603, N'01317 Bartelt Pass', 2, N'Arlington', N'Virginia', N'22234', 0, 38.8808, -77.113)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (604, N'7 Debra Circle', 5, N'Sacramento', N'California', N'95865', 0, 38.596, -121.3978)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (605, N'00 Norway Maple Hill', 54, N'Richmond', N'Virginia', N'23293', 1, 37.5242, -77.4932)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (606, N'66 Dennis Lane', 3, N'Meridian', N'Mississippi', N'39305', 1, 32.4401, -88.6783)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (607, N'3587 Schlimgen Parkway', 55, N'Shawnee Mission', N'Kansas', N'66215', 0, 38.949, -94.7405)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (608, N'15816 Di Loreto Parkway', 48, N'Columbus', N'Mississippi', N'39705', 1, 33.5508, -88.4865)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (609, N'11 Meadow Valley Park', NULL, N'Baton Rouge', N'Louisiana', N'70826', 1, 30.5159, -91.0804)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (610, N'5 Harper Way', 5, N'Saint Paul', N'Minnesota', N'55123', 0, 44.806, -93.1409)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (611, N'0 Barby Junction', 13, N'Suffolk', N'Virginia', N'23436', 0, 36.8926, -76.5142)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (612, N'96831 Clyde Gallagher Point', 16, N'Cincinnati', N'Ohio', N'45218', 1, 39.2663, -84.5221)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (613, N'4 Roxbury Plaza', 14, N'Reston', N'Virginia', N'22096', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (614, N'8 Harbort Alley', 2, N'Nashville', N'Tennessee', N'37235', 0, 36.1866, -86.7852)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (615, N'16660 Goodland Park', NULL, N'Minneapolis', N'Minnesota', N'55412', 0, 45.0242, -93.302)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (616, N'05072 Ilene Point', 54, N'Oklahoma City', N'Oklahoma', N'73109', 0, 35.4259, -97.5261)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (617, N'91638 Bunting Junction', 71, N'Spokane', N'Washington', N'99205', 0, 47.6964, -117.4399)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (618, N'649 South Circle', 32, N'Saint Cloud', N'Minnesota', N'56372', 0, 45.5289, -94.5933)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (619, N'475 Di Loreto Court', 69, N'Sioux City', N'Iowa', N'51105', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (620, N'867 Clemons Plaza', 8, N'Louisville', N'Kentucky', N'40225', 0, 38.189, -85.6768)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (621, N'9 Dunning Hill', 89, N'Abilene', N'Texas', N'79699', 0, 32.4665, -99.7117)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (622, N'8 Basil Court', 19, N'Austin', N'Texas', N'78789', 1, 30.3264, -97.7713)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (623, N'6767 Crowley Park', NULL, N'Topeka', N'Kansas', N'66629', 1, 39.0429, -95.7697)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (624, N'4333 Amoth Trail', 25, N'New Haven', N'Connecticut', N'06510', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (625, N'63 Meadow Ridge Hill', 27, N'Salt Lake City', N'Utah', N'84125', 0, 40.6681, -111.9083)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (626, N'77564 Kipling Alley', 93, N'Lincoln', N'Nebraska', N'68517', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (627, N'86 Mallard Park', 56, N'Las Vegas', N'Nevada', N'89140', 1, 36.086, -115.1471)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (628, N'05709 Moulton Lane', NULL, N'Ogden', N'Utah', N'84409', 0, 41.2553, -111.9567)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (629, N'53857 Arkansas Road', 11, N'Honolulu', N'Hawaii', N'96825', 1, 21.2987, -157.6985)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (630, N'62 Garrison Park', 4, N'El Paso', N'Texas', N'79928', 1, 31.6631, -106.1401)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (631, N'83439 Sutteridge Circle', 90, N'Kansas City', N'Missouri', N'64101', 0, 39.1024, -94.5986)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (632, N'597 New Castle Trail', 74, N'Spring', N'Texas', N'77386', 0, 30.1288, -95.4239)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (633, N'6 Moland Street', 4, N'Columbus', N'Ohio', N'43204', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (634, N'68879 Oak Terrace', 62, N'North Hollywood', N'California', N'91616', 1, 33.7866, -118.2987)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (635, N'74 Laurel Court', 34, N'New Brunswick', N'New Jersey', N'08922', 1, 40.43, -74.4173)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (636, N'113 Daystar Court', 70, N'El Paso', N'Texas', N'79905', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (637, N'7 Carpenter Park', 91, N'Nashville', N'Tennessee', N'37215', 0, 36.0986, -86.8219)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (638, N'8 Thierer Junction', NULL, N'Springfield', N'Virginia', N'22156', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (639, N'96636 Division Plaza', 96, N'Tucson', N'Arizona', N'85710', 1, 32.2138, -110.824)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (640, N'5 Northwestern Place', 19, N'Young America', N'Minnesota', N'55557', 0, 44.8055, -93.7665)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (641, N'778 Daystar Parkway', NULL, N'Amarillo', N'Texas', N'79105', 1, 35.4015, -101.8951)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (642, N'09 Chive Road', 56, N'Saint Paul', N'Minnesota', N'55123', 0, 44.806, -93.1409)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (643, N'0 Fallview Alley', NULL, N'Miami', N'Florida', N'33245', 0, 25.5584, -80.4582)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (644, N'582 Oak Point', 84, N'El Paso', N'Texas', N'79934', 1, 31.9386, -106.4073)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (645, N'35925 Boyd Hill', NULL, N'El Paso', N'Texas', N'88546', 0, 31.6948, -106.3)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (646, N'9 Pennsylvania Place', NULL, N'Mobile', N'Alabama', N'36628', 0, 30.6589, -88.178)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (647, N'9 Beilfuss Street', 5, N'Newton', N'Massachusetts', N'02162', 1, 42.3319, -71.254)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (648, N'21774 Northfield Trail', NULL, N'Chicago', N'Illinois', N'60636', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (649, N'34 Old Shore Alley', NULL, N'Denton', N'Texas', N'76205', 1, 33.1903, -97.1282)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (650, N'60630 Kinsman Court', 90, N'Portland', N'Oregon', N'97296', 1, 45.5806, -122.3748)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (651, N'0617 Almo Circle', NULL, N'Chicago', N'Illinois', N'60681', 1, 41.8119, -87.6873)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (652, N'1 Upham Alley', NULL, N'Peoria', N'Illinois', N'61651', 0, 40.7442, -89.7184)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (653, N'2869 Derek Terrace', 10, N'Brooklyn', N'New York', N'11254', 0, 40.6451, -73.945)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (654, N'194 Daystar Terrace', 17, N'Seattle', N'Washington', N'98140', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (655, N'3851 Southridge Alley', 22, N'Saint Louis', N'Missouri', N'63169', 0, 38.6531, -90.2435)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (656, N'14 Di Loreto Parkway', NULL, N'Fort Worth', N'Texas', N'76105', 0, 32.7233, -97.269)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (657, N'92075 Bluejay Drive', 82, N'Philadelphia', N'Pennsylvania', N'19109', 1, 39.9496, -75.1637)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (658, N'192 Corry Lane', 12, N'Lynn', N'Massachusetts', N'01905', 1, 42.4694, -70.9728)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (659, N'349 Monica Parkway', 15, N'New Orleans', N'Louisiana', N'70116', 1, 29.9686, -90.0646)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (660, N'0510 Prairie Rose Center', 78, N'Austin', N'Texas', N'78764', 0, 30.4455, -97.6595)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (661, N'98793 Nova Drive', 6, N'Hartford', N'Connecticut', N'06105', 1, 41.7691, -72.701)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (662, N'5 Mccormick Court', 53, N'Des Moines', N'Iowa', N'50305', 1, 41.6727, -93.5722)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (663, N'95721 Mifflin Park', NULL, N'Sacramento', N'California', N'94207', 1, 38.3774, -121.4444)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (664, N'5728 Scoville Point', NULL, N'Fort Wayne', N'Indiana', N'46805', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (665, N'59838 Mockingbird Hill', 46, N'Carlsbad', N'California', N'92013', 1, 33.0169, -116.846)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (666, N'1118 Rigney Trail', 32, N'Greenville', N'South Carolina', N'29615', 1, 34.8661, -82.3198)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (667, N'752 Knutson Trail', 52, N'Wichita Falls', N'Texas', N'76305', 0, 33.9995, -98.3938)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (668, N'306 5th Plaza', 85, N'Rochester', N'New York', N'14683', 1, 43.286, -77.6843)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (669, N'66 Butternut Point', NULL, N'Madison', N'Wisconsin', N'53790', 1, 43.0696, -89.4239)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (670, N'06 Tony Court', NULL, N'Des Moines', N'Iowa', N'50320', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (671, N'6 Lakeland Place', 31, N'Jersey City', N'New Jersey', N'07310', 1, 40.7324, -74.0431)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (672, N'4274 Butterfield Place', 16, N'Oceanside', N'California', N'92056', 0, 33.1968, -117.2831)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (673, N'9218 Old Gate Park', 54, N'Daytona Beach', N'Florida', N'32128', 0, 29.0838, -81.0336)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (674, N'0 Westend Pass', 10, N'Philadelphia', N'Pennsylvania', N'19136', 0, 40.0422, -75.0244)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (675, N'3314 Loftsgordon Drive', 44, N'Honolulu', N'Hawaii', N'96810', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (676, N'44 Dovetail Drive', 23, N'Spartanburg', N'South Carolina', N'29305', 0, 35.1114, -82.1055)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (677, N'8271 Bayside Junction', NULL, N'Saint Joseph', N'Missouri', N'64504', 0, 39.7076, -94.8677)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (678, N'8 Alpine Road', 100, N'Laredo', N'Texas', N'78044', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (679, N'087 Everett Drive', NULL, N'Peoria', N'Illinois', N'61640', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (680, N'8 Briar Crest Street', 54, N'Albuquerque', N'New Mexico', N'87110', 1, 35.1104, -106.5781)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (681, N'6783 Novick Hill', 44, N'Tallahassee', N'Florida', N'32314', 0, 30.4793, -84.3462)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (682, N'0 Carpenter Center', 58, N'Washington', N'District of Columbia', N'20442', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (683, N'06069 Rusk Hill', 22, N'Alexandria', N'Virginia', N'22333', 1, 38.8158, -77.09)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (684, N'90230 Pepper Wood Plaza', NULL, N'Reno', N'Nevada', N'89595', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (685, N'640 Larry Alley', 69, N'Des Moines', N'Iowa', N'50347', 1, 41.6727, -93.5722)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (686, N'38302 Anderson Road', 25, N'Alexandria', N'Virginia', N'22313', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (687, N'583 Summit Point', NULL, N'Washington', N'District of Columbia', N'20268', 0, 38.8933, -77.0146)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (688, N'918 Dixon Street', 72, N'San Antonio', N'Texas', N'78210', 0, 29.3977, -98.4658)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (689, N'2540 Eagan Pass', 59, N'Portland', N'Oregon', N'97216', 1, 45.5137, -122.5569)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (690, N'43 Rutledge Hill', 34, N'Saint Louis', N'Missouri', N'63136', 0, 38.7196, -90.27)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (691, N'301 Longview Circle', 36, N'Staten Island', N'New York', N'10305', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (692, N'4597 Toban Street', NULL, N'New York City', N'New York', N'10009', 1, 40.7262, -73.9796)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (693, N'89 Carey Junction', 2, N'Denver', N'Colorado', N'80204', 0, 39.734, -105.0259)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (694, N'0825 Trailsway Street', NULL, N'Bridgeport', N'Connecticut', N'06606', 1, 41.2091, -73.2086)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (695, N'28654 Pawling Crossing', 88, N'Birmingham', N'Alabama', N'35263', 0, 33.5225, -86.8094)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (696, N'97 West Avenue', NULL, N'Tacoma', N'Washington', N'98424', 0, 47.2325, -122.3594)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (697, N'8566 Kedzie Junction', 54, N'Washington', N'District of Columbia', N'20580', 0, 38.8933, -77.0146)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (698, N'036 Golf View Way', 43, N'Baltimore', N'Maryland', N'21229', 0, 39.2856, -76.6899)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (699, N'441 Bluestem Drive', NULL, N'Maple Plain', N'Minnesota', N'55572', 0, 45.0159, -93.4719)
GO
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (700, N'90189 Mariners Cove Alley', NULL, N'Modesto', N'California', N'95397', 1, 37.6566, -121.0191)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (701, N'11 Amoth Trail', 36, N'New York City', N'New York', N'10079', 1, 40.7808, -73.9772)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (702, N'545 Gulseth Place', 26, N'Montgomery', N'Alabama', N'36195', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (703, N'7 Fieldstone Crossing', 34, N'Waterbury', N'Connecticut', N'06721', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (704, N'88 Washington Trail', NULL, N'Boise', N'Idaho', N'83722', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (705, N'39917 Dayton Park', 80, N'Staten Island', N'New York', N'10305', 0, 40.5973, -74.0768)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (706, N'27747 South Terrace', 52, N'Salt Lake City', N'Utah', N'84140', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (707, N'809 Forster Point', 87, N'Green Bay', N'Wisconsin', N'54305', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (708, N'64 Dakota Court', NULL, N'Independence', N'Missouri', N'64054', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (709, N'1519 Susan Center', 35, N'Saint Louis', N'Missouri', N'63169', 0, 38.6531, -90.2435)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (710, N'8 Loeprich Alley', 54, N'Dallas', N'Texas', N'75310', 1, 32.7673, -96.7776)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (711, N'8704 Browning Street', NULL, N'Scottsdale', N'Arizona', N'85260', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (712, N'86499 Armistice Lane', 32, N'New York City', N'New York', N'10175', 0, 40.7543, -73.9798)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (713, N'8749 Fordem Way', 47, N'Winston Salem', N'North Carolina', N'27150', 0, 36.0275, -80.2073)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (714, N'1 Arkansas Park', 58, N'San Antonio', N'Texas', N'78230', 0, 29.5407, -98.5521)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (715, N'88 Fieldstone Court', 41, N'Toledo', N'Ohio', N'43610', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (716, N'7 Oak Parkway', NULL, N'Tampa', N'Florida', N'33625', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (717, N'85978 Mallard Crossing', 29, N'Schaumburg', N'Illinois', N'60193', 1, 42.0144, -88.0935)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (718, N'8 Acker Alley', 6, N'White Plains', N'New York', N'10633', 1, 41.119, -73.733)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (719, N'74710 Stoughton Circle', NULL, N'New Orleans', N'Louisiana', N'70154', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (720, N'2304 Eastwood Crossing', 57, N'Monroe', N'Louisiana', N'71213', 1, 32.4908, -92.1594)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (721, N'9682 Melody Pass', NULL, N'Columbus', N'Georgia', N'31914', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (722, N'787 Fairview Alley', NULL, N'Richmond', N'California', N'94807', 1, 37.7772, -121.9554)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (723, N'1578 Luster Terrace', 55, N'Fort Collins', N'Colorado', N'80525', 1, 40.5384, -105.0547)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (724, N'14 Annamark Trail', 80, N'Fairfax', N'Virginia', N'22036', 0, 38.7351, -77.0796)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (725, N'2027 6th Trail', 39, N'San Diego', N'California', N'92121', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (726, N'933 Kropf Trail', NULL, N'Chicago', N'Illinois', N'60686', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (727, N'3 Chinook Pass', 4, N'Durham', N'North Carolina', N'27710', 1, 36.0512, -78.8577)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (728, N'1 Veith Terrace', 81, N'North Las Vegas', N'Nevada', N'89036', 1, 35.9279, -114.9721)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (729, N'30317 Drewry Trail', 71, N'Honolulu', N'Hawaii', N'96820', 0, 21.351, -157.8795)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (730, N'85951 Pine View Center', 51, N'Alexandria', N'Louisiana', N'71307', 1, 31.2034, -92.5269)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (731, N'1 Artisan Point', 24, N'Irvine', N'California', N'92717', 0, 33.6462, -117.8398)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (732, N'1065 Heffernan Alley', 51, N'El Paso', N'Texas', N'79923', 1, 31.6948, -106.3)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (733, N'3848 Shelley Trail', 32, N'Columbus', N'Ohio', N'43240', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (734, N'15 Weeping Birch Alley', 56, N'Fresno', N'California', N'93773', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (735, N'005 Namekagon Place', 53, N'Seattle', N'Washington', N'98166', 1, 47.4511, -122.353)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (736, N'91129 Rigney Way', NULL, N'New Orleans', N'Louisiana', N'70183', 0, 29.6779, -90.0901)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (737, N'4775 Barby Alley', 33, N'Winston Salem', N'North Carolina', N'27150', 0, 36.0275, -80.2073)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (738, N'93 Pennsylvania Avenue', 86, N'Fort Pierce', N'Florida', N'34981', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (739, N'16 John Wall Terrace', 62, N'Fredericksburg', N'Virginia', N'22405', 0, 38.3365, -77.4366)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (740, N'8523 Melby Place', 11, N'Cincinnati', N'Ohio', N'45213', 1, 39.1802, -84.4204)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (741, N'75138 Dwight Parkway', 30, N'Sioux Falls', N'South Dakota', N'57110', 0, 43.5486, -96.6332)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (742, N'949 Morning Court', 26, N'Washington', N'District of Columbia', N'56944', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (743, N'61 Sunfield Street', 16, N'San Francisco', N'California', N'94177', 0, 37.7848, -122.7278)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (744, N'1 Red Cloud Street', 51, N'Jamaica', N'New York', N'11480', 1, 40.6914, -73.8061)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (745, N'1 Hovde Crossing', 7, N'Portland', N'Oregon', N'97211', 1, 45.5653, -122.6448)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (746, N'9 Crownhardt Court', 6, N'Washington', N'District of Columbia', N'20319', 0, 38.8667, -77.0166)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (747, N'94 Onsgard Alley', NULL, N'Rochester', N'New York', N'14619', 1, 43.1367, -77.6481)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (748, N'965 Fairview Circle', 42, N'Cincinnati', N'Ohio', N'45296', 0, 39.1668, -84.5382)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (749, N'202 Artisan Crossing', 94, N'Peoria', N'Illinois', N'61605', 0, 40.6775, -89.6263)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (750, N'4 Acker Junction', NULL, N'Baton Rouge', N'Louisiana', N'70894', 1, 30.5159, -91.0804)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (751, N'64 North Alley', 26, N'Boulder', N'Colorado', N'80328', 1, 40.0878, -105.3735)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (752, N'869 Anderson Point', 41, N'Huntington', N'West Virginia', N'25721', 0, 38.4134, -82.2774)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (753, N'41 Fremont Parkway', 78, N'Dallas', N'Texas', N'75277', 1, 32.7673, -96.7776)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (754, N'1 Bluestem Drive', 59, N'Portland', N'Oregon', N'97221', 1, 45.4918, -122.7267)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (755, N'5 Straubel Plaza', NULL, N'Charleston', N'West Virginia', N'25336', 0, 38.2968, -81.5547)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (756, N'36 Superior Circle', 15, N'Omaha', N'Nebraska', N'68164', 1, 41.2955, -96.1008)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (757, N'07 Northview Crossing', 19, N'Austin', N'Texas', N'78721', 0, 30.2721, -97.6868)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (758, N'7 Cambridge Center', 53, N'Lincoln', N'Nebraska', N'68505', 1, 40.8247, -96.6252)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (759, N'6872 Debra Avenue', 54, N'Tacoma', N'Washington', N'98464', 1, 47.0662, -122.1132)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (760, N'156 Duke Crossing', 83, N'Jefferson City', N'Missouri', N'65105', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (761, N'591 Maywood Way', NULL, N'Phoenix', N'Arizona', N'85030', 0, 33.2765, -112.1872)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (762, N'345 Talisman Street', 97, N'Riverside', N'California', N'92513', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (763, N'09 International Parkway', 45, N'Bakersfield', N'California', N'93386', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (764, N'23987 Ridgeview Place', 16, N'Pocatello', N'Idaho', N'83206', 0, 42.6395, -112.3138)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (765, N'3564 Pleasure Park', 44, N'Marietta', N'Georgia', N'30061', 0, 33.9328, -84.556)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (766, N'0608 Pierstorff Plaza', NULL, N'Naperville', N'Illinois', N'60567', 0, 41.8397, -88.0887)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (767, N'0 Moland Point', NULL, N'Des Moines', N'Iowa', N'50936', 0, 41.6727, -93.5722)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (768, N'0069 Mifflin Avenue', 95, N'Allentown', N'Pennsylvania', N'18105', 0, 40.6934, -75.4712)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (769, N'0856 Lakewood Gardens Crossing', 45, N'Aurora', N'Colorado', N'80015', 0, 39.6255, -104.7874)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (770, N'1 Menomonie Point', 42, N'Kent', N'Washington', N'98042', 0, 47.368, -122.1206)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (771, N'7490 Kensington Hill', 17, N'Los Angeles', N'California', N'90094', 1, 33.9754, -118.417)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (772, N'7 Fuller Road', 90, N'Panama City', N'Florida', N'32405', 1, 30.1949, -85.6727)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (773, N'86716 Northfield Hill', 56, N'Fort Worth', N'Texas', N'76178', 1, 32.7714, -97.2915)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (774, N'10 Glendale Place', NULL, N'Springfield', N'Illinois', N'62776', 0, 39.7495, -89.606)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (775, N'34755 Calypso Point', 64, N'Greeley', N'Colorado', N'80638', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (776, N'59 Hanover Terrace', 71, N'New York City', N'New York', N'10292', 0, 40.7808, -73.9772)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (777, N'4966 Jenna Point', NULL, N'Cincinnati', N'Ohio', N'45999', 0, 39.1668, -84.5382)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (778, N'305 Bunting Road', 35, N'Milwaukee', N'Wisconsin', N'53285', 0, 43.0174, -87.5697)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (779, N'41186 Buena Vista Center', 38, N'Berkeley', N'California', N'94705', 1, 37.8571, -122.25)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (780, N'736 Bartillon Trail', 48, N'Columbus', N'Georgia', N'31998', 1, 32.491, -84.8741)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (781, N'6121 Dryden Parkway', 100, N'Columbia', N'South Carolina', N'29225', 1, 34.006, -80.9708)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (782, N'38 Esch Parkway', 62, N'Santa Cruz', N'California', N'95064', 0, 36.9959, -122.0578)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (783, N'9 Bunker Hill Drive', 31, N'Springfield', N'Illinois', N'62764', 0, 39.7495, -89.606)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (784, N'1447 Hovde Plaza', 13, N'Sioux Falls', N'South Dakota', N'57105', 1, 43.524, -96.7341)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (785, N'32 Bashford Junction', 55, N'Des Moines', N'Iowa', N'50369', 1, 41.6727, -93.5722)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (786, N'99 Porter Road', 98, N'Kansas City', N'Missouri', N'64179', 0, 39.035, -94.3567)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (787, N'822 Forster Court', NULL, N'Beaufort', N'South Carolina', N'29905', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (788, N'98382 Hagan Point', 72, N'Cleveland', N'Ohio', N'44130', 0, 41.3826, -81.7964)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (789, N'409 Ryan Circle', 49, N'Sarasota', N'Florida', N'34238', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (790, N'645 Fisk Avenue', 21, N'Chicago', N'Illinois', N'60624', 0, 41.8804, -87.7223)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (791, N'2803 Old Shore Avenue', 76, N'Ogden', N'Utah', N'84409', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (792, N'51894 Union Place', 51, N'Saint Louis', N'Missouri', N'63169', 1, 38.6531, -90.2435)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (793, N'80732 Mockingbird Crossing', NULL, N'Shawnee Mission', N'Kansas', N'66205', 0, 39.0312, -94.6308)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (794, N'148 Welch Road', 38, N'Grand Rapids', N'Michigan', N'49518', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (795, N'4 Starling Plaza', 8, N'Bradenton', N'Florida', N'34205', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (796, N'97 Shopko Point', 20, N'Atlanta', N'Georgia', N'30328', 1, 33.9335, -84.3958)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (797, N'90 Ridge Oak Hill', NULL, N'Las Vegas', N'Nevada', N'89155', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (798, N'7510 Maple Wood Plaza', NULL, N'Petaluma', N'California', N'94975', 1, 38.4631, -122.99)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (799, N'5 Arkansas Alley', 33, N'Syracuse', N'New York', N'13210', 1, 43.0354, -76.1282)
GO
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (800, N'636 Pearson Circle', 54, N'Saint Louis', N'Missouri', N'63116', 0, 38.5814, -90.2625)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (801, N'43 Iowa Trail', 8, N'Delray Beach', N'Florida', N'33448', 1, 26.6459, -80.4303)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (802, N'34637 Swallow Plaza', 73, N'Saint Petersburg', N'Florida', N'33705', 0, 27.7391, -82.6435)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (803, N'4113 Blackbird Drive', 57, N'Boulder', N'Colorado', N'80328', 1, 40.0878, -105.3735)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (804, N'653 Rusk Court', 15, N'Canton', N'Ohio', N'44705', 0, 40.8259, -81.3399)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (805, N'2478 Truax Junction', 99, N'Lexington', N'Kentucky', N'40515', 0, 37.9651, -84.4708)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (806, N'4 Arrowood Lane', 11, N'Columbia', N'South Carolina', N'29203', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (807, N'5950 Maple Wood Center', 89, N'Miami', N'Florida', N'33134', 0, 25.768, -80.2714)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (808, N'875 Utah Circle', NULL, N'Olympia', N'Washington', N'98506', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (809, N'678 Comanche Place', 7, N'Atlanta', N'Georgia', N'30323', 1, 33.8444, -84.474)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (810, N'8 Miller Lane', NULL, N'Raleigh', N'North Carolina', N'27690', 1, 35.7977, -78.6253)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (811, N'755 Brickson Park Crossing', NULL, N'Biloxi', N'Mississippi', N'39534', 1, 30.4067, -88.9211)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (812, N'42158 John Wall Terrace', NULL, N'Alexandria', N'Virginia', N'22313', 1, 38.8158, -77.09)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (813, N'0 Messerschmidt Way', NULL, N'Greensboro', N'North Carolina', N'27415', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (814, N'7 Eagle Crest Lane', 69, N'Jackson', N'Mississippi', N'39236', 1, 32.3113, -90.3972)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (815, N'93783 Prairie Rose Avenue', 40, N'Houston', N'Texas', N'77201', 1, 29.834, -95.4342)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (816, N'5244 Jenna Place', 99, N'Gatesville', N'Texas', N'76598', 0, 31.3902, -97.7993)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (817, N'7554 Hooker Court', 82, N'Houston', N'Texas', N'77201', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (818, N'615 Haas Park', NULL, N'Brooklyn', N'New York', N'11231', 0, 40.6794, -74.0014)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (819, N'75237 David Place', NULL, N'Saint Louis', N'Missouri', N'63110', 1, 38.6185, -90.2564)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (820, N'50015 Dawn Alley', 77, N'Fort Lauderdale', N'Florida', N'33315', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (821, N'98 Mockingbird Way', 46, N'Mount Vernon', N'New York', N'10557', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (822, N'09770 Ramsey Crossing', 40, N'Boise', N'Idaho', N'83705', 1, 43.5851, -116.2191)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (823, N'881 1st Terrace', 19, N'Birmingham', N'Alabama', N'35279', 1, 33.5446, -86.9292)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (824, N'7 Mesta Avenue', 55, N'Saint Petersburg', N'Florida', N'33710', 1, 27.7898, -82.7243)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (825, N'687 Texas Plaza', 49, N'Watertown', N'Massachusetts', N'02472', 0, 42.37, -71.1773)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (826, N'2414 Bunker Hill Parkway', 100, N'Amarillo', N'Texas', N'79188', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (827, N'046 Luster Terrace', 55, N'Saint Petersburg', N'Florida', N'33731', 1, 27.8918, -82.7248)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (828, N'5710 Kropf Road', 92, N'Washington', N'District of Columbia', N'20215', 1, 38.8933, -77.0146)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (829, N'3508 Nobel Center', 22, N'Winston Salem', N'North Carolina', N'27105', 0, 36.144, -80.2376)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (830, N'0152 Welch Park', 86, N'Washington', N'District of Columbia', N'20238', 1, 38.8933, -77.0146)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (831, N'6 Everett Street', 57, N'Redwood City', N'California', N'94064', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (832, N'06 Carpenter Crossing', 87, N'Huntsville', N'Alabama', N'35810', 1, 34.7784, -86.6091)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (833, N'94 Northridge Lane', 1, N'San Jose', N'California', N'95118', 1, 37.2568, -121.8896)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (834, N'6 Lawn Street', 35, N'Las Vegas', N'Nevada', N'89140', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (835, N'90043 Gulseth Avenue', 99, N'Columbus', N'Ohio', N'43284', 0, 39.969, -83.0114)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (836, N'38468 Fieldstone Center', 41, N'Waterbury', N'Connecticut', N'06705', 0, 41.5503, -72.9963)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (837, N'474 Crescent Oaks Terrace', NULL, N'Washington', N'District of Columbia', N'20073', 0, 38.897, -77.0251)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (838, N'17 Erie Place', NULL, N'Virginia Beach', N'Virginia', N'23459', 0, 36.9216, -76.0171)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (839, N'6365 Badeau Drive', 90, N'Austin', N'Texas', N'78732', 0, 30.3752, -97.9007)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (840, N'3143 Badeau Road', 44, N'Humble', N'Texas', N'77346', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (841, N'50 Monterey Trail', 33, N'Austin', N'Texas', N'78778', 0, 30.3264, -97.7713)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (842, N'670 Sunfield Hill', 41, N'Atlanta', N'Georgia', N'30323', 1, 33.8444, -84.474)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (843, N'0929 Portage Avenue', 43, N'Detroit', N'Michigan', N'48258', 1, 42.2399, -83.1508)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (844, N'88 Thompson Pass', 96, N'San Francisco', N'California', N'94137', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (845, N'2156 Little Fleur Terrace', 31, N'Madison', N'Wisconsin', N'53710', 1, 43.0696, -89.4239)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (846, N'04222 Express Junction', NULL, N'Delray Beach', N'Florida', N'33448', 0, 26.6459, -80.4303)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (847, N'6033 Sauthoff Lane', 97, N'Stockton', N'California', N'95205', 1, 37.9625, -121.2624)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (848, N'27416 Fieldstone Street', 89, N'Houston', N'Texas', N'77015', 0, 29.7853, -95.1852)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (849, N'77 Acker Point', NULL, N'Houston', N'Texas', N'77206', 1, 29.834, -95.4342)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (850, N'3 Fairfield Place', 6, N'Minneapolis', N'Minnesota', N'55407', 0, 44.9378, -93.2545)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (851, N'48360 Fairview Plaza', NULL, N'Honolulu', N'Hawaii', N'96825', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (852, N'23 Anthes Road', NULL, N'Kansas City', N'Missouri', N'64190', 0, 39.3432, -94.8516)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (853, N'86 Barnett Place', NULL, N'Bakersfield', N'California', N'93305', 1, 35.3855, -118.986)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (854, N'67 Bartillon Plaza', 9, N'Denver', N'Colorado', N'80249', 1, 39.7783, -104.7556)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (855, N'4 Waywood Hill', 96, N'El Paso', N'Texas', N'88530', 1, 31.6948, -106.3)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (856, N'6057 Katie Crossing', 51, N'Memphis', N'Tennessee', N'38114', 0, 35.0981, -89.9825)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (857, N'490 Meadow Ridge Hill', 88, N'Hayward', N'California', N'94544', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (858, N'44 Elmside Parkway', 93, N'Melbourne', N'Florida', N'32919', 0, 28.3067, -80.6862)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (859, N'115 Welch Road', 70, N'Minneapolis', N'Minnesota', N'55428', 1, 45.0632, -93.3811)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (860, N'716 Cody Plaza', 81, N'Chico', N'California', N'95973', 0, 39.8032, -121.8673)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (861, N'1 Cambridge Pass', 23, N'Knoxville', N'Tennessee', N'37995', 1, 35.9901, -83.9622)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (862, N'6420 Montana Terrace', 46, N'Des Moines', N'Iowa', N'50936', 1, 41.6727, -93.5722)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (863, N'1422 Iowa Crossing', 42, N'Fort Myers', N'Florida', N'33906', 0, 26.5529, -81.9486)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (864, N'7062 Saint Paul Court', 31, N'Richmond', N'Virginia', N'23203', 1, 37.5593, -77.4471)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (865, N'2 Cherokee Center', 69, N'Erie', N'Pennsylvania', N'16565', 0, 42.1827, -80.0649)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (866, N'9655 Rusk Plaza', 96, N'Spring', N'Texas', N'77388', 0, 30.0505, -95.4695)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (867, N'394 Truax Terrace', 49, N'Richmond', N'Virginia', N'23260', 1, 37.5242, -77.4932)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (868, N'3 Eastlawn Road', NULL, N'Fort Worth', N'Texas', N'76192', 1, 32.7714, -97.2915)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (869, N'64888 Reindahl Pass', NULL, N'Merrifield', N'Virginia', N'22119', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (870, N'0529 Barby Point', 77, N'Las Vegas', N'Nevada', N'89105', 1, 36.086, -115.1471)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (871, N'26 Anniversary Avenue', NULL, N'Oakland', N'California', N'94611', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (872, N'181 Fuller Parkway', 50, N'North Las Vegas', N'Nevada', N'89036', 0, 35.9279, -114.9721)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (873, N'32820 Towne Center', NULL, N'Houston', N'Texas', N'77260', 0, 29.7687, -95.3867)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (874, N'4 Maywood Park', 53, N'Huntington', N'West Virginia', N'25770', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (875, N'37162 Susan Junction', 71, N'Columbia', N'Missouri', N'65211', 0, 38.9033, -92.1022)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (876, N'01 Westerfield Hill', 29, N'Wilmington', N'Delaware', N'19892', 1, 39.5645, -75.597)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (877, N'9 Merrick Junction', NULL, N'Washington', N'District of Columbia', N'20404', 0, 38.8992, -77.0089)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (878, N'948 Troy Circle', 92, N'New York City', N'New York', N'10170', 1, 40.7526, -73.9755)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (879, N'7 Moose Parkway', 72, N'Washington', N'District of Columbia', N'20046', 1, 38.8933, -77.0146)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (880, N'8141 Fuller Pass', 23, N'Sacramento', N'California', N'95865', 0, 38.596, -121.3978)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (881, N'0 Sundown Pass', 92, N'Washington', N'District of Columbia', N'20425', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (882, N'283 Colorado Way', NULL, N'Lexington', N'Kentucky', N'40581', 0, 38.0283, -84.4715)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (883, N'89444 Hooker Lane', 84, N'Brooklyn', N'New York', N'11225', 1, 40.6628, -73.9546)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (884, N'22 Oakridge Lane', 32, N'Winston Salem', N'North Carolina', N'27150', 1, 36.0275, -80.2073)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (885, N'5691 Del Mar Circle', NULL, N'Baltimore', N'Maryland', N'21216', 1, 39.3093, -76.6699)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (886, N'334 Eagan Road', 45, N'Yakima', N'Washington', N'98907', 1, 46.6288, -120.574)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (887, N'53 Carberry Street', 86, N'Lincoln', N'Nebraska', N'68517', 0, 40.9317, -96.6045)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (888, N'85 Wayridge Point', 44, N'Santa Monica', N'California', N'90410', 1, 33.7866, -118.2987)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (889, N'64929 Maple Park', NULL, N'Houston', N'Texas', N'77260', 0, 29.7687, -95.3867)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (890, N'8 Heath Circle', NULL, N'Chicago', N'Illinois', N'60691', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (891, N'54392 Oneill Center', NULL, N'Los Angeles', N'California', N'90087', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (892, N'0324 Upham Terrace', 74, N'Las Vegas', N'Nevada', N'89145', 1, 36.1693, -115.2828)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (893, N'0 Trailsway Lane', 14, N'Miami', N'Florida', N'33124', 1, 25.5584, -80.4582)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (894, N'0 Carpenter Alley', 100, N'Dallas', N'Texas', N'75372', 1, 32.7673, -96.7776)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (895, N'08376 Forster Place', NULL, N'Dallas', N'Texas', N'75260', 0, 32.7673, -96.7776)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (896, N'8712 Sachtjen Way', NULL, N'Garden Grove', N'California', N'92844', 0, 33.7661, -117.9738)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (897, N'7 American Ash Lane', 73, N'Corpus Christi', N'Texas', N'78475', 0, 27.777, -97.4632)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (898, N'4893 Westport Trail', 72, N'Arlington', N'Virginia', N'22234', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (899, N'581 Pawling Hill', NULL, N'Madison', N'Wisconsin', N'53785', 0, 43.0696, -89.4239)
GO
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (900, N'64 Darwin Trail', 75, N'Tampa', N'Florida', N'33686', 1, 27.872, -82.4388)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (901, N'0678 Heath Drive', 64, N'Springfield', N'Illinois', N'62794', 0, 39.7495, -89.606)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (902, N'75 Rieder Pass', 45, N'New Orleans', N'Louisiana', N'70124', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (903, N'6606 Melrose Junction', NULL, N'Washington', N'District of Columbia', N'20442', 1, 38.896, -77.0177)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (904, N'724 Hudson Pass', 36, N'Saint Cloud', N'Minnesota', N'56372', 0, 45.5289, -94.5933)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (905, N'3 American Way', 28, N'Grand Rapids', N'Michigan', N'49505', 1, 43.012, -85.6309)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (906, N'0 Veith Parkway', 19, N'Colorado Springs', N'Colorado', N'80910', 0, 38.8152, -104.7703)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (907, N'305 Drewry Alley', NULL, N'El Paso', N'Texas', N'79945', 1, 31.6948, -106.3)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (908, N'17854 Packers Park', NULL, N'Lynchburg', N'Virginia', N'24515', 0, 37.4009, -79.1785)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (909, N'328 Oakridge Circle', 37, N'Houston', N'Texas', N'77005', 1, 29.7179, -95.4263)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (910, N'94 Esch Alley', NULL, N'Dallas', N'Texas', N'75358', 0, 32.7942, -96.7652)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (911, N'540 Homewood Way', 57, N'Augusta', N'Georgia', N'30919', 0, 33.386, -82.091)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (912, N'98431 Darwin Way', 59, N'Sioux Falls', N'South Dakota', N'57198', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (913, N'1864 Summerview Point', 64, N'Wilmington', N'Delaware', N'19892', 1, 39.5645, -75.597)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (914, N'5 Trailsway Junction', 41, N'Young America', N'Minnesota', N'55551', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (915, N'9 Mallory Trail', NULL, N'El Paso', N'Texas', N'88525', 1, 31.6948, -106.3)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (916, N'64 South Center', 47, N'Washington', N'District of Columbia', N'20442', 0, 38.896, -77.0177)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (917, N'20 Gina Drive', 2, N'Amarillo', N'Texas', N'79159', 1, 35.216, -102.0714)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (918, N'6648 Ilene Terrace', 94, N'Madison', N'Wisconsin', N'53705', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (919, N'539 Alpine Center', NULL, N'Atlanta', N'Georgia', N'31106', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (920, N'33954 Artisan Place', 36, N'Knoxville', N'Tennessee', N'37995', 0, 35.9901, -83.9622)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (921, N'43 Maywood Road', 97, N'Newport Beach', N'California', N'92662', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (922, N'9 Arkansas Place', NULL, N'Chicago', N'Illinois', N'60657', 0, 41.9399, -87.6528)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (923, N'6891 Dovetail Terrace', 1, N'Kalamazoo', N'Michigan', N'49048', 1, 42.3189, -85.5152)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (924, N'8 Almo Terrace', NULL, N'Tacoma', N'Washington', N'98481', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (925, N'9 Lakewood Gardens Center', 19, N'Springfield', N'Illinois', N'62776', 0, 39.7495, -89.606)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (926, N'3 Waxwing Way', 29, N'Orange', N'California', N'92668', 0, 33.7867, -117.8742)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (927, N'943 Service Parkway', 88, N'Hyattsville', N'Maryland', N'20784', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (928, N'289 Village Green Avenue', 51, N'Midland', N'Michigan', N'48670', 0, 43.6375, -84.2568)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (929, N'319 Crowley Drive', 98, N'Akron', N'Ohio', N'44315', 0, 41.028, -81.4632)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (930, N'21306 Pleasure Center', NULL, N'Dallas', N'Texas', N'75287', 1, 33.0005, -96.8314)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (931, N'7 1st Parkway', NULL, N'Louisville', N'Kentucky', N'40205', 0, 38.2222, -85.6885)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (932, N'028 Lyons Crossing', NULL, N'Washington', N'District of Columbia', N'20310', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (933, N'60 Bunting Junction', 82, N'Boulder', N'Colorado', N'80305', 1, 39.9807, -105.2531)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (934, N'86 Merrick Place', 37, N'Phoenix', N'Arizona', N'85030', 1, 33.2765, -112.1872)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (935, N'51012 Barby Drive', NULL, N'Mesa', N'Arizona', N'85215', 0, 33.4707, -111.7188)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (936, N'6128 Loomis Place', 25, N'Ventura', N'California', N'93005', 0, 34.0324, -119.1343)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (937, N'176 Algoma Circle', NULL, N'Dallas', N'Texas', N'75397', 0, 32.7673, -96.7776)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (938, N'973 Maple Parkway', 99, N'Des Moines', N'Iowa', N'50330', 1, 41.6727, -93.5722)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (939, N'639 Spohn Drive', 36, N'Springfield', N'Massachusetts', N'01114', 1, 42.1707, -72.6048)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (940, N'020 School Way', NULL, N'Topeka', N'Kansas', N'66699', 1, 39.0429, -95.7697)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (941, N'401 Carpenter Center', 1, N'Milwaukee', N'Wisconsin', N'53277', 0, 43.0389, -87.9024)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (942, N'27311 Vera Junction', 75, N'Fresno', N'California', N'93726', 0, 36.7949, -119.7604)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (943, N'77106 North Court', 46, N'Washington', N'District of Columbia', N'20591', 0, 38.8933, -77.0146)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (944, N'57 Dakota Terrace', 84, N'Norfolk', N'Virginia', N'23520', 1, 36.9312, -76.2397)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (945, N'4 Old Gate Alley', 61, N'Sacramento', N'California', N'94230', 0, 38.3774, -121.4444)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (946, N'74 Algoma Pass', 82, N'Nashville', N'Tennessee', N'37240', 1, 36.1866, -86.7852)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (947, N'3 Arapahoe Crossing', 34, N'Greeley', N'Colorado', N'80638', 1, 40.5009, -104.315)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (948, N'32782 Myrtle Court', NULL, N'Portland', N'Oregon', N'97216', 1, 45.5137, -122.5569)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (949, N'911 Banding Circle', 18, N'San Antonio', N'Texas', N'78255', 0, 29.6701, -98.6873)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (950, N'50995 Maywood Parkway', 21, N'Shreveport', N'Louisiana', N'71130', 0, 32.6076, -93.7526)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (951, N'5 Arapahoe Plaza', 78, N'Alexandria', N'Virginia', N'22309', 1, 38.7192, -77.1073)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (952, N'22106 Summerview Park', 71, N'Phoenix', N'Arizona', N'85015', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (953, N'4045 Texas Terrace', 37, N'Clearwater', N'Florida', N'34629', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (954, N'74 Transport Crossing', 32, N'Buffalo', N'New York', N'14225', 1, 42.9255, -78.7481)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (955, N'23963 Mendota Circle', NULL, N'Oxnard', N'California', N'93034', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (956, N'39 Schiller Park', 34, N'San Antonio', N'Texas', N'78255', 1, 29.6701, -98.6873)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (957, N'1020 Warbler Junction', 56, N'Pensacola', N'Florida', N'32526', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (958, N'73106 Prairieview Hill', 95, N'Sarasota', N'Florida', N'34233', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (959, N'648 Ryan Junction', 83, N'Lexington', N'Kentucky', N'40586', 0, 38.0283, -84.4715)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (960, N'4 Nevada Point', 31, N'Portsmouth', N'New Hampshire', N'03804', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (961, N'8 Granby Park', 77, N'Saint Cloud', N'Minnesota', N'56398', 0, 45.5289, -94.5933)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (962, N'68362 Knutson Parkway', 25, N'Dulles', N'Virginia', N'20189', 1, 39.009, -77.4422)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (963, N'464 Loomis Center', 82, N'Kansas City', N'Kansas', N'66105', 0, 39.085, -94.6356)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (964, N'644 Kipling Court', NULL, N'Huntington', N'West Virginia', N'25775', 0, 38.4134, -82.2774)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (965, N'83600 Melvin Point', 10, N'Lexington', N'Kentucky', N'40515', 0, 37.9651, -84.4708)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (966, N'7671 Reindahl Center', 83, N'New Orleans', N'Louisiana', N'70183', 1, 29.6779, -90.0901)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (967, N'0 New Castle Terrace', 62, N'Houston', N'Texas', N'77250', 0, 29.7629, -95.3629)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (968, N'46961 Almo Court', 70, N'Washington', N'District of Columbia', N'20220', 0, 38.8933, -77.0146)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (969, N'7187 Hanson Center', 72, N'Tampa', N'Florida', N'33694', 0, 27.872, -82.4388)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (970, N'251 MyStreet Update18225', 18225, N'City Update18225', N'State Update18225', N'18225', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (971, N'628 Farragut Trail', 66, N'Helena', N'Montana', N'59623', 0, 46.5901, -112.0402)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (972, N'90 Maryland Circle', 47, N'Grand Forks', N'North Dakota', N'58207', 1, 47.9335, -97.3944)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (973, N'8 High Crossing Crossing', 14, N'Rochester', N'New York', N'14609', 0, 43.174, -77.5637)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (974, N'155 Russell Park', 36, N'San Francisco', N'California', N'94132', 1, 37.7211, -122.4754)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (975, N'56273 Fair Oaks Road', NULL, N'Fresno', N'California', N'93740', 0, 36.7464, -119.6397)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (976, N'2 Dapin Center', 71, N'Sacramento', N'California', N'95828', 1, 38.4826, -121.4006)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (977, N'03423 Hansons Park', NULL, N'Honolulu', N'Hawaii', N'96845', 0, 21.3278, -157.8294)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (978, N'548 Atwood Drive', NULL, N'San Luis Obispo', N'California', N'93407', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (979, N'8 Muir Parkway', 63, N'Lubbock', N'Texas', N'79415', 0, 33.6021, -101.876)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (980, N'60351 Manufacturers Pass', 10, N'Young America', N'Minnesota', N'55564', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (981, N'1188 Randy Point', 13, N'Mount Vernon', N'New York', N'10557', 1, 41.119, -73.733)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (982, N'460 Schurz Plaza', 73, N'Los Angeles', N'California', N'90101', 1, 33.7866, -118.2987)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (983, N'91469 Kinsman Lane', 15, N'Ridgely', N'Maryland', N'21684', 0, 38.8893, -75.8612)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (984, N'1 Continental Way', 11, N'Springfield', N'Illinois', N'62705', 0, 39.7495, -89.606)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (985, N'9668 Calypso Way', 54, N'Columbia', N'South Carolina', N'29225', 1, 34.006, -80.9708)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (986, N'3 Grasskamp Circle', 6, N'Lexington', N'Kentucky', N'40576', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (987, N'633 Erie Trail', 42, N'Portsmouth', N'New Hampshire', N'03804', 0, 43.0059, -71.0132)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (988, N'98 Tennyson Lane', 3, N'Miami', N'Florida', N'33190', 0, 25.5593, -80.3483)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (989, N'75 Magdeline Plaza', 63, N'Monticello', N'Minnesota', N'55590', NULL, NULL, NULL)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (990, N'9 Packers Road', 96, N'Ogden', N'Utah', N'84403', 0, 41.1894, -111.9489)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (991, N'750 Melby Hill', 99, N'Chandler', N'Arizona', N'85246', 1, 33.2765, -112.1872)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (992, N'10 Weeping Birch Trail', NULL, N'Buffalo', N'New York', N'14210', 0, 42.8614, -78.8206)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (993, N'6 Magdeline Court', 77, N'Tucson', N'Arizona', N'85710', 1, 32.2138, -110.824)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (994, N'598 Schmedeman Drive', 60, N'Washington', N'District of Columbia', N'20337', 0, 38.8933, -77.0146)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (995, N'0646 John Wall Crossing', 43, N'Tulsa', N'Oklahoma', N'74184', 1, 36.1398, -96.0297)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (996, N'54951 Hanson Parkway', 24, N'Colorado Springs', N'Colorado', N'80920', 0, 38.9497, -104.767)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (997, N'0450 Mayfield Park', 89, N'New York City', N'New York', N'10029', 1, 40.7918, -73.9448)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (998, N'5 Tennessee Way', NULL, N'Lansing', N'Michigan', N'48912', 0, 42.7371, -84.5244)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (999, N'290 Pepper Wood Parkway', NULL, N'North Hollywood', N'California', N'91606', NULL, NULL, NULL)
GO
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1000, N'66 Spaight Hill', 90, N'Jamaica', N'New York', N'11480', 0, 40.6914, -73.8061)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1001, N'123 Random Drive', 100, N'Randomtown', N'VA', N'22191', 1, -133.22555444, 150.000999888)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1002, N'123 Random Drive', 100, N'Randomtown', N'VA', N'22191', 1, -133.22555444, 150.000999888)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1003, N'123 Random Drive', 100, N'Randomtown', N'VA', N'22191', 1, -133.22555444, 150.000999888)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1004, N'123 Random Drive', 100, N'Randomtown', N'VA', N'22191', 1, -133.22555444, 150.000999888)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1005, N'123 Random Drive_updated', 101, N'Randomtown', N'VA', N'221911', 0, -132.22555444, 149.000999888)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1006, N'123 Random Drive_updated', 101, N'Randomtown', N'VA', N'221911', 0, -132.22555444, 149.000999888)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1007, N'123 Random Drive_updated', 101, N'Randomtown', N'VA', N'221911', 0, -132.22555444, 149.000999888)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1008, N'123 Random Drive_updated', 101, N'Randomtown', N'VA', N'221911', 0, -132.22555444, 149.000999888)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1009, N'123 Random Drive_updated', 101, N'Randomtown', N'VA', N'221911', 0, -132.22555444, 149.000999888)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1010, N'123 Random Drive_updated', 101, N'Randomtown', N'VA', N'221911', 0, -132.22555444, 149.000999888)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1015, N'Some Li ne One Info', 0, N'Salinas', N'CA', N'99976', 1, 125.000999888, -145.6545342)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1016, N'Some Li ne One Info', 0, N'Salinas', N'CA', N'99976', 1, 125.000999888, -145.6545342)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1017, N'Some Li ne One Info', 100, N'Salinas', N'CA', N'99976', 1, 125.000999888, -145.6545342)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1018, N'45 Sabio Street', 95, N'Los Angeles', N'CA', N'42356', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1019, N'Some Li ne One Info', 100, N'Salinas', N'CA', N'99976', 1, 125.000999888, -145.6545342)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1020, N'45 Sabio Street', 95, N'Los Angeles', N'CA', N'42356', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1021, N'45 MyStreet', 95, N'Pella', N'IOWA', N'2356', 0, 91, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1022, N'45 MyStreet', 95, N'Pella', N'IOWA', N'2356', 0, 0, 181)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1023, N'45 Sabio Street', 95, N'Los Angeles', N'CA', N'42356', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1024, N'45 Sabio Street', 95, N'Los Angeles', N'CA', N'42356', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1025, N'45 Sabio Street', 95, N'Los Angeles', N'CA', N'42356', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1026, N'45 Sabio Street', 95, N'Los Angeles', N'CA', N'42356', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1028, N'45 Sabio Street', 95, N'Los Angeles', N'CA', N'42356', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1029, N'45 Sabio Street', 95, N'Los Angeles', N'CA', N'42356', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1031, N'45 Sabio Street', 95, N'Los Angeles', N'CA', N'42356', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1032, N'145 West Street', 295, N'SF', N'NV', N'99887', 1, 100, -100)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1033, N'45 Sabio Street', 0, N'Los Angeles', N'CA', N'42356', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1034, N'145 West Street', 295, N'SF', N'NV', N'99887', 1, 90, -180.1)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1035, N'45 Sabio Street', 95, N'Los Angeles', N'CA', N'42356', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1036, N'45 MyStreet', 95, N'Pella', N'IOWA', N'2356', 0, 91, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1037, N'45 MyStreet', 95, N'Pella', N'IOWA', N'2356', 0, 0, 181)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1038, N'45 Sabio Street', 95, N'Los Angeles', N'CA', N'42356', 0, 0, 0)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1039, N'145 West Street', 295, N'SF', N'NV', N'99887', 0, 90, -180.1)
INSERT [dbo].[Sabio_Addresses] ([Id], [LineOne], [SuiteNumber], [City], [State], [PostalCode], [IsActive], [Lat], [Long]) VALUES (1040, N'45 Sabio Street', 95, N'Los Angeles', N'CA', N'42356', 0, 0, 0)
SET IDENTITY_INSERT [dbo].[Sabio_Addresses] OFF
GO
SET IDENTITY_INSERT [dbo].[SeasonTerms] ON 

INSERT [dbo].[SeasonTerms] ([Id], [Term]) VALUES (1, N'Fall 2023')
INSERT [dbo].[SeasonTerms] ([Id], [Term]) VALUES (2, N'Winter 2023')
INSERT [dbo].[SeasonTerms] ([Id], [Term]) VALUES (3, N'Spring 2023')
INSERT [dbo].[SeasonTerms] ([Id], [Term]) VALUES (4, N'Summer 2023')
INSERT [dbo].[SeasonTerms] ([Id], [Term]) VALUES (11, N'SabioTerm 3001638185695652269023')
INSERT [dbo].[SeasonTerms] ([Id], [Term]) VALUES (14, N'SabioTerm 3001638185695667448917')
INSERT [dbo].[SeasonTerms] ([Id], [Term]) VALUES (17, N'SabioTerm 3001638185703791838513')
INSERT [dbo].[SeasonTerms] ([Id], [Term]) VALUES (20, N'SabioTerm 3001638185713525391515')
INSERT [dbo].[SeasonTerms] ([Id], [Term]) VALUES (23, N'SabioTerm 3001638185724979868714')
SET IDENTITY_INSERT [dbo].[SeasonTerms] OFF
GO
SET IDENTITY_INSERT [dbo].[Skills] ON 

INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (1, N'Typing', 8, CAST(N'2023-03-29T23:58:42.6666667' AS DateTime2), CAST(N'2023-04-14T21:09:59.2866667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (2, N'C++', 5665, CAST(N'2023-03-29T23:58:51.8866667' AS DateTime2), CAST(N'2023-03-29T23:58:51.8866667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (3, N'VD6', 5665, CAST(N'2023-03-29T23:58:57.8300000' AS DateTime2), CAST(N'2023-03-29T23:58:57.8300000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (4, N'HTML', 5665, CAST(N'2023-03-29T23:59:05.9033333' AS DateTime2), CAST(N'2023-03-29T23:59:05.9033333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (5, N'CSS', 5665, CAST(N'2023-03-29T23:59:21.0500000' AS DateTime2), CAST(N'2023-03-29T23:59:21.0500000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (6, N'Volleyball', 1008, CAST(N'2023-03-30T18:39:50.1133333' AS DateTime2), CAST(N'2023-04-17T16:24:40.4800000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (7, N'Football', 1008, CAST(N'2023-03-30T20:47:08.2300000' AS DateTime2), CAST(N'2023-04-17T16:24:40.4800000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (8, N'Baseball', 5667, CAST(N'2023-03-30T21:03:36.2900000' AS DateTime2), CAST(N'2023-03-30T21:03:36.2900000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (13, N'Knitting', 5667, CAST(N'2023-03-30T22:17:39.2000000' AS DateTime2), CAST(N'2023-03-30T22:17:39.2000000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (14, N'Crochet', 5667, CAST(N'2023-03-30T22:17:39.2000000' AS DateTime2), CAST(N'2023-03-30T22:17:39.2000000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (15, N'Dog Walking', 5667, CAST(N'2023-03-30T22:22:15.2333333' AS DateTime2), CAST(N'2023-03-30T22:22:15.2333333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (16, N'Running', 5667, CAST(N'2023-03-30T22:22:15.2333333' AS DateTime2), CAST(N'2023-03-30T22:22:15.2333333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (17, N'SabioSkillA_8164', 8164, CAST(N'2023-03-30T22:25:07.0666667' AS DateTime2), CAST(N'2023-03-30T22:25:07.0666667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (18, N'SabioSkillB_8164', 8164, CAST(N'2023-03-30T22:25:07.0666667' AS DateTime2), CAST(N'2023-03-30T22:25:07.0666667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (19, N'SabioSkillA_7356', 7356, CAST(N'2023-03-30T22:47:10.8133333' AS DateTime2), CAST(N'2023-03-30T22:47:10.8133333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (20, N'SabioSkillB_7356', 7356, CAST(N'2023-03-30T22:47:10.8133333' AS DateTime2), CAST(N'2023-03-30T22:47:10.8133333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (21, N'SabioSkillA_3465', 3465, CAST(N'2023-03-30T22:56:14.6133333' AS DateTime2), CAST(N'2023-03-30T22:56:14.6133333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (22, N'SabioSkillB_3465', 3465, CAST(N'2023-03-30T22:56:14.6133333' AS DateTime2), CAST(N'2023-03-30T22:56:14.6133333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (23, N'Boxing', 5667, CAST(N'2023-03-30T23:14:41.5833333' AS DateTime2), CAST(N'2023-03-30T23:14:41.5833333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (24, N'Walking', 5667, CAST(N'2023-03-30T23:14:41.5833333' AS DateTime2), CAST(N'2023-03-30T23:14:41.5833333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (25, N'SabioSkillA_366', 366, CAST(N'2023-03-30T23:16:15.8133333' AS DateTime2), CAST(N'2023-03-30T23:16:15.8133333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (26, N'SabioSkillB_366', 366, CAST(N'2023-03-30T23:16:15.8133333' AS DateTime2), CAST(N'2023-03-30T23:16:15.8133333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (75, N'SabioSkillA_7921', 7921, CAST(N'2023-03-31T03:01:24.6533333' AS DateTime2), CAST(N'2023-03-31T03:01:24.6533333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (76, N'SabioSkillB_7921', 1008, CAST(N'2023-03-31T03:01:24.6533333' AS DateTime2), CAST(N'2023-04-17T16:24:40.4800000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (77, N'SabioSkillA_4424', 4424, CAST(N'2023-03-31T03:04:19.9400000' AS DateTime2), CAST(N'2023-03-31T03:04:19.9400000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (78, N'SabioSkillB_4424', 1008, CAST(N'2023-03-31T03:04:19.9400000' AS DateTime2), CAST(N'2023-04-15T02:31:31.7533333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (80, N'SabioSkillB_7148', 7148, CAST(N'2023-03-31T03:06:41.7433333' AS DateTime2), CAST(N'2023-03-31T03:06:41.7433333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (81, N'SabioSkillA_1283', 1283, CAST(N'2023-03-31T03:09:36.9666667' AS DateTime2), CAST(N'2023-03-31T03:09:36.9666667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (82, N'SabioSkillB_1283', 1283, CAST(N'2023-03-31T03:09:36.9666667' AS DateTime2), CAST(N'2023-03-31T03:09:36.9666667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (83, N'SabioSkillA_4505', 4505, CAST(N'2023-03-31T03:11:09.5933333' AS DateTime2), CAST(N'2023-03-31T03:11:09.5933333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (84, N'SabioSkillB_4505', 4505, CAST(N'2023-03-31T03:11:09.5933333' AS DateTime2), CAST(N'2023-03-31T03:11:09.5933333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (107, N'Hand Signals', 4, CAST(N'2023-03-31T17:20:05.1866667' AS DateTime2), CAST(N'2023-04-01T22:39:48.4966667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (108, N'Dating', 4, CAST(N'2023-03-31T17:20:05.1866667' AS DateTime2), CAST(N'2023-04-01T22:39:48.4966667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (112, N'Crunches', 1008, CAST(N'2023-03-31T17:29:50.2600000' AS DateTime2), CAST(N'2023-04-17T16:24:40.4800000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (113, N'Jumping Jacks', 1008, CAST(N'2023-03-31T17:29:50.2600000' AS DateTime2), CAST(N'2023-04-17T16:24:40.4800000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (117, N'Munchies', 1008, CAST(N'2023-04-01T19:40:16.5200000' AS DateTime2), CAST(N'2023-04-17T16:24:40.4800000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (118, N'Fist Pumping', 4, CAST(N'2023-04-01T19:45:35.8033333' AS DateTime2), CAST(N'2023-04-01T19:45:35.8033333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (119, N'Curling', 4, CAST(N'2023-04-01T19:45:35.8033333' AS DateTime2), CAST(N'2023-04-01T19:45:35.8033333' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (311, N'one', 4, CAST(N'2023-04-03T13:11:37.6166667' AS DateTime2), CAST(N'2023-04-03T13:11:37.6166667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (312, N'two', 4, CAST(N'2023-04-03T13:11:37.6166667' AS DateTime2), CAST(N'2023-04-03T13:11:37.6166667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (313, N'three', 4, CAST(N'2023-04-03T13:11:37.6166667' AS DateTime2), CAST(N'2023-04-03T13:11:37.6166667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (314, N'four', 4, CAST(N'2023-04-03T13:11:37.6166667' AS DateTime2), CAST(N'2023-04-03T13:11:37.6166667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (355, N'six', 4, CAST(N'2023-04-03T22:59:27.5100000' AS DateTime2), CAST(N'2023-04-03T22:59:27.5100000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (356, N'sevel', 4, CAST(N'2023-04-03T22:59:27.5100000' AS DateTime2), CAST(N'2023-04-03T22:59:27.5100000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (389, N'ten', 1008, CAST(N'2023-04-05T22:13:06.9000000' AS DateTime2), CAST(N'2023-04-15T02:04:45.3900000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (390, N'nine', 4, CAST(N'2023-04-05T22:13:06.9000000' AS DateTime2), CAST(N'2023-04-05T22:13:06.9000000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (391, N'C#', 4, CAST(N'2023-04-05T22:18:44.3600000' AS DateTime2), CAST(N'2023-04-05T22:18:44.3600000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (392, N'.Net', 4, CAST(N'2023-04-05T22:18:44.3600000' AS DateTime2), CAST(N'2023-04-05T22:18:44.3600000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (393, N'ASP', 4, CAST(N'2023-04-05T22:18:44.3600000' AS DateTime2), CAST(N'2023-04-05T22:18:44.3600000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (394, N'JSP', 4, CAST(N'2023-04-05T22:18:44.3600000' AS DateTime2), CAST(N'2023-04-05T22:18:44.3600000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (395, N'Linux', 4, CAST(N'2023-04-05T22:26:23.7600000' AS DateTime2), CAST(N'2023-04-05T22:26:23.7600000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (396, N'VB3', 4, CAST(N'2023-04-05T22:26:23.7600000' AS DateTime2), CAST(N'2023-04-05T22:26:23.7600000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (397, N'Cold Fusion', 4, CAST(N'2023-04-05T22:26:23.7600000' AS DateTime2), CAST(N'2023-04-05T22:26:23.7600000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (398, N'Managing', 4, CAST(N'2023-04-11T03:06:46.6900000' AS DateTime2), CAST(N'2023-04-11T03:06:46.6900000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (399, N'hockey', 1008, CAST(N'2023-04-14T20:25:45.9800000' AS DateTime2), CAST(N'2023-04-15T02:04:57.6600000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (400, N'guitar', 1008, CAST(N'2023-04-14T20:25:45.9800000' AS DateTime2), CAST(N'2023-04-15T02:04:57.6600000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (401, N'Coding', 1008, CAST(N'2023-04-14T20:27:27.9966667' AS DateTime2), CAST(N'2023-04-15T16:26:31.5866667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (402, N'Slithering', 1008, CAST(N'2023-04-15T01:53:52.9733333' AS DateTime2), CAST(N'2023-04-17T16:24:40.4800000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (403, N'twist', 1008, CAST(N'2023-04-15T02:03:54.6566667' AS DateTime2), CAST(N'2023-04-15T02:04:45.3900000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (404, N'tiny', 1008, CAST(N'2023-04-15T02:03:54.6566667' AS DateTime2), CAST(N'2023-04-15T02:04:45.3900000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (405, N'tots', 1008, CAST(N'2023-04-15T02:03:54.6566667' AS DateTime2), CAST(N'2023-04-15T02:04:45.3900000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (406, N'Drinking', 1008, CAST(N'2023-04-15T02:06:41.7600000' AS DateTime2), CAST(N'2023-04-17T16:24:40.4800000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (407, N'Big Toe', 1008, CAST(N'2023-04-15T02:06:53.9133333' AS DateTime2), CAST(N'2023-04-17T16:24:40.4800000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (408, N'Dodge Ball', 1008, CAST(N'2023-04-15T16:26:31.5866667' AS DateTime2), CAST(N'2023-04-15T16:26:31.5866667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (409, N'goober', 1008, CAST(N'2023-04-17T16:24:20.0500000' AS DateTime2), CAST(N'2023-04-17T16:24:20.0500000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (410, N'gunker', 1008, CAST(N'2023-04-17T16:24:20.0500000' AS DateTime2), CAST(N'2023-04-17T16:24:20.0500000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (411, N'gopher', 1008, CAST(N'2023-04-17T16:24:20.0500000' AS DateTime2), CAST(N'2023-04-17T16:24:20.0500000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (412, N'Mopping', 8, CAST(N'2023-04-19T20:48:57.4566667' AS DateTime2), CAST(N'2023-04-19T20:48:57.4566667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (413, N'Cleaning', 8, CAST(N'2023-04-19T20:48:57.4566667' AS DateTime2), CAST(N'2023-04-19T20:48:57.4566667' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (414, N'Tennis', 8, CAST(N'2023-04-19T21:07:02.4700000' AS DateTime2), CAST(N'2023-04-19T21:07:02.4700000' AS DateTime2))
INSERT [dbo].[Skills] ([Id], [Name], [UserId], [DateCreated], [DateModified]) VALUES (415, N'Fencing', 1008, CAST(N'2023-04-19T21:16:56.7966667' AS DateTime2), CAST(N'2023-04-19T21:16:56.7966667' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Skills] OFF
GO
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (1, 1)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (1, 2)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (2, 3)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (2, 4)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (3, 5)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (3, 6)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (4, 1)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (4, 2)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (5, 3)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (5, 4)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (6, 5)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (6, 6)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (7, 1)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (7, 2)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (8, 3)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (8, 4)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (9, 5)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (9, 6)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (10, 1)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (10, 2)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (11, 3)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (11, 4)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (12, 5)
INSERT [dbo].[StudentCourses] ([StudentId], [CourseId]) VALUES (12, 6)
GO
SET IDENTITY_INSERT [dbo].[Students] ON 

INSERT [dbo].[Students] ([Id], [Name], [DOB]) VALUES (1, N'James', CAST(N'1999-04-22T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[Students] ([Id], [Name], [DOB]) VALUES (2, N'Jerry', CAST(N'2000-04-23T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[Students] ([Id], [Name], [DOB]) VALUES (3, N'Janice', CAST(N'2001-04-24T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[Students] ([Id], [Name], [DOB]) VALUES (4, N'Terry', CAST(N'2000-05-01T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[Students] ([Id], [Name], [DOB]) VALUES (5, N'Terrence', CAST(N'2000-05-02T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[Students] ([Id], [Name], [DOB]) VALUES (6, N'Trisha', CAST(N'1998-06-01T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[Students] ([Id], [Name], [DOB]) VALUES (7, N'Tammy', CAST(N'1999-06-05T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[Students] ([Id], [Name], [DOB]) VALUES (8, N'Barbara', CAST(N'2000-06-25T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[Students] ([Id], [Name], [DOB]) VALUES (9, N'Bill', CAST(N'2001-07-03T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[Students] ([Id], [Name], [DOB]) VALUES (10, N'Baxter', CAST(N'2000-08-01T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[Students] ([Id], [Name], [DOB]) VALUES (11, N'Zed', CAST(N'2000-01-07T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[Students] ([Id], [Name], [DOB]) VALUES (12, N'Kelly', CAST(N'2002-02-02T00:00:00.0000000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Students] OFF
GO
SET IDENTITY_INSERT [dbo].[Tags] ON 

INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (1, 0, N'Ford Tag 1', NULL, NULL, NULL)
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (2, 0, N'Ford Tag 2', NULL, NULL, NULL)
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (3, 0, N'Apple Tage 1', NULL, NULL, NULL)
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (4, 0, N'Apple Tag 2', NULL, NULL, NULL)
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (13, 0, N'tag1', 4, CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (14, 0, N'tag2', 4, CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (15, 0, N'tag3', 4, CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (16, 0, N'tag4', 4, CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (53, 0, N'tag1', 4, CAST(N'2023-04-05T15:16:09.2866667' AS DateTime2), CAST(N'2023-04-05T15:16:09.2866667' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (54, 0, N'tag2', 4, CAST(N'2023-04-05T15:16:09.2866667' AS DateTime2), CAST(N'2023-04-05T15:16:09.2866667' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (55, 0, N'tag5', 4, CAST(N'2023-04-05T15:16:09.2866667' AS DateTime2), CAST(N'2023-04-05T15:16:09.2866667' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (56, 0, N'tag6', 4, CAST(N'2023-04-05T15:16:09.2866667' AS DateTime2), CAST(N'2023-04-05T15:16:09.2866667' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (61, 0, N'tag1', 4, CAST(N'2023-04-05T15:17:18.2633333' AS DateTime2), CAST(N'2023-04-05T15:17:18.2633333' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (62, 0, N'tag2', 4, CAST(N'2023-04-05T15:17:18.2633333' AS DateTime2), CAST(N'2023-04-05T15:17:18.2633333' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (63, 0, N'tag5', 4, CAST(N'2023-04-05T15:17:18.2633333' AS DateTime2), CAST(N'2023-04-05T15:17:18.2633333' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (64, 0, N'tag6', 4, CAST(N'2023-04-05T15:17:18.2633333' AS DateTime2), CAST(N'2023-04-05T15:17:18.2633333' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (65, 0, N'tag1', 4, CAST(N'2023-04-05T15:17:40.4966667' AS DateTime2), CAST(N'2023-04-05T15:17:40.4966667' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (66, 0, N'tag2', 4, CAST(N'2023-04-05T15:17:40.4966667' AS DateTime2), CAST(N'2023-04-05T15:17:40.4966667' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (67, 0, N'tag5', 4, CAST(N'2023-04-05T15:17:40.4966667' AS DateTime2), CAST(N'2023-04-05T15:17:40.4966667' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (68, 0, N'tag6', 4, CAST(N'2023-04-05T15:17:40.4966667' AS DateTime2), CAST(N'2023-04-05T15:17:40.4966667' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (69, 0, N'tag1', 4, CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (70, 0, N'tag2', 4, CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (71, 0, N'tag5', 4, CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (72, 0, N'tag6', 4, CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (73, 0, N'tag1', 4, CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (74, 0, N'tag2', 4, CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (75, 0, N'tag5', 4, CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2))
INSERT [dbo].[Tags] ([id], [EntityId], [Name], [UserId], [DateCreated], [DateModified]) VALUES (76, 0, N'tag6', 4, CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Tags] OFF
GO
SET IDENTITY_INSERT [dbo].[Teachers] ON 

INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (1, N'Mr. Jones')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (2, N'Mrs. Baxter')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (3, N'Mr. Armstrong')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (4, N'Mr. Amunrud')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (5, N'Ms. Harper')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (6, N'Mrs. Becker')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (7, N'Ms. Trimble')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (8, N'Mr. Hobart')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (9, N'Mr. Crax')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (10, N'Ms. Twinkle')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (11, N'Mr. Zoffer')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (12, N'Mr. Hope')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (19, N'Mrs.Sabio638185695652269023')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (22, N'Mrs.Sabio638185695667448917')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (25, N'Mrs.Sabio638185703791838513')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (28, N'Mrs.Sabio638185713525391515')
INSERT [dbo].[Teachers] ([Id], [Name]) VALUES (31, N'Mrs.Sabio638185724979868714')
SET IDENTITY_INSERT [dbo].[Teachers] OFF
GO
SET IDENTITY_INSERT [dbo].[TechCompanies] ON 

INSERT [dbo].[TechCompanies] ([Id], [DateCreated], [DateModified], [Name], [Profile], [Summary], [Headline], [ContactInformation], [ShortTitle], [Title], [ShortDescription], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [BaseMetaData], [Site]) VALUES (1, CAST(N'2023-04-04T01:46:01.7200000' AS DateTime2), CAST(N'2023-04-04T01:46:01.7200000' AS DateTime2), N'Ford', N'Ford Profile', N'Ford Summary', N'Ford Headline', 5, N'Ford Short Title', N'Ford Title', N'Ford Short Description', N'Ford Content', 4, 4, N'FORD1001', 0, N'Active', NULL, 0)
INSERT [dbo].[TechCompanies] ([Id], [DateCreated], [DateModified], [Name], [Profile], [Summary], [Headline], [ContactInformation], [ShortTitle], [Title], [ShortDescription], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [BaseMetaData], [Site]) VALUES (2, CAST(N'2023-04-04T01:47:21.0200000' AS DateTime2), CAST(N'2023-04-19T22:38:12.9833333' AS DateTime2), N'Apple 124', N'Apple Profile 123', N'Apple Summary 123', N'Apple Headline 122', 6, N'Apple Short Title', N'Apple Title', N'Apple Short Desc', N'Apple Content', 4, 1008, N'APPLE1001123', 0, N'Active', NULL, 0)
INSERT [dbo].[TechCompanies] ([Id], [DateCreated], [DateModified], [Name], [Profile], [Summary], [Headline], [ContactInformation], [ShortTitle], [Title], [ShortDescription], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [BaseMetaData], [Site]) VALUES (5, CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), N'Acme 125', N'Acme Profile 125', N'Acme Summary 125', N'Acme Headline 125', 9, NULL, NULL, NULL, NULL, 4, 4, N'ACMESLUG00125', NULL, N'Active', NULL, NULL)
INSERT [dbo].[TechCompanies] ([Id], [DateCreated], [DateModified], [Name], [Profile], [Summary], [Headline], [ContactInformation], [ShortTitle], [Title], [ShortDescription], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [BaseMetaData], [Site]) VALUES (6, CAST(N'2023-04-05T00:10:32.9766667' AS DateTime2), CAST(N'2023-04-18T19:55:57.7600000' AS DateTime2), N'Acme 12-6', N'Acme Profile 126', N'Acme Summary 126', N'Acme Headline 126', 10, NULL, NULL, NULL, NULL, 4, 1008, N'ACMESLUG00126', NULL, N'Active', NULL, NULL)
INSERT [dbo].[TechCompanies] ([Id], [DateCreated], [DateModified], [Name], [Profile], [Summary], [Headline], [ContactInformation], [ShortTitle], [Title], [ShortDescription], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [BaseMetaData], [Site]) VALUES (7, CAST(N'2023-04-05T00:51:08.5700000' AS DateTime2), CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2), N'Acme 127', N'Acme Profile 127', N'Acme Summary 127', N'Acme Headline 127', 11, NULL, NULL, NULL, NULL, 4, 4, N'ACMESLUG00127', NULL, N'Active', NULL, NULL)
INSERT [dbo].[TechCompanies] ([Id], [DateCreated], [DateModified], [Name], [Profile], [Summary], [Headline], [ContactInformation], [ShortTitle], [Title], [ShortDescription], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [BaseMetaData], [Site]) VALUES (8, CAST(N'2023-04-05T00:52:02.7466667' AS DateTime2), CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2), N'Acme 128', N'Acme Profile 128', N'Acme Summary 128', N'Acme Headline 128', 12, NULL, NULL, NULL, NULL, 4, 4, N'ACMESLUG00128', NULL, N'Active', NULL, NULL)
INSERT [dbo].[TechCompanies] ([Id], [DateCreated], [DateModified], [Name], [Profile], [Summary], [Headline], [ContactInformation], [ShortTitle], [Title], [ShortDescription], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [BaseMetaData], [Site]) VALUES (9, CAST(N'2023-04-05T00:53:13.9400000' AS DateTime2), CAST(N'2023-04-05T15:17:59.5200000' AS DateTime2), N'Acme 129', N'Acme Profile 129', N'Acme Summary 129', N'Acme Headline 129', 13, NULL, NULL, NULL, NULL, 4, 4, N'ACMESLUG00129', NULL, N'Active', NULL, NULL)
INSERT [dbo].[TechCompanies] ([Id], [DateCreated], [DateModified], [Name], [Profile], [Summary], [Headline], [ContactInformation], [ShortTitle], [Title], [ShortDescription], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [BaseMetaData], [Site]) VALUES (10, CAST(N'2023-04-05T00:53:31.5900000' AS DateTime2), CAST(N'2023-04-05T15:18:26.1600000' AS DateTime2), N'Acme 130', N'Acme Profile 130', N'Acme Summary 130', N'Acme Headline 130', 14, NULL, NULL, NULL, NULL, 4, 4, N'ACMESLUG00130', NULL, N'Active', NULL, NULL)
INSERT [dbo].[TechCompanies] ([Id], [DateCreated], [DateModified], [Name], [Profile], [Summary], [Headline], [ContactInformation], [ShortTitle], [Title], [ShortDescription], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [BaseMetaData], [Site]) VALUES (11, CAST(N'2023-04-18T01:34:04.7233333' AS DateTime2), CAST(N'2023-04-18T19:47:11.6466667' AS DateTime2), N'Apple', N'Apple Profile', N'Apple Summary', N'Apple Headline', 15, NULL, NULL, NULL, NULL, 8, 8, N'APPLE1001', NULL, N'Active', NULL, NULL)
INSERT [dbo].[TechCompanies] ([Id], [DateCreated], [DateModified], [Name], [Profile], [Summary], [Headline], [ContactInformation], [ShortTitle], [Title], [ShortDescription], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [BaseMetaData], [Site]) VALUES (12, CAST(N'2023-04-18T20:23:10.1000000' AS DateTime2), CAST(N'2023-04-18T20:24:13.5800000' AS DateTime2), N'THIS BIG COMPANY', N'THIS BIG COMPANY Profile', N'THIS BIG COMPANY Summary', N'THIS BIG COMPANY HL', 16, NULL, NULL, NULL, NULL, 1008, 1008, N'THIS BIG COMPANYSLUG', NULL, N'Deleted', NULL, NULL)
INSERT [dbo].[TechCompanies] ([Id], [DateCreated], [DateModified], [Name], [Profile], [Summary], [Headline], [ContactInformation], [ShortTitle], [Title], [ShortDescription], [Content], [CreatedBy], [ModifiedBy], [Slug], [EntityTypeId], [StatusId], [BaseMetaData], [Site]) VALUES (13, CAST(N'2023-04-18T21:51:25.4566667' AS DateTime2), CAST(N'2023-04-18T21:51:25.4566667' AS DateTime2), N'New', N'3', N'2', N'1', 17, NULL, NULL, NULL, NULL, 1008, 1008, N'4', NULL, N'Deleted', NULL, NULL)
SET IDENTITY_INSERT [dbo].[TechCompanies] OFF
GO
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (1, 489)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (1, 490)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (1, 491)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (2, 500)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (2, 501)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (2, 502)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (5, 513)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (5, 514)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (5, 515)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (5, 516)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (6, 513)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (6, 514)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (6, 517)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (6, 518)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (7, 513)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (7, 514)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (7, 517)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (7, 518)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (8, 513)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (8, 514)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (8, 517)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (8, 518)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (9, 513)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (9, 514)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (9, 517)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (9, 518)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (10, 513)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (10, 514)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (10, 517)
INSERT [dbo].[TechCompaniesFriends] ([TechCompanyId], [FriendId]) VALUES (10, 518)
GO
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (1, 400)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (1, 401)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (2, 501)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (5, 412)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (5, 413)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (5, 414)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (5, 415)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (6, 495)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (7, 460)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (7, 461)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (7, 462)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (7, 463)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (8, 464)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (8, 465)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (8, 466)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (8, 467)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (9, 468)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (9, 469)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (9, 470)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (9, 471)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (10, 472)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (10, 473)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (10, 474)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (10, 475)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (11, 491)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (12, 497)
INSERT [dbo].[TechCompaniesImages] ([TechCompanyId], [ImageId]) VALUES (13, 499)
GO
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (1, 1)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (1, 2)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (2, 3)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (2, 4)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (5, 13)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (5, 14)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (5, 15)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (5, 16)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (6, 53)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (6, 54)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (6, 55)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (6, 56)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (7, 61)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (7, 62)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (7, 63)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (7, 64)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (8, 65)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (8, 66)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (8, 67)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (8, 68)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (9, 69)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (9, 70)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (9, 71)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (9, 72)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (10, 73)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (10, 74)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (10, 75)
INSERT [dbo].[TechCompaniesTags] ([TechCompanyId], [TagId]) VALUES (10, 76)
GO
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (1, 1)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (1, 2)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (2, 91)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (5, 13)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (5, 14)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (5, 15)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (5, 16)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (6, 85)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (7, 61)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (7, 62)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (7, 63)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (7, 64)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (8, 65)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (8, 66)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (8, 67)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (8, 68)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (9, 69)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (9, 70)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (9, 71)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (9, 72)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (10, 73)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (10, 74)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (10, 75)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (10, 76)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (11, 81)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (12, 87)
INSERT [dbo].[TechCompaniesUrls] ([TechCompanyId], [UrlId]) VALUES (13, 89)
GO
SET IDENTITY_INSERT [dbo].[Urls] ON 

INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (1, 0, N'http:/www.ford.com', 4, CAST(N'2023-04-04T01:54:35.2500000' AS DateTime2), CAST(N'2023-04-04T01:54:35.2500000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (2, 0, N'http://www.fordtrucks.com', 4, CAST(N'2023-04-04T01:54:52.5766667' AS DateTime2), CAST(N'2023-04-04T01:54:52.5766667' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (13, 0, N'url1.jpg', 4, CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (14, 0, N'url1.jpg', 4, CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (15, 0, N'url1.jpg', 4, CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (16, 0, N'url1.jpg', 4, CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2), CAST(N'2023-04-04T22:56:07.8500000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (61, 0, N'url1.jpg', 4, CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2), CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (62, 0, N'url2.jpg', 4, CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2), CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (63, 0, N'url5.jpg', 4, CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2), CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (64, 0, N'url6.jpg', 4, CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2), CAST(N'2023-04-05T15:17:18.2500000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (65, 0, N'url1.jpg', 4, CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2), CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (66, 0, N'url2.jpg', 4, CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2), CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (67, 0, N'url5.jpg', 4, CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2), CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (68, 0, N'url6.jpg', 4, CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2), CAST(N'2023-04-05T15:17:40.4800000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (69, 0, N'url1.jpg', 4, CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (70, 0, N'url2.jpg', 4, CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (71, 0, N'url5.jpg', 4, CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (72, 0, N'url6.jpg', 4, CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2), CAST(N'2023-04-05T15:17:59.5366667' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (73, 0, N'url1.jpg', 4, CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (74, 0, N'url2.jpg', 4, CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (75, 0, N'url5.jpg', 4, CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (76, 0, N'url6.jpg', 4, CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2), CAST(N'2023-04-05T15:18:26.1733333' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (81, 0, N'http://www.apple.com', 8, CAST(N'2023-04-18T19:47:11.6600000' AS DateTime2), CAST(N'2023-04-18T19:47:11.6600000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (85, 0, N'url1.jpg', 1008, CAST(N'2023-04-18T19:55:57.7600000' AS DateTime2), CAST(N'2023-04-18T19:55:57.7600000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (87, 0, N'https://www.pwcva.gov/', 1008, CAST(N'2023-04-18T20:24:13.5800000' AS DateTime2), CAST(N'2023-04-18T20:24:13.5800000' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (89, 0, N'www.this.com', 1008, CAST(N'2023-04-18T21:51:25.4566667' AS DateTime2), CAST(N'2023-04-18T21:51:25.4566667' AS DateTime2))
INSERT [dbo].[Urls] ([id], [EntityId], [Url], [UserId], [DateCreated], [DateModified]) VALUES (91, 0, N'http://www.apple.com', 1008, CAST(N'2023-04-19T22:38:13.0000000' AS DateTime2), CAST(N'2023-04-19T22:38:13.0000000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Urls] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (1, N'John1', N'Nelson1', N'john1@john1.com', N'password123', N'http://www.avatar.com/myAvatar', N'ABCD1001', CAST(N'2023-03-29T03:30:05.2966667' AS DateTime2), CAST(N'2023-03-29T03:30:05.2966667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (2, N'John2', N'Nelson2', N'john1@john1.com', N'password124', N'http://www.avatar.com/myAvatar', N'ABCD1002', CAST(N'2023-03-29T03:30:05.7866667' AS DateTime2), CAST(N'2023-03-29T03:30:05.7866667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (3, N'John3', N'Nelson3', N'john1@john1.com', N'password125', N'http://www.avatar.com/myAvatar', N'ABCD1003', CAST(N'2023-03-29T03:30:06.2600000' AS DateTime2), CAST(N'2023-03-29T03:30:06.2600000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (4, N'John4', N'Nelson4', N'john1@john1.com', N'password126', N'http://www.avatar.com/myAvatar', N'ABCD1004', CAST(N'2023-03-29T03:30:06.7300000' AS DateTime2), CAST(N'2023-03-29T03:30:06.7300000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (5, N'John5', N'Nelson5', N'john1@john1.com', N'password127', N'http://www.avatar.com/myAvatar', N'ABCD1005', CAST(N'2023-03-29T03:30:07.1800000' AS DateTime2), CAST(N'2023-03-29T03:30:07.1800000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (6, N'John6', N'Nelson6', N'john1@john1.com', N'password128', N'http://www.avatar.com/myAvatar', N'ABCD1006', CAST(N'2023-03-29T03:30:07.6200000' AS DateTime2), CAST(N'2023-03-29T03:30:07.6200000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (7, N'John7', N'Nelson7', N'john1@john1.com', N'password129', N'http://www.avatar.com/myAvatar', N'ABCD1007', CAST(N'2023-03-29T03:30:08.0900000' AS DateTime2), CAST(N'2023-03-29T03:30:08.0900000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (8, N'John8', N'Nelson8', N'john1@john1.com', N'password130', N'http://www.avatar.com/myAvatar', N'ABCD1008', CAST(N'2023-03-29T03:30:08.5400000' AS DateTime2), CAST(N'2023-03-29T03:30:08.5400000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (9, N'John9', N'Nelson9', N'john1@john1.com', N'password131', N'http://www.avatar.com/myAvatar', N'ABCD1009', CAST(N'2023-03-29T03:30:08.9933333' AS DateTime2), CAST(N'2023-03-29T03:30:08.9933333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (10, N'John10', N'Nelson10', N'john1@john1.com', N'password132', N'http://www.avatar.com/myAvatar', N'ABCD1010', CAST(N'2023-03-29T03:30:09.4633333' AS DateTime2), CAST(N'2023-03-29T03:30:09.4633333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (11, N'John11', N'Nelson11', N'john1@john1.com', N'password133', N'http://www.avatar.com/myAvatar', N'ABCD1011', CAST(N'2023-03-29T03:30:09.9000000' AS DateTime2), CAST(N'2023-03-29T03:30:09.9000000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (12, N'John12', N'Nelson12', N'john1@john1.com', N'password134', N'http://www.avatar.com/myAvatar', N'ABCD1012', CAST(N'2023-03-29T03:30:10.3533333' AS DateTime2), CAST(N'2023-03-29T03:30:10.3533333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (13, N'John13', N'Nelson13', N'john1@john1.com', N'password135', N'http://www.avatar.com/myAvatar', N'ABCD1013', CAST(N'2023-03-29T03:30:10.8233333' AS DateTime2), CAST(N'2023-03-29T03:30:10.8233333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (14, N'John14', N'Nelson14', N'john1@john1.com', N'password136', N'http://www.avatar.com/myAvatar', N'ABCD1014', CAST(N'2023-03-29T03:30:11.2600000' AS DateTime2), CAST(N'2023-03-29T03:30:11.2600000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (15, N'John15', N'Nelson15', N'john1@john1.com', N'password137', N'http://www.avatar.com/myAvatar', N'ABCD1015', CAST(N'2023-03-29T03:30:11.6966667' AS DateTime2), CAST(N'2023-03-29T03:30:11.6966667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (16, N'FName_Update4065', N'LName_Update4065', N'updated@example.com4065', N'password138', N'https://update_img_url.jpg4065', N'testTenant4065', CAST(N'2023-03-29T03:30:12.1366667' AS DateTime2), CAST(N'2023-04-13T15:28:21.1033333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (17, N'John17', N'Nelson17', N'john1@john1.com', N'password139', N'http://www.avatar.com/myAvatar', N'ABCD1017', CAST(N'2023-03-29T03:30:12.5900000' AS DateTime2), CAST(N'2023-03-29T03:30:12.5900000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (18, N'John18', N'Nelson18', N'john1@john1.com', N'password140', N'http://www.avatar.com/myAvatar', N'ABCD1018', CAST(N'2023-03-29T03:30:13.0566667' AS DateTime2), CAST(N'2023-03-29T03:30:13.0566667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (19, N'John19', N'Nelson19', N'john1@john1.com', N'password141', N'http://www.avatar.com/myAvatar', N'ABCD1019', CAST(N'2023-03-29T03:30:13.5100000' AS DateTime2), CAST(N'2023-03-29T03:30:13.5100000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (20, N'John20', N'Nelson20', N'john1@john1.com', N'password142', N'http://www.avatar.com/myAvatar', N'ABCD1020', CAST(N'2023-03-29T03:30:13.9633333' AS DateTime2), CAST(N'2023-03-29T03:30:13.9633333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (21, N'John21', N'Nelson21', N'john1@john1.com', N'password143', N'http://www.avatar.com/myAvatar', N'ABCD1021', CAST(N'2023-03-29T03:30:14.4933333' AS DateTime2), CAST(N'2023-03-29T03:30:14.4933333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (22, N'John22', N'Nelson22', N'john1@john1.com', N'password144', N'http://www.avatar.com/myAvatar', N'ABCD1022', CAST(N'2023-03-29T03:30:14.9633333' AS DateTime2), CAST(N'2023-03-29T03:30:14.9633333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (23, N'John23', N'Nelson23', N'john1@john1.com', N'password145', N'http://www.avatar.com/myAvatar', N'ABCD1023', CAST(N'2023-03-29T03:30:15.4333333' AS DateTime2), CAST(N'2023-03-29T03:30:15.4333333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (24, N'John24', N'Nelson24', N'john1@john1.com', N'password146', N'http://www.avatar.com/myAvatar', N'ABCD1024', CAST(N'2023-03-29T03:30:15.9000000' AS DateTime2), CAST(N'2023-03-29T03:30:15.9000000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (25, N'Hobart', N'Jenkins', N'hobart@jones.com', N'password', N'avatar.jpg', N'TENANT123098', CAST(N'2023-03-29T03:30:16.3866667' AS DateTime2), CAST(N'2023-04-14T02:04:20.0600000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (26, N'John26', N'Nelson26', N'john1@john1.com', N'password148', N'http://www.avatar.com/myAvatar', N'ABCD1026', CAST(N'2023-03-29T03:30:16.8700000' AS DateTime2), CAST(N'2023-03-29T03:30:16.8700000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (27, N'John27', N'Nelson27', N'john1@john1.com', N'password149', N'http://www.avatar.com/myAvatar', N'ABCD1027', CAST(N'2023-03-29T03:30:17.3233333' AS DateTime2), CAST(N'2023-03-29T03:30:17.3233333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (28, N'John28', N'Nelson28', N'john1@john1.com', N'password150', N'http://www.avatar.com/myAvatar', N'ABCD1028', CAST(N'2023-03-29T03:30:17.7766667' AS DateTime2), CAST(N'2023-03-29T03:30:17.7766667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (29, N'John29', N'Nelson29', N'john1@john1.com', N'password151', N'http://www.avatar.com/myAvatar', N'ABCD1029', CAST(N'2023-03-29T03:30:18.2433333' AS DateTime2), CAST(N'2023-03-29T03:30:18.2433333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (30, N'John30', N'Nelson30', N'john1@john1.com', N'password152', N'http://www.avatar.com/myAvatar', N'ABCD1030', CAST(N'2023-03-29T03:30:18.6833333' AS DateTime2), CAST(N'2023-03-29T03:30:18.6833333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (31, N'John31', N'Nelson31', N'john1@john1.com', N'password153', N'http://www.avatar.com/myAvatar', N'ABCD1031', CAST(N'2023-03-29T03:30:19.1400000' AS DateTime2), CAST(N'2023-03-29T03:30:19.1400000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (32, N'John32', N'Nelson32', N'john1@john1.com', N'password154', N'http://www.avatar.com/myAvatar', N'ABCD1032', CAST(N'2023-03-29T03:30:19.5933333' AS DateTime2), CAST(N'2023-03-29T03:30:19.5933333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (33, N'John33', N'Nelson33', N'john1@john1.com', N'password155', N'http://www.avatar.com/myAvatar', N'ABCD1033', CAST(N'2023-03-29T03:30:20.0933333' AS DateTime2), CAST(N'2023-03-29T03:30:20.0933333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (34, N'John34', N'Nelson34', N'john1@john1.com', N'password156', N'http://www.avatar.com/myAvatar', N'ABCD1034', CAST(N'2023-03-29T03:30:20.5766667' AS DateTime2), CAST(N'2023-03-29T03:30:20.5766667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (35, N'John35', N'Nelson35', N'john1@john1.com', N'password157', N'http://www.avatar.com/myAvatar', N'ABCD1035', CAST(N'2023-03-29T03:30:21.0166667' AS DateTime2), CAST(N'2023-03-29T03:30:21.0166667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (36, N'John36', N'Nelson36', N'john1@john1.com', N'password158', N'http://www.avatar.com/myAvatar', N'ABCD1036', CAST(N'2023-03-29T03:30:21.4833333' AS DateTime2), CAST(N'2023-03-29T03:30:21.4833333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (37, N'John37', N'Nelson37', N'john1@john1.com', N'password159', N'http://www.avatar.com/myAvatar', N'ABCD1037', CAST(N'2023-03-29T03:30:21.9366667' AS DateTime2), CAST(N'2023-03-29T03:30:21.9366667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (38, N'John38', N'Nelson38', N'john1@john1.com', N'password160', N'http://www.avatar.com/myAvatar', N'ABCD1038', CAST(N'2023-03-29T03:30:22.4066667' AS DateTime2), CAST(N'2023-03-29T03:30:22.4066667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (39, N'John39', N'Nelson39', N'john1@john1.com', N'password161', N'http://www.avatar.com/myAvatar', N'ABCD1039', CAST(N'2023-03-29T03:30:22.8600000' AS DateTime2), CAST(N'2023-03-29T03:30:22.8600000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (40, N'John40', N'Nelson40', N'john1@john1.com', N'password162', N'http://www.avatar.com/myAvatar', N'ABCD1040', CAST(N'2023-03-29T03:30:23.3133333' AS DateTime2), CAST(N'2023-03-29T03:30:23.3133333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (41, N'John41', N'Nelson41', N'john1@john1.com', N'password163', N'http://www.avatar.com/myAvatar', N'ABCD1041', CAST(N'2023-03-29T03:30:23.7800000' AS DateTime2), CAST(N'2023-03-29T03:30:23.7800000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (42, N'John42', N'Nelson42', N'john1@john1.com', N'password164', N'http://www.avatar.com/myAvatar', N'ABCD1042', CAST(N'2023-03-29T03:30:24.2200000' AS DateTime2), CAST(N'2023-03-29T03:30:24.2200000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (43, N'John43', N'Nelson43', N'john1@john1.com', N'password165', N'http://www.avatar.com/myAvatar', N'ABCD1043', CAST(N'2023-03-29T03:30:24.6400000' AS DateTime2), CAST(N'2023-03-29T03:30:24.6400000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (45, N'John45', N'Nelson45', N'john1@john1.com', N'password123123', N'http://www.avatar.com/myAvatar', N'ABCD1045', CAST(N'2023-03-29T03:30:25.5633333' AS DateTime2), CAST(N'2023-03-29T04:16:07.0300000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (46, N'John46', N'Nelson46', N'john1@john1.com', N'password168', N'http://www.avatar.com/myAvatar', N'ABCD1046', CAST(N'2023-03-29T03:30:26.0000000' AS DateTime2), CAST(N'2023-03-29T03:30:26.0000000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (47, N'John47', N'Nelson47', N'john1@john1.com', N'password169', N'http://www.avatar.com/myAvatar', N'ABCD1047', CAST(N'2023-03-29T03:30:26.4533333' AS DateTime2), CAST(N'2023-03-29T03:30:26.4533333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (48, N'John48', N'Nelson48', N'john1@john1.com', N'password170', N'http://www.avatar.com/myAvatar', N'ABCD1048', CAST(N'2023-03-29T03:30:26.9066667' AS DateTime2), CAST(N'2023-03-29T03:30:26.9066667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (49, N'John49', N'Nelson49', N'john1@john1.com', N'password171', N'http://www.avatar.com/myAvatar', N'ABCD1049', CAST(N'2023-03-29T03:30:27.3600000' AS DateTime2), CAST(N'2023-03-29T03:30:27.3600000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (50, N'John50', N'Nelson50', N'john1@john1.com', N'password172', N'http://www.avatar.com/myAvatar', N'ABCD1050', CAST(N'2023-03-29T03:30:27.7966667' AS DateTime2), CAST(N'2023-03-29T03:30:27.7966667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (51, N'John51', N'Nelson51', N'john1@john1.com', N'password173', N'http://www.avatar.com/myAvatar', N'ABCD1051', CAST(N'2023-03-29T03:30:28.2500000' AS DateTime2), CAST(N'2023-03-29T03:30:28.2500000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (52, N'John52', N'Nelson52', N'john1@john1.com', N'password174', N'http://www.avatar.com/myAvatar', N'ABCD1052', CAST(N'2023-03-29T03:30:28.7100000' AS DateTime2), CAST(N'2023-03-29T03:30:28.7100000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (53, N'John53', N'Nelson53', N'john1@john1.com', N'password175', N'http://www.avatar.com/myAvatar', N'ABCD1053', CAST(N'2023-03-29T03:30:29.1466667' AS DateTime2), CAST(N'2023-03-29T03:30:29.1466667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (54, N'John54', N'Nelson54', N'john1@john1.com', N'password176', N'http://www.avatar.com/myAvatar', N'ABCD1054', CAST(N'2023-03-29T03:30:29.6166667' AS DateTime2), CAST(N'2023-03-29T03:30:29.6166667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (55, N'John55', N'Nelson55', N'john1@john1.com', N'password177', N'http://www.avatar.com/myAvatar', N'ABCD1055', CAST(N'2023-03-29T03:30:30.0533333' AS DateTime2), CAST(N'2023-03-29T03:30:30.0533333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (56, N'John56', N'Nelson56', N'john1@john1.com', N'password178', N'http://www.avatar.com/myAvatar', N'ABCD1056', CAST(N'2023-03-29T03:30:30.4900000' AS DateTime2), CAST(N'2023-03-29T03:30:30.4900000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (57, N'John57', N'Nelson57', N'john1@john1.com', N'password179', N'http://www.avatar.com/myAvatar', N'ABCD1057', CAST(N'2023-03-29T03:30:30.9300000' AS DateTime2), CAST(N'2023-03-29T03:30:30.9300000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (58, N'John58', N'Nelson58', N'john1@john1.com', N'password180', N'http://www.avatar.com/myAvatar', N'ABCD1058', CAST(N'2023-03-29T03:30:31.3800000' AS DateTime2), CAST(N'2023-03-29T03:30:31.3800000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (59, N'John59', N'Nelson59', N'john1@john1.com', N'password181', N'http://www.avatar.com/myAvatar', N'ABCD1059', CAST(N'2023-03-29T03:30:31.8200000' AS DateTime2), CAST(N'2023-03-29T03:30:31.8200000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (60, N'John60', N'Nelson60', N'john1@john1.com', N'password182', N'http://www.avatar.com/myAvatar', N'ABCD1060', CAST(N'2023-03-29T03:30:32.2733333' AS DateTime2), CAST(N'2023-03-29T03:30:32.2733333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (61, N'John61', N'Nelson61', N'john1@john1.com', N'password183', N'http://www.avatar.com/myAvatar', N'ABCD1061', CAST(N'2023-03-29T03:30:32.6933333' AS DateTime2), CAST(N'2023-03-29T03:30:32.6933333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (62, N'John62', N'Nelson62', N'john1@john1.com', N'password184', N'http://www.avatar.com/myAvatar', N'ABCD1062', CAST(N'2023-03-29T03:30:33.1466667' AS DateTime2), CAST(N'2023-03-29T03:30:33.1466667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (63, N'John63', N'Nelson63', N'john1@john1.com', N'password185', N'http://www.avatar.com/myAvatar', N'ABCD1063', CAST(N'2023-03-29T03:30:33.6000000' AS DateTime2), CAST(N'2023-03-29T03:30:33.6000000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (64, N'John64', N'Nelson64', N'john1@john1.com', N'password186', N'http://www.avatar.com/myAvatar', N'ABCD1064', CAST(N'2023-03-29T03:30:34.0366667' AS DateTime2), CAST(N'2023-03-29T03:30:34.0366667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (65, N'John65', N'Nelson65', N'john1@john1.com', N'password187', N'http://www.avatar.com/myAvatar', N'ABCD1065', CAST(N'2023-03-29T03:30:34.5066667' AS DateTime2), CAST(N'2023-03-29T03:30:34.5066667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (66, N'John66', N'Nelson66', N'john1@john1.com', N'password188', N'http://www.avatar.com/myAvatar', N'ABCD1066', CAST(N'2023-03-29T03:30:34.9600000' AS DateTime2), CAST(N'2023-03-29T03:30:34.9600000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (67, N'John67', N'Nelson67', N'john1@john1.com', N'password189', N'http://www.avatar.com/myAvatar', N'ABCD1067', CAST(N'2023-03-29T03:30:35.4000000' AS DateTime2), CAST(N'2023-03-29T03:30:35.4000000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (68, N'John68', N'Nelson68', N'john1@john1.com', N'password190', N'http://www.avatar.com/myAvatar', N'ABCD1068', CAST(N'2023-03-29T03:30:35.8866667' AS DateTime2), CAST(N'2023-03-29T03:30:35.8866667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (69, N'John69', N'Nelson69', N'john1@john1.com', N'password191', N'http://www.avatar.com/myAvatar', N'ABCD1069', CAST(N'2023-03-29T03:30:36.3400000' AS DateTime2), CAST(N'2023-03-29T03:30:36.3400000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (70, N'John70', N'Nelson70', N'john1@john1.com', N'password192', N'http://www.avatar.com/myAvatar', N'ABCD1070', CAST(N'2023-03-29T03:30:36.7933333' AS DateTime2), CAST(N'2023-03-29T03:30:36.7933333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (71, N'John71', N'Nelson71', N'john1@john1.com', N'password193', N'http://www.avatar.com/myAvatar', N'ABCD1071', CAST(N'2023-03-29T03:30:37.2633333' AS DateTime2), CAST(N'2023-03-29T03:30:37.2633333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (72, N'John72', N'Nelson72', N'john1@john1.com', N'password194', N'http://www.avatar.com/myAvatar', N'ABCD1072', CAST(N'2023-03-29T03:30:37.7166667' AS DateTime2), CAST(N'2023-03-29T03:30:37.7166667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (73, N'John73', N'Nelson73', N'john1@john1.com', N'password195', N'http://www.avatar.com/myAvatar', N'ABCD1073', CAST(N'2023-03-29T03:30:38.1700000' AS DateTime2), CAST(N'2023-03-29T03:30:38.1700000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (74, N'John74', N'Nelson74', N'john1@john1.com', N'password196', N'http://www.avatar.com/myAvatar', N'ABCD1074', CAST(N'2023-03-29T03:30:38.6200000' AS DateTime2), CAST(N'2023-03-29T03:30:38.6200000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (75, N'John75', N'Nelson75', N'john1@john1.com', N'password197', N'http://www.avatar.com/myAvatar', N'ABCD1075', CAST(N'2023-03-29T03:30:39.0766667' AS DateTime2), CAST(N'2023-03-29T03:30:39.0766667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (76, N'John76', N'Nelson76', N'john1@john1.com', N'password198', N'http://www.avatar.com/myAvatar', N'ABCD1076', CAST(N'2023-03-29T03:30:39.5300000' AS DateTime2), CAST(N'2023-03-29T03:30:39.5300000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (77, N'John77', N'Nelson77', N'john1@john1.com', N'password199', N'http://www.avatar.com/myAvatar', N'ABCD1077', CAST(N'2023-03-29T03:30:40.3966667' AS DateTime2), CAST(N'2023-03-29T03:30:40.3966667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (78, N'John78', N'Nelson78', N'john1@john1.com', N'password200', N'http://www.avatar.com/myAvatar', N'ABCD1078', CAST(N'2023-03-29T03:30:40.8633333' AS DateTime2), CAST(N'2023-03-29T03:30:40.8633333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (79, N'John79', N'Nelson79', N'john1@john1.com', N'password201', N'http://www.avatar.com/myAvatar', N'ABCD1079', CAST(N'2023-03-29T03:30:41.3333333' AS DateTime2), CAST(N'2023-03-29T03:30:41.3333333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (80, N'John80', N'Nelson80', N'john1@john1.com', N'password202', N'http://www.avatar.com/myAvatar', N'ABCD1080', CAST(N'2023-03-29T03:30:41.8333333' AS DateTime2), CAST(N'2023-03-29T03:30:41.8333333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (81, N'John81', N'Nelson81', N'john1@john1.com', N'password203', N'http://www.avatar.com/myAvatar', N'ABCD1081', CAST(N'2023-03-29T03:30:42.2900000' AS DateTime2), CAST(N'2023-03-29T03:30:42.2900000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (82, N'John82', N'Nelson82', N'john1@john1.com', N'password204', N'http://www.avatar.com/myAvatar', N'ABCD1082', CAST(N'2023-03-29T03:30:42.7433333' AS DateTime2), CAST(N'2023-03-29T03:30:42.7433333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (83, N'John83', N'Nelson83', N'john1@john1.com', N'password205', N'http://www.avatar.com/myAvatar', N'ABCD1083', CAST(N'2023-03-29T03:30:43.1966667' AS DateTime2), CAST(N'2023-03-29T03:30:43.1966667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (84, N'John84', N'Nelson84', N'john1@john1.com', N'password206', N'http://www.avatar.com/myAvatar', N'ABCD1084', CAST(N'2023-03-29T03:30:43.6366667' AS DateTime2), CAST(N'2023-03-29T03:30:43.6366667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (85, N'John85', N'Nelson85', N'john1@john1.com', N'password207', N'http://www.avatar.com/myAvatar', N'ABCD1085', CAST(N'2023-03-29T03:30:44.3700000' AS DateTime2), CAST(N'2023-03-29T03:30:44.3700000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (86, N'John86', N'Nelson86', N'john1@john1.com', N'password208', N'http://www.avatar.com/myAvatar', N'ABCD1086', CAST(N'2023-03-29T03:30:44.8100000' AS DateTime2), CAST(N'2023-03-29T03:30:44.8100000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (87, N'John87', N'Nelson87', N'john1@john1.com', N'password209', N'http://www.avatar.com/myAvatar', N'ABCD1087', CAST(N'2023-03-29T03:30:45.2466667' AS DateTime2), CAST(N'2023-03-29T03:30:45.2466667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (88, N'John88', N'Nelson88', N'john1@john1.com', N'password210', N'http://www.avatar.com/myAvatar', N'ABCD1088', CAST(N'2023-03-29T03:30:45.7000000' AS DateTime2), CAST(N'2023-03-29T03:30:45.7000000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (89, N'John89', N'Nelson89', N'john1@john1.com', N'password211', N'http://www.avatar.com/myAvatar', N'ABCD1089', CAST(N'2023-03-29T03:30:46.1366667' AS DateTime2), CAST(N'2023-03-29T03:30:46.1366667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (90, N'John90', N'Nelson90', N'john1@john1.com', N'password212', N'http://www.avatar.com/myAvatar', N'ABCD1090', CAST(N'2023-03-29T03:30:46.5933333' AS DateTime2), CAST(N'2023-03-29T03:30:46.5933333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (91, N'John91', N'Nelson91', N'john1@john1.com', N'password213', N'http://www.avatar.com/myAvatar', N'ABCD1091', CAST(N'2023-03-29T03:30:47.0300000' AS DateTime2), CAST(N'2023-03-29T03:30:47.0300000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (92, N'John92', N'Nelson92', N'john1@john1.com', N'password214', N'http://www.avatar.com/myAvatar', N'ABCD1092', CAST(N'2023-03-29T03:30:47.4833333' AS DateTime2), CAST(N'2023-03-29T03:30:47.4833333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (93, N'John93', N'Nelson93', N'john1@john1.com', N'password215', N'http://www.avatar.com/myAvatar', N'ABCD1093', CAST(N'2023-03-29T03:30:47.9200000' AS DateTime2), CAST(N'2023-03-29T03:30:47.9200000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (94, N'John94', N'Nelson94', N'john1@john1.com', N'password216', N'http://www.avatar.com/myAvatar', N'ABCD1094', CAST(N'2023-03-29T03:30:48.3600000' AS DateTime2), CAST(N'2023-03-29T03:30:48.3600000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (95, N'John95', N'Nelson95', N'john1@john1.com', N'password217', N'http://www.avatar.com/myAvatar', N'ABCD1095', CAST(N'2023-03-29T03:30:48.8000000' AS DateTime2), CAST(N'2023-03-29T03:30:48.8000000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (96, N'John96', N'Nelson96', N'john1@john1.com', N'password218', N'http://www.avatar.com/myAvatar', N'ABCD1096', CAST(N'2023-03-29T03:30:49.2666667' AS DateTime2), CAST(N'2023-03-29T03:30:49.2666667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (97, N'John97', N'Nelson97', N'john1@john1.com', N'password219', N'http://www.avatar.com/myAvatar', N'ABCD1097', CAST(N'2023-03-29T03:30:49.7200000' AS DateTime2), CAST(N'2023-03-29T03:30:49.7200000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (98, N'John98', N'Nelson98', N'john1@john1.com', N'password220', N'http://www.avatar.com/myAvatar', N'ABCD1098', CAST(N'2023-03-29T03:30:50.1566667' AS DateTime2), CAST(N'2023-03-29T03:30:50.1566667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (99, N'John99', N'Nelson99', N'john1@john1.com', N'password221', N'http://www.avatar.com/myAvatar', N'ABCD1099', CAST(N'2023-03-29T03:30:50.6100000' AS DateTime2), CAST(N'2023-03-29T03:30:50.6100000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (100, N'Harry', N'Jones', N'Harry@email.com', N'password', N'myavatar.jpg', N'TENANTID33334', CAST(N'2023-03-29T03:44:39.7400000' AS DateTime2), CAST(N'2023-03-29T03:44:39.7400000' AS DateTime2), N'user')
GO
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (101, N'Harry', N'Jones', N'Harry@email.com', N'password', N'myavatar.jpg', N'TENANTID33334', CAST(N'2023-03-29T04:06:26.6100000' AS DateTime2), CAST(N'2023-03-29T04:06:26.6100000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (102, N'Harry', N'Jamison', N'Harry@email.com', N'myavatar.jpg', N'TENANTID33334', N'password', CAST(N'2023-03-29T04:20:54.0733333' AS DateTime2), CAST(N'2023-03-29T04:20:54.0733333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (132, N'Unique2801', N'last', N'email', N'pass', N'avatarUrl', N'tenantId', CAST(N'2023-03-29T13:18:18.1066667' AS DateTime2), CAST(N'2023-03-29T13:18:18.1066667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (133, N'Unique2801', N'last', N'email', N'pass', N'avatarUrl', N'tenantId', CAST(N'2023-03-29T13:18:18.1066667' AS DateTime2), CAST(N'2023-03-29T13:18:18.1066667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (134, N'Unique2801', N'last', N'email', N'pass', N'avatarUrl', N'tenantId', CAST(N'2023-03-29T13:18:18.1066667' AS DateTime2), CAST(N'2023-03-29T13:18:18.1066667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (135, N'Unique2801', N'last', N'email', N'pass', N'avatarUrl', N'tenantId', CAST(N'2023-03-29T13:18:18.1066667' AS DateTime2), CAST(N'2023-03-29T13:18:18.1066667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (136, N'Unique2801', N'last', N'email', N'pass', N'avatarUrl', N'tenantId', CAST(N'2023-03-29T13:18:18.1066667' AS DateTime2), CAST(N'2023-03-29T13:18:18.1066667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (137, N'Unique2801', N'last', N'email', N'pass', N'avatarUrl', N'tenantId', CAST(N'2023-03-29T13:18:18.1066667' AS DateTime2), CAST(N'2023-03-29T13:18:18.1066667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (183, N'Harry', N'Winkins', N'Harry.Winkins@email.com', N'password123', N'harry.jpg', N'HARRY1001', CAST(N'2023-04-09T19:12:45.0766667' AS DateTime2), CAST(N'2023-04-09T19:12:45.0766667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (184, N'Harry', N'Winkins', N'Harry.Winkins@email.com', N'password124', N'harry1.jpg', N'HARRY1002', CAST(N'2023-04-09T19:19:26.4233333' AS DateTime2), CAST(N'2023-04-09T19:19:26.4233333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (185, N'Harry 123', N'Winkins 123', N'Harry.Winkins@email.com', N'password125', N'harry2.jpg', N'HARRY1003', CAST(N'2023-04-09T19:19:26.4566667' AS DateTime2), CAST(N'2023-04-09T19:19:26.4566667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (186, N'Harry', N'Winkins', N'Harry.Winkins@email.com', N'password126', N'harry1.jpg', N'HARRY1002', CAST(N'2023-04-09T19:20:30.5900000' AS DateTime2), CAST(N'2023-04-09T19:20:30.5900000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (187, N'Harry 127', N'Winkins 127', N'Harry.Winkins@email.com', N'password127', N'harry2.jpg', N'HARRY1007', CAST(N'2023-04-09T19:20:51.1933333' AS DateTime2), CAST(N'2023-04-09T19:20:51.1933333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (188, N'Harry', N'Winkins', N'Harry.Winkins@email.com', N'password126', N'harry1.jpg', N'HARRY1002', CAST(N'2023-04-09T19:21:44.2866667' AS DateTime2), CAST(N'2023-04-09T19:21:44.2866667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (189, N'Harry 127', N'Winkins 127', N'Harry.Winkins@email.com', N'password127', N'harry2.jpg', N'HARRY1007', CAST(N'2023-04-09T19:23:02.1900000' AS DateTime2), CAST(N'2023-04-09T19:23:13.5366667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (190, N'Fname_Insert', N'Lname_Insert', N'testInsert@example.com', N'Password123', N'https://some_img_url.jpg', N'testTenant', CAST(N'2023-04-13T15:27:10.8866667' AS DateTime2), CAST(N'2023-04-13T15:27:10.8866667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (191, N'Fname_Test', N'Lname_test', N'badEmail', N'Password', N'https://some_img_url.jpg', N'testTenant', CAST(N'2023-04-13T15:27:12.5966667' AS DateTime2), CAST(N'2023-04-13T15:27:12.5966667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (192, N'Fname_Test', N'Lname_test', N'test@example.com', N'Password', N'https://some_img_url.jpg', N'testTenant', CAST(N'2023-04-13T15:27:14.7300000' AS DateTime2), CAST(N'2023-04-13T15:27:14.7300000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (194, N'Fname_Insert', N'Lname_Insert', N'testInsert@example.com', N'Password123', N'https://some_img_url.jpg', N'testTenant', CAST(N'2023-04-13T15:35:10.4033333' AS DateTime2), CAST(N'2023-04-13T15:35:10.4033333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (195, N'Fname_Test', N'Lname_test', N'badEmail', N'Password', N'https://some_img_url.jpg', N'testTenant', CAST(N'2023-04-13T15:35:12.0766667' AS DateTime2), CAST(N'2023-04-13T15:35:12.0766667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (196, N'Fname_Insert', N'Lname_Insert', N'testInsert@example.com', N'Password123', N'https://some_img_url.jpg', N'testTenant', CAST(N'2023-04-13T15:38:04.6966667' AS DateTime2), CAST(N'2023-04-13T15:38:04.6966667' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (197, N'Fname_Insert', N'Lname_Insert', N'testInsert@example.com', N'Password123', N'https://some_img_url.jpg', N'testTenant', CAST(N'2023-04-13T16:48:49.6633333' AS DateTime2), CAST(N'2023-04-13T16:48:49.6633333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (199, N'John124444', N'Nelson12', N'user@example.com', N'string123', N'string', N'string', CAST(N'2023-04-14T15:22:23.9533333' AS DateTime2), CAST(N'2023-04-14T15:23:50.9233333' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (200, N'John', N'Nelson', N'tester123@tester.com', N'$2b$10$uTOqtvrD6fVoQk7/fORs0.PuoU2DYPQM1RN/Tdz81SQZYmOzKroUi', N'string', N'string', CAST(N'2023-04-26T21:00:14.1400000' AS DateTime2), CAST(N'2023-04-26T21:00:14.1400000' AS DateTime2), N'visitor')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (201, N'Kaye', N'Nelson', N'kayenelson@yahoo.com', N'$2b$10$uTOqtvrD6fVoQk7/fORs0.PuoU2DYPQM1RN/Tdz81SQZYmOzKroUi', N'www.jpg', N'TENANT200056', CAST(N'2023-04-26T21:06:45.6000000' AS DateTime2), CAST(N'2023-04-26T21:06:45.6000000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (202, N'George', N'Jones', N'gj@123.com', N'$2b$10$uTOqtvrD6fVoQk7/fORs0.PuoU2DYPQM1RN/Tdz81SQZYmOzKroUi', N'https://images.panda.org/assets/images/pages/welcome/orangutan_1600x1000_279157.jpg', N'TENANT200059', CAST(N'2023-04-27T00:41:01.3266667' AS DateTime2), CAST(N'2023-04-27T00:41:01.3266667' AS DateTime2), N'admin')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (203, N'Harry', N'Jones', N'Harry321@email.com', N'$2b$10$uTOqtvrD6fVoQk7/fORs0.PuoU2DYPQM1RN/Tdz81SQZYmOzKroUi', N'TENANTID33334', N'password', CAST(N'2023-04-27T22:40:42.1000000' AS DateTime2), CAST(N'2023-04-27T22:40:42.1000000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (204, N'Johnny', N'Nelson', N'john_seed@yahoo.com', N'$2b$10$yhA6pePGQUeFRqf347J6Qekn362d9yb3w6vI2ndswfiJuyqIZp2E2', N'https://images.panda.org/assets/images/pages/welcome/orangutan_1600x1000_279157.jpg', N'TENANT200055', CAST(N'2023-05-04T01:40:48.8800000' AS DateTime2), CAST(N'2023-05-04T01:40:48.8800000' AS DateTime2), N'user')
INSERT [dbo].[Users] ([Id], [FirstName], [LastName], [Email], [Password], [AvatarUrl], [TenantId], [DateCreated], [DateModified], [Roles]) VALUES (205, N'John', N'Nelson', N'sjbjohn@gmail.com', N'$2b$10$KwZJJVgEtu0pMg9Njz.wS.r/qcFswX3/Gn1hsp05ukmfF.g5pjtmO', N'https://images.panda.org/assets/images/pages/welcome/orangutan_1600x1000_279157.jpg', N'TENANT200021', CAST(N'2023-05-04T01:41:26.8400000' AS DateTime2), CAST(N'2023-05-04T01:41:26.8400000' AS DateTime2), N'user')
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
INSERT [flat].[InstructorsOffices] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned]) VALUES (1, N'Abercrombie', N'Kim', CAST(N'1995-03-11T00:00:00.000' AS DateTime), 1, N'Washington', N'103', CAST(N'2020-04-03T07:31:04.520' AS DateTime))
INSERT [flat].[InstructorsOffices] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned]) VALUES (4, N'Fakhouri', N'Fadi', CAST(N'2002-08-06T00:00:00.000' AS DateTime), 2, N'Adams', N'908', CAST(N'2020-03-03T07:31:04.520' AS DateTime))
INSERT [flat].[InstructorsOffices] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned]) VALUES (5, N'Harui', N'Roger', CAST(N'1998-07-01T00:00:00.000' AS DateTime), 3, N'Williams', N'8', CAST(N'2020-02-10T07:31:04.520' AS DateTime))
INSERT [flat].[InstructorsOffices] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned]) VALUES (18, N'Zheng', N'Roger', CAST(N'2004-02-12T00:00:00.000' AS DateTime), 4, N'Monroe', N'34', CAST(N'2020-04-03T07:31:04.520' AS DateTime))
INSERT [flat].[InstructorsOffices] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned]) VALUES (25, N'Kapoor', N'Candace', CAST(N'2001-01-15T00:00:00.000' AS DateTime), 5, N'Jackson', N'23', CAST(N'2020-01-03T07:31:04.520' AS DateTime))
INSERT [flat].[InstructorsOffices] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned]) VALUES (27, N'Serrano', N'Stacy', CAST(N'1999-06-01T00:00:00.000' AS DateTime), 6, N'Van Buren', N'56', CAST(N'2020-01-16T07:31:04.520' AS DateTime))
INSERT [flat].[InstructorsOffices] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned]) VALUES (31, N'Stewart', N'Jasmine', CAST(N'1997-10-12T00:00:00.000' AS DateTime), 7, N'Grant', N'21', CAST(N'2020-04-03T07:31:04.520' AS DateTime))
INSERT [flat].[InstructorsOffices] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned]) VALUES (32, N'Xu', N'Kristen', CAST(N'2001-07-23T00:00:00.000' AS DateTime), 8, N'Garfield', N'123', CAST(N'2020-04-03T07:31:04.520' AS DateTime))
INSERT [flat].[InstructorsOffices] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned]) VALUES (34, N'Van Houten', N'Roger', CAST(N'2000-12-07T00:00:00.000' AS DateTime), 9, N'Roosevelt', N'45', CAST(N'2020-04-03T07:31:04.520' AS DateTime))
GO
INSERT [flat].[InstructorsOfficesCourses] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned], [CourseId], [Title], [Credits], [DepartmentId]) VALUES (1, N'Abercrombie', N'Kim', CAST(N'1995-03-11T00:00:00.000' AS DateTime), 1, N'Washington', N'103', CAST(N'2020-04-03T07:31:04.520' AS DateTime), 1050, N'Chemistry', 4, 1)
INSERT [flat].[InstructorsOfficesCourses] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned], [CourseId], [Title], [Credits], [DepartmentId]) VALUES (1, N'Abercrombie', N'Kim', CAST(N'1995-03-11T00:00:00.000' AS DateTime), 1, N'Washington', N'103', CAST(N'2020-04-03T07:31:04.520' AS DateTime), 1061, N'Physics', 4, 1)
INSERT [flat].[InstructorsOfficesCourses] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned], [CourseId], [Title], [Credits], [DepartmentId]) VALUES (4, N'Fakhouri', N'Fadi', CAST(N'2002-08-06T00:00:00.000' AS DateTime), 2, N'Adams', N'908', CAST(N'2020-03-03T07:31:04.520' AS DateTime), 2030, N'Poetry', 2, 2)
INSERT [flat].[InstructorsOfficesCourses] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned], [CourseId], [Title], [Credits], [DepartmentId]) VALUES (5, N'Harui', N'Roger', CAST(N'1998-07-01T00:00:00.000' AS DateTime), 3, N'Williams', N'8', CAST(N'2020-02-10T07:31:04.520' AS DateTime), 1045, N'Calculus', 4, 7)
INSERT [flat].[InstructorsOfficesCourses] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned], [CourseId], [Title], [Credits], [DepartmentId]) VALUES (18, N'Zheng', N'Roger', CAST(N'2004-02-12T00:00:00.000' AS DateTime), 4, N'Monroe', N'34', CAST(N'2020-04-03T07:31:04.520' AS DateTime), 4022, N'Microeconomics', 3, 4)
INSERT [flat].[InstructorsOfficesCourses] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned], [CourseId], [Title], [Credits], [DepartmentId]) VALUES (25, N'Kapoor', N'Candace', CAST(N'2001-01-15T00:00:00.000' AS DateTime), 5, N'Jackson', N'23', CAST(N'2020-01-03T07:31:04.520' AS DateTime), 2042, N'Literature', 4, 2)
INSERT [flat].[InstructorsOfficesCourses] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned], [CourseId], [Title], [Credits], [DepartmentId]) VALUES (27, N'Serrano', N'Stacy', CAST(N'1999-06-01T00:00:00.000' AS DateTime), 6, N'Van Buren', N'56', CAST(N'2020-01-16T07:31:04.520' AS DateTime), 2021, N'Composition', 3, 2)
INSERT [flat].[InstructorsOfficesCourses] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned], [CourseId], [Title], [Credits], [DepartmentId]) VALUES (31, N'Stewart', N'Jasmine', CAST(N'1997-10-12T00:00:00.000' AS DateTime), 7, N'Grant', N'21', CAST(N'2020-04-03T07:31:04.520' AS DateTime), 1061, N'Physics', 4, 1)
INSERT [flat].[InstructorsOfficesCourses] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned], [CourseId], [Title], [Credits], [DepartmentId]) VALUES (32, N'Xu', N'Kristen', CAST(N'2001-07-23T00:00:00.000' AS DateTime), 8, N'Garfield', N'123', CAST(N'2020-04-03T07:31:04.520' AS DateTime), 2021, N'Composition', 3, 2)
INSERT [flat].[InstructorsOfficesCourses] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned], [CourseId], [Title], [Credits], [DepartmentId]) VALUES (32, N'Xu', N'Kristen', CAST(N'2001-07-23T00:00:00.000' AS DateTime), 8, N'Garfield', N'123', CAST(N'2020-04-03T07:31:04.520' AS DateTime), 4041, N'Macroeconomics', 3, 4)
INSERT [flat].[InstructorsOfficesCourses] ([PersonId], [LastName], [FirstName], [HireDate], [Id], [Name], [Number], [DateAssigned], [CourseId], [Title], [Credits], [DepartmentId]) VALUES (34, N'Van Houten', N'Roger', CAST(N'2000-12-07T00:00:00.000' AS DateTime), 9, N'Roosevelt', N'45', CAST(N'2020-04-03T07:31:04.520' AS DateTime), 4061, N'Quantitative', 2, 4)
GO
ALTER TABLE [dbo].[AbstractValues] ADD  CONSTRAINT [DF_AbstractValues_someValue]  DEFAULT ((0)) FOR [someValue]
GO
ALTER TABLE [dbo].[Cars] ADD  CONSTRAINT [DF_Cars_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Cars] ADD  CONSTRAINT [DF_Cars_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[ContactInformation] ADD  CONSTRAINT [DF_ContactInformation_EntityId]  DEFAULT ((0)) FOR [EntityId]
GO
ALTER TABLE [dbo].[ContactInformation] ADD  CONSTRAINT [DF_ContactInformation_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[ContactInformation] ADD  CONSTRAINT [DF_ContactInformation_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[Events] ADD  CONSTRAINT [DF_Events_StatusId]  DEFAULT (N'Active') FOR [StatusId]
GO
ALTER TABLE [dbo].[Events] ADD  CONSTRAINT [DF_Events_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Events] ADD  CONSTRAINT [DF_Events_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[Events] ADD  CONSTRAINT [DF_Events_DateStart]  DEFAULT (getutcdate()) FOR [DateStart]
GO
ALTER TABLE [dbo].[Events] ADD  CONSTRAINT [DF_Events_DateEnd]  DEFAULT (getutcdate()) FOR [DateEnd]
GO
ALTER TABLE [dbo].[Events] ADD  CONSTRAINT [DF_Table_1_latitude]  DEFAULT ((0)) FOR [Latitude]
GO
ALTER TABLE [dbo].[Events] ADD  CONSTRAINT [DF_Table_1_longitude]  DEFAULT ((0)) FOR [Longitude]
GO
ALTER TABLE [dbo].[Features] ADD  CONSTRAINT [DF_Features_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Features] ADD  CONSTRAINT [DF_Features_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[Friends] ADD  CONSTRAINT [DF_Friends_DateAdded]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Friends] ADD  CONSTRAINT [DF_Friends_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[FriendsV2] ADD  CONSTRAINT [DF_FriendsV2_DateAdded]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[FriendsV2] ADD  CONSTRAINT [DF_FriendsV2_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[FriendsV2] ADD  CONSTRAINT [DF_FriendsV2_EntityTypeId]  DEFAULT ((0)) FOR [EntityTypeId]
GO
ALTER TABLE [dbo].[Images] ADD  CONSTRAINT [DF_Images_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Images] ADD  CONSTRAINT [DF_Images_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[Images] ADD  CONSTRAINT [DF_Images_EntityId]  DEFAULT ((0)) FOR [EntityId]
GO
ALTER TABLE [dbo].[Jobs] ADD  CONSTRAINT [DF_Jobs_EntityTypeId]  DEFAULT ((0)) FOR [EntityTypeId]
GO
ALTER TABLE [dbo].[Jobs] ADD  CONSTRAINT [DF_Jobs_StatusId]  DEFAULT (N'Active') FOR [StatusId]
GO
ALTER TABLE [dbo].[Jobs] ADD  CONSTRAINT [DF_Jobs_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Jobs] ADD  CONSTRAINT [DF_Jobs_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[Jobs] ADD  CONSTRAINT [DF_Jobs_Site]  DEFAULT ((0)) FOR [Site]
GO
ALTER TABLE [dbo].[Manufacturers] ADD  CONSTRAINT [DF_Manufacturers_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Manufacturers] ADD  CONSTRAINT [DF_Manufacturers_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[People] ADD  CONSTRAINT [DF_People_Age]  DEFAULT ((0)) FOR [Age]
GO
ALTER TABLE [dbo].[People] ADD  CONSTRAINT [DF_People_DateAdded]  DEFAULT (getutcdate()) FOR [DateAdded]
GO
ALTER TABLE [dbo].[People] ADD  CONSTRAINT [DF_People_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[Skills] ADD  CONSTRAINT [DF_Starter_DateAdded]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Skills] ADD  CONSTRAINT [DF_Starter_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[Tags] ADD  CONSTRAINT [DF_Tags_EntityId]  DEFAULT ((0)) FOR [EntityId]
GO
ALTER TABLE [dbo].[Tags] ADD  CONSTRAINT [DF_Tags_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Tags] ADD  CONSTRAINT [DF_Tags_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[TechCompanies] ADD  CONSTRAINT [DF_@TableName_DateAdded]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[TechCompanies] ADD  CONSTRAINT [DF_@TableName_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[TechCompanies] ADD  CONSTRAINT [DF_TechCompanies_StatusId]  DEFAULT (N'Active') FOR [StatusId]
GO
ALTER TABLE [dbo].[Urls] ADD  CONSTRAINT [DF_Urls_EntityId]  DEFAULT ((0)) FOR [EntityId]
GO
ALTER TABLE [dbo].[Urls] ADD  CONSTRAINT [DF_Urls_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Urls] ADD  CONSTRAINT [DF_Urls_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_Roles]  DEFAULT ('user') FOR [Roles]
GO
ALTER TABLE [dbo].[Cars]  WITH NOCHECK ADD  CONSTRAINT [FK_Cars_Manufacturers] FOREIGN KEY([ManufacturerId])
REFERENCES [dbo].[Manufacturers] ([Id])
GO
ALTER TABLE [dbo].[Cars] NOCHECK CONSTRAINT [FK_Cars_Manufacturers]
GO
ALTER TABLE [dbo].[CarsFeatures]  WITH NOCHECK ADD  CONSTRAINT [FK_CarsFeatures_Cars] FOREIGN KEY([CarId])
REFERENCES [dbo].[Cars] ([Id])
GO
ALTER TABLE [dbo].[CarsFeatures] NOCHECK CONSTRAINT [FK_CarsFeatures_Cars]
GO
ALTER TABLE [dbo].[CarsFeatures]  WITH NOCHECK ADD  CONSTRAINT [FK_CarsFeatures_Features] FOREIGN KEY([FeatureId])
REFERENCES [dbo].[Features] ([Id])
GO
ALTER TABLE [dbo].[CarsFeatures] NOCHECK CONSTRAINT [FK_CarsFeatures_Features]
GO
ALTER TABLE [dbo].[Courses]  WITH NOCHECK ADD  CONSTRAINT [FK_Courses_SeasonTerms] FOREIGN KEY([SeasonTermId])
REFERENCES [dbo].[SeasonTerms] ([Id])
GO
ALTER TABLE [dbo].[Courses] NOCHECK CONSTRAINT [FK_Courses_SeasonTerms]
GO
ALTER TABLE [dbo].[Courses]  WITH NOCHECK ADD  CONSTRAINT [FK_Courses_Teachers] FOREIGN KEY([TeacherId])
REFERENCES [dbo].[Teachers] ([Id])
GO
ALTER TABLE [dbo].[Courses] NOCHECK CONSTRAINT [FK_Courses_Teachers]
GO
ALTER TABLE [dbo].[FriendSkills]  WITH NOCHECK ADD  CONSTRAINT [FK_FriendSkills_FriendsV2] FOREIGN KEY([FriendId])
REFERENCES [dbo].[FriendsV2] ([Id])
GO
ALTER TABLE [dbo].[FriendSkills] NOCHECK CONSTRAINT [FK_FriendSkills_FriendsV2]
GO
ALTER TABLE [dbo].[FriendSkills]  WITH NOCHECK ADD  CONSTRAINT [FK_FriendSkills_Skills] FOREIGN KEY([SkillId])
REFERENCES [dbo].[Skills] ([Id])
GO
ALTER TABLE [dbo].[FriendSkills] NOCHECK CONSTRAINT [FK_FriendSkills_Skills]
GO
ALTER TABLE [dbo].[FriendsV2]  WITH NOCHECK ADD  CONSTRAINT [FK_FriendsV2_Images1] FOREIGN KEY([PrimaryImageId])
REFERENCES [dbo].[Images] ([Id])
GO
ALTER TABLE [dbo].[FriendsV2] NOCHECK CONSTRAINT [FK_FriendsV2_Images1]
GO
ALTER TABLE [dbo].[PetImages]  WITH NOCHECK ADD  CONSTRAINT [FK_PetImages_Pets1] FOREIGN KEY([PetId])
REFERENCES [dbo].[Pets] ([Id])
GO
ALTER TABLE [dbo].[PetImages] NOCHECK CONSTRAINT [FK_PetImages_Pets1]
GO
ALTER TABLE [dbo].[StudentCourses]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCourses_Courses] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses] ([Id])
GO
ALTER TABLE [dbo].[StudentCourses] NOCHECK CONSTRAINT [FK_StudentCourses_Courses]
GO
ALTER TABLE [dbo].[StudentCourses]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCourses_Students] FOREIGN KEY([StudentId])
REFERENCES [dbo].[Students] ([Id])
GO
ALTER TABLE [dbo].[StudentCourses] NOCHECK CONSTRAINT [FK_StudentCourses_Students]
GO
/****** Object:  StoredProcedure [dbo].[Cars_Delete]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Cars_Delete]
					@Id int

/*
--test code
DECLARE				@Id int =9

select * from [Cars] where id = @id

exec dbo.Cars_Delete @Id

select * from [Cars] where id = @id

--end test code
*/

as


BEGIN


DELETE		c
FROM		Cars c
WHERE		Id = @Id

END
GO
/****** Object:  StoredProcedure [dbo].[Cars_Insert]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Cars_Insert]
					@Make nvarchar(50)
					,@Model nvarchar(50)
					,@Year int
					,@IsUsed bit
					,@ManufacturerId int
					,@Id int OUTPUT

/*
--test code
DECLARE				@Make nvarchar(50) = 'Chevrolet'
					,@Model nvarchar(50) = 'Tahoe'
					,@Year int = 2022
					,@IsUsed bit = 0
					,@ManufacturerId int = 4
					,@Id int =0

exec dbo.Cars_Insert @Make
					,@Model
					,@Year 
					,@IsUsed 
					,@ManufacturerId 
					,@Id OUTPUT

select * from [Cars] where id = @id

--end test code
*/

as


BEGIN

INSERT INTO [Cars]
					(Make
					,Model
					,[Year]
					,IsUsed
					,ManufacturerId)
		VALUES
					(@Make
					,@Model
					,@Year
					,@IsUsed
					,@ManufacturerId)

SET @Id = SCOPE_IDENTITY()

END
GO
/****** Object:  StoredProcedure [dbo].[Cars_SelectAll]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Cars_SelectAll]

/*
--test code

exec dbo.Cars_SelectAll
--end test code
*/

as


BEGIN

SELECT	[Id]
		,[Make]
		,[Model]
		,[Year]
		,[IsUsed]
		,[DateCreated]
		,[DateModified]
FROM dbo.Cars

END
GO
/****** Object:  StoredProcedure [dbo].[Cars_SelectById]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Cars_SelectById]
						@Id int
/*
--test code
declare @Id int = 7
exec dbo.Cars_SelectById @Id
--end test code
*/

as


BEGIN

SELECT	[Id]
		,[Make]
		,[Model]
		,[Year]
		,[IsUsed]
		,[DateCreated]
		,[DateModified]
FROM dbo.Cars
WHERE Id=@Id

END
GO
/****** Object:  StoredProcedure [dbo].[Cars_SelectByIdV2]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Cars_SelectByIdV2]
					@Id int

/*
--test code
DECLARE				@Id int = 1

exec dbo.Cars_SelectByIdV2 @Id


--end test code
*/

as


BEGIN

SELECT		c.Id
			,m.Name as Make
			,m.Country
			,c.Model
			,c.Year
			,c.IsUsed
			,(SELECT	f.Id
					,f.name 
					FROM Features f
					inner join CarsFeatures cf
					on f.Id = cf.FeatureId
					where cf.CarId = c.Id 
					FOR JSON AUTO) Features
			,c.DateCreated
			,c.DateModified
FROM		Manufacturers m 
INNER JOIN	Cars c
ON			m.Id = c.ManufacturerId
INNER JOIN  CarsFeatures cf1
ON			c.id = cf1.CarId
INNER JOIN  Features f1
ON			cf1.FeatureId = f1.Id
WHERE		c.Id = @Id


END
GO
/****** Object:  StoredProcedure [dbo].[Cars_SelectByMake]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Cars_SelectByMake]
						@Make nvarchar(50)

/*
--test code
declare @Make nvarchar(50) = 'nissan'
exec dbo.Cars_SelectByMake @Make
--end test code
*/

as


BEGIN

SELECT	[Id]
		,[Make]
		,[Model]
		,[DateCreated]
		,[DateModified]
FROM dbo.Cars
WHERE Make=@Make

END
GO
/****** Object:  StoredProcedure [dbo].[Cars_SelectByManufacturerId]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Cars_SelectByManufacturerId]
					@ManufacturerId int

/*
--test code
DECLARE				@Id int =2

exec dbo.Cars_SelectByManufacturerId @Id

select * from [Cars] where id = @id

--end test code
*/

as


BEGIN

SELECT		m.Id
			,m.Name as Make
			,m.Country
			,c.Model
			,c.Year
			,c.IsUsed
			,c.dateCreated
			,c.DateModified
FROM		Manufacturers m 
INNER JOIN	Cars c
ON			m.Id = c.ManufacturerId
WHERE		m.Id = @ManufacturerId


END
GO
/****** Object:  StoredProcedure [dbo].[Cars_SelectByUsedStatus]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Cars_SelectByUsedStatus]
					@IsUsed bit

/*
--test code
DECLARE				@IsUsed bit = 0

exec dbo.Cars_SelectByUsedStatus @IsUsed

select * from [Cars] where id = @id

--end test code
*/

as


BEGIN

SELECT		m.Id
			,m.Name as Make
			,m.Country
			,c.Model
			,c.Year
			,c.IsUsed
			,c.dateCreated
			,c.DateModified
FROM		Manufacturers m 
INNER JOIN	Cars c
ON			m.Id = c.ManufacturerId
WHERE		c.IsUsed = @IsUsed


END
GO
/****** Object:  StoredProcedure [dbo].[Cars_SelectByYear]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Cars_SelectByYear]
						@Year int

/*
--test code
declare @Year int = 2023
exec dbo.Cars_SelectByYear @Year
--end test code
*/

as


BEGIN

SELECT	[Id]
		,[Make]
		,[Year]
		,[DateCreated]
		,[DateModified]
FROM dbo.Cars
WHERE [Year]=@Year

END
GO
/****** Object:  StoredProcedure [dbo].[Cars_Update]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Cars_Update]
					@Make nvarchar(50)
					,@Model nvarchar(50)
					,@Year int
					,@Id int

/*
--test code
DECLARE				@Make nvarchar(50) = 'Chevy'
					,@Model nvarchar(50) = 'Tahoe LTD'
					,@Year int = 2023
					,@Id int =9

select * from [Cars] where id = @id

exec dbo.Cars_Update @Make
					,@Model
					,@Year 
					,@Id

select * from [Cars] where id = @id

--end test code
*/

as


BEGIN

DECLARE @DateModified datetime2(7) = GETUTCDATE()

UPDATE		[Cars]
SET			Make = @Make
			,Model = @Model
			,[Year] = @Year
			,DateModified = @DateModified
WHERE		Id = @Id

END
GO
/****** Object:  StoredProcedure [dbo].[Cars_UpdateUsedStatus]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Cars_UpdateUsedStatus]
					@Id int

/*
--test code
DECLARE				@Id int =9

select * from [Cars] where id = @id

exec dbo.Cars_UpdateUsedStatus @Id

select * from [Cars] where id = @id

--end test code
*/

as


BEGIN

DECLARE @DateModified datetime2(7) = GETUTCDATE()

UPDATE		[Cars]
SET			IsUsed = 1
			,DateModified = @DateModified
WHERE		Id = @Id

END
GO
/****** Object:  StoredProcedure [dbo].[cleanOrphans]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[cleanOrphans]

as

begin

delete f from friendsv2 f where
f.Title LIKE '%Sabio%'

delete im 
from images im
left outer join FriendsV2 f
on im.Id = f.PrimaryImageId
where f.id is null

delete fs
from friendskills fs
left outer join friendsv2 f
on fs.friendid = f.id
where f.id is null

delete sk 
from skills sk
left outer join friendskills fs
on sk.id = fs.skillid
where fs.skillid is null

delete f 
from friendsv2 f
left outer join friendskills fs
on f.id = fs.friendid
left outer join images im
on f.primaryimageid = im.id
where im.id is null
and fs.friendid is null

end


/*

execute cleanOrphans



delete orphaned images

delete im from images im
left outer join FriendsV2 f
on im.Id = f.PrimaryImageId
where f.id is null

*/

/*

delete orphaned skills

delete sk from skills sk
left outer join friendskills fs
on sk.id = fs.skillid
where fs.skillid is null


*/
/*

delete orphaned friends

delete f from friendsv2 f
left outer join friendskills fs
on f.id = fs.friendid
left outer join images im
on f.primaryimageid = im.id
where im.id is null
and fs.id is null




select * 
from friendskills fs
left outer join skills sk
on fs.skillid = sk.id
where sk.id is null



*/

GO
/****** Object:  StoredProcedure [dbo].[Concerts_Delete]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROC [dbo].[Concerts_Delete]
									@Id int			
	AS

	BEGIN

		DELETE FROM [dbo].[Concerts]
		 WHERE Id = @Id

    END
GO
/****** Object:  StoredProcedure [dbo].[Concerts_Insert]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

			CREATE PROC [dbo].[Concerts_Insert]
										@Name nvarchar(500)
										,@Description nvarchar(500)
										,@IsFree bit
										,@Address nvarchar(500)
										,@Cost int
										,@DateOfEvent datetime2(7)
										,@Id int OUTPUT

			AS

			BEGIN

				INSERT INTO [dbo].[Concerts]
						([Name]
						,[Description]
						,[IsFree]
						,[Address]
						,[Cost]
						,[DateOfEvent])
				VALUES (@Name, @Description, @IsFree, @Address, @Cost, @DateOfEvent)
				SET @Id = SCOPE_IDENTITY()

			END
		
GO
/****** Object:  StoredProcedure [dbo].[Concerts_SelectAll]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROC [dbo].[Concerts_SelectAll]

	AS

	BEGIN

			SELECT [Id]
				,[Name]
				,[Description]
				,[IsFree]
				,[Address]
				,[Cost]
				,[DateOfEvent]
			FROM [dbo].[Concerts]
	END
GO
/****** Object:  StoredProcedure [dbo].[Concerts_SelectById]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

			CREATE PROC [dbo].[Concerts_SelectById]
												@Id int

			AS

			BEGIN

				SELECT [Id]
					  ,[Name]
					  ,[Description]
					  ,[IsFree]
					  ,[Address]
					  ,[Cost]
					  ,[DateOfEvent]
				  FROM [dbo].[Concerts]
				WHERE Id = @Id
			END
		
GO
/****** Object:  StoredProcedure [dbo].[Concerts_Update]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROC [dbo].[Concerts_Update]
									@Name nvarchar(500)
									,@Description nvarchar(500)
									,@IsFree bit
									,@Address nvarchar(500)
									,@Cost int
									,@DateOfEvent datetime2(7)
									,@Id int			
	AS

	BEGIN

		UPDATE [dbo].[Concerts]
		   SET [Name] = @Name
			  ,[Description] = @Description
			  ,[IsFree] = @IsFree
			  ,[Address] = @Address
			  ,[Cost] = @Cost
			  ,[DateOfEvent] = @DateOfEvent
		 WHERE Id = @Id

	END
GO
/****** Object:  StoredProcedure [dbo].[Courses_Insert]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

			CREATE PROC [dbo].[Courses_Insert]
										@Name nvarchar(200)
										,@Description nvarchar(200)
										,@SeasonTermId int
										,@TeacherId int
										,@Id int OUTPUT

/*
declare @Id int = 0
execute Courses_Insert "Test","Test Descr",1,1,@Id OUTPUT

*/


			AS

			BEGIN

				INSERT INTO [dbo].[Courses]
						([Name]
						,[Description]
						,[SeasonTermId]
						,[TeacherId])
				VALUES (@Name, 
						@Description, 
						@SeasonTermId, 
						@TeacherId)
				SET @Id = SCOPE_IDENTITY()

			END
		
GO
/****** Object:  StoredProcedure [dbo].[Courses_Pagination]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Courses_Pagination]  @PageIndex int 
                                  ,@PageSize int 




/*

---test code
Declare @PageIndex int = 0, 
		@PageSize int = 5

execute dbo.Courses_Pagination @PageIndex  
                                     ,@PageSize 


---test code end

*/
as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex
SELECT	c.[Id]
		,c.[Name]
		,c.[Description]
		,st.term SeasonTerm
		,t.[name] Teacher
		,(SELECT stu.Id
					,stu.Name 
		FROM dbo.students stu
		inner join dbo.studentcourses sc
		on stu.Id = sc.studentid
		where sc.courseid = c.id 
		FOR JSON AUTO) Students
		,(SELECT COUNT(*) FROM dbo.Courses c1
inner join seasonterms st1
on c1.SeasonTermId = st1.id
inner join teachers t1
on c1.teacherid = t1.id) TotalCount
FROM dbo.Courses c
inner join seasonterms st
on c.SeasonTermId = st.id
inner join teachers t
on c.teacherid = t.id

  ORDER BY c.Id

  OFFSET @OffSet Rows
  Fetch Next @PageSize Rows ONLY



END


GO
/****** Object:  StoredProcedure [dbo].[Courses_SelectById]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Courses_SelectById]
						@Id int
/*
--test code
declare @Id int = 4
exec Courses_SelectById @Id
--end test code
*/

as


BEGIN

SELECT	c.[Id]
		,c.[Name]
		,c.[Description]
		,st.term SeasonTerm
		,t.[name] Teacher
		,(SELECT stu.Id
					,stu.Name 
		FROM dbo.students stu
		inner join dbo.studentcourses sc
		on stu.Id = sc.studentid
		where sc.courseid = @Id 
		FOR JSON AUTO) Students
FROM dbo.Courses c
inner join seasonterms st
on c.SeasonTermId = st.id
inner join teachers t
on c.teacherid = t.id
WHERE c.Id=@Id

END
GO
/****** Object:  StoredProcedure [dbo].[Courses_update]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

			CREATE PROC [dbo].[Courses_update]
										@Name nvarchar(200)
										,@Description nvarchar(200)
										,@SeasonTermId int
										,@TeacherId int
										,@Id int

/*
declare @Id int = 0
execute Courses_update "Test MOD","Test MOD2",4,4,21

*/


			AS

			BEGIN

				
				UPDATE [dbo].[Courses]
				SET	Name = @Name
					,Description = @Description
					,SeasonTermId = @SeasonTermId
					,TeacherId = @TeacherId
				WHERE Id = @Id


			END
		
GO
/****** Object:  StoredProcedure [dbo].[Events_Feeds]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Events_Feeds]

/*
--test code

exec dbo.Events_Feeds

--end test code
*/


as



BEGIN

SELECT
	id
	,[description]
	,[name]
	,summary
	,headline
	,slug
	,statusId
	,dateStart
	,dateEnd
	,latitude
	,longitude
	,zipCode
	,[address]
	,metaData = JSON_QUERY((select dateStart
						,dateEnd
						,[location]=JSON_QUERY((select ev2.latitude
											,ev2.longitude
											,ev2.zipCode
											,ev2.[address]
									From [events] ev2
									where ev2.id = [events].id 
									for JSON Path,  WITHOUT_ARRAY_WRAPPER))
				From [events] ev1
				where ev1.id = [events].id
				for JSON Path, WITHOUT_ARRAY_WRAPPER))

FROM [Events]

END
GO
/****** Object:  StoredProcedure [dbo].[Events_FeedsV2]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Events_FeedsV2]
								@PageIndex int 
                                  ,@PageSize int
/*
--test code

exec dbo.Events_FeedsV2

--end test code
*/


as



BEGIN

Declare @OffSet int = @PageSize * @PageIndex

SELECT
	id
	,[name]
	,[description]
	,summary
	,headline
	,slug
	,statusId
	,dateStart
	,dateEnd
	,latitude
	,longitude
	,zipCode
	,[address]
	,(select COUNT(*)
		from dbo.events) as TotalCount
FROM [Events]
  ORDER BY dateStart

  OFFSET @OffSet Rows
  Fetch Next @PageSize Rows ONLY

END
GO
/****** Object:  StoredProcedure [dbo].[Events_Insert]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Events_Insert]
					@description nvarchar(700)
					,@name nvarchar(100)
					,@summary nvarchar(256)
					,@headline nvarchar(128)
					,@slug nvarchar(50)
					,@statusId nvarchar(10)
					,@dateStart datetime2(7)
					,@dateEnd datetime2(7)
					,@latitude float
					,@longitude float
					,@zipCode nvarchar(20)
					,@address nvarchar(256)
					,@UserId int
					,@Id int OUTPUT

/*
--test code
DECLARE				@description nvarchar(700) = 'Big Event Desc 123'
					,@name nvarchar(100) = 'Big Event 123'
					,@summary nvarchar(256) = 'BE Summary'
					,@headline nvarchar(128) = 'BE Headline'
					,@slug nvarchar(50) = 'BE SLUG 1001'
					,@statusId nvarchar(10) = 'Active'
					,@dateStart datetime2(7) = '05/05/2023'
					,@dateEnd datetime2(7) = '05.09.2023'
					,@latitude float = 120.199988987
					,@longitude float = -135.5252345
					,@zipCode nvarchar(20) = '33334'
					,@address nvarchar(256) = '123 Main Street'
					,@UserId int = 4
					,@Id int =0

exec dbo.Events_Insert @description
					,@name
					,@summary
					,@headline
					,@slug
					,@statusId
					,@dateStart
					,@dateEnd
					,@latitude
					,@longitude
					,@zipCode
					,@address
					,@UserId
					,@Id OUTPUT

select * from [events] where id = @id

--end test code
*/

as


BEGIN

INSERT INTO [events]
					([description]
					,[name]
					,summary
					,headline
					,slug
					,statusId
					,dateStart
					,dateEnd
					,latitude
					,longitude
					,zipCode
					,UserId
					,[address])
		VALUES
					(@description
					,@name
					,@summary
					,@headline
					,@slug
					,@statusId
					,@dateStart
					,@dateEnd
					,@latitude
					,@longitude
					,@zipCode
					,@UserId
					,@address)

SET @Id = SCOPE_IDENTITY()

END
GO
/****** Object:  StoredProcedure [dbo].[Events_Search]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Events_Search]
							@PageIndex int 
                            ,@PageSize int 
							,@DateStart datetime2(7)
							,@DateEnd datetime2(7)
					

/*
--test code

exec dbo.Events_Search 0, 10, '04/01/2023', '06/26/2023'

--end test code
*/


as



BEGIN

Declare @OffSet int = @PageSize * @PageIndex

SELECT
	id
	,[description]
	,[name]
	,summary
	,headline
	,slug
	,statusId
	,dateStart
	,dateEnd
	,latitude
	,longitude
	,zipCode
	,[address]
	,metaData = JSON_QUERY((select dateStart
						,dateEnd
						,[location]=JSON_QUERY((select ev2.latitude
											,ev2.longitude
											,ev2.zipCode
											,ev2.[address]
									From [events] ev2
									where ev2.id = [events].id 
									for JSON Path,  WITHOUT_ARRAY_WRAPPER))
				From [events] ev1
				where ev1.id = [events].id
				for JSON Path, WITHOUT_ARRAY_WRAPPER))

FROM [Events]

WHERE ([events].DateStart > @DateStart)
AND ([events].DateStart < @DateEnd)

ORDER BY [events].id

OFFSET @OffSet Rows
Fetch Next @PageSize Rows ONLY

END
GO
/****** Object:  StoredProcedure [dbo].[Events_Update]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Events_Update]
					@description nvarchar(700)
					,@name nvarchar(100)
					,@summary nvarchar(256)
					,@headline nvarchar(128)
					,@slug nvarchar(50)
					,@statusId nvarchar(10)
					,@dateStart datetime2(7)
					,@dateEnd datetime2(7)
					,@latitude float
					,@longitude float
					,@zipCode nvarchar(20)
					,@address nvarchar(256)
					,@UserId int
					,@Id int

/*
--test code
DECLARE				@description nvarchar(700) = 'Big Event Desc 223'
					,@name nvarchar(100) = 'Big Event 223'
					,@summary nvarchar(256) = 'BE Summary 2'
					,@headline nvarchar(128) = 'BE Headline 2'
					,@slug nvarchar(50) = 'BE SLUG 2001'
					,@statusId nvarchar(10) = 'Active'
					,@dateStart datetime2(7) = '05/12/2023'
					,@dateEnd datetime2(7) = '05/29/2023'
					,@latitude float = 120.199988922
					,@longitude float = -135.5252322
					,@zipCode nvarchar(20) = '33337'
					,@address nvarchar(256) = '223 Main Street'
					,@UserId int = 4
					,@Id int = 5

exec dbo.Events_Update @description
					,@name
					,@summary
					,@headline
					,@slug
					,@statusId
					,@dateStart
					,@dateEnd
					,@latitude
					,@longitude
					,@zipCode
					,@address
					,@UserId
					,@Id

select * from [events] where id = @id

--end test code
*/

as


BEGIN

DECLARE @DateModified datetime2(7) = GETUTCDATE()

update [events]
			SET		[description] = @description
					,[name] = @name
					,summary = @summary
					,headline = @headline
					,slug = @slug
					,statusId = @statusId
					,dateStart = @dateStart
					,dateEnd = @dateEnd
					,latitude = @latitude
					,longitude = @longitude
					,zipCode = @zipCode
					,UserId = @UserId
					,[address] = @address
					,DateModified = @DateModified
		WHERE Id=@Id

END
GO
/****** Object:  StoredProcedure [dbo].[Friends_Delete]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[Friends_Delete]

				@Id int


/*



---test code
Declare @Id int = 41
select * from dbo.friends where Id=@id
execute dbo.Friends_Delete @Id
select * from dbo.friends where Id=@id
									
---test code end

*/
as

BEGIN

DELETE 
  FROM [dbo].[Friends]
  WHERE [Id] = @Id

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_DeleteV2]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Friends_DeleteV2]

				@Id int

/*
---test code
Declare @Id int = 41
select * from dbo.friends where Id=@id
execute dbo.Friends_DeleteV2 @Id
select * from dbo.friends where Id=@id
			
delete
from FriendSkills
where FriendId = @Id

---test code end

To delete the associated FriendSkill records
*/
as

BEGIN

--DELETE IMAGE
DELETE im
  FROM dbo.Images im
  inner join dbo.FriendsV2 f
  ON im.Id = f.PrimaryImageId
  WHERE f.Id = @id	

--DELETE FRIENDSV2
DELETE 
FROM dbo.FriendsV2
WHERE [Id] = @Id

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_DeleteV3]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[Friends_DeleteV3]

				@Id int


/*



---test code
Declare @Id int = 41
select * from dbo.friends where Id=@id
execute dbo.Friends_DeleteV3 @Id
select * from dbo.friends where Id=@id
			

select * from dbo.friendsv2 f
left outer join dbo.friendskills fs
on f.id = fs.friendid
left outer join dbo.skills sk
on fs.skillid = sk.id
where fs.Id IS NULL
---test code end
To delete the associated FriendSkill records
*/
as

BEGIN

--DELETE IMAGE
DELETE im
  FROM dbo.Images im
  inner join dbo.FriendsV2 f
  ON im.Id = f.PrimaryImageId
  WHERE f.Id = @id	

--DELETE FRIENDSV2
DELETE 
FROM dbo.FriendsV2
WHERE [Id] = @Id

DELETE
FROM FriendSkills
WHERE FriendId = @Id

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_Insert]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[Friends_Insert]

			@Title nvarchar(120)
           ,@Bio nvarchar(700)
           ,@Summary nvarchar(255)
           ,@Headline nvarchar(80)
           ,@Slug nvarchar(100)
           ,@StatusId int
           ,@PrimaryImageUrl nvarchar(256)
           ,@UserId int 
		   ,@Id int OUTPUT


/*
---test code
Declare 	@Title nvarchar(120) = 'Jason the Leader'
           ,@Bio nvarchar(700) = 'This is my bio'
           ,@Summary nvarchar(255) = 'My summary'
           ,@Headline nvarchar(80) = 'My headline'
           ,@Slug nvarchar(100) = 'SLUgHyHytGrF'
           ,@StatusId int = 1
           ,@PrimaryImageUrl nvarchar(256) = 'somecrazyavatar.bmp'
           ,@UserId int = 5665
		   ,@id int = 0




execute dbo.Friends_Insert @Title
           ,@Bio
           ,@Summary
           ,@Headline
           ,@Slug
           ,@StatusId
           ,@PrimaryImageUrl
           ,@UserId
		   ,@Id OUTPUT

select * from dbo.friends where Id=@Id
									
---test code end

*/
as

BEGIN

INSERT INTO [dbo].[Friends]
           ([Title]
           ,[Bio]
           ,[Summary]
           ,[Headline]
           ,[Slug]
           ,[StatusId]
           ,[PrimaryImageUrl]
		   ,[UserId])
     VALUES
           (@Title
           ,@Bio
           ,@Summary
           ,@Headline
           ,@Slug
           ,@StatusId
           ,@PrimaryImageUrl
		   ,@UserId)

SET @Id = SCOPE_IDENTITY()

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_InsertV2]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Friends_InsertV2]

			@Title nvarchar(120)
           ,@Bio nvarchar(700)
           ,@Summary nvarchar(255)
           ,@Headline nvarchar(80)
           ,@Slug nvarchar(100)
           ,@StatusId int
		   ,@ImageTypeId int
		   ,@ImageUrl nvarchar(256)
		   ,@UserId int 
		   ,@Id int OUTPUT




/*
---test code
Declare 	@Title nvarchar(120) = 'Humphrey'
           ,@Bio nvarchar(700) = 'This is my bio'
           ,@Summary nvarchar(255) = 'My summary'
           ,@Headline nvarchar(80) = 'My headline'
           ,@Slug nvarchar(100) = 'SLUgHyHytGrF'
           ,@StatusId int = 1
		   ,@ImageTypeId int = 1
           ,@ImageUrl nvarchar(256) = 'someurl.jpg'
		   ,@UserId int = 5665
		   ,@id int = 0


execute dbo.Friends_InsertV2 @Title
           ,@Bio
           ,@Summary
           ,@Headline
           ,@Slug
           ,@StatusId
		   ,@ImageTypeId
           ,@ImageUrl
		   ,@UserId
		   ,@Id OUTPUT


execute dbo.Friends_SelectAllV2
select * from Images
									
---test code end

*/
as

BEGIN

INSERT INTO [dbo].[Images]
           ([TypeId]
           ,[Url]
           ,[UserId])
     VALUES
           (@ImageTypeId
           ,@ImageUrl
           ,@UserId)

SET @Id = SCOPE_IDENTITY()

INSERT INTO [dbo].[FriendsV2]
           ([Title]
           ,[Bio]
           ,[Summary]
           ,[Headline]
           ,[Slug]
           ,[StatusId]
           ,[PrimaryImageId]
		   ,[UserId])
     VALUES
           (@Title
           ,@Bio
           ,@Summary
           ,@Headline
           ,@Slug
           ,@StatusId
           ,@Id
		   ,@UserId)

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_InsertV3]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Friends_InsertV3]

			@Title nvarchar(120)
           ,@Bio nvarchar(700)
           ,@Summary nvarchar(255)
           ,@Headline nvarchar(80)
           ,@Slug nvarchar(100)
           ,@StatusId int
		   ,@ImageTypeId int
		   ,@ImageUrl nvarchar(256)
		   ,@UserId int 
		   ,@BatchSkills dbo.BatchSkills READONLY
		   ,@Id int OUTPUT

/*
---test code
Declare 	@Title nvarchar(120) = 'Hey!!!!'
           ,@Bio nvarchar(700) = 'This is my bio'
           ,@Summary nvarchar(255) = 'My summary'
           ,@Headline nvarchar(80) = 'My headline'
           ,@Slug nvarchar(100) = 'hghghghg1234'
           ,@StatusId int = 1
		   ,@ImageTypeId int = 1
           ,@ImageUrl nvarchar(256) = 'https://upload.wikimedia.org/wikipedia/commons/a/ac/Monterey_County_Courthouse_2018_Salinas_CA_%281%29.jpg'
		   ,@UserId int = 4
		   ,@BatchSkills dbo.BatchSkills 
		   ,@id int = 0

INSERT INTO @BatchSkills
		VALUES ('six'),('sevel'),('three'),('four'),('Managing')

execute dbo.Friends_InsertV3 @Title
           ,@Bio
           ,@Summary
           ,@Headline
           ,@Slug
           ,@StatusId
		   ,@ImageTypeId
           ,@ImageUrl
		   ,@UserId
		   ,@BatchSkills
		   ,@Id OUTPUT

---test code end

--additional test code
select * from Images
select * from Skills
select * from FriendSkills

execute dbo.Friends_SelectAllV2
--additional test code end

execute cleanOrphans


*/
as

BEGIN

DECLARE @ImageId int = 0
		,@FriendId int = 0
		,@DateModified datetime2(7) = GETUTCDATE()

INSERT INTO [dbo].[Images]
           ([TypeId]
           ,[Url]
           ,[UserId])
     VALUES
           (@ImageTypeId
           ,@ImageUrl
           ,@UserId)

SET @ImageId = SCOPE_IDENTITY()

INSERT INTO [dbo].[FriendsV2]
           ([Title]
           ,[Bio]
           ,[Summary]
           ,[Headline]
           ,[Slug]
           ,[StatusId]
           ,[PrimaryImageId]
		   ,[UserId])
     VALUES
           (@Title
           ,@Bio
           ,@Summary
           ,@Headline
           ,@Slug
           ,@StatusId
           ,@ImageId
		   ,@UserId)

SET @FriendId = SCOPE_IDENTITY()

INSERT INTO dbo.skills
		(Name,
		UserId)
		select Name,
			@UserId
		from @BatchSkills bs
		where not exists	
		(select 1 from dbo.skills sk
		where sk.name = bs.name)

INSERT INTO dbo.FriendSkills
			(FriendId
			,SkillId)
	  SELECT
			@FriendId
			,sk.Id
	  FROM @BatchSkills bs
	  inner join dbo.skills sk
	  on bs.Name = sk.Name


SET @Id = @FriendId

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_Pagination]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[Friends_Pagination]  @PageIndex int 
                                  ,@PageSize int



/*

---test code
Declare @PageIndex int = 0,@PageSize int = 5
execute dbo.Friends_Pagination @PageIndex  
                                  ,@PageSize 
---test code end

*/
as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex

SELECT [Id]
      ,[Title]
      ,[Bio]
      ,[Summary]
      ,[Headline]
      ,[Slug]
      ,[StatusId]
      ,[PrimaryImageUrl]
      ,[UserId]
      ,[DateCreated]
      ,[DateModified]
	  ,TotalCount = (Select COUNT(id) 
					from friends)
  FROM [dbo].[Friends]
  ORDER BY Id

  OFFSET @OffSet Rows
  Fetch Next @PageSize Rows ONLY

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_PaginationV2]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Friends_PaginationV2]  @PageIndex int 
                                  ,@PageSize int



/*

---test code
Declare @PageIndex int = 2,@PageSize int = 3
execute dbo.Friends_PaginationV2 @PageIndex  
                                  ,@PageSize 
---test code end

*/
as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex

SELECT F.Id
      ,F.Title
      ,F.Bio
      ,F.Summary
      ,F.Headline
      ,F.Slug
      ,F.StatusId
	  ,I.Id
	  ,I.TypeId
	  ,I.Url
	  ,F.UserId
	  ,I.DateCreated
	  ,I.DateModified
	  ,(SELECT COUNT(FR.Id) TotalCount
			FROM dbo.FriendsV2 FR inner join dbo.Images IM
			ON FR.PrimaryImageId = IM.Id) TotalCount
  FROM dbo.FriendsV2 as F inner join dbo.Images as I
  ON F.PrimaryImageId = I.Id
  ORDER BY I.Id

  OFFSET @OffSet Rows
  Fetch Next @PageSize Rows ONLY

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_PaginationV3]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Friends_PaginationV3]  @PageIndex int 
                                  ,@PageSize int 




/*

---test code
Declare @PageIndex int = 0, 
		@PageSize int = 5

execute dbo.Friends_PaginationV3 @PageIndex  
                                     ,@PageSize 


---test code end

*/
as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex

SELECT f.Id
		,f.Title
		,f.Bio
		,f.Summary
		,f.Headline
		,f.Slug
		,f.StatusId
		,i.Id as ImageId
		,i.TypeId as ImageTypeId
		,i.Url as ImageUrl
		,(SELECT	sk.Name
					,sk.Id 
					FROM dbo.Skills sk
					inner join dbo.FriendSkills fs
					on sk.Id = fs.SkillId
					where fs.FriendId = f.Id 
					FOR JSON AUTO) Skills
		,f.UserId
		,i.DateCreated
		,i.DateModified
		,(Select COUNT(*) 
			  FROM dbo.FriendsV2 as f inner join dbo.Images as i
				ON f.PrimaryImageId = i.Id) TotalCount
FROM dbo.FriendsV2 as f inner join dbo.Images as i
ON f.PrimaryImageId = i.Id

  ORDER BY f.Id

  OFFSET @OffSet Rows
  Fetch Next @PageSize Rows ONLY



END


GO
/****** Object:  StoredProcedure [dbo].[Friends_Search_Pagination]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[Friends_Search_Pagination]  @PageIndex int 
                                  ,@PageSize int 
								  ,@Query nvarchar(100)



/*

---test code
Declare @PageIndex int = 1, 
		@PageSize int = 3, 
		@Query nvarchar(100) = 'friend 1'

execute dbo.Friends_Search_Pagination @PageIndex  
                                     ,@PageSize 
								     ,@Query

SELECT [Id]
      ,[Title]
      ,[Bio]
      ,[Summary]
      ,[Headline]
      ,[Slug]
      ,[StatusId]
      ,[PrimaryImageUrl]
      ,[UserId]
      ,[DateCreated]
      ,[DateModified]
  FROM [dbo].[Friends]
  ORDER BY Id

---test code end

*/
as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex

SELECT [Id]
      ,[Title]
      ,[Bio]
      ,[Summary]
      ,[Headline]
      ,[Slug]
      ,[StatusId]
      ,[PrimaryImageUrl]
      ,[UserId]
      ,[DateCreated]
      ,[DateModified]
	  ,TotalCount = (Select COUNT(id) 
					from Friends
					WHERE (Title LIKE '%' + @Query + '%'))
  FROM [dbo].[Friends]

  WHERE (Title LIKE '%' + @Query + '%')
  ORDER BY Id

  OFFSET @OffSet Rows
  Fetch Next @PageSize Rows ONLY

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_Search_PaginationV2]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Friends_Search_PaginationV2]  @PageIndex int 
                                  ,@PageSize int 
								  ,@Query nvarchar(100)



/*

---test code
Declare @PageIndex int = 1, 
		@PageSize int = 5, 
		@Query nvarchar(100) = 'friend 1'

execute dbo.Friends_Search_PaginationV2 @PageIndex  
                                     ,@PageSize 
								     ,@Query

SELECT f.Id
      ,f.Title
      ,f.Bio
      ,f.Summary
      ,f.Headline
      ,f.Slug
      ,f.StatusId
      ,f.PrimaryImageId
      ,f.DateCreated
      ,f.DateModified
  FROM dbo.FriendsV2 F
  ORDER BY f.Id



SELECT COUNT(*) 
			FROM dbo.FriendsV2 fr inner join dbo.Images im
			ON fr.PrimaryImageId = im.Id
			WHERE (fr.Title LIKE '%best%')
			  ORDER BY fr.Id
			  OFFSET 0 Rows
			  Fetch Next 10 Rows ONLY
---test code end

*/
as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex

DECLARE @TotalCount int = 0
DECLARE @ImageId int = 0
DECLARE @TempTable Table 
			(id int)

INSERT INTO @TempTable 
				(Id)
			SELECT im.Id
			FROM dbo.FriendsV2 fr inner join dbo.Images im
			ON fr.PrimaryImageId = im.Id
			WHERE (fr.Title LIKE '%' + @Query + '%')
			  ORDER BY im.Id
				OFFSET @OffSet Rows
				Fetch Next @PageSize Rows ONLY

SELECT @TotalCount = COUNT(*)
FROM @TempTable

SELECT f.Id
      ,f.Title
      ,f.Bio
      ,f.Summary
      ,f.Headline
      ,f.Slug
      ,f.StatusId
	  ,f.PrimaryImageId ImageId
	  ,i.TypeId ImageType
	  ,i.Url ImageUrl
	  ,f.UserId
	  ,i.DateCreated
	  ,i.DateModified
	  ,@TotalCount
  FROM dbo.FriendsV2 as f inner join dbo.Images as i
  ON f.PrimaryImageId = i.Id

  WHERE (f.Title LIKE '%' + @Query + '%')
  ORDER BY i.Id

  OFFSET @OffSet Rows
  Fetch Next @PageSize Rows ONLY

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_Search_PaginationV3]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Friends_Search_PaginationV3]  @PageIndex int 
                                  ,@PageSize int 
								  ,@Query nvarchar(100)

/*

---test code
Declare @PageIndex int = 0, 
		@PageSize int = 5, 
		@Query nvarchar(100) = 'b'

execute dbo.Friends_Search_PaginationV3 @PageIndex  
                                     ,@PageSize 
								     ,@Query

SELECT F.Id
      ,F.Title
      ,F.Bio
      ,F.Summary
      ,F.Headline
      ,F.Slug
      ,F.StatusId
      ,F.PrimaryImageId
      ,F.DateCreated
      ,F.DateModified
  FROM dbo.FriendsV2 F
  ORDER BY F.Id

---test code end
*/
as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex

SELECT f.Id
		,f.Title
		,f.Bio
		,f.Summary
		,f.Headline
		,f.Slug
		,f.StatusId
		,i.Id as ImageId
		,i.TypeId as ImageTypeId
		,i.Url as ImageUrl
		,(SELECT	sk.Name
					,sk.Id 
					FROM dbo.Skills sk
					inner join dbo.FriendSkills fs
					on sk.Id = fs.SkillId
					where fs.FriendId = f.Id 
					FOR JSON AUTO) Skills
		,f.UserId
		,i.DateCreated
		,i.DateModified
		,(Select COUNT(*) 
			  FROM dbo.FriendsV2 as f inner join dbo.Images as i
				ON f.PrimaryImageId = i.Id
				WHERE (f.Title LIKE '%' + @Query + '%')) TotalCount
FROM dbo.FriendsV2 as f inner join dbo.Images as i
ON f.PrimaryImageId = i.Id
  WHERE (f.Title LIKE '%' + @Query + '%')

  ORDER BY f.Id

  OFFSET @OffSet Rows
  Fetch Next @PageSize Rows ONLY

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_SearchPaginationV3]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Friends_SearchPaginationV3]  @PageIndex int 
                                  ,@PageSize int 
								  ,@Query nvarchar(100)



/*

---test code
Declare @PageIndex int = 0, 
		@PageSize int = 5, 
		@Query nvarchar(100) = 'b'

execute dbo.Friends_SearchPaginationV3 @PageIndex  
                                     ,@PageSize 
								     ,@Query

SELECT F.Id
      ,F.Title
      ,F.Bio
      ,F.Summary
      ,F.Headline
      ,F.Slug
      ,F.StatusId
      ,F.PrimaryImageId
      ,F.DateCreated
      ,F.DateModified
  FROM dbo.FriendsV2 F
  ORDER BY F.Id

---test code end

*/
as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex

SELECT sk.Id
	  ,sk.Name
  FROM dbo.Skills as sk inner join dbo.FriendSkills as fs
  ON sk.Id = fs.SkillId
  inner join dbo.FriendsV2 f
  ON fs.FriendId = f.Id

  WHERE (f.Title LIKE '%' + @Query + '%')
  ORDER BY f.Id

  OFFSET @OffSet Rows
  Fetch Next @PageSize Rows ONLY

  FOR JSON AUTO

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_SelectAll]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[Friends_SelectAll]


/*

---test code
execute dbo.Friends_SelectAll
---test code end

*/
as

BEGIN

SELECT [Id]
      ,[Title]
      ,[Bio]
      ,[Summary]
      ,[Headline]
      ,[Slug]
      ,[StatusId]
      ,[PrimaryImageUrl]
      ,[UserId]
      ,[DateCreated]
      ,[DateModified]
  FROM [dbo].[Friends]

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_SelectAllV2]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Friends_SelectAllV2]


/*

---test code
execute dbo.Friends_SelectAllV2
---test code end

*/
as

BEGIN

SELECT F.Id
      ,F.Title
      ,F.Bio
      ,F.Summary
      ,F.Headline
      ,F.Slug
      ,F.StatusId
      ,F.PrimaryImageId
	  ,F.UserId
      ,F.DateCreated
      ,F.DateModified
	  ,I.Id
	  ,I.TypeId
	  ,I.UserId
	  ,I.DateCreated
	  ,I.DateModified
  FROM dbo.FriendsV2 as F inner join dbo.Images as I
  ON F.PrimaryImageId = I.Id

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_SelectAllV3]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[Friends_SelectAllV3]  





/*

---test code


execute dbo.Friends_SelectAllV3


---test code end

*/
as

BEGIN

SELECT	f.Id
		,f.Title
		,f.Bio
		,f.Summary
		,f.Headline
		,f.Slug
		,f.StatusId
		,i.Id ImageId
		,i.TypeId ImageTypeId
		,i.Url ImageUrl
		,(SELECT	sk.Id
					,sk.Name 
		FROM dbo.Skills sk
		inner join dbo.FriendSkills fs
		on sk.Id = fs.SkillId
		where fs.FriendId = f.Id 
		FOR JSON AUTO) Skills
		,f.UserId
		,i.DateCreated
		,i.DateModified
  FROM dbo.FriendsV2 as f inner join dbo.Images as i
  ON f.PrimaryImageId = i.Id 

  --ORDER BY f.Id


END


GO
/****** Object:  StoredProcedure [dbo].[Friends_SelectById]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[Friends_SelectById]

				@Id int


/*

Declare @Id int = 40

---test code

execute dbo.Friends_SelectById @Id
									
---test code end

*/
as

BEGIN

SELECT [Id]
      ,[Title]
      ,[Bio]
      ,[Summary]
      ,[Headline]
      ,[Slug]
      ,[StatusId]
      ,[PrimaryImageUrl]
      ,[UserId]
      ,[DateCreated]
      ,[DateModified]
  FROM [dbo].[Friends]
  WHERE [Id] = @Id

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_SelectByIdV2]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Friends_SelectByIdV2]

				@Id int


/*


---test code
Declare @Id int = 20

execute dbo.Friends_SelectByIdV2 @Id
									
---test code end

select * from dbo.FriendsV2

select * from dbo.FriendsV2


//this was expecting the userid from friends, not images


*/
as

BEGIN

SELECT F.Id
      ,F.Title
      ,F.Bio
      ,F.Summary
      ,F.Headline
      ,F.Slug
      ,F.StatusId
	  ,I.Id ImageId
	  ,I.TypeId ImageTypeId
	  ,I.Url ImageUrl
	  ,F.UserId 
	  ,I.DateCreated
	  ,I.DateModified
  FROM dbo.FriendsV2 as f inner join dbo.Images as I
  on F.PrimaryImageId = I.Id
  WHERE F.Id = @Id

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_SelectByIdV3]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Friends_SelectByIdV3]  

							@Id int 

/*

---test code
Declare @Id int = 500

execute dbo.Friends_SelectByIdV3 @Id

---test code end
*/
as

BEGIN

SELECT	f.Id
		,f.Title
		,f.Bio
		,f.Summary
		,f.Headline
		,f.Slug
		,f.StatusId
		,i.Id ImageId
		,i.TypeId ImageTypeId
		,i.Url ImageUrl
		,(SELECT	sk.Id
					,sk.Name 
		FROM dbo.Skills sk
		inner join dbo.FriendSkills fs
		on sk.Id = fs.SkillId
		where fs.FriendId = @Id 
		FOR JSON AUTO) Skills
		,f.UserId
		,i.DateCreated
		,i.DateModified
  FROM dbo.FriendsV2 as f inner join dbo.Images as i
  ON f.PrimaryImageId = i.Id 
  where f.Id = @Id

END


GO
/****** Object:  StoredProcedure [dbo].[Friends_Update]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[Friends_Update]

			@Title nvarchar(120)
           ,@Bio nvarchar(700)
           ,@Summary nvarchar(255)
           ,@Headline nvarchar(80)
           ,@Slug nvarchar(100)
           ,@StatusId int
           ,@PrimaryImageUrl nvarchar(256)
           ,@UserId int 
		   ,@Id int


/*
---test code



Declare 	@Title nvarchar(120) = 'Jason the Leader'
           ,@Bio nvarchar(700) = 'This is my bio'
           ,@Summary nvarchar(255) = 'My summary'
           ,@Headline nvarchar(80) = 'My headline'
           ,@Slug nvarchar(100) = 'SLUgHyHytGrF'
           ,@StatusId int = 1
           ,@PrimaryImageUrl nvarchar(256) = 'somecrazyavatar.bmp'
           ,@UserId int = 4
		   ,@id int = 45

select * from dbo.friends where Id=45


execute dbo.Friends_Update @Title
           ,@Bio
           ,@Summary
           ,@Headline
           ,@Slug
           ,@StatusId
           ,@PrimaryImageUrl
           ,@UserId
		   ,@Id

select * from dbo.friends where Id=@Id
									
---test code end

*/
as

BEGIN

DECLARE @DateModified datetime2(7) = GETUTCDATE()

UPDATE [dbo].[Friends]
   SET [Title] = @Title
      ,[Bio] = @Bio
      ,[Summary] = @Summary
      ,[Headline] = @Headline
      ,[Slug] = @Slug
      ,[StatusId] = @StatusId
      ,[PrimaryImageUrl] = @PrimaryImageUrl
	  ,[UserId] = @UserId
	  ,DateModified = @DateModified
 WHERE [Id] = @Id



END


GO
/****** Object:  StoredProcedure [dbo].[Friends_UpdateV2]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[Friends_UpdateV2]

			@Title nvarchar(120)
           ,@Bio nvarchar(700)
           ,@Summary nvarchar(255)
           ,@Headline nvarchar(80)
           ,@Slug nvarchar(100)
           ,@StatusId int
		   ,@ImageTypeId int
           ,@ImageUrl nvarchar(256)
           ,@UserId int 
		   ,@Id int


/*
---test code



Declare 	@Title nvarchar(120) = 'Jason the Leader'
           ,@Bio nvarchar(700) = 'This is my bio'
           ,@Summary nvarchar(255) = 'My summary'
           ,@Headline nvarchar(80) = 'My headline'
           ,@Slug nvarchar(100) = 'SLUgHyHytGrF'
           ,@StatusId int = 1
		   ,@ImageTypeId int = 1
           ,@ImageUrl nvarchar(256) = 'dbo.Friends_UpdateV2.bmp'
           ,@UserId int = 4
		   ,@id int = 500

select * from dbo.friendsv2 where Id=@Id


execute dbo.Friends_UpdateV2 @Title
           ,@Bio
           ,@Summary
           ,@Headline
           ,@Slug
           ,@StatusId
		   ,@ImageTypeId
           ,@ImageUrl
           ,@UserId
		   ,@Id

select * from dbo.friendsv2 where Id=@Id
									
---test code end
DECLARE @ImageId int = 0

SELECT @ImageId = fr.PrimaryImageId
	FROM dbo.FriendsV2 fr
	WHERE fr.Id = @Id
*/
as

BEGIN

DECLARE @DateModified datetime2(7) = GETUTCDATE()


UPDATE fr
   SET fr.Title = @Title
      ,fr.Bio = @Bio
      ,fr.Summary = @Summary
      ,fr.Headline = @Headline
      ,fr.Slug = @Slug
      ,fr.StatusId = @StatusId
	  ,fr.UserId = @UserId
	  ,fr.DateModified = @DateModified
	FROM dbo.FriendsV2 fr
	INNER JOIN dbo.Images im
	ON fr.PrimaryImageId = im.Id
	WHERE fr.Id = @Id

Update im
	SET TypeId = @ImageTypeId
		,Url = @ImageUrl
		,UserId = @UserId
		,DateModified = @DateModified
	FROM dbo.Images im
	INNER JOIN dbo.FriendsV2 fr
	ON im.Id = fr.PrimaryImageId
	where fr.Id = @Id


END


GO
/****** Object:  StoredProcedure [dbo].[Friends_UpdateV3]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Friends_UpdateV3]

			@Title nvarchar(120)
           ,@Bio nvarchar(700)
           ,@Summary nvarchar(255)
           ,@Headline nvarchar(80)
           ,@Slug nvarchar(100)
           ,@StatusId int
		   ,@ImageTypeId int
           ,@ImageUrl nvarchar(256)
           ,@UserId int 
		   ,@BatchSkills dbo.BatchSkills READONLY
		   ,@Id int

/*
---test code
Declare 	@Title nvarchar(120) = '500 Friend'
           ,@Bio nvarchar(700) = 'This is my bio 500'
           ,@Summary nvarchar(255) = 'My summary 500'
           ,@Headline nvarchar(80) = 'My headline 500'
           ,@Slug nvarchar(100) = 'SLUgHyHytGrF500'
           ,@StatusId int = 1
		   ,@ImageTypeId int = 1
           ,@ImageUrl nvarchar(256) = 'dbo.Friends_UpdateV3.bmp'
           ,@UserId int = 4
		   ,@BatchSkills dbo.BatchSkills 
		   ,@id int = 500

INSERT INTO @BatchSkills
		VALUES ('Munchies'),('Jumping Jacks'),('Volleyball'),('Football')

select * from dbo.friendsv2 where Id=@Id

execute dbo.Friends_UpdateV3 @Title
           ,@Bio
           ,@Summary
           ,@Headline
           ,@Slug
           ,@StatusId
		   ,@ImageTypeId
           ,@ImageUrl
           ,@UserId
		   ,@BatchSkills
		   ,@Id

select * from dbo.friendsv2 where Id=500
select * from Images where Id = 38	
select * from friendskills inner join skills on friendskills.skillid = skills.id
---test code end

*/
as

BEGIN

DECLARE @DateModified datetime2(7) = GETUTCDATE()

--CREATE TEMP SKILLS TABLE
--FOR SKILLS THAT ALREADY EXIST
DECLARE @SkillsExist TABLE 
			(Id int
			,Name nvarchar(128))

--POPULATE THE TEMP SKILLS EXIST 
--TABLE WITH RECORDS THAT MATCH 
--BATCHSKILLS TABLE
INSERT INTO @SkillsExist
			(Id
			,Name)
			SELECT	sk.Id
					,sk.Name
			FROM dbo.Skills sk
			inner join @BatchSkills sn
			on sk.Name = sn.Name

--CREATE TEMP SKILLS TABLE
--FOR SKILLS THAT DONT ALREADY EXIST
DECLARE @SkillsDontExist dbo.BatchSkills

INSERT INTO @SkillsDontExist
		Select Name 
		From @BatchSkills sn
		Where Not Exists (Select 1 
							from dbo.skills sk 
							where sk.name = sn.Name)

UPDATE fr
   SET fr.Title = @Title
      ,fr.Bio = @Bio
      ,fr.Summary = @Summary
      ,fr.Headline = @Headline
      ,fr.Slug = @Slug
      ,fr.StatusId = @StatusId
	  ,fr.UserId = @UserId
	  ,fr.DateModified = @DateModified
	FROM dbo.FriendsV2 fr
	INNER JOIN dbo.Images im
	ON fr.PrimaryImageId = im.Id
	WHERE fr.Id = @Id

Update im
	SET TypeId = @ImageTypeId
		,Url = @ImageUrl
		,UserId = @UserId
		,DateModified = @DateModified
	FROM dbo.Images im
	INNER JOIN dbo.FriendsV2 fr
	ON im.Id = fr.PrimaryImageId
	where fr.Id = @Id

UPDATE sk
	SET sk.Name = se.Name
		,sk.UserId = @UserId
		,sk.DateModified = @DateModified
	FROM dbo.Skills sk
	INNER JOIN  @SkillsExist se
	ON sk.Id = se.Id

DECLARE @output TABLE (id int)
INSERT INTO dbo.Skills
			(Name	
			,UserId)
OUTPUT inserted.ID INTO @output
		SELECT 
			sde.Name
			,@UserId
		FROM
			@SkillsDontExist sde

INSERT INTO @output (id)
		Select Id from @SkillsExist

--INSERT RECORDS UNLESS THERE IS A MATCH@SkillsDontExist
--NO NEED FOR UPDATE
INSERT INTO dbo.FriendSkills
			(FriendId
			,SkillId)
	  SELECT
			@Id
			,o.Id
	  FROM @output o
	  WHERE NOT EXISTS
			(SELECT 1 
			FROM dbo.FriendSkills
			WHERE FriendId = @Id
			AND SkillId = o.id)

END


GO
/****** Object:  StoredProcedure [dbo].[Jobs_GetById]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[Jobs_GetById]
								@Id int 

/*

--test code

exec dbo.Jobs_GetById 8

--test code

insert into jobs
(Title
	,Pay
	,Summary
	,Description
	,ShortDescription
	,ShortTitle
	,CreatedBy
	,ModifiedBy
	,Slug
	,TechCompanyId)
Values
('Software Dev 8'
,'100,000.07'
,'Summary 130'
,'Description 130'
,'Short Description 130'
,'Short Title 130'
,4
,4
,'SLUG123463'
,10)


declare @techCompany table ([json] nvarchar(max)) 

insert @techCompany ([json])
exec dbo.techcompanies_selectbyid 10
	
select [json] from @techCompany



*/

as

BEGIN

	SELECT		j.description
				,j.summary
				,j.pay
				,j.title
				,j.id
				,j.shortTitle
				,j.shortDescription
				,j.content
				,j.createdBy
				,j.modifiedBy
				,j.slug
				,j.entityTypeId
				,j.statusId
				,j.dateCreated
				,j.dateModified
				,j.site
				,j.techcompanyid
				,JSON_QUERY(dbo.TechCompanies_GetById_JSON(tc.id)) as techCompany
				,skills = (Select	skills.id
									,skills.name
							from skills
							inner join jobsskills js
							on skills.id = js.skillid
							where js.jobid = j.id
							FOR JSON AUTO)
	from jobs j
	inner join TechCompanies tc
	on j.techcompanyid = tc.id

	Where j.id = @Id



END






GO
/****** Object:  StoredProcedure [dbo].[Jobs_GetByIdV2]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[Jobs_GetByIdV2]
								@Id int 

/*

--test code

exec dbo.Jobs_GetByIdV2 8

--test code

insert into jobs
(Title
	,Pay
	,Summary
	,Description
	,ShortDescription
	,ShortTitle
	,CreatedBy
	,ModifiedBy
	,Slug
	,TechCompanyId)
Values
('Software Dev 8'
,'100,000.07'
,'Summary 130'
,'Description 130'
,'Short Description 130'
,'Short Title 130'
,4
,4
,'SLUG123463'
,10)


declare @techCompany table ([json] nvarchar(max)) 

insert @techCompany ([json])
exec dbo.techcompanies_selectbyid 10
	
select [json] from @techCompany



*/

as

BEGIN

	SELECT		j.id
				,j.title
				,j.description
				,j.summary
				,j.pay
				,j.slug
				,skills = (Select	skills.id
									,skills.name
							from skills
							inner join jobsskills js
							on skills.id = js.skillid
							where js.jobid = j.id
							FOR JSON AUTO)
				,j.techcompanyid
				,j.statusId
			  ,JSON_QUERY(dbo.TechCompanies_GetById_JSON(tc.id)) as techCompany
	from jobs j
	inner join TechCompanies tc
	on j.techcompanyid = tc.id

	Where j.id = @Id



END






GO
/****** Object:  StoredProcedure [dbo].[Jobs_GetBySlug]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[Jobs_GetBySlug]
								@Slug nvarchar(50) 

/*

--test code

exec dbo.Jobs_GetBySlug 'SLUG123456'

--test code

insert into jobs
(Title
	,Pay
	,Summary
	,Description
	,ShortDescription
	,ShortTitle
	,CreatedBy
	,ModifiedBy
	,Slug
	,TechCompanyId)
Values
('Software Dev 8'
,'100,000.07'
,'Summary 130'
,'Description 130'
,'Short Description 130'
,'Short Title 130'
,4
,4
,'SLUG123463'
,10)


declare @techCompany table ([json] nvarchar(max)) 

insert @techCompany ([json])
exec dbo.techcompanies_selectbyid 10
	
select [json] from @techCompany



*/

as

BEGIN

	SELECT		j.description
				,j.summary
				,j.pay
				,j.title
				,j.id
				,j.shortTitle
				,j.shortDescription
				,j.content
				,j.createdBy
				,j.modifiedBy
				,j.slug
				,j.entityTypeId
				,j.statusId
				,j.dateCreated
				,j.dateModified
				,j.site
				,JSON_QUERY(dbo.TechCompanies_GetById_JSON(tc.id)) as techCompany
				,skills = (Select	skills.id
									,skills.name
							from skills
							inner join jobsskills js
							on skills.id = js.skillid
							where js.jobid = j.id
							FOR JSON AUTO)
	from jobs j
	inner join TechCompanies tc
	on j.techcompanyid = tc.id

	Where j.slug = @Slug


END






GO
/****** Object:  StoredProcedure [dbo].[Jobs_Insert]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Jobs_Insert]
					
						@Title nvarchar(100)
						,@Description nvarchar(500)
						,@Summary nvarchar(256)
						,@Pay nvarchar(10)
						,@Slug nvarchar(50)
						,@StatusId nvarchar(10)
						,@TechCompanyId int
						,@BatchSkills dbo.BatchSkills READONLY
						,@UserId int
						,@Id int OUTPUT

/*

--test code
declare 	@Title nvarchar(100) = 'Dog Food Tester'
			,@Description nvarchar(500) = 'Description 432'
			,@Summary nvarchar(256) = 'Summary 432'
			,@Pay nvarchar(10) = '125,000.00'
			,@Slug nvarchar(50) = 'SLUGINSERT10001'
			,@StatusId nvarchar(10) = 'Active'
			,@TechCompanyId int = 10
			,@BatchSkills dbo.BatchSkills
			,@UserId int = 4
			,@Id int = 0

INSERT INTO @BatchSkills
		VALUES ('six'),('sevel'),('ten'),('nine')

exec dbo.Jobs_Insert 	@Title 
						,@Description 
						,@Summary 
						,@Pay 
						,@Slug 
						,@StatusId 
						,@TechCompanyId 
						,@BatchSkills
						,@UserId 
						,@Id OUTPUT

exec dbo.Jobs_GetById @Id

--end test code


*/
as

BEGIN

DECLARE @JobId int = 0

insert into jobs
		(title
		,description
		,summary
		,pay
		,slug
		,statusid
		,techcompanyid
		,createdby
		,modifiedby)
	values
		(@Title
		,@Description
		,@Summary
		,@Pay
		,@Slug
		,@StatusId
		,@TechCompanyId
		,@UserId
		,@UserId)

SET @JobId = SCOPE_IDENTITY()
SET @Id = @JobId

INSERT INTO dbo.skills
		(Name,
		UserId)
		select Name,
			@UserId
		from @BatchSkills bs
		where not exists	
		(select 1 from dbo.skills sk
		where sk.name = bs.name)

INSERT INTO dbo.JobsSkills
			(JobId
			,SkillId)
	  SELECT
			@JobId
			,sk.Id
	  FROM @BatchSkills bs
	  inner join dbo.skills sk
	  on bs.Name = sk.Name

END
GO
/****** Object:  StoredProcedure [dbo].[Jobs_Pagination]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[Jobs_Pagination]
								@PageIndex int 
								,@PageSize int 
/*

--test code

exec dbo.Jobs_Pagination 0 ,10

--test code

insert into jobs
(Title
	,Pay
	,Summary
	,Description
	,ShortDescription
	,ShortTitle
	,CreatedBy
	,ModifiedBy
	,Slug
	,TechCompanyId)
Values
('Software Dev 8'
,'100,000.07'
,'Summary 130'
,'Description 130'
,'Short Description 130'
,'Short Title 130'
,4
,4
,'SLUG123463'
,10)

*/

as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex


	SELECT		j.description
				,j.summary
				,j.pay
				,j.title
				,j.id
				,j.shortTitle
				,j.shortDescription
				,j.content
				,j.createdBy
				,j.modifiedBy
				,j.slug
				,j.entityTypeId
				,j.statusId
				,j.dateCreated
				,j.dateModified
				,j.site
				,j.techcompanyid
				,JSON_QUERY(dbo.TechCompanies_GetById_JSON(tc.id)) as techCompany
				,skills = (Select	skills.id
									,skills.name
							from skills
							inner join jobsskills js
							on skills.id = js.skillid
							where js.jobid = j.id
							FOR JSON AUTO)
	from jobs j
	inner join TechCompanies tc
	on j.techcompanyid = tc.id

	ORDER BY j.Id

	OFFSET @OffSet Rows
	Fetch Next @PageSize Rows ONLY


END






GO
/****** Object:  StoredProcedure [dbo].[Jobs_PaginationV2]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[Jobs_PaginationV2]
								@PageIndex int 
								,@PageSize int 
/*

--test code

exec dbo.Jobs_PaginationV2 0 ,15

--test code

insert into jobs
(Title
	,Pay
	,Summary
	,Description
	,ShortDescription
	,ShortTitle
	,CreatedBy
	,ModifiedBy
	,Slug
	,TechCompanyId)
Values
('Software Dev 8'
,'100,000.07'
,'Summary 130'
,'Description 130'
,'Short Description 130'
,'Short Title 130'
,4
,4
,'SLUG123463'
,10)

*/

as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex


	SELECT		j.id
				,j.title
				,j.description
				,j.summary
				,j.pay
				,j.slug
				,skills = (Select	skills.id
									,skills.name
							from skills
							inner join jobsskills js
							on skills.id = js.skillid
							where js.jobid = j.id
							FOR JSON AUTO)
				,j.techcompanyid
				,j.statusId
				,JSON_QUERY(dbo.TechCompanies_GetById_JSON(tc.id)) as techCompany
				,(Select COUNT(*) 
			  FROM Jobs) TotalCount
	from jobs j
	inner join TechCompanies tc
	on j.techcompanyid = tc.id
	ORDER BY j.Id

	OFFSET @OffSet Rows
	Fetch Next @PageSize Rows ONLY


END






GO
/****** Object:  StoredProcedure [dbo].[Jobs_Search_Pagination]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[Jobs_Search_Pagination]
									@PageIndex int 
									,@PageSize int
									,@Search nvarchar(100)

/*

--test code

exec dbo.Jobs_Search_Pagination 0,10,'128'

--test code

insert into jobs
(Title
	,Pay
	,Summary
	,Description
	,ShortDescription
	,ShortTitle
	,CreatedBy
	,ModifiedBy
	,Slug
	,TechCompanyId)
Values
('Software Dev 8'
,'100,000.07'
,'Summary 130'
,'Description 130'
,'Short Description 130'
,'Short Title 130'
,4
,4
,'SLUG123463'
,10)



*/

as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex

	SELECT		j.description
				,j.summary
				,j.pay
				,j.title
				,j.id
				,j.shortTitle
				,j.shortDescription
				,j.content
				,j.createdBy
				,j.modifiedBy
				,j.slug
				,j.entityTypeId
				,j.statusId
				,j.dateCreated
				,j.dateModified
				,j.site
				,j.techcompanyid
				,JSON_QUERY(dbo.TechCompanies_GetById_JSON(tc.id)) as techCompany
				,skills = (Select	skills.id
									,skills.name
							from skills
							inner join jobsskills js
							on skills.id = js.skillid
							where js.jobid = j.id
							FOR JSON AUTO)
	from jobs j
	inner join TechCompanies tc
	on j.techcompanyid = tc.id

	WHERE (
			(j.title LIKE '%' + @Search + '%')
			OR (j.summary LIKE '%' + @Search + '%')
			OR (j.description LIKE '%' + @Search + '%')
	)

	ORDER BY j.Id

	OFFSET @OffSet Rows
	Fetch Next @PageSize Rows ONLY


END






GO
/****** Object:  StoredProcedure [dbo].[Jobs_Search_PaginationV2]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[Jobs_Search_PaginationV2]
									@PageIndex int 
									,@PageSize int
									,@Search nvarchar(100)

/*

--test code

exec dbo.Jobs_Search_PaginationV2 0,10,'Dog'

--test code

insert into jobs
(Title
	,Pay
	,Summary
	,Description
	,ShortDescription
	,ShortTitle
	,CreatedBy
	,ModifiedBy
	,Slug
	,TechCompanyId)
Values
('Software Dev 8'
,'100,000.07'
,'Summary 130'
,'Description 130'
,'Short Description 130'
,'Short Title 130'
,4
,4
,'SLUG123463'
,10)



*/

as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex

	SELECT		j.id
				,j.title
				,j.description
				,j.summary
				,j.pay
				,j.slug
				,skills = (Select	skills.id
									,skills.name
							from skills
							inner join jobsskills js
							on skills.id = js.skillid
							where js.jobid = j.id
							FOR JSON AUTO)
				,j.techcompanyid
				,j.statusId
	  			,JSON_QUERY(dbo.TechCompanies_GetById_JSON(tc.id)) as techCompany
				,(Select COUNT(*) 
				FROM Jobs j2
				inner join TechCompanies tc
				on j2.techcompanyid = tc.id
			  	WHERE (
					(j2.title LIKE '%' + @Search + '%')
					OR (j2.summary LIKE '%' + @Search + '%')
					OR (j2.description LIKE '%' + @Search + '%')
					)) TotalCount
	from jobs j
	inner join TechCompanies tc
	on j.techcompanyid = tc.id

	WHERE (
			(j.title LIKE '%' + @Search + '%')
			OR (j.summary LIKE '%' + @Search + '%')
			OR (j.description LIKE '%' + @Search + '%')
	)

	ORDER BY j.Id

	OFFSET @OffSet Rows
	Fetch Next @PageSize Rows ONLY


END






GO
/****** Object:  StoredProcedure [dbo].[Jobs_SetStatusById]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Jobs_SetStatusById]
									@Id int
									,@Status nvarchar(10)
/*
--test code

Declare @Id int = 2
execute dbo.Jobs_SetStatusById @Id, 'Active'
select * from jobs where id = @Id


--end test code

*/
as

BEGIN

update Jobs
set StatusId = @Status
where id = @id

END
GO
/****** Object:  StoredProcedure [dbo].[Jobs_Update]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Jobs_Update]
					
						@Title nvarchar(100)
						,@Description nvarchar(500)
						,@Summary nvarchar(256)
						,@Pay nvarchar(10)
						,@Slug nvarchar(50)
						,@StatusId nvarchar(10)
						,@TechCompanyId int
						,@BatchSkills dbo.BatchSkills READONLY
						,@UserId int
						,@Id int

/*

--test code
declare 	@Title nvarchar(100) = 'Legacy Engineer 123'
			,@Description nvarchar(500) = 'Description 433'
			,@Summary nvarchar(256) = 'Summary 433'
			,@Pay nvarchar(10) = '126,000.00'
			,@Slug nvarchar(50) = 'SLUGINSERT10002'
			,@StatusId nvarchar(10) = 'Active'
			,@TechCompanyId int = 9
			,@BatchSkills dbo.BatchSkills
			,@UserId int = 4
			,@Id int = 8

INSERT INTO @BatchSkills
		VALUES ('C#'),('Linux'),('VB3'),('Cold Fusion')

exec dbo.Jobs_Update 	@Title 
						,@Description 
						,@Summary 
						,@Pay 
						,@Slug 
						,@StatusId 
						,@TechCompanyId 
						,@BatchSkills
						,@UserId 
						,@Id

exec dbo.Jobs_GetById @Id

--end test code


*/
as

BEGIN

update jobs
	set title = @Title
		,description = @Description
		,summary = @Summary
		,pay = @Pay
		,slug = @Slug
		,statusid = @StatusId
		,techcompanyid = @TechCompanyId
		,modifiedby = @UserId
	where jobs.id = @Id

INSERT INTO dbo.skills
		(Name,
		UserId)
		select Name,
			@UserId
		from @BatchSkills bs
		where not exists	
		(select 1 from dbo.skills sk
		where sk.name = bs.name)

delete js
from JobsSkills js
where js.jobid = @Id

INSERT INTO dbo.JobsSkills
			(JobId
			,SkillId)
	  SELECT
			@Id
			,sk.Id
	  FROM @BatchSkills bs
	  inner join dbo.skills sk
	  on bs.Name = sk.Name
	  where not exists 
			(Select 1
			From JobsSkills
			Where JobId = @Id
			AND SkillId = sk.Id) 

END
GO
/****** Object:  StoredProcedure [dbo].[People_DeleteById]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[People_DeleteById]

				@Id int


as

/* ---Test code

Declare @id int = 10
Execute dbo.People_DeleteById @Id

---Test Code End
Create proc dbo.People_DeleteById


*/


BEGIN

DELETE 
	FROM [dbo].[People]
	WHERE [Id]=@Id

END


GO
/****** Object:  StoredProcedure [dbo].[People_Insert]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[People_Insert]


			--these are parameters
			@PersonName nvarchar(50)
			,@Age int
			,@UserId nvarchar(128)
			,@IsASmoker bit
			,@Id int OUTPUT


/*
It was Create proc dbo.People_Insert at first 
Execute dbo.People_Insert to create the stored procedure
Alter proc dbo.People_Insert run this to save the stored procedure

Declare @Id int=0;

Declare @PersonName nvarchar(50)='Johnny'
			,@Age int = 54
			,@UserId nvarchar(128)='JOHNNY0001'
			,@IsASmoker bit = 1

Execute dbo.People_Insert @PersonName
				,@Age
				,@UserId
				,@IsASmoker
				,@Id OUTPUT

Select * 
from dbo.People
where Id=@Id


*/


as

BEGIN

INSERT INTO [dbo].[People]
           ([Name]
           ,[Age]
           ,[IsSmoker]	
           ,[UserId])
     VALUES
           (@PersonName
           ,@Age
           ,@IsASmoker
           ,@UserId)

SET @Id = SCOPE_IDENTITY()

--SELECT @Id

END
GO
/****** Object:  StoredProcedure [dbo].[People_SelectAll]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[People_SelectAll]

as

/* ---Test code

Execute dbo.People_SelectAll

---Test Code End
Create proc dbo.People_SelectAll


*/


BEGIN

SELECT [Id]
      ,[Name]
      ,[Age]
      ,[IsSmoker]
      ,[DateAdded]
      ,[DateModified]
      ,[UserId]
  FROM [dbo].[People]

END


GO
/****** Object:  StoredProcedure [dbo].[People_SelectById]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[People_SelectById]

				@Id int


as

/* ---Test code

Declare @id int = 10
Execute dbo.People_SelectById @Id

---Test Code End
Create proc dbo.People_SelectById


*/


BEGIN

SELECT [Id]
      ,[Name]
      ,[Age]
      ,[IsSmoker]
      ,[DateAdded]
      ,[DateModified]
      ,[UserId]
  FROM [dbo].[People]
  WHERE [Id]=@Id

END


GO
/****** Object:  StoredProcedure [dbo].[People_SelectBySmokerFlag]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[People_SelectBySmokerFlag]

				@IsSmoker bit


as

/* ---Test code

Declare @IsSmoker bit = 1
Execute dbo.People_SelectBySmokerFlag @IsSmoker

---Test Code End

Create proc dbo.People_SelectBySmokerFlag


*/


BEGIN

SELECT [Id]
      ,[Name]
      ,[Age]
      ,[IsSmoker]
      ,[DateAdded]
      ,[DateModified]
      ,[UserId]
  FROM [dbo].[People]
  WHERE [IsSmoker]=@IsSmoker

END


GO
/****** Object:  StoredProcedure [dbo].[People_Update]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[People_Update]

			@PersonName nvarchar(50)
			,@Age int
			,@IsASmoker bit
			,@DateModified datetime2(7)
			,@UserId nvarchar(128)
			,@Id int



/*

Create proc dbo.People_Update
Alter dbo.People_Update

Declare @Id int=12;

Select * 
from dbo.People
where Id=@Id

Declare @PersonName nvarchar(50)='Todd'
			,@Age int = 66
			,@IsASmoker bit = 0
			,@DateModified datetime2(7) = GETUTCDATE()
			,@UserId nvarchar(128) = 'HHHHRRRRTTTT'


Execute dbo.People_Update @PersonName
				,@Age
				,@IsASmoker
				,@DateModified
				,@UserId
				,@Id


Select * 
from dbo.People
where Id=@Id

Select * 
from dbo.People
where Id=12

*/

as 

BEGIN

UPDATE [dbo].[People]
   SET [Name] = @PersonName
      ,[Age] = @Age
      ,[IsSmoker] = @IsASmoker
	  ,[DateModified]=@DateModified
      ,[UserId] = @UserId
 WHERE Id = @Id


END


/*

Select * 
from dbo.People
where Id=@Id

*/
GO
/****** Object:  StoredProcedure [dbo].[Pets_Insert]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

			CREATE PROC [dbo].[Pets_Insert]
										@Breed nvarchar(100)
										,@Size nvarchar(20)
										,@Color nvarchar(10)
										,@ImageUrl nvarchar(500) 


/*

execute Pets_Insert "chihuahua","toy","white","chichi.jpg"

*/


			AS

			BEGIN

			DECLARE @Id int = 0

				INSERT INTO [dbo].[Pets]
						([breed]
						,[Size]
						,color)
				VALUES (@Breed, 
						@Size, 
						@Color)

				SET @Id = SCOPE_IDENTITY()

				INSERT INTO PetImages
				(PetId,
				Url)
				VALUES (@Id,
						@ImageUrl)


			END
		
GO
/****** Object:  StoredProcedure [dbo].[Sabio_Addresses_DeleteById]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create proc [dbo].[Sabio_Addresses_DeleteById]
			@Id int
/*

	declare @Id int = 10
	Execute [dbo].[Sabio_Addresses_DeleteById] @Id

*/

as
BEGIN

	  DELETE
	  FROM [dbo].[Sabio_Addresses]
	  Where Id = @Id

END



GO
/****** Object:  StoredProcedure [dbo].[Sabio_Addresses_Insert]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[Sabio_Addresses_Insert]
			@Id int OUTPUT,
			@LineOne nvarchar(50),
			@SuiteNumber int,
			@City nvarchar(50),
			@State nvarchar(50),
			@PostalCode nvarchar(50),
			@IsActive bit,
			@Lat float,
			@Long float
as

BEGIN




	INSERT INTO [dbo].[Sabio_Addresses]
           ([LineOne]
           ,[SuiteNumber]
           ,[City]
           ,[State]
           ,[PostalCode]
           ,[IsActive]
           ,[Lat]
           ,[Long])
     VALUES
           (
		   @LineOne	
		   ,@SuiteNumber
		   ,@City		
		   ,@State		
		   ,@PostalCode	
		   ,@IsActive	
		   ,@Lat		
		   ,@Long	
		   )

	SET @Id = SCOPE_IDENTITY()





END


GO
/****** Object:  StoredProcedure [dbo].[Sabio_Addresses_SelectById]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create proc [dbo].[Sabio_Addresses_SelectById]
			@Id int
/*

	declare @Id int = 10
	Execute [dbo].[Sabio_Addresses_SelectById] @Id

*/

as
BEGIN

	SELECT 
	      [Id]
		  ,[LineOne]
		  ,[SuiteNumber]
		  ,[City]
		  ,[State]
		  ,[PostalCode]
		  ,[IsActive]
		  ,[Lat]
		  ,[Long]
	  FROM [dbo].[Sabio_Addresses]
	  Where Id = @Id

END



GO
/****** Object:  StoredProcedure [dbo].[Sabio_Addresses_SelectRandom50]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[Sabio_Addresses_SelectRandom50]

/*

	Execute [dbo].[Sabio_Addresses_SelectRandom50]

*/

as
BEGIN

	SELECT top 50 
	      [Id]
		  ,[LineOne]
		  ,[SuiteNumber]
		  ,[City]
		  ,[State]
		  ,[PostalCode]
		  ,[IsActive]
		  ,[Lat]
		  ,[Long]
	  FROM [dbo].[Sabio_Addresses]
	  Order By NEWID()

END



GO
/****** Object:  StoredProcedure [dbo].[Sabio_Addresses_Update]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create proc [dbo].[Sabio_Addresses_Update]
			@Id int,
			@LineOne nvarchar(50),
			@SuiteNumber int,
			@City nvarchar(50),
			@State nvarchar(50),
			@PostalCode nvarchar(50),
			@IsActive bit,
			@Lat float,
			@Long float
as

BEGIN

	UPDATE [dbo].[Sabio_Addresses]
	   SET [LineOne]		= @LineOne
		  ,[SuiteNumber]	= @SuiteNumber
		  ,[City]			= @City
		  ,[State]			= @State
		  ,[PostalCode]		= @PostalCode
		  ,[IsActive]		= @IsActive
		  ,[Lat]			= @Lat
		  ,[Long]			= @Long
	 WHERE Id = @Id


END


GO
/****** Object:  StoredProcedure [dbo].[Students_Delete]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Students_Delete]
					@Id int

/*
--test code
DECLARE				@Id int =13

exec Students_Delete @Id



--end test code
*/

as


BEGIN


DELETE		sc
FROM		studentcourses sc
WHERE		sc.studentid = @Id

DELETE		s
FROM		Students s
WHERE		s.Id = @Id

END
GO
/****** Object:  StoredProcedure [dbo].[techCompanies_Insert]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[techCompanies_Insert]
									@Name nvarchar(100)
									,@Profile nvarchar(700)
									,@Summary nvarchar(256)
									,@Headline nvarchar(100)
									,@ContactInformation nvarchar(256)
									,@Slug nvarchar(50)
									,@StatusId nvarchar(10)
									,@BatchImages dbo.BatchImages READONLY
									,@BatchUrls dbo.BatchUrls READONLY 
									,@BatchTags dbo.BatchTags READONLY 
									,@BatchFriends dbo.BatchFriendIds READONLY
									,@UserId int
									,@Id int OUTPUT
/*
--test code

Declare		@Name nvarchar(100) = 'Acme 125'
			,@Profile nvarchar(700) = 'Acme Profile 125'
			,@Summary nvarchar(256) = 'Acme Summary 125'
			,@Headline nvarchar(100) = 'Acme Headline 125'
			,@ContactInformation nvarchar(256) = 'Acme Contact 125'
			,@Slug nvarchar(50) = 'ACMESLUG00125'
			,@StatusId nvarchar(10) = 'Active'
			,@BatchImages dbo.BatchImages
			,@BatchUrls dbo.BatchUrls 
			,@BatchTags dbo.BatchTags 
			,@BatchFriends dbo.BatchFriendIds
			,@UserId int = 4
			,@Id int = 0

INSERT INTO @BatchImages
				(imagetypeid, imageurl)
		VALUES (0,'image1.jpg'),(0,'image2.jpg'),(0,'image3.jpg'),(0,'image4.jpg')
INSERT INTO @BatchUrls
		VALUES ('url1.jpg'),('url2.jpg'),('url3.jpg'),('url4.jpg')
INSERT INTO @BatchTags
		VALUES ('tag1'),('tag2'),('tag3'),('tag4')
INSERT INTO @BatchFriends
		VALUES (513),(514),(515),(516)

execute dbo.techCompanies_Insert @Name
								,@Profile
								,@Summary
								,@Headline
								,@ContactInformation
								,@Slug
								,@StatusId
								,@BatchImages
								,@BatchUrls 
								,@BatchTags 
								,@BatchFriends
								,@UserId
								,@Id OUTPUT

select max(id) from techcompanies
select max(id) from images
select max(id) from tags
select max(id) from urls
select max(id) from contactinformation






--end test code

*/
as

BEGIN

DECLARE @DateModified datetime2(7) = getutcdate()
DECLARE @ContactId int = 0
		,@TechCompanyId int = 0

--insert contact information and get the ID
INSERT INTO ContactInformation
				(UserId
				,data)
			VALUES 
				(@UserId
				,@ContactInformation)

SET @ContactId = SCOPE_IDENTITY()

--insert techcompany and get the id
INSERT INTO techcompanies 
				(name	
				,profile
				,summary
				,headline
				,contactinformation
				,slug
				,statusid
				,createdby
				,modifiedby)
			VALUES
				(@Name
				,@Profile
				,@Summary
				,@Headline
				,@ContactId
				,@Slug
				,@StatusId
				,@UserId
				,@UserId)

SET @TechCompanyId = SCOPE_IDENTITY()

--insert images and get table of ids
DECLARE  @OutImageIds TABLE (Id INT)

INSERT INTO images 
				(typeid
				,url
				,UserId)
		OUTPUT INSERTED.Id INTO @OutImageIds
			Select
				imagetypeid
				,imageurl
				,@UserId
			from @BatchImages

--insert techcompanyimages with imageids and techcompany id
INSERT INTO TechCompaniesImages
				(techcompanyid
				,imageid)
			Select	@TechCompanyId
					,id
			From @OutImageIds

--insert urls and get url ids
DECLARE  @OutUrlIds TABLE (Id INT)

INSERT INTO urls 
				(url
				,UserId)
		OUTPUT INSERTED.Id INTO @OutUrlIds
			Select
				Url
				,@UserId
			from @BatchUrls

--insert techcompanyurls with urlids and techcompany id
INSERT INTO TechCompaniesUrls
				(techcompanyid
				,urlid)
			Select	@TechCompanyId
					,id
			From @OutUrlIds

--insert tags and get tag ids
DECLARE  @OutTagIds TABLE (Id INT)

INSERT INTO tags 
				(name
				,UserId)
		OUTPUT INSERTED.Id INTO @OutTagIds
			Select
				name
				,@UserId
			from @BatchTags
--insert techcompanytags with tagids and techcompany id
INSERT INTO TechCompaniesTags
				(techcompanyid
				,tagid)
			Select	@TechCompanyId
					,id
			From @OutTagIds

--insert techcompanyfriends with friendids and techcompany id
INSERT INTO TechCompaniesFriends
				(techcompanyid
				,friendid)
			Select	@TechCompanyId
					,id
			From @BatchFriends

END
GO
/****** Object:  StoredProcedure [dbo].[techCompanies_InsertV2]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[techCompanies_InsertV2]
									@Name nvarchar(100)
									,@Profile nvarchar(700)
									,@Summary nvarchar(256)
									,@Headline nvarchar(100)
									,@ContactInformation nvarchar(256)
									,@Slug nvarchar(50)
									,@StatusId nvarchar(10)
									,@BatchImages dbo.BatchImages READONLY
									,@BatchUrls dbo.BatchUrls READONLY 
									,@UserId int
									,@Id int OUTPUT
/*
--test code

Declare		@Name nvarchar(100) = 'Acme 125'
			,@Profile nvarchar(700) = 'Acme Profile 125'
			,@Summary nvarchar(256) = 'Acme Summary 125'
			,@Headline nvarchar(100) = 'Acme Headline 125'
			,@ContactInformation nvarchar(256) = 'Acme Contact 125'
			,@Slug nvarchar(50) = 'ACMESLUG00125'
			,@StatusId nvarchar(10) = 'Active'
			,@BatchImages dbo.BatchImages
			,@BatchUrls dbo.BatchUrls 
			,@UserId int = 4
			,@Id int = 0

INSERT INTO @BatchImages
				(imagetypeid, imageurl)
		VALUES (0,'image1.jpg'),(0,'image2.jpg'),(0,'image3.jpg'),(0,'image4.jpg')
INSERT INTO @BatchUrls
		VALUES ('url1.jpg'),('url2.jpg'),('url3.jpg'),('url4.jpg')

execute dbo.techCompanies_Insert @Name
								,@Profile
								,@Summary
								,@Headline
								,@ContactInformation
								,@Slug
								,@StatusId
								,@BatchImages
								,@BatchUrls 
								,@UserId
								,@Id OUTPUT

select max(id) from techcompanies
select max(id) from images
select max(id) from urls
select max(id) from contactinformation






--end test code

*/
as

BEGIN

DECLARE @DateModified datetime2(7) = getutcdate()
DECLARE @ContactId int = 0
		,@TechCompanyId int = 0

--insert contact information and get the ID
INSERT INTO ContactInformation
				(UserId
				,data)
			VALUES 
				(@UserId
				,@ContactInformation)

SET @ContactId = SCOPE_IDENTITY()

--insert techcompany and get the id
INSERT INTO techcompanies 
				(name	
				,profile
				,summary
				,headline
				,contactinformation
				,slug
				,statusid
				,createdby
				,modifiedby)
			VALUES
				(@Name
				,@Profile
				,@Summary
				,@Headline
				,@ContactId
				,@Slug
				,@StatusId
				,@UserId
				,@UserId)

SET @TechCompanyId = SCOPE_IDENTITY()
SET @Id = @TechCompanyId

--insert images and get table of ids
DECLARE  @OutImageIds TABLE (Id INT)

INSERT INTO images 
				(typeid
				,url
				,UserId)
		OUTPUT INSERTED.Id INTO @OutImageIds
			Select
				imagetypeid
				,imageurl
				,@UserId
			from @BatchImages

--insert techcompanyimages with imageids and techcompany id
INSERT INTO TechCompaniesImages
				(techcompanyid
				,imageid)
			Select	@TechCompanyId
					,id
			From @OutImageIds

--insert urls and get url ids
DECLARE  @OutUrlIds TABLE (Id INT)

INSERT INTO urls 
				(url
				,UserId)
		OUTPUT INSERTED.Id INTO @OutUrlIds
			Select
				Url
				,@UserId
			from @BatchUrls

--insert techcompanyurls with urlids and techcompany id
INSERT INTO TechCompaniesUrls
				(techcompanyid
				,urlid)
			Select	@TechCompanyId
					,id
			From @OutUrlIds


END
GO
/****** Object:  StoredProcedure [dbo].[techCompanies_Pagination]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[techCompanies_Pagination]

									@PageIndex int 
									,@PageSize int
/*
--test code

execute dbo.techCompanies_Pagination 0, 3

--end test code

*/
as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex

--select (

select	techCompanies.id
		,techCompanies.slug
		,techCompanies.statusId
		,techCompanies.name
		,techCompanies.headline
		,techCompanies.profile
		,techCompanies.summary
		,techCompanies.entityTypeId
		,contactInformation = JSON_QUERY((select contactinformation.id 
									,contactinformation.entityId
									,contactinformation.[data]
									,contactinformation.dateCreated
									,contactinformation.dateModified 
								from contactInformation 
								inner join techcompanies tc1
								on tc1.contactinformation = contactinformation.id
								where tc1.id = techCompanies.id
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
		,images = (Select	images.id
							,images.entityId
							,images.typeId imageTypeId
							,images.url imageUrl
						from images 
						inner join techcompaniesimages tci
						on images.id = tci.imageid
						where  tci.techcompanyid = techCompanies.id 
						FOR JSON AUTO)

		,urls = (Select	urls.id
							,urls.entityId
							,urls.url
						from urls 
						inner join techcompaniesurls tcu
						on urls.id = tcu.urlid
						where  tcu.techcompanyid = techCompanies.id 
						FOR JSON AUTO)

		,friends = (Select	friends.id
							,friends.bio
							,friends.title
							,friends.Summary
							,Friends.Headline
							,friends.entityTypeId
							,friends.StatusId
							,friends.Slug
							,friends.UserId
							,skills = (Select	skills.id
												,skills.name
										from skills
										inner join friendskills fs
										on skills.id = fs.skillid
										where fs.friendid = friends.id
										FOR JSON AUTO)
							,primaryImage = JSON_QUERY((Select		images.id
														,images.entityid
														,images.TypeId imageTypeId
														,images.url imageUrl
												from images
												inner join FriendsV2 f2
												on images.id = f2.PrimaryImageId
												where f2.Id = friends.id
												FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
							,Friends.DateCreated
							,Friends.DateModified
						from FriendsV2 friends
						inner join techcompaniesfriends tcf
						on friends.id = tcf.friendid
						where tcf.techcompanyid = techCompanies.id
						for JSON auto)
		,tags = (Select		tags.id
							,tags.name
					from	tags
					inner join techcompaniestags tct
					on tags.id = tct.tagid
					where tct.techcompanyid = techCompanies.id
					for JSON auto)
		,techCompanies.dateCreated
		,techCompanies.dateModified
		,(Select COUNT(*) 
			  FROM TechCompanies) TotalCount
		,modifiedBy UserId
FROM TechCompanies 

ORDER BY techCompanies.id

OFFSET @OffSet Rows
Fetch Next @PageSize Rows ONLY

--FOR JSON PATH

--) AS JSON

END
GO
/****** Object:  StoredProcedure [dbo].[techCompanies_Search_Pagination]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[techCompanies_Search_Pagination]

									@PageIndex int 
									,@PageSize int
									,@Search nvarchar(100)
/*
--test code

execute dbo.techCompanies_Search_Pagination 0, 3, 'App'

--end test code

*/
as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex

select	techCompanies.id
		,techCompanies.slug
		,techCompanies.statusId
		,techCompanies.name
		,techCompanies.headline
		,techCompanies.profile
		,techCompanies.summary
		,techCompanies.entityTypeId
		,contactInformation = JSON_QUERY((select contactinformation.id 
									,contactinformation.entityId
									,contactinformation.[data]
									,contactinformation.dateCreated
									,contactinformation.dateModified 
								from contactInformation 
								inner join techcompanies tc1
								on tc1.contactinformation = contactinformation.id
								where tc1.id = techCompanies.id
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
		,images = (Select	images.id
							,images.entityId
							,images.typeId imageTypeId
							,images.url imageUrl
						from images 
						inner join techcompaniesimages tci
						on images.id = tci.imageid
						where  tci.techcompanyid = techCompanies.id 
						FOR JSON AUTO)
		,urls = (Select	urls.id
							,urls.entityId
							,urls.url
						from urls 
						inner join techcompaniesurls tcu
						on urls.id = tcu.urlid
						where  tcu.techcompanyid = techCompanies.id 
						FOR JSON AUTO)

		,friends = (Select	friends.id
							,friends.bio
							,friends.title
							,friends.Summary
							,Friends.Headline
							,friends.entityTypeId
							,friends.StatusId
							,friends.Slug
							,friends.UserId
							,skills = (Select	skills.id
												,skills.name
										from skills
										inner join friendskills fs
										on skills.id = fs.skillid
										where fs.friendid = friends.id
										FOR JSON AUTO)
							,primaryImage = JSON_QUERY((Select		images.id
														,images.entityid
														,images.TypeId imageTypeId
														,images.url imageUrl
												from images
												inner join FriendsV2 f2
												on images.id = f2.PrimaryImageId
												where f2.Id = friends.id
												FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
							,Friends.DateCreated
							,Friends.DateModified
						from FriendsV2 friends
						inner join techcompaniesfriends tcf
						on friends.id = tcf.friendid
						where tcf.techcompanyid = techCompanies.id
						for JSON auto)
		,tags = (Select		tags.id
							,tags.name
					from	tags
					inner join techcompaniestags tct
					on tags.id = tct.tagid
					where tct.techcompanyid = techCompanies.id
					for JSON auto)
		,techCompanies.dateCreated
		,techCompanies.dateModified
		,(Select COUNT(*) 
			  FROM TechCompanies
			  WHERE (
			(techCompanies.name LIKE '%' + @Search + '%')
			OR (techCompanies.headline LIKE '%' + @Search + '%')
			OR (techCompanies.title LIKE '%' + @Search + '%')
			OR (techCompanies.summary LIKE '%' + @Search + '%')
			)) TotalCount
		,modifiedBy UserId
FROM techCompanies 
 WHERE (
			(techCompanies.name LIKE '%' + @Search + '%')
			OR (techCompanies.headline LIKE '%' + @Search + '%')
			OR (techCompanies.title LIKE '%' + @Search + '%')
			OR (techCompanies.summary LIKE '%' + @Search + '%')
)


ORDER BY techCompanies.id

OFFSET @OffSet Rows
Fetch Next @PageSize Rows ONLY

END
GO
/****** Object:  StoredProcedure [dbo].[techCompanies_SelectById]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[techCompanies_SelectById]

									@Id int 

/*
--test code

execute dbo.techCompanies_SelectById 5

--end test code

*/
as

BEGIN

--select only from TechCompanies with all references
--to other tables in subqueries
select	techCompanies.id
		,techCompanies.slug
		,techCompanies.statusId
		,techCompanies.name
		,techCompanies.headline
		,techCompanies.profile
		,techCompanies.summary
		,techCompanies.entityTypeId
		,contactInformation = JSON_QUERY((select contactinformation.id   --REQUIRED to remove array wrapper
									,contactinformation.entityId
									,contactinformation.[data]
									,contactinformation.dateCreated
									,contactinformation.dateModified 
								from contactInformation 
								inner join techcompanies tc1
								on tc1.contactinformation = contactinformation.id
								where tc1.id = techCompanies.id
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))   --REQUIRED to remove array wrapper
		,images = (Select	images.id
							,images.entityId
							,images.typeId imageTypeId
							,images.url imageUrl
						from images 
						inner join techcompaniesimages tci
						on images.id = tci.imageid
						where  tci.techcompanyid = techCompanies.id 
						FOR JSON AUTO)
		,urls = (Select	urls.id
							,urls.entityId
							,urls.url
						from urls 
						inner join techcompaniesurls tcu
						on urls.id = tcu.urlid
						where  tcu.techcompanyid = techCompanies.id 
						FOR JSON AUTO)

		,friends = (Select	friends.id
							,friends.bio
							,friends.title
							,friends.Summary
							,Friends.Headline
							,friends.entityTypeId
							,friends.StatusId
							,friends.Slug
							,friends.UserId
							,skills = (Select	skills.id
												,skills.name
										from skills
										inner join friendskills fs
										on skills.id = fs.skillid
										where fs.friendid = friends.id
										FOR JSON AUTO)
							,primaryImage = JSON_QUERY((Select		images.id   --REQUIRED to remove array wrapper
														,images.entityid
														,images.TypeId imageTypeId
														,images.url imageUrl
												from images
												inner join FriendsV2 f2
												on images.id = f2.PrimaryImageId
												where f2.Id = friends.id
												FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))   --REQUIRED to remove array wrapper
							,Friends.DateCreated
							,Friends.DateModified
						from FriendsV2 friends
						inner join techcompaniesfriends tcf
						on friends.id = tcf.friendid
						where tcf.techcompanyid = techCompanies.id
						for JSON auto)
		,tags = (Select		tags.id
							,tags.name tagName
					from	tags
					inner join techcompaniestags tct
					on tags.id = tct.tagid
					where tct.techcompanyid = techCompanies.id
					for JSON auto)
		,techCompanies.dateCreated
		,techCompanies.dateModified
		,techCompanies.ModifiedBy
FROM TechCompanies 
WHERE TechCompanies.id = @Id

ORDER BY techCompanies.id

END
GO
/****** Object:  StoredProcedure [dbo].[techCompanies_SelectBySlug]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[techCompanies_SelectBySlug]

									@Slug nvarchar(100)
/*
--test code

execute dbo.techCompanies_SelectBySlug 'FORD1001'

--end test code

*/
as

BEGIN

select	techCompanies.id
		,techCompanies.slug
		,techCompanies.statusId
		,techCompanies.name
		,techCompanies.headline
		,techCompanies.profile
		,techCompanies.summary
		,techCompanies.entityTypeId
		,contactInformation = JSON_QUERY((select contactinformation.id 
									,contactinformation.entityId
									,contactinformation.[data]
									,contactinformation.dateCreated
									,contactinformation.dateModified 
								from contactInformation 
								inner join techcompanies tc1
								on tc1.contactinformation = contactinformation.id
								where tc1.id = techCompanies.id
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
		,images = (Select	images.id
							,images.entityId
							,images.typeId imageTypeId
							,images.url imageUrl
						from images 
						inner join techcompaniesimages tci
						on images.id = tci.imageid
						where  tci.techcompanyid = techCompanies.id 
						FOR JSON AUTO)
		,urls = (Select	urls.id
							,urls.entityId
							,urls.url
						from urls 
						inner join techcompaniesurls tcu
						on urls.id = tcu.urlid
						where  tcu.techcompanyid = techCompanies.id 
						FOR JSON AUTO)

		,friends = (Select	friends.id
							,friends.bio
							,friends.title
							,friends.Summary
							,Friends.Headline
							,friends.entityTypeId
							,friends.StatusId
							,friends.Slug
							,skills = (Select	skills.id
												,skills.name
										from skills
										inner join friendskills fs
										on skills.id = fs.skillid
										where fs.friendid = friends.id
										FOR JSON AUTO)
							,primaryImage = JSON_QUERY((Select		images.id
														,images.entityid
														,images.TypeId imageTypeId
														,images.url imageUrl
												from images
												inner join FriendsV2 f2
												on images.id = f2.PrimaryImageId
												where f2.Id = friends.id
												FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
							,Friends.DateCreated
							,Friends.DateModified
						from FriendsV2 friends
						inner join techcompaniesfriends tcf
						on friends.id = tcf.friendid
						where tcf.techcompanyid = techCompanies.id
						for JSON auto)
		,tags = (Select		tags.id
							,tags.entityId
							,tags.name tagName
					from	tags
					inner join techcompaniestags tct
					on tags.id = tct.tagid
					where tct.techcompanyid = techCompanies.id
					for JSON auto)
		,techCompanies.dateCreated
		,techCompanies.dateModified

FROM techCompanies 
WHERE techCompanies.slug=@Slug


ORDER BY techCompanies.id

END
GO
/****** Object:  StoredProcedure [dbo].[techCompanies_SetStatusById]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[techCompanies_SetStatusById]
									@Id int
									,@Status nvarchar(10)
/*
--test code

Declare @Id int = 2
execute dbo.techCompanies_SetStatusById @Id, 'Active'
select * from techcompanies where id = @Id


--end test code

*/
as

BEGIN

update TechCompanies
set StatusId = @Status
where id = @id

END
GO
/****** Object:  StoredProcedure [dbo].[techCompanies_Update]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[techCompanies_Update]
									@Name nvarchar(100)
									,@Profile nvarchar(700)
									,@Summary nvarchar(256)
									,@Headline nvarchar(100)
									,@ContactInformation nvarchar(256)
									,@Slug nvarchar(50)
									,@StatusId nvarchar(10)
									,@BatchImages dbo.BatchImages READONLY
									,@BatchUrls dbo.BatchUrls READONLY 
									,@BatchTags dbo.BatchTags READONLY 
									,@BatchFriends dbo.BatchFriendIds READONLY
									,@UserId int
									,@Id int
/*
--test code

Declare		@Name nvarchar(100) = 'Acme 130'
			,@Profile nvarchar(700) = 'Acme Profile 130'
			,@Summary nvarchar(256) = 'Acme Summary 130'
			,@Headline nvarchar(100) = 'Acme Headline 130'
			,@ContactInformation nvarchar(256) = 'Acme Contact 130'
			,@Slug nvarchar(50) = 'ACMESLUG00130'
			,@StatusId nvarchar(10) = 'Active'
			,@BatchImages dbo.BatchImages
			,@BatchUrls dbo.BatchUrls 
			,@BatchTags dbo.BatchTags 
			,@BatchFriends dbo.BatchFriendIds
			,@UserId int = 4
			,@Id int = 10

INSERT INTO @BatchImages
				(imagetypeid, imageurl)
		VALUES (0,'image1.jpg'),(0,'image2.jpg'),(0,'image5.jpg'),(0,'image6.jpg')
INSERT INTO @BatchUrls
		VALUES ('url1.jpg'),('url2.jpg'),('url5.jpg'),('url6.jpg')
INSERT INTO @BatchTags
		VALUES ('tag1'),('tag2'),('tag5'),('tag6')
INSERT INTO @BatchFriends
		VALUES (513),(514),(517),(518)

execute dbo.techCompanies_Update @Name
								,@Profile
								,@Summary
								,@Headline
								,@ContactInformation
								,@Slug
								,@StatusId
								,@BatchImages
								,@BatchUrls 
								,@BatchTags 
								,@BatchFriends
								,@UserId
								,@Id

select max(id) from techcompanies
select max(id) from images
select max(id) from tags
select max(id) from urls
select max(id) from contactinformation

execute Friends_SelectAllV2

execute dbo.techcompanies_SelectById 9



--end test code

*/
as

BEGIN

DECLARE @DateModified datetime2(7) = getutcdate()

--insert contact information and get the ID
UPDATE ci
			SET 
				ci.data=@ContactInformation
				,ci.DateModified = @DateModified
				,ci.UserId=@UserId
			from ContactInformation ci
			inner join techcompanies tc
			on ci.id = tc.ContactInformation
			where tc.id = @Id


--insert techcompany and get the id
UPDATE TechCompanies 
			SET name = @Name	
				,profile = @Profile
				,summary = @Summary
				,headline = @Headline
				,slug = @Slug
				,statusid = @StatusId
				,modifiedby = @UserId
				,datemodified = @DateModified
			where id = @Id
				
--delete old images
DELETE im from images im
inner join techcompaniesimages tci
on im.id = tci.imageid
where tci.techcompanyid = @Id

DELETE tci from techcompaniesimages tci
where tci.techcompanyid = @Id

--insert images and get table of ids
DECLARE  @OutImageIds TABLE (Id INT)

INSERT INTO images 
				(typeid
				,url
				,UserId)
		OUTPUT INSERTED.Id INTO @OutImageIds
			Select
				imagetypeid
				,imageurl
				,@UserId
			from @BatchImages

--insert techcompanyimages with imageids and techcompany id
INSERT INTO TechCompaniesImages
				(techcompanyid
				,imageid)
			Select	@Id
					,id
			From @OutImageIds


--delete old urls
DELETE urls from urls
inner join techcompaniesurls tcu
on urls.id = tcu.urlid
where tcu.techcompanyid = @Id

DELETE tcu from techcompaniesurls tcu
where tcu.techcompanyid = @Id

--insert urls and get url ids
DECLARE  @OutUrlIds TABLE (Id INT)

INSERT INTO urls 
				(url
				,UserId)
		OUTPUT INSERTED.Id INTO @OutUrlIds
			Select
				Url
				,@UserId
			from @BatchUrls

--insert techcompanyurls with urlids and techcompany id
INSERT INTO TechCompaniesUrls
				(techcompanyid
				,urlid)
			Select	@Id
					,id
			From @OutUrlIds


--delete old tags
DELETE tags from tags
inner join techcompaniestags tct
on tags.id = tct.tagid
where tct.techcompanyid = @Id

DELETE tct from techcompaniestags tct
where tct.techcompanyid = @Id


--insert tags and get tag ids
DECLARE  @OutTagIds TABLE (Id INT)

INSERT INTO tags 
				(name
				,UserId)
		OUTPUT INSERTED.Id INTO @OutTagIds
			Select
				name
				,@UserId
			from @BatchTags
--insert techcompanytags with tagids and techcompany id
INSERT INTO TechCompaniesTags
				(techcompanyid
				,tagid)
			Select	@Id
					,id
			From @OutTagIds

--delete old friend references
DELETE from techcompaniesfriends
where techcompanyid = @Id

--insert techcompanyfriends with friendids and techcompany id
INSERT INTO TechCompaniesFriends
				(techcompanyid
				,friendid)
			Select	@Id
					,id
			From @BatchFriends

END
GO
/****** Object:  StoredProcedure [dbo].[techCompanies_UpdateV2]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[techCompanies_UpdateV2]
									@Name nvarchar(100)
									,@Profile nvarchar(700)
									,@Summary nvarchar(256)
									,@Headline nvarchar(100)
									,@ContactInformation nvarchar(256)
									,@Slug nvarchar(50)
									,@StatusId nvarchar(10)
									,@BatchImages dbo.BatchImages READONLY
									,@BatchUrls dbo.BatchUrls READONLY 
									,@UserId int
									,@Id int
/*
--test code

Declare		@Name nvarchar(100) = 'Acme 130'
			,@Profile nvarchar(700) = 'Acme Profile 130'
			,@Summary nvarchar(256) = 'Acme Summary 130'
			,@Headline nvarchar(100) = 'Acme Headline 130'
			,@ContactInformation nvarchar(256) = 'Acme Contact 130'
			,@Slug nvarchar(50) = 'ACMESLUG00130'
			,@StatusId nvarchar(10) = 'Active'
			,@BatchImages dbo.BatchImages
			,@BatchUrls dbo.BatchUrls 
			,@UserId int = 4
			,@Id int = 10

INSERT INTO @BatchImages
				(imagetypeid, imageurl)
		VALUES (0,'image1.jpg'),(0,'image2.jpg'),(0,'image5.jpg'),(0,'image6.jpg')
INSERT INTO @BatchUrls
		VALUES ('url1.jpg'),('url2.jpg'),('url5.jpg'),('url6.jpg')

execute dbo.techCompanies_UpdateV2 @Name
								,@Profile
								,@Summary
								,@Headline
								,@ContactInformation
								,@Slug
								,@StatusId
								,@BatchImages
								,@BatchUrls 
								,@UserId
								,@Id

select max(id) from techcompanies
select max(id) from images
select max(id) from urls
select max(id) from contactinformation

execute Friends_SelectAllV2

execute dbo.techcompanies_SelectById 9



--end test code

*/
as

BEGIN

DECLARE @DateModified datetime2(7) = getutcdate()

--insert contact information and get the ID
UPDATE ci
			SET 
				ci.data=@ContactInformation
				,ci.DateModified = @DateModified
				,ci.UserId=@UserId
			from ContactInformation ci
			inner join techcompanies tc
			on ci.id = tc.ContactInformation
			where tc.id = @Id


--insert techcompany and get the id
UPDATE TechCompanies 
			SET name = @Name	
				,profile = @Profile
				,summary = @Summary
				,headline = @Headline
				,slug = @Slug
				,statusid = @StatusId
				,modifiedby = @UserId
				,datemodified = @DateModified
			where id = @Id
				
--delete old images
DELETE im from images im
inner join techcompaniesimages tci
on im.id = tci.imageid
where tci.techcompanyid = @Id

DELETE tci from techcompaniesimages tci
where tci.techcompanyid = @Id

--insert images and get table of ids
DECLARE  @OutImageIds TABLE (Id INT)

INSERT INTO images 
				(typeid
				,url
				,UserId)
		OUTPUT INSERTED.Id INTO @OutImageIds
			Select
				imagetypeid
				,imageurl
				,@UserId
			from @BatchImages

--insert techcompanyimages with imageids and techcompany id
INSERT INTO TechCompaniesImages
				(techcompanyid
				,imageid)
			Select	@Id
					,id
			From @OutImageIds


--delete old urls
DELETE urls from urls
inner join techcompaniesurls tcu
on urls.id = tcu.urlid
where tcu.techcompanyid = @Id

DELETE tcu from techcompaniesurls tcu
where tcu.techcompanyid = @Id

--insert urls and get url ids
DECLARE  @OutUrlIds TABLE (Id INT)

INSERT INTO urls 
				(url
				,UserId)
		OUTPUT INSERTED.Id INTO @OutUrlIds
			Select
				Url
				,@UserId
			from @BatchUrls

--insert techcompanyurls with urlids and techcompany id
INSERT INTO TechCompaniesUrls
				(techcompanyid
				,urlid)
			Select	@Id
					,id
			From @OutUrlIds

END
GO
/****** Object:  StoredProcedure [dbo].[throwaway_test1]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[throwaway_test1]
		@ReceiverTable dbo.SkillsTemp READONLY

as

BEGIN

		Declare @AnotherTemp Table(
				Id int
				,Name nvarchar(100)
				,SkillId int
				,SkillName nvarchar(100)
				,userId int
				,DateSkillCreated datetime2(7)
				,DateSkillMofidied datetime2(7)
	)
		insert into @AnotherTemp
		select * 
		from @ReceiverTable tt
		inner join dbo.Skills sk
		on tt.name = sk.name

		select (select COUNT(Id) from @AnotherTemp) TotalCount
		,*
		from @AnotherTemp

END
GO
/****** Object:  StoredProcedure [dbo].[Users_ByEmail]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Users_ByEmail]

	@email nvarchar(100)

/*
---test code
Declare @email nvarchar(100) = 'gj@123.com'
execute dbo.Users_ByEmail @email
---test code end

*/



as

BEGIN

SELECT [Id]
      ,[FirstName]
      ,[LastName]
      ,[Email]
	  ,[Password]
      ,[AvatarUrl]
      ,[TenantId]
      ,[DateCreated]
      ,[DateModified]
  FROM [dbo].[Users]
  WHERE [email]= @email

END

GO
/****** Object:  StoredProcedure [dbo].[Users_Delete]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Users_Delete]

	@Id int

/*
---test code
Declare @Id int = 44

SELECT [Id]
      ,[FirstName]
      ,[LastName]
      ,[Email]
      ,[Password]
      ,[AvatarUrl]
      ,[TenantId]
      ,[DateCreated]
      ,[DateModified]
  FROM [dbo].[Users]
  WHERE [Id]= @Id


execute dbo.Users_Delete @Id

SELECT [Id]
      ,[FirstName]
      ,[LastName]
      ,[Email]
      ,[Password]
      ,[AvatarUrl]
      ,[TenantId]
      ,[DateCreated]
      ,[DateModified]
  FROM [dbo].[Users]
  WHERE [Id]= @Id
  ---test code end
*/



as

BEGIN

DELETE 
  FROM [dbo].[Users]
  WHERE [Id]= @Id

END

GO
/****** Object:  StoredProcedure [dbo].[Users_Insert]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Users_Insert]

			@FirstName nvarchar(100)
           ,@LastName nvarchar(100)
           ,@Email nvarchar(100)
		   ,@Password nvarchar(64)
           ,@AvatarUrl nvarchar(256)
           ,@TenantId nvarchar(30)
		   ,@Id int OUTPUT



/*
---test code
declare 	@FirstName nvarchar(100) = 'Harry'
           ,@LastName nvarchar(100) = 'Jones'
           ,@Email nvarchar(100) = 'Harry@email.com'
           ,@AvatarUrl nvarchar(256) = 'myavatar.jpg'
           ,@TenantId nvarchar(30) = 'TENANTID33334'
           ,@Password nvarchar(64) = 'password'
		   ,@Id int = 0

execute dbo.Users_Insert @FirstName
           ,@LastName
           ,@Email
           ,@AvatarUrl
           ,@TenantId
           ,@Password
		   ,@Id OUTPUT

		   SELECT Id, 
					FirstName, 
					LastName, 
					Email
		   FROM dbo.Users
		   WHERE Id=@Id
		   ---test code end

*/



as

BEGIN

INSERT INTO [dbo].[Users]
           ([FirstName]
           ,[LastName]
           ,[Email]
		   ,[Password]
           ,[AvatarUrl]
           ,[TenantId])
     VALUES
           (@FirstName
           ,@LastName
           ,@Email
		   ,@Password
           ,@AvatarUrl
           ,@TenantId)

		   SET @Id = SCOPE_IDENTITY()

END

GO
/****** Object:  StoredProcedure [dbo].[Users_Login]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Users_Login]

	@email nvarchar(100),
	@password nvarchar(80)

/*
---test code
Declare @email nvarchar(100) = 'sjbjohn@gmail.com'
Declare @password nvarchar(80) = '123!@#qweQWE'
execute dbo.Users_Login @email, @password
---test code end

*/



as

BEGIN

SELECT [Id]
      ,[FirstName]
      ,[LastName]
      ,[Email]
	  --,[Password]
      ,[AvatarUrl]
      ,[TenantId]
      ,[DateCreated]
      ,[DateModified]
  FROM [dbo].[Users]
  WHERE [email]= @email
  and [password] = @password

END

GO
/****** Object:  StoredProcedure [dbo].[Users_Pagination]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Users_Pagination]  @PageIndex int 
                                ,@PageSize int 

/*


Declare @PageIndex int = 0,@PageSize int = 5
execute dbo.Users_Pagination @PageIndex  
                                  ,@PageSize 

*/



as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex

SELECT [Id]
      ,[FirstName]
      ,[LastName]
      ,[Email]
      --,[Password]
      ,[AvatarUrl]
      ,[TenantId]
      ,[DateCreated]
      ,[DateModified]
	  ,TotalCount = (Select COUNT(id) from users)
  FROM [dbo].[Users]
  ORDER BY Id

  OFFSET @OffSet Rows
  Fetch Next @PageSize Rows ONLY

END

GO
/****** Object:  StoredProcedure [dbo].[Users_Search_Pagination]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Users_Search_Pagination]  @PageIndex int 
                                ,@PageSize int 
								,@Query nvarchar(100)

/*
---Test 

Declare @PageIndex int = 1,
		@PageSize int = 10, 
		@Query nvarchar(100) = 'ohn'

execute dbo.Users_Search_Pagination @PageIndex  
                                  ,@PageSize 
								  ,@Query

SELECT [Id]
      ,[FirstName]
      ,[LastName]
      ,[Email]
      ,[AvatarUrl]
      ,[TenantId]
      ,[DateCreated]
      ,[DateModified]
  FROM [dbo].[Users]
  ORDER BY Id

  --Test end


*/



as

BEGIN

Declare @OffSet int = @PageSize * @PageIndex

SELECT [Id]
      ,[FirstName]
      ,[LastName]
      ,[Email]
	  --,[Password]
      ,[AvatarUrl]
      ,[TenantId]
      ,[DateCreated]
      ,[DateModified]
	  ,TotalCount = (Select COUNT(id) 
					from users
					WHERE (FirstName LIKE '%' + @Query + '%' OR 
					LastName LIKE '%' + @Query + '%'))
  FROM [dbo].[Users]
 
  WHERE (FirstName LIKE '%' + @Query + '%' OR 
		LastName LIKE '%' + @Query + '%')

  ORDER BY Id

  OFFSET @OffSet Rows
  Fetch Next @PageSize Rows ONLY




END

GO
/****** Object:  StoredProcedure [dbo].[Users_SelectAll]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Users_SelectAll]

/*

---test code
execute dbo.Users_SelectAll
---test code end

*/



as

BEGIN

SELECT [Id]
      ,[FirstName]
      ,[LastName]
      ,[Email]
	  --,[Password]
      ,[AvatarUrl]
      ,[TenantId]
      ,[DateCreated]
      ,[DateModified]
  FROM [dbo].[Users]

END

GO
/****** Object:  StoredProcedure [dbo].[Users_SelectById]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Users_SelectById]

	@Id int

/*
---test code
Declare @Id int = 44
execute dbo.Users_SelectById @Id
---test code end

*/



as

BEGIN

SELECT [Id]
      ,[FirstName]
      ,[LastName]
      ,[Email]
	  --,[Password]
      ,[AvatarUrl]
      ,[TenantId]
      ,[DateCreated]
      ,[DateModified]
	  ,[Roles]
  FROM [dbo].[Users]
  WHERE [Id]= @Id

END

GO
/****** Object:  StoredProcedure [dbo].[Users_Update]    Script Date: 6/21/2023 5:25:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Users_Update]

			@FirstName nvarchar(100)
           ,@LastName nvarchar(100)
           ,@Email nvarchar(100)
		   --,@Password nvarchar(64)
           ,@AvatarUrl nvarchar(256)
           ,@TenantId nvarchar(30)
		   ,@Id int



/*

---test code

Declare @Id int = 25

		   SELECT Id, 
					FirstName, 
					LastName, 
					Email
		   FROM dbo.Users
		   WHERE Id=@Id

declare 	@FirstName nvarchar(100) = 'Hobart'
           ,@LastName nvarchar(100) = 'Jenkins'
           ,@Email nvarchar(100) = 'hobart@jones.com'
           ,@AvatarUrl nvarchar(256) = 'avatar.jpg'
           ,@TenantId nvarchar(30) = 'TENANT123098'
		   
execute dbo.Users_Update @FirstName
					,@LastName
					,@Email
					,@AvatarUrl
					,@TenantId
					,@Id

		   SELECT Id, 
					FirstName, 
					LastName, 
					Email,
					Password
		   FROM dbo.Users
		   WHERE Id=@Id
---test code end

*/



as

BEGIN

UPDATE [dbo].[Users]
   SET [FirstName] = @FirstName
      ,[LastName] = @LastName
      ,[Email] = @Email
      --,[Password] = @Password
      ,[AvatarUrl] = @AvatarUrl
      ,[TenantId] = @TenantId
      ,[DateModified] = GETUTCDATE()
 WHERE Id = @Id

END

GO
