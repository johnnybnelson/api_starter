using Golden.Services.Interfaces;
using Golden.Data;
using Golden.Data.Providers;
using Golden.Models;
using Golden.Models.Domain.Contacts;
using Golden.Models.Domain.Friends;
using Golden.Models.Domain.Images;
using Golden.Models.Domain.Tags;
using Golden.Models.Domain.TechCompanies;
using Golden.Models.Domain.Urls;
using Golden.Models.Requests.TechCompanies;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Golden.Data.Interfaces;
using Golden.Data.Extensions;

namespace Golden.Services
{
    public class TechCompanyService : ITechCompanyService
    {
        IDataProvider _data = null;

        public TechCompanyService(IDataProvider data)
        {
            //establish a data providor locally inside this
            //address object
            _data = data;
        }

        public Paged<TechCompany> GetPaginated(int pageIndex, int pageSize)
        {

            Paged<TechCompany> pagedList = null;
            List<TechCompany> techCompanyList = null;

            int totalCount = 0;
            string procName = "[dbo].[techCompanies_Pagination]";

            _data.ExecuteCmd(procName, delegate (SqlParameterCollection paramCollection)
            {
                //param mapper takes data in one shape and produces another shape
                //int->param(int)
                paramCollection.AddWithValue("@PageIndex", pageIndex);
                paramCollection.AddWithValue("@PageSize", pageSize);

            }, delegate (IDataReader reader, short set)
            {
                //single record mapper
                //one shape > second shape
                //reader from DB, tabular data stream
                int startIndex = 0;
                TechCompany thisCompany = new TechCompany();

                thisCompany.Id = reader.GetSafeInt32(startIndex++);
                thisCompany.Slug = reader.GetSafeString(startIndex++);
                thisCompany.StatusId = reader.GetSafeString(startIndex++);
                thisCompany.Name = reader.GetSafeString(startIndex++);
                thisCompany.Headline = reader.GetSafeString(startIndex++);
                thisCompany.Profile = reader.GetSafeString(startIndex++);
                thisCompany.Summary = reader.GetSafeString(startIndex++);
                startIndex++; //skip one
                thisCompany.contactInformation = reader.DeserializeObject<ContactInformation>(startIndex++);
                thisCompany.Images = reader.DeserializeObject<List<Image>>(startIndex++);
                thisCompany.Urls = reader.DeserializeObject<List<Url>>(startIndex++);
                thisCompany.Friends = reader.DeserializeObject<List<FriendV3>>(startIndex++);
                thisCompany.Tags = reader.DeserializeObject<List<Tag>>(startIndex++);
                thisCompany.DateCreated = reader.GetSafeDateTime(startIndex++);
                thisCompany.DateModified = reader.GetSafeDateTime(startIndex++);
                totalCount = reader.GetSafeInt32(startIndex++);
                thisCompany.UserId = reader.GetSafeInt32(startIndex++);


                //only create a new friend list
                //if it is null
                if (techCompanyList == null)
                {
                    techCompanyList = new List<TechCompany>();
                }

                //add the friend to the friend list
                techCompanyList.Add(thisCompany);
            }
            );
            if (techCompanyList != null)
            {
                pagedList = new Paged<TechCompany>(techCompanyList, pageIndex, pageSize, totalCount);
            }
            return pagedList;
        }



        public Paged<TechCompany> GetPaginatedSearch(int pageIndex, int pageSize, string queryString)
        {

            Paged<TechCompany> pagedList = null;
            List<TechCompany> techCompanyList = null;

            int totalCount = 0;
            string procName = "[dbo].[techCompanies_Search_Pagination]";

            _data.ExecuteCmd(procName, delegate (SqlParameterCollection paramCollection)
            {
                //param mapper takes data in one shape and produces another shape
                //int->param(int)
                paramCollection.AddWithValue("@PageIndex", pageIndex);
                paramCollection.AddWithValue("@PageSize", pageSize);
                paramCollection.AddWithValue("@Search", queryString);

            }, delegate (IDataReader reader, short set)
            {
                //single record mapper
                //one shape > second shape
                //reader from DB, tabular data stream
                int startIndex = 0;
                TechCompany thisCompany = new TechCompany();

                thisCompany.Id = reader.GetSafeInt32(startIndex++);
                thisCompany.Slug = reader.GetSafeString(startIndex++);
                thisCompany.StatusId = reader.GetSafeString(startIndex++);
                thisCompany.Name = reader.GetSafeString(startIndex++);
                thisCompany.Headline = reader.GetSafeString(startIndex++);
                thisCompany.Profile = reader.GetSafeString(startIndex++);
                thisCompany.Summary = reader.GetSafeString(startIndex++);
                startIndex++; //skip one
                thisCompany.contactInformation = reader.DeserializeObject<ContactInformation>(startIndex++);
                thisCompany.Images = reader.DeserializeObject<List<Image>>(startIndex++);
                thisCompany.Urls = reader.DeserializeObject<List<Url>>(startIndex++);
                thisCompany.Friends = reader.DeserializeObject<List<FriendV3>>(startIndex++);
                thisCompany.Tags = reader.DeserializeObject<List<Tag>>(startIndex++);
                thisCompany.DateCreated = reader.GetSafeDateTime(startIndex++);
                thisCompany.DateModified = reader.GetSafeDateTime(startIndex++);
                thisCompany.UserId = reader.GetSafeInt32(startIndex++);

                totalCount = reader.GetSafeInt32(startIndex++);

                //only create a new friend list
                //if it is null
                if (techCompanyList == null)
                {
                    techCompanyList = new List<TechCompany>();
                }

                //add the friend to the friend list
                techCompanyList.Add(thisCompany);
            }
            );
            if (techCompanyList != null)
            {
                pagedList = new Paged<TechCompany>(techCompanyList, pageIndex, pageSize, totalCount);
            }
            return pagedList;
        }


