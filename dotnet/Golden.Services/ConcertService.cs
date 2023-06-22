using Golden.Data.Providers;
using Golden.Models.Domain.Addresses;
using System.Data.SqlClient;
using System.Data;
using Golden.Models.Domain.Concerts;
using Golden.Data;
using System.Net;
using System;
using System.Collections.Generic;
using Golden.Models.Requests.Addresses;
using Golden.Models.Requests.Concerts;
using System.Reflection.PortableExecutable;
using Golden.Data.Interfaces;
using Golden.Data.Extensions;

namespace Golden.Services
{
    public class ConcertService
    {

        IDataProvider _data = null;

        public ConcertService(IDataProvider data)
        {

            //establish a data providor locally inside this
            //address object
            _data = data;
        }


        public Concert GetById(int id)
        {
            Concert concert = null;

            string procName = "[dbo].[Concerts_SelectById]";

            _data.ExecuteCmd(procName, delegate (SqlParameterCollection paramCollection)
            {
                //param mapper takes data in one shape and produces another shape
                //int->param(int)
                paramCollection.AddWithValue("id", id);

            }, delegate (IDataReader reader, short set)
            {
                //single record mapper
                //one shape > second shape
                //reader from DB, tabular data stream
                //concert = new Concert();

                concert = SingleConcertMapper(reader);
            }
            );
            return concert;
        }

        private static Concert SingleConcertMapper(IDataReader reader)
        {
            int startIndex = 0;
            Concert concert = new Concert();
            concert.Id = reader.GetSafeInt32(startIndex++);
            concert.Name = reader.GetSafeString(startIndex++);
            concert.Description = reader.GetSafeString(startIndex++);
            concert.IsFree = reader.GetSafeBool(startIndex++);
            concert.Address = reader.GetSafeString(startIndex++);
            concert.Cost = reader.GetSafeInt32(startIndex++);
            concert.DateOfEvent = reader.GetSafeDateTime(startIndex++);
            return concert;
        }


        public List<Concert> GetAll()
        {
            List<Concert> concertList = null;

            string procName = "[dbo].[Concerts_SelectAll]";

            _data.ExecuteCmd(procName, null,

            delegate (IDataReader reader, short set)
            {
                //single record mapper
                //one shape > second shape
                //reader from DB, tabular data stream
                Concert concert = SingleConcertMapper(reader);

                if (concertList == null)
                {
                    concertList = new List<Concert>();
                }
                concertList.Add(concert);
            }
            );
            return concertList;
        }



        public int Add(ConcertAddRequest newConcert)
        {

            int id = 0;

            string procName = "[dbo].[Concerts_Insert]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                AddCommonParams(newConcert, paramCollection);

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

        public void Update(ConcertUpdateRequest updateConcert)
        {

            string procName = "[dbo].[Concerts_Update]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {

                AddCommonParams(updateConcert, paramCollection);
                paramCollection.AddWithValue("@Id", updateConcert.Id);

            }, returnParameters: null);

        }

        private static void AddCommonParams(ConcertAddRequest newConcert, SqlParameterCollection paramCollection)
        {
            paramCollection.AddWithValue("@Name", newConcert.Name);
            paramCollection.AddWithValue("@Description", newConcert.Description);
            paramCollection.AddWithValue("@IsFree", newConcert.IsFree);
            paramCollection.AddWithValue("@Address", newConcert.Address);
            paramCollection.AddWithValue("@Cost", newConcert.Cost);
            paramCollection.AddWithValue("@DateOfEvent", newConcert.DateOfEvent);
        }

        public void Delete(int deleteId)
        {

            string procName = "[dbo].[Concerts_Delete]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {

                paramCollection.AddWithValue("@Id", deleteId);


            }, returnParameters: null);

        }

    }
}
