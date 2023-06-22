using Golden.Data.Providers;
//using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
//using System.Linq;
//using System.Text;
//using System.Threading.Tasks;
using Golden.Data;
//using System.Net;
//using Golden.Models.Requests.Addresses;
//using Golden.Models.Requests;
using Golden.Models.Requests.Users;
using Golden.Models.Domain.Users;
using Golden.Models;
using Golden.Services.Interfaces;
using Golden.Data.Interfaces;
using Golden.Data.Extensions;
//using System.ComponentModel.DataAnnotations;
//using System.Security.Policy;

namespace Golden.Services
{
    public class UserServiceV1 : IUserServiceV1
    {

        IDataProvider _data = null;

        //constructor to establish data provider
        public UserServiceV1(IDataProvider data)
        {
            //establish a data providor locally inside this
            //address object
            _data = data;
        }

        public User Login(UserLogin user)
        {
            string procName = "[dbo].[Users_Login]";

            User thisUser = null;

            _data.ExecuteCmd(procName, delegate (SqlParameterCollection paramCollection)
            {
                //param mapper takes data in one shape and produces another shape
                //int->param(int)
                paramCollection.AddWithValue("@email", user.Email);
                paramCollection.AddWithValue("@password", user.Password);

            }, delegate (IDataReader reader, short set)
            {
                //single record mapper
                //one shape > second shape
                //reader from DB, tabular data stream
                int startIndex = 0;

                thisUser = MapSingleUser(reader, ref startIndex);

            }
            );
            return thisUser;
        }

        //get all users
        public List<User> GetAll()
        {
            List<User> userList = null;

            string procName = "[dbo].[Users_SelectAll]";

            _data.ExecuteCmd(procName, null, delegate (IDataReader reader, short set)
            {
                //single record mapper
                //one shape > second shape
                //reader from DB, tabular data stream
                int startIndex = 0;

                User thisUser = MapSingleUser(reader, ref startIndex);

                //only create a new user list
                //if it is null
                if (userList == null)
                {
                    userList = new List<User>();
                }

                //add the user to the user list
                userList.Add(thisUser);
            }
            );
            return userList;
        }

        //common shared code between getAll and get(id)
        private static User MapSingleUser(IDataReader reader, ref int startIndex)
        {
            User thisUser = new User();

            thisUser.Id = reader.GetSafeInt32(startIndex++);
            thisUser.FirstName = reader.GetSafeString(startIndex++);
            thisUser.LastName = reader.GetSafeString(startIndex++);
            thisUser.Email = reader.GetSafeString(startIndex++);
            thisUser.AvatarUrl = reader.GetSafeString(startIndex++);
            thisUser.TenantId = reader.GetSafeString(startIndex++);
            thisUser.DateCreated = reader.GetSafeDateTime(startIndex++);
            thisUser.DateModified = reader.GetSafeDateTime(startIndex++);

            return thisUser;

        }

        //get by id
        public User Get(int id)
        {
            User thisUser = null;

            string procName = "[dbo].[Users_SelectById]";

            _data.ExecuteCmd(procName, delegate (SqlParameterCollection paramCollection)
            {
                //param mapper takes data in one shape and produces another shape
                //int->param(int)
                paramCollection.AddWithValue("@Id", id);

            }, delegate (IDataReader reader, short set)
            {
                //single record mapper
                //one shape > second shape
                //reader from DB, tabular data stream
                int startIndex = 0;

                thisUser = MapSingleUser(reader, ref startIndex);

            }
            );
            return thisUser;
        }

        //get paginated
        //DIFFERENT!!!
        //Pay attention!!!!
        //
        //Returns Paged<User>
        public Paged<User> GetPaginated(int pageIndex, int pageSize)
        {
            //create Paged User to wrap the results!
            //
            Paged<User> pagedList = null;

            //create the user list
            //
            List<User> userList = null;

            //get the total count
            //
            int totalCount = 0;

            //stored proc name
            //
            string procName = "[dbo].[Users_Pagination]";

            //execut the stored procudure
            //the execute command takes the following params:
            //storedProc: string of stored proc name
            //parameter mapping object: Action<SqlParameterCollection> inputParamMapper
            //data reader object for returns: Action< IDataReader, short> singleRecordMapper
            //OPTIONAL param collection: Action<SqlParameterCollection> returnParameters = null,
            //OPTIONAL modifiers/command: Action< SqlCommand > cmdModifier = null
            //
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
                User thisUser = MapSingleUser(reader, ref startIndex);
                totalCount = reader.GetSafeInt32(startIndex++);

                //only create a new user list
                //if it is null
                if (userList == null)
                {
                    userList = new List<User>();
                }
                userList.Add(thisUser);
            }
            );

