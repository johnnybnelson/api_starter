using Golden.Models.Interfaces;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Requests.Addresses
{
    public class AddressUpdateRequest : AddressAddRequest, IModelIdentifier     //<-- IModelIdentifier will allow the /id in the URL to be placed into
    {                                                                           // the ID of the "model" for updates
        public int Id { get; set; }
    }
}
