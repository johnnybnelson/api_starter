using Golden.Services.Interfaces;
using Golden.Data;
using Golden.Data.Providers;
using Golden.Models;
using Golden.Models.Domain.Events;
using Golden.Models.Requests.Events;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Golden.Data.Interfaces;
using Golden.Data.Extensions;

namespace Golden.Services
{
    public class EventService : IEventService
    {

        IDataProvider _data = null;

        public EventService(IDataProvider data)
        {
            //establish a data providor locally inside this
            //address object
            _data = data;
        }


        //get feed
        public Paged<Event> Feeds(int pageIndex, int pageSize)
        {
            Paged<Event> pagedList = null;

            List<Event> eventList = null;

            string procName = "[dbo].[Events_FeedsV2]";

            int totalCount = 0;

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
                Event thisEvent = new Event();

                thisEvent.Id = reader.GetSafeInt32(startIndex++);
                thisEvent.Name = reader.GetSafeString(startIndex++);
                thisEvent.Description = reader.GetSafeString(startIndex++);
                thisEvent.Summary = reader.GetSafeString(startIndex++);
                thisEvent.Headline = reader.GetSafeString(startIndex++);
                thisEvent.Slug = reader.GetSafeString(startIndex++);
                thisEvent.StatusId = reader.GetSafeString(startIndex++);
                thisEvent.DateStart = reader.GetSafeDateTime(startIndex++);
                thisEvent.DateEnd = reader.GetSafeDateTime(startIndex++);
                thisEvent.Latitude = reader.GetSafeDouble(startIndex++);
                thisEvent.Longitude = reader.GetSafeDouble(startIndex++);
                thisEvent.ZipCode = reader.GetSafeString(startIndex++);
                thisEvent.Address = reader.GetSafeString(startIndex++);
                totalCount = reader.GetSafeInt32(startIndex++);

                //only create a new friend list
                //if it is null
                if (eventList == null)
                {
                    eventList = new List<Event>();
                }

                //add the friend to the friend list
                eventList.Add(thisEvent);
            }
            );

            if (eventList != null)
            {
                pagedList = new Paged<Event>(eventList, pageIndex, pageSize, totalCount);
            }
            return pagedList;
        }



        //add
        public int Add(EventAddRequest newFriend, int UserId)
        {
            int id = 0;

            string procName = "[dbo].[Events_Insert]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                //call the method to populate "like" commands
                AssignCommonParams(newFriend, UserId, paramCollection);

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



        //update
        public void Update(EventUpdateRequest existingFriend, int UserId)
        {

            string procName = "[dbo].[Events_Update]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                //call the method to populate "like" commands
                paramCollection.AddWithValue("@Id", existingFriend.Id);
                AssignCommonParams(existingFriend, UserId, paramCollection);

            }, null
            );
        }

        //common param assignments between add and update
        private static void AssignCommonParams(EventAddRequest existingFriend, int UserId, SqlParameterCollection paramCollection)
        {
            paramCollection.AddWithValue("@Description", existingFriend.Description);
            paramCollection.AddWithValue("@Name", existingFriend.Name);
            paramCollection.AddWithValue("@Summary", existingFriend.Summary);
            paramCollection.AddWithValue("@Headline", existingFriend.Headline);
            paramCollection.AddWithValue("@Slug", existingFriend.Slug);
            paramCollection.AddWithValue("@StatusId", existingFriend.StatusId);
            paramCollection.AddWithValue("@DateStart", existingFriend.DateStart);
            paramCollection.AddWithValue("@DateEnd", existingFriend.DateEnd);
            paramCollection.AddWithValue("@UserId", existingFriend.UserId > 0 ? existingFriend.UserId : UserId);
            paramCollection.AddWithValue("@Latitude", existingFriend.Latitude);
            paramCollection.AddWithValue("@Longitude", existingFriend.Longitude);
            paramCollection.AddWithValue("@ZipCode", existingFriend.ZipCode);
            paramCollection.AddWithValue("@Address", existingFriend.Address);
        }
    }
}