        public TechCompany GetById(int id)
        {
            //friend object that will be returned
            TechCompany thisCompany = null;

            //stored procedure name
            string procName = "[dbo].[techCompanies_SelectById]";

            //execute the stored proc
            //pass in the parameter collection
            _data.ExecuteCmd(procName, delegate (SqlParameterCollection paramCollection)
            {
                //param mapper takes data in one shape and produces another shape
                //int->param(int)
                paramCollection.AddWithValue("@Id", id);
            },
            //return the data reader, which will be used to populate
            //the friend object
            delegate (IDataReader reader, short set)
            {
                //single record mapper
                //one shape > second shape
                //reader from DB, tabular data stream
                int startIndex = 0;
                thisCompany = new TechCompany();
                thisCompany.Id = reader.GetSafeInt32(startIndex++);
                thisCompany.Slug = reader.GetSafeString(startIndex++);
                thisCompany.StatusId = reader.GetSafeString(startIndex++);
                thisCompany.Name = reader.GetSafeString(startIndex++);
                thisCompany.Headline = reader.GetSafeString(startIndex++);
                thisCompany.Profile = reader.GetSafeString(startIndex++);
                thisCompany.Summary = reader.GetSafeString(startIndex++);
                startIndex++; //skip one
                thisCompany.contactInformation = reader.DeserializeObject<ContactInformation>(startIndex++);
                thisCompany.Images = reader.DeserializeObject<List<Image>>(startIndex++);
                thisCompany.Urls = reader.DeserializeObject<List<Url>>(startIndex++);
                thisCompany.Friends = reader.DeserializeObject<List<FriendV3>>(startIndex++);
                thisCompany.Tags = reader.DeserializeObject<List<Tag>>(startIndex++);
                thisCompany.DateCreated = reader.GetSafeDateTime(startIndex++);
                thisCompany.DateModified = reader.GetSafeDateTime(startIndex++);
                thisCompany.UserId = reader.GetSafeInt32(startIndex++);

            }
            );
            return thisCompany;
        }

