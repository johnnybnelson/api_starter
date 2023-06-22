using Golden.Data.Providers;
using Golden.Models.Requests.Jobs;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;
using Golden.Models.Domain.CodingChallenge.Requests;
using Golden.Data;
using Golden.Models.Domain.Jobs;
using Golden.Models.Domain.Skills;
using Golden.Models.Domain.TechCompanies;
using Golden.Models.Domain.CodingChallenge.Domain;
using Golden.Models;
using Golden.Data.Interfaces;
using Golden.Data.Extensions;

namespace Golden.Services.CodingChallenge
{
    public class CourseService : ICourseService
    {

        IDataProvider _data = null;

        public CourseService(IDataProvider data)
        {
            //establish a data providor locally inside this
            //address object
            _data = data;
        }


        public int AddCourse(CourseAddRequest newCourse)
        {
            int id = 0;

            string procName = "[dbo].[Courses_Insert]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                //I am not consolidating "like" functionality as to make
                //the code more readable!!!!!!
                //
                paramCollection.AddWithValue("@Name", newCourse.Name);
                paramCollection.AddWithValue("@Description", newCourse.Description);
                paramCollection.AddWithValue("@SeasonTermId", newCourse.SeasonTermId);
                paramCollection.AddWithValue("@TeacherId", newCourse.TeacherId);

                //setting up an output parameter to capture the new friend id
                //
                SqlParameter idOut = new SqlParameter("@Id", SqlDbType.Int);
                idOut.Direction = ParameterDirection.Output;

                //add it to the collection
                paramCollection.Add(idOut);
                //
                //

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


        public Course GetCourseById(int id)
        {
            //friend object that will be returned
            Course thisCourse = null;

            //stored procedure name
            string procName = "[dbo].[Courses_SelectById]";

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
                thisCourse = new Course();
                thisCourse.Id = reader.GetSafeInt32(startIndex++);
                thisCourse.Name = reader.GetSafeString(startIndex++);
                thisCourse.Description = reader.GetSafeString(startIndex++);
                thisCourse.SeasonTerm = reader.GetSafeString(startIndex++);
                thisCourse.Teacher = reader.GetSafeString(startIndex++);
                thisCourse.Students = reader.DeserializeObject<List<Student>>(startIndex++);
            }
            );
            return thisCourse;
        }



        public void UpdateCourse(CourseUpdateRequest existingCourse)
        {
            string procName = "[dbo].[Courses_Update]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                //I am not consolidating "like" functionality as to make
                //the code more readable!!!!!!
                //
                paramCollection.AddWithValue("@Id", existingCourse.Id);
                paramCollection.AddWithValue("@Name", existingCourse.Name);
                paramCollection.AddWithValue("@Description", existingCourse.Description);
                paramCollection.AddWithValue("@SeasonTermId", existingCourse.SeasonTermId);
                paramCollection.AddWithValue("@TeacherId", existingCourse.TeacherId);

            }, null
            );

        }


        public void DeleteStudent(int Id)
        {
            string procName = "[dbo].[Students_Delete]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                paramCollection.AddWithValue("@Id", Id);
            }, null
            );
        }


        public Paged<Course> GetCoursesByPage(int pageIndex, int pageSize)
        {

            Paged<Course> pagedList = null;
            List<Course> courseList = null;

            int totalCount = 0;
            string procName = "[dbo].[Courses_Pagination]";

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
                Course thisCourse = new Course();

                thisCourse.Id = reader.GetSafeInt32(startIndex++);
                thisCourse.Name = reader.GetSafeString(startIndex++);
                thisCourse.Description = reader.GetSafeString(startIndex++);
                thisCourse.SeasonTerm = reader.GetSafeString(startIndex++);
                thisCourse.Teacher = reader.GetSafeString(startIndex++);
                thisCourse.Students = reader.DeserializeObject<List<Student>>(startIndex++);
                totalCount = reader.GetSafeInt32(startIndex++);

                //only create a new friend list
                //if it is null
                if (courseList == null)
                {
                    courseList = new List<Course>();
                }

                //add the friend to the friend list
                courseList.Add(thisCourse);
            }
            );
            if (courseList != null)
            {
                pagedList = new Paged<Course>(courseList, pageIndex, pageSize, totalCount);
            }
            return pagedList;
        }





    }

}
