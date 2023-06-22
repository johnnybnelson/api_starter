using System;
//using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
//using System.Linq;
//using System.Text;
//using System.Threading.Tasks;

namespace Golden.Models.Requests.Addresses
{
    public class AddressAddRequest
    {


        public bool IsActive { get; set; }

        [Range(-180, 180)]
        public double Long { get; set; }

        [Range(-90, 90)]
        public double Lat { get; set; }

        [Required]
        [StringLength(50)]
        public string LineOne { get; set; }

        [Range(1, int.MaxValue)]
        public int SuiteNumber { get; set; }

        [Required]
        [StringLength(50)]
        public string City { get; set; }

        [Required]
        [StringLength(50)]
        public string PostalCode { get; set; }

        [Required]
        [StringLength(50)]
        public string State { get; set; }
    }
}