        //for marking tech companies "deleted"
        public void SetStatus(int Id, string status)
        {
            string procName = "[dbo].[techCompanies_SetStatusById]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                paramCollection.AddWithValue("@Id", Id);
                paramCollection.AddWithValue("@Status", status);
            }, null
            );
        }


        public int Add(TechCompanyAddRequest newTechCompany, int UserId)
        {
            int id = 0;

            string procName = "[dbo].[techCompanies_InsertV2]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                //I am not consolidating "like" functionality as to make
                //the code more readable!!!!!!
                //
                paramCollection.AddWithValue("@Name", newTechCompany.Name);
                paramCollection.AddWithValue("@Profile", newTechCompany.Profile);
                paramCollection.AddWithValue("@Summary", newTechCompany.Summary);
                paramCollection.AddWithValue("@Headline", newTechCompany.Headline);
                paramCollection.AddWithValue("@ContactInformation", newTechCompany.ContactInformation);
                paramCollection.AddWithValue("@Slug", newTechCompany.Slug);
                paramCollection.AddWithValue("@StatusId", newTechCompany.StatusId);
                paramCollection.AddWithValue("@UserId", newTechCompany.UserId > 0 ? newTechCompany.UserId : UserId);


                //setting up an output parameter to capture the new friend id
                //
                SqlParameter idOut = new SqlParameter("@Id", SqlDbType.Int);
                idOut.Direction = ParameterDirection.Output;

                //add it to the collection
                paramCollection.Add(idOut);
                //
                //

                //build a data table and pass it as a type based on a uder-defined table
                //in the database
                //
                DataTable batchImages = new DataTable();

                //the BatchImages data table two columns
                batchImages.Columns.Add("imageTypeId", typeof(int));
                batchImages.Columns.Add("imageUrl", typeof(string));

                //add the images from the list into the batchimages data table
                for (int index = 0; index < newTechCompany.Images.Count; index++)
                {
                    batchImages.Rows.Add(newTechCompany.Images[index].ImageTypeId, newTechCompany.Images[index].ImageUrl);
                }

                //create a new parameter, assign it a matching name from the proc
                SqlParameter batchImagesParam = new SqlParameter();
                batchImagesParam.ParameterName = "@BatchImages";
                batchImagesParam.SqlDbType = SqlDbType.Structured;
                batchImagesParam.TypeName = "BatchImages";      //this is the user-defined-table name in SQL Server
                batchImagesParam.Value = batchImages;           //assign the list as the value

                paramCollection.Add(batchImagesParam);          //add the parameter to the request


                DataTable batchUrls = new DataTable();

                //the BatchUrls data table only has one column
                batchUrls.Columns.Add("Url", typeof(string));

                //add the urls from the list into the batchurls data table
                for (int index = 0; index < newTechCompany.Urls.Count; index++)
                {
                    batchUrls.Rows.Add(newTechCompany.Urls[index].url);
                }

                //create a new parameter, assign it a matching name from the proc
                SqlParameter batchUrlsParam = new SqlParameter();
                batchUrlsParam.ParameterName = "@BatchUrls";
                batchUrlsParam.SqlDbType = SqlDbType.Structured;
                batchUrlsParam.TypeName = "BatchUrls";      //this is the user-defined-table name in SQL Server
                batchUrlsParam.Value = batchUrls;           //assign the list as the value

                paramCollection.Add(batchUrlsParam);          //add the parameter to the request



            },
            //returning an ID of the friend table
            returnParameters: delegate (SqlParameterCollection returnCollection)
            {
                //value is an object
                object oId = returnCollection["@Id"].Value;

                //convert the object to an int
                int.TryParse(oId.ToString(), out id);
            }
            );
            return id;
        }

        public void Update(TechCompanyUpdateRequest existingTechCompany, int UserId)
        {
            //int id = 0;

            string procName = "[dbo].[techCompanies_UpdateV2]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                //I am not consolidating "like" functionality as to make
                //the code more readable!!!!!!
                //
                paramCollection.AddWithValue("@Id", existingTechCompany.Id);
                paramCollection.AddWithValue("@Name", existingTechCompany.Name);
                paramCollection.AddWithValue("@Profile", existingTechCompany.Profile);
                paramCollection.AddWithValue("@Summary", existingTechCompany.Summary);
                paramCollection.AddWithValue("@Headline", existingTechCompany.Headline);
                paramCollection.AddWithValue("@ContactInformation", existingTechCompany.ContactInformation);
                paramCollection.AddWithValue("@Slug", existingTechCompany.Slug);
                paramCollection.AddWithValue("@StatusId", existingTechCompany.StatusId);
                paramCollection.AddWithValue("@UserId", existingTechCompany.UserId > 0 ? existingTechCompany.UserId : UserId);

                //In this section, we will add a parameter type of 
                //user-defined table for Images
                //
                DataTable batchImages = new DataTable();

                //the BatchImages data table has two columns
                batchImages.Columns.Add("imageTypeId", typeof(int));
                batchImages.Columns.Add("imageUrl", typeof(string));

                //add the images from the list into the batchimages data table
                for (int index = 0; index < existingTechCompany.Images.Count; index++)
                {
                    batchImages.Rows.Add(existingTechCompany.Images[index].ImageTypeId, existingTechCompany.Images[index].ImageUrl);
                }

                //create a new parameter, assign it a matching name from the proc
                SqlParameter batchImagesParam = new SqlParameter();
                batchImagesParam.ParameterName = "@BatchImages";
                batchImagesParam.SqlDbType = SqlDbType.Structured;
                batchImagesParam.TypeName = "BatchImages";      //this is the user-defined-table name in SQL Server
                batchImagesParam.Value = batchImages;           //assign the list as the value

                paramCollection.Add(batchImagesParam);          //add the parameter to the collection

                //In this section, we will add a parameter type of 
                //user-defined table for Urls
                //
                DataTable batchUrls = new DataTable();

                //the BatchUrls data table only has one column
                batchUrls.Columns.Add("Url", typeof(string));

                //add the Urls from the list into the batchUrls data table
                for (int index = 0; index < existingTechCompany.Urls.Count; index++)
                {
                    batchUrls.Rows.Add(existingTechCompany.Urls[index].url);
                }

                //create a new parameter, assign it a matching name from the proc
                SqlParameter batchUrlsParam = new SqlParameter();
                batchUrlsParam.ParameterName = "@BatchUrls";
                batchUrlsParam.SqlDbType = SqlDbType.Structured;
                batchUrlsParam.TypeName = "BatchUrls";      //this is the user-defined-table name in SQL Server
                batchUrlsParam.Value = batchUrls;           //assign the list as the value

                paramCollection.Add(batchUrlsParam);          //add the parameter to the request

            }, null
            );
        }
    }
}
