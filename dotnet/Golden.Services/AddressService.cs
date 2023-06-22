using Golden.Data.Providers;
using Golden.Models.Domain;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Golden.Data;
using Golden.Models.Requests.Addresses;
using Golden.Models.Domain.Addresses;
using Golden.Services.Interfaces;
using Golden.Data.Interfaces;
using Golden.Data.Extensions;

namespace Golden.Services
{
    public class AddressService : IAddressService
    {

        IDataProvider _data = null;

        //function Get
        //Gets one Address record by ID
        public Address Get(int id)
        {
            Address address = null;

            string procName = "[dbo].[golden_Addresses_SelectById]";

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
                address = MapSingleAddress(reader);
            }
            );
            return address;
        }

        //function Get
        //Gets one Address record by ID
        public List<Address> GetRandomAddresses()
        {
            List<Address> addressList = null;

            string procName = "[dbo].[golden_Addresses_SelectRandom50]";

            _data.ExecuteCmd(procName, null,

            delegate (IDataReader reader, short set)
            {
                //single record mapper
                //one shape > second shape
                //reader from DB, tabular data stream
                Address address = MapSingleAddress(reader);

                if (addressList == null)
                {
                    addressList = new List<Address>();
                }
                addressList.Add(address);
            }
            );
            return addressList;
        }

        //this was generated using the mapping functionality of visual studio
        //highlight, right click, quick actions and refactoring, extract method
        private static Address MapSingleAddress(IDataReader reader)
        {
            Address address = new Address();

            int startIndex = 0;

            address.Id = reader.GetSafeInt32(startIndex++);
            address.LineOne = reader.GetSafeString(startIndex++);
            address.SuiteNumber = reader.GetSafeInt32(startIndex++);
            address.City = reader.GetSafeString(startIndex++);
            address.State = reader.GetSafeString(startIndex++);
            address.PostalCode = reader.GetSafeString(startIndex++);
            address.IsActive = reader.GetSafeBool(startIndex++);
            address.Lat = reader.GetSafeDouble(startIndex++);
            address.Long = reader.GetSafeDouble(startIndex++);
            return address;
        }

        //inserting a new record
        public int Add(AddressAddRequest newAddress, int userId)
        {

            int id = 0;

            string procName = "[dbo].[golden_Addresses_Insert]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                AddCommonParams(newAddress, paramCollection);

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

        private static void AddCommonParams(AddressAddRequest newAddress, SqlParameterCollection paramCollection)
        {
            paramCollection.AddWithValue("@LineOne", newAddress.LineOne);
            paramCollection.AddWithValue("@SuiteNumber", newAddress.SuiteNumber);
            paramCollection.AddWithValue("@City", newAddress.City);
            paramCollection.AddWithValue("@State", newAddress.State);
            paramCollection.AddWithValue("@PostalCode", newAddress.PostalCode);
            paramCollection.AddWithValue("@IsActive", newAddress.IsActive);
            paramCollection.AddWithValue("@Lat", newAddress.Lat);
            paramCollection.AddWithValue("@Long", newAddress.Long);
        }



        //inserting a new record
        public void Update(AddressUpdateRequest updateAddress, int userId)
        {

            string procName = "[dbo].[golden_Addresses_Update]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {

                AddCommonParams(updateAddress, paramCollection);
                paramCollection.AddWithValue("@Id", updateAddress.Id);

            }, returnParameters: null);

        }


        public void Delete(int deleteId)
        {

            string procName = "[dbo].[golden_Addresses_DeleteById]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {

                paramCollection.AddWithValue("@Id", deleteId);


            }, returnParameters: null);

        }

        public AddressService(IDataProvider data)
        {

            //establish a data providor locally inside this
            //address object
            _data = data;
        }
    }
}
