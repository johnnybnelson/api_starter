using Golden.Data.Providers;
using Golden.Models.Domain.Contacts;
using Golden.Models.Domain.Friends;
using Golden.Models.Domain.Tags;
using Golden.Models.Domain.TechCompanies;
using Golden.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Golden.Models.Domain.Jobs;
using Golden.Data;
using Golden.Models.Domain.Skills;
using Golden.Models.Requests.Friends;
using Golden.Models.Requests.Jobs;
using Golden.Services.Interfaces;
using Golden.Data.Interfaces;
using Golden.Data.Extensions;

namespace Golden.Services
{
    public class JobService : IJobService
    {

        IDataProvider _data = null;

        public JobService(IDataProvider data)
        {
            //establish a data providor locally inside this
            //address object
            _data = data;
        }

        //get page
        public Paged<Job> GetPaginated(int pageIndex, int pageSize)
        {

            Paged<Job> pagedList = null;
            List<Job> jobList = null;

            int totalCount = 0;
            string procName = "[dbo].[Jobs_PaginationV2]";

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
                Job thisJob = new Job();

                thisJob.Id = reader.GetSafeInt32(startIndex++);
                thisJob.Title = reader.GetSafeString(startIndex++);
                thisJob.Description = reader.GetSafeString(startIndex++);
                thisJob.Summary = reader.GetSafeString(startIndex++);
                thisJob.Pay = reader.GetSafeString(startIndex++);
                thisJob.Slug = reader.GetSafeString(startIndex++);
                thisJob.Skills = reader.DeserializeObject<List<Skill>>(startIndex++);
                thisJob.TechCompanyId = reader.GetSafeInt32(startIndex++);
                thisJob.StatusId = reader.GetSafeString(startIndex++);
                thisJob.TechCompany = reader.DeserializeObject<TechCompany>(startIndex++);
                totalCount = reader.GetSafeInt32(startIndex++);

                //only create a new friend list
                //if it is null
                if (jobList == null)
                {
                    jobList = new List<Job>();
                }

                //add the friend to the friend list
                jobList.Add(thisJob);
            }
            );
            if (jobList != null)
            {
                pagedList = new Paged<Job>(jobList, pageIndex, pageSize, totalCount);
            }
            return pagedList;
        }

        public Paged<Job> GetPaginatedSearch(int pageIndex, int pageSize, string queryString)
        {

            Paged<Job> pagedList = null;
            List<Job> jobList = null;

            int totalCount = 0;
            string procName = "[dbo].[Jobs_Search_PaginationV2]";

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
                Job thisJob = new Job();

                thisJob.Id = reader.GetSafeInt32(startIndex++);
                thisJob.Title = reader.GetSafeString(startIndex++);
                thisJob.Description = reader.GetSafeString(startIndex++);
                thisJob.Summary = reader.GetSafeString(startIndex++);
                thisJob.Pay = reader.GetSafeString(startIndex++);
                thisJob.Slug = reader.GetSafeString(startIndex++);
                thisJob.Skills = reader.DeserializeObject<List<Skill>>(startIndex++);
                thisJob.TechCompanyId = reader.GetSafeInt32(startIndex++);
                thisJob.StatusId = reader.GetSafeString(startIndex++);
                thisJob.TechCompany = reader.DeserializeObject<TechCompany>(startIndex++);
                totalCount = reader.GetSafeInt32(startIndex++);

                //only create a new friend list
                //if it is null
                if (jobList == null)
                {
                    jobList = new List<Job>();
                }

                //add the friend to the friend list
                jobList.Add(thisJob);
            }
            );
            if (jobList != null)
            {
                pagedList = new Paged<Job>(jobList, pageIndex, pageSize, totalCount);
            }
            return pagedList;
        }

        //page search

        //get by ID
        public Job GetById(int id)
        {
            //friend object that will be returned
            Job thisJob = null;

            //stored procedure name
            string procName = "[dbo].[Jobs_GetByIdV2]";

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
                thisJob = new Job();
                thisJob.Id = reader.GetSafeInt32(startIndex++);
                thisJob.Title = reader.GetSafeString(startIndex++);
                thisJob.Description = reader.GetSafeString(startIndex++);
                thisJob.Summary = reader.GetSafeString(startIndex++);
                thisJob.Pay = reader.GetSafeString(startIndex++);
                thisJob.Slug = reader.GetSafeString(startIndex++);
                thisJob.Skills = reader.DeserializeObject<List<Skill>>(startIndex++);
                thisJob.TechCompanyId = reader.GetSafeInt32(startIndex++);
                thisJob.StatusId = reader.GetSafeString(startIndex++);
                thisJob.TechCompany = reader.DeserializeObject<TechCompany>(startIndex++);

            }
            );
            return thisJob;
        }


        //set status
        //for marking tech companies "deleted"
        public void SetStatus(int Id, string status)
        {
            string procName = "[dbo].[Jobs_SetStatusById]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                paramCollection.AddWithValue("@Id", Id);
                paramCollection.AddWithValue("@Status", status);
            }, null
            );
        }

        //insert/add

        public int Add(JobAddRequest newJob, int UserId)
        {
            int id = 0;

            string procName = "[dbo].[Jobs_Insert]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                //I am not consolidating "like" functionality as to make
                //the code more readable!!!!!!
                //
                paramCollection.AddWithValue("@Title", newJob.Title);
                paramCollection.AddWithValue("@Description", newJob.Description);
                paramCollection.AddWithValue("@Summary", newJob.Summary);
                paramCollection.AddWithValue("@Pay", newJob.Pay);
                paramCollection.AddWithValue("@Slug", newJob.Slug);
                paramCollection.AddWithValue("@StatusId", newJob.StatusId);
                paramCollection.AddWithValue("@TechCompanyId", newJob.TechCompanyId);
                paramCollection.AddWithValue("@UserId", newJob.UserId > 0 ? newJob.UserId : UserId);


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
                DataTable batchSkills = new DataTable();

                //the BatchSkills data table only has one column
                batchSkills.Columns.Add("Name", typeof(string));

                //add the skills from the list into the batchskills data table
                for (int index = 0; index < newJob.Skills.Count; index++)
                {
                    batchSkills.Rows.Add(newJob.Skills[index]);
                }

                //create a new parameter, assign it a matching name from the proc
                SqlParameter batchSkillsParam = new SqlParameter();
                batchSkillsParam.ParameterName = "@BatchSkills";
                batchSkillsParam.SqlDbType = SqlDbType.Structured;
                batchSkillsParam.TypeName = "BatchSkills";      //this is the user-defined-table name in SQL Server
                batchSkillsParam.Value = batchSkills;           //assign the list as the value

                paramCollection.Add(batchSkillsParam);          //add the parameter to the request

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

        //update
        public void Update(JobUpdateRequest existingJob, int UserId)
        {
            string procName = "[dbo].[Jobs_Update]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                //I am not consolidating "like" functionality as to make
                //the code more readable!!!!!!
                //
                paramCollection.AddWithValue("@Id", existingJob.Id);
                paramCollection.AddWithValue("@Title", existingJob.Title);
                paramCollection.AddWithValue("@Description", existingJob.Description);
                paramCollection.AddWithValue("@Summary", existingJob.Summary);
                paramCollection.AddWithValue("@Pay", existingJob.Pay);
                paramCollection.AddWithValue("@Slug", existingJob.Slug);
                paramCollection.AddWithValue("@StatusId", existingJob.StatusId);
                paramCollection.AddWithValue("@TechCompanyId", existingJob.TechCompanyId);
                paramCollection.AddWithValue("@UserId", existingJob.UserId > 0 ? existingJob.UserId : UserId);


                //build a data table and pass it as a type based on a uder-defined table
                //in the database
                //
                DataTable batchSkills = new DataTable();

                //the BatchSkills data table only has one column
                batchSkills.Columns.Add("Name", typeof(string));

                //add the skills from the list into the batchskills data table
                for (int index = 0; index < existingJob.Skills.Count; index++)
                {
                    batchSkills.Rows.Add(existingJob.Skills[index]);
                }

                //create a new parameter, assign it a matching name from the proc
                SqlParameter batchSkillsParam = new SqlParameter();
                batchSkillsParam.ParameterName = "@BatchSkills";
                batchSkillsParam.SqlDbType = SqlDbType.Structured;
                batchSkillsParam.TypeName = "BatchSkills";      //this is the user-defined-table name in SQL Server
                batchSkillsParam.Value = batchSkills;           //assign the list as the value

                paramCollection.Add(batchSkillsParam);          //add the parameter to the request

            }, null
            );

        }







    }
}
