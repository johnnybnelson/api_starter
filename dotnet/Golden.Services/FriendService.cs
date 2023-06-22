using Golden.Data.Providers;
using Golden.Models.Domain.Friends;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using Golden.Data;
using Golden.Models.Requests.Friends;
//using Golden.Models.Domain.Users;
using Golden.Models;
using Golden.Models.Domain.Skills;
using Golden.Services.Interfaces;
using Golden.Data.Interfaces;
using Golden.Data.Extensions;
//using System;

namespace Golden.Services
{
    public class FriendService : IFriendService
    {
        IDataProvider _data = null;

        public FriendService(IDataProvider data)
        {
            //establish a data providor locally inside this
            //address object
            _data = data;
        }

        //V3 FUNCTIONALITY!!!!
        //V3 is the functionality that deals with the friendv2 table
        //and the relationship between friendsv2, the images table,
        //and the skills table. This alse deals with the bridge
        //table "friendskills" (indirectly).
        //
        //get by id
        public FriendV3 GetV3(int id)
        {
            FriendV3 thisFriend = null;

            string procName = "[dbo].[Friends_SelectByIdV3]";

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

                //string skillsString = "";
                //Skill skill = null;


                thisFriend = new FriendV3();
                thisFriend.Id = reader.GetSafeInt32(startIndex++);
                thisFriend.Title = reader.GetSafeString(startIndex++);
                thisFriend.Bio = reader.GetSafeString(startIndex++);
                thisFriend.Summary = reader.GetSafeString(startIndex++);
                thisFriend.Headline = reader.GetSafeString(startIndex++);
                thisFriend.Slug = reader.GetSafeString(startIndex++);
                thisFriend.StatusId = thisFriend.StatusString(reader.GetSafeInt32(startIndex++));
                thisFriend.PrimaryImage.Id = reader.GetSafeInt32(startIndex++);
                thisFriend.PrimaryImage.ImageTypeId = reader.GetSafeInt32(startIndex++);
                thisFriend.PrimaryImage.ImageUrl = reader.GetSafeString(startIndex++);
                thisFriend.Skills = reader.DeserializeObject<List<Skill>>(startIndex++);
                thisFriend.UserId = reader.GetSafeInt32(startIndex++);
                thisFriend.DateCreated = reader.GetSafeDateTime(startIndex++);
                thisFriend.DateModified = reader.GetSafeDateTime(startIndex++);
            }
            );
            return thisFriend;
        }

        //get all
        public List<FriendV3> GetAllV3()
        {
            List<FriendV3> friendList = null;

            string procName = "[dbo].[Friends_SelectAllV3]";

            _data.ExecuteCmd(procName, null, delegate (IDataReader reader, short set)
            {
                //single record mapper
                //one shape > second shape
                //reader from DB, tabular data stream
                int startIndex = 0;
                FriendV3 thisFriend = new FriendV3();

                thisFriend = new FriendV3();
                thisFriend.Id = reader.GetSafeInt32(startIndex++);
                thisFriend.Title = reader.GetSafeString(startIndex++);
                thisFriend.Bio = reader.GetSafeString(startIndex++);
                thisFriend.Summary = reader.GetSafeString(startIndex++);
                thisFriend.Headline = reader.GetSafeString(startIndex++);
                thisFriend.Slug = reader.GetSafeString(startIndex++);
                thisFriend.StatusId = thisFriend.StatusString(reader.GetSafeInt32(startIndex++));
                thisFriend.PrimaryImage.Id = reader.GetSafeInt32(startIndex++);
                thisFriend.PrimaryImage.ImageTypeId = reader.GetSafeInt32(startIndex++);
                thisFriend.PrimaryImage.ImageUrl = reader.GetSafeString(startIndex++);
                thisFriend.Skills = reader.DeserializeObject<List<Skill>>(startIndex++);
                thisFriend.UserId = reader.GetSafeInt32(startIndex++);
                thisFriend.DateCreated = reader.GetSafeDateTime(startIndex++);
                thisFriend.DateModified = reader.GetSafeDateTime(startIndex++);

                //only create a new friend list
                //if it is null
                if (friendList == null)
                {
                    friendList = new List<FriendV3>();
                }
                //add the friend to the friend list
                friendList.Add(thisFriend);
            }
            );
            return friendList;

        }


        public Paged<FriendV3> GetPaginatedV3(int pageIndex, int pageSize)
        {
            //create Paged User to wrap the results!
            //
            Paged<FriendV3> pagedList = null;

            List<FriendV3> friendList = null;

            //get the total count
            //
            int totalCount = 0;

            string procName = "[dbo].[Friends_PaginationV3]";

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
                FriendV3 thisFriend = new FriendV3();

                thisFriend.Id = reader.GetSafeInt32(startIndex++);
                thisFriend.Title = reader.GetSafeString(startIndex++);
                thisFriend.Bio = reader.GetSafeString(startIndex++);
                thisFriend.Summary = reader.GetSafeString(startIndex++);
                thisFriend.Headline = reader.GetSafeString(startIndex++);
                thisFriend.Slug = reader.GetSafeString(startIndex++);
                thisFriend.StatusId = thisFriend.StatusString(reader.GetSafeInt32(startIndex++));
                thisFriend.PrimaryImage.Id = reader.GetSafeInt32(startIndex++);
                thisFriend.PrimaryImage.ImageTypeId = reader.GetSafeInt32(startIndex++);
                thisFriend.PrimaryImage.ImageUrl = reader.GetSafeString(startIndex++);
                thisFriend.Skills = reader.DeserializeObject<List<Skill>>(startIndex++);
                thisFriend.UserId = reader.GetSafeInt32(startIndex++);
                thisFriend.DateCreated = reader.GetSafeDateTime(startIndex++);
                thisFriend.DateModified = reader.GetSafeDateTime(startIndex++);
                totalCount = reader.GetSafeInt32(startIndex++);

                //only create a new friend list
                //if it is null
                if (friendList == null)
                {
                    friendList = new List<FriendV3>();
                }

                //add the friend to the friend list
                friendList.Add(thisFriend);
            }
            );
            if (friendList != null)
            {
                pagedList = new Paged<FriendV3>(friendList, pageIndex, pageSize, totalCount);
            }
            return pagedList;
        }

        public Paged<FriendV3> GetPaginatedSearchV3(int pageIndex, int pageSize, string queryString)
        {
            //create Paged User to wrap the results!
            //
            Paged<FriendV3> pagedList = null;

            List<FriendV3> friendList = null;

            //get the total count
            //
            int totalCount = 0;

            string procName = "[dbo].[Friends_Search_PaginationV3]";

            _data.ExecuteCmd(procName, delegate (SqlParameterCollection paramCollection)
            {
                //param mapper takes data in one shape and produces another shape
                //int->param(int)
                paramCollection.AddWithValue("@PageIndex", pageIndex);
                paramCollection.AddWithValue("@PageSize", pageSize);
                paramCollection.AddWithValue("@Query", queryString);

            }, delegate (IDataReader reader, short set)
            {
                //single record mapper
                //one shape > second shape
                //reader from DB, tabular data stream

                int startIndex = 0;
                FriendV3 thisFriend = new FriendV3();

                thisFriend.Id = reader.GetSafeInt32(startIndex++);
                thisFriend.Title = reader.GetSafeString(startIndex++);
                thisFriend.Bio = reader.GetSafeString(startIndex++);
                thisFriend.Summary = reader.GetSafeString(startIndex++);
                thisFriend.Headline = reader.GetSafeString(startIndex++);
                thisFriend.Slug = reader.GetSafeString(startIndex++);
                thisFriend.StatusId = thisFriend.StatusString(reader.GetSafeInt32(startIndex++));
                thisFriend.PrimaryImage.Id = reader.GetSafeInt32(startIndex++);
                thisFriend.PrimaryImage.ImageTypeId = reader.GetSafeInt32(startIndex++);
                thisFriend.PrimaryImage.ImageUrl = reader.GetSafeString(startIndex++);
                thisFriend.Skills = reader.DeserializeObject<List<Skill>>(startIndex++);
                thisFriend.UserId = reader.GetSafeInt32(startIndex++);
                thisFriend.DateCreated = reader.GetSafeDateTime(startIndex++);
                thisFriend.DateModified = reader.GetSafeDateTime(startIndex++);
                totalCount = reader.GetSafeInt32(startIndex++);

                //only create a new friend list
                //if it is null
                if (friendList == null)
                {
                    friendList = new List<FriendV3>();
                }

                //add the friend to the friend list
                friendList.Add(thisFriend);
            }
            );
            if (friendList != null)
            {
                pagedList = new Paged<FriendV3>(friendList, pageIndex, pageSize, totalCount);
            }
            return pagedList;
        }

        //Add
        public int AddV3(FriendAddRequestV3 newFriend, int UserId)
        {
            int id = 0;

            string procName = "[dbo].[Friends_InsertV3]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                //I am not consolidating "like" functionality as to make
                //the code more readable!!!!!!
                //
                AssignCommonParamsV3(newFriend, UserId, paramCollection);


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
                AssignBatchSkillsToParam(newFriend, paramCollection);


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

        private static void AssignCommonParamsV3(FriendAddRequestV3 newFriend, int UserId, SqlParameterCollection paramCollection)
        {
            paramCollection.AddWithValue("@Title", newFriend.Title);
            paramCollection.AddWithValue("@Bio", newFriend.Bio);
            paramCollection.AddWithValue("@Summary", newFriend.Summary);
            paramCollection.AddWithValue("@Headline", newFriend.Headline);
            paramCollection.AddWithValue("@Slug", newFriend.Slug);
            paramCollection.AddWithValue("@StatusId", newFriend.StatusInt());
            paramCollection.AddWithValue("@ImagetypeId", newFriend.ImageTypeId);
            paramCollection.AddWithValue("@ImageUrl", newFriend.ImageUrl);
            paramCollection.AddWithValue("@UserId", newFriend.UserId > 0 ? newFriend.UserId : UserId);
        }

        //update by FriendUpdateRequestV3 passed
        //
        public void UpdateV3(FriendUpdateRequestV3 existingFriend, int UserId)
        {
            string procName = "[dbo].[Friends_UpdateV3]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                paramCollection.AddWithValue("@Id", existingFriend.Id);         //add ID params
                AssignCommonParamsV3(existingFriend, UserId, paramCollection);  //add common params
                AssignBatchSkillsToParam(existingFriend, paramCollection);      //add batch skills table to params
            }, null
            );
        }

        //common function to add array of skills to a data table
        //and pass that to the stored procedure as a parameter
        private static void AssignBatchSkillsToParam(FriendAddRequestV3 existingFriend, SqlParameterCollection paramCollection)
        {
            DataTable batchSkills = new DataTable();
            batchSkills.Columns.Add("Name", typeof(string));

            for (int index = 0; index < existingFriend.Skills.Count; index++)
            {
                batchSkills.Rows.Add(existingFriend.Skills[index]);
            }

            SqlParameter batchSkillsParam = new SqlParameter();
            batchSkillsParam.ParameterName = "@BatchSkills";
            batchSkillsParam.SqlDbType = SqlDbType.Structured;
            batchSkillsParam.TypeName = "BatchSkills";
            batchSkillsParam.Value = batchSkills;

            paramCollection.Add(batchSkillsParam);
        }

        //delete by friend id passed
        public void DeleteV3(int deleteId)
        {
            string procName = "[dbo].[Friends_DeleteV3]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                paramCollection.AddWithValue("@Id", deleteId);
            }, null
            );
        }
        //
        //END OF V3 FUNCTIONALITY

        //get by id
        public Friend Get(int id)
        {
            //friend object that will be returned
            Friend thisFriend = null;

            //stored procedure name
            string procName = "[dbo].[Friends_SelectById]";

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
                thisFriend = MapSingleFriend(reader, ref startIndex);
            }
            );
            return thisFriend;
        }

        //shared function between getAll and get
        private static Friend MapSingleFriend(IDataReader reader, ref int startIndex)
        {
            Friend thisFriend = new Friend();
            thisFriend.Id = reader.GetSafeInt32(startIndex++);
            thisFriend.Title = reader.GetSafeString(startIndex++);
            thisFriend.Bio = reader.GetSafeString(startIndex++);
            thisFriend.Summary = reader.GetSafeString(startIndex++);
            thisFriend.Headline = reader.GetSafeString(startIndex++);
            thisFriend.Slug = reader.GetSafeString(startIndex++);
            thisFriend.StatusId = reader.GetSafeInt32(startIndex++);
            thisFriend.PrimaryImageUrl = reader.GetSafeString(startIndex++);
            thisFriend.UserId = reader.GetSafeInt32(startIndex++);
            thisFriend.DateCreated = reader.GetSafeDateTime(startIndex++);
            thisFriend.DateModified = reader.GetSafeDateTime(startIndex++);
            return thisFriend;
        }

        //get all paginated
        public Paged<Friend> GetPaginated(int pageIndex, int pageSize)
        {
            //create Paged User to wrap the results!
            //namely, the totalcount, pageindex, and pagesize
            Paged<Friend> pagedList = null;

            //return will be a list of friends
            List<Friend> friendList = null;

            //will grab the total count from the last column in the reader
            int totalCount = 0;


            string procName = "[dbo].[Friends_Pagination]";

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
                Friend thisFriend = MapSingleFriend(reader, ref startIndex);
                totalCount = reader.GetSafeInt32(startIndex);

                //only create a new friend list
                //if it is null
                if (friendList == null)
                {
                    friendList = new List<Friend>();
                }

                //add the friend to the friend list
                friendList.Add(thisFriend);
            }
            );
            if (friendList != null)
            {
                pagedList = new Paged<Friend>(friendList, pageIndex, pageSize, totalCount);
            }

            return pagedList;
        }

        //get all paginated
        public Paged<Friend> GetPaginatedSearch(int pageIndex, int pageSize, string queryString)
        {
            //create Paged User to wrap the results!
            //namely, the totalcount, pageindex, and pagesize
            Paged<Friend> pagedList = null;

            List<Friend> friendList = null;

            int totalCount = 0;

            string procName = "[dbo].[Friends_Search_Pagination]";


            _data.ExecuteCmd(procName, delegate (SqlParameterCollection paramCollection)
            {
                //param mapper takes data in one shape and produces another shape
                //int->param(int)
                paramCollection.AddWithValue("@PageIndex", pageIndex);
                paramCollection.AddWithValue("@PageSize", pageSize);
                paramCollection.AddWithValue("@Query", queryString);

            }, delegate (IDataReader reader, short set)
            {
                //single record mapper
                //one shape > second shape
                //reader from DB, tabular data stream

                int startIndex = 0;
                Friend thisFriend = MapSingleFriend(reader, ref startIndex);
                totalCount = reader.GetSafeInt32(startIndex);

                //only create a new friend list
                //if it is null
                if (friendList == null)
                {
                    friendList = new List<Friend>();
                }

                //add the friend to the friend list
                friendList.Add(thisFriend);

            }
            );
            if (friendList != null)
            {
                pagedList = new Paged<Friend>(friendList, pageIndex, pageSize, totalCount);
            }
            return pagedList;
        }



        //get all
        public List<Friend> GetAll()
        {
            List<Friend> friendList = null;

            string procName = "[dbo].[Friends_SelectAll]";

            _data.ExecuteCmd(procName, null, delegate (IDataReader reader, short set)
            {
                //single record mapper
                //one shape > second shape
                //reader from DB, tabular data stream
                int startIndex = 0;
                Friend thisFriend = MapSingleFriend(reader, ref startIndex);

                //only create a new friend list
                //if it is null
                if (friendList == null)
                {
                    friendList = new List<Friend>();
                }

                //add the friend to the friend list
                friendList.Add(thisFriend);
            }
            );
            return friendList;
        }

        //Add
        public int Add(FriendAddRequest newFriend, int UserId)
        {
            int id = 0;

            string procName = "[dbo].[Friends_Insert]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                //call the method to populate "like" commands
                AssignCommonParams(newFriend, paramCollection);
                paramCollection.AddWithValue("@UserId", newFriend.UserId > 0 ? newFriend.UserId : UserId);

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

        //shared method between add and update
        private static void AssignCommonParams(FriendAddRequest newFriend, SqlParameterCollection paramCollection)
        {
            paramCollection.AddWithValue("@Title", newFriend.Title);
            paramCollection.AddWithValue("@Bio", newFriend.Bio);
            paramCollection.AddWithValue("@Summary", newFriend.Summary);
            paramCollection.AddWithValue("@Headline", newFriend.Headline);
            paramCollection.AddWithValue("@Slug", newFriend.Slug);
            paramCollection.AddWithValue("@StatusId", newFriend.StatusId);
            paramCollection.AddWithValue("@PrimaryImageUrl", newFriend.PrimaryImageUrl);
        }

        //Update
        public void Update(FriendUpdateRequest existingFriend, int UserId)
        {
            string procName = "[dbo].[Friends_Update]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                paramCollection.AddWithValue("@Id", existingFriend.Id);
                AssignCommonParams(existingFriend, paramCollection);
                paramCollection.AddWithValue("@UserId", existingFriend.UserId > 0 ? existingFriend.UserId : UserId);

            }, null
            );
        }

        //delete
        public void Delete(int deleteId)
        {
            string procName = "[dbo].[Friends_Delete]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                paramCollection.AddWithValue("@Id", deleteId);
            }, null
            );
        }
    }
}
