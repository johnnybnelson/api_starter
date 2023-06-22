using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Domain.Addresses
{

    //domain objects are for data coming from the database
    //
    public class Address : BaseAddress
    {
        [Required]   //Tells the system that this is required
        public bool IsActive { get; set; }

        [Range(-180, 180)]  //allowable range
        public double Long { get; set; }

        [Range(-90, 90)]  //allowable range
        public double Lat { get; set; }
    }
}
