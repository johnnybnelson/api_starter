using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Domain.Addresses
{
    public class BaseAddress
    {
        [Range(1, int.MaxValue)]  //allowable range
        public int Id { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(50)]  //allowable range
        public string LineOne { get; set; }

        [Range(1, int.MaxValue)]  //allowable range
        public int SuiteNumber { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(50)]  //allowable range
        public string City { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(50)]  //allowable range
        public string PostalCode { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(50)]  //allowable range
        public string State { get; set; }
    }
}