            if (userList != null)
            {
                pagedList = new Paged<User>(userList, pageIndex, pageSize, totalCount);
            }
            return pagedList;
        }

        //get search paginated
        public Paged<User> GetPaginatedSearch(int pageIndex, int pageSize, string searchString)
        {
            //create Paged User to wrap the results!
            //
            Paged<User> pagedList = null;

            //create the user list
            //
            List<User> userList = null;
            int totalCount = 0;

            string procName = "[dbo].[Users_Search_Pagination]";

            _data.ExecuteCmd(procName, delegate (SqlParameterCollection paramCollection)
            {
                //param mapper takes data in one shape and produces another shape
                //int->param(int)
                paramCollection.AddWithValue("@PageIndex", pageIndex);
                paramCollection.AddWithValue("@PageSize", pageSize);
                paramCollection.AddWithValue("@Query", searchString);

            }, delegate (IDataReader reader, short set)
            {
                //single record mapper
                //one shape > second shape
                //reader from DB, tabular data stream
                int startIndex = 0;
                User thisUser = MapSingleUser(reader, ref startIndex);
                totalCount = reader.GetSafeInt32(startIndex++);

                //only create a new user list
                //if it is null
                if (userList == null)
                {
                    userList = new List<User>();
                }
                userList.Add(thisUser);
            }
            );
            if (userList != null)
            {
                pagedList = new Paged<User>(userList, pageIndex, pageSize, totalCount);
            }
            return pagedList;
        }

        //add
        public int Add(UserAddRequest newUser)
        {

            int id = 0;

            string procName = "[dbo].[Users_Insert]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                AddCommonParams(newUser, paramCollection);

                //setting up an output parameter
                SqlParameter idOut = new SqlParameter("@Id", SqlDbType.Int);
                idOut.Direction = ParameterDirection.Output;

                //add it to the collection
                paramCollection.Add(idOut);

            }, returnParameters: delegate (SqlParameterCollection returnCollection)
            {
                //value is an object
                object oId = returnCollection["@Id"].Value;

                //convert the object to an int
                int.TryParse(oId.ToString(), out id);
            }
            );
            return id;
        }

        //shared method with common code between add and update
        private static void AddCommonParams(UserAddRequest newUser, SqlParameterCollection paramCollection)
        {
            paramCollection.AddWithValue("@FirstName", newUser.FirstName);
            paramCollection.AddWithValue("@LastName", newUser.LastName);
            paramCollection.AddWithValue("@Email", newUser.Email);
            paramCollection.AddWithValue("@Password", newUser.Password);
            paramCollection.AddWithValue("@AvatarUrl", newUser.AvatarUrl);
            paramCollection.AddWithValue("@TenantId", newUser.TenantId);
        }

        //update
        public void Update(UserUpdateRequest existingUser)
        {

            string procName = "[dbo].[Users_Update]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                paramCollection.AddWithValue("@Id", existingUser.Id);
                paramCollection.AddWithValue("@FirstName", existingUser.FirstName);
                paramCollection.AddWithValue("@LastName", existingUser.LastName);
                paramCollection.AddWithValue("@Email", existingUser.Email);
                paramCollection.AddWithValue("@AvatarUrl", existingUser.AvatarUrl);
                paramCollection.AddWithValue("@TenantId", existingUser.TenantId);
            }, null
            );
        }

        //delete
        public void Delete(int deleteId)
        {
            string procName = "[dbo].[Users_Delete]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                paramCollection.AddWithValue("@Id", deleteId);
            }, null
            );
        }
    }
}
