using Golden.Data.Providers;
using Golden.Models.Requests.Jobs;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Golden.Models.Requests.Pets;
using Golden.Services.Interfaces;
using Golden.Data.Interfaces;

namespace Golden.Services
{
    public class PetService : IPetService
    {

        IDataProvider _data = null;

        public PetService(IDataProvider data)
        {
            //establish a data providor locally inside this
            //address object
            _data = data;
        }



        public int Add(PetAddRequest newPet)
        {
            int id = 0;

            string procName = "[dbo].[Pets_Insert]";
            _data.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                //I am not consolidating "like" functionality as to make
                //the code more readable!!!!!!
                //
                paramCollection.AddWithValue("@Breed", newPet.Breed);
                paramCollection.AddWithValue("@Size", newPet.Size);
                paramCollection.AddWithValue("@Color", newPet.Color);
                paramCollection.AddWithValue("@ImageUrl", newPet.Url);


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




    }
}
