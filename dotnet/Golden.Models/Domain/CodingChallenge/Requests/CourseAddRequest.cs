using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Domain.CodingChallenge.Requests
{
    public class CourseAddRequest
    {
        [Required]   //Tells the system that this is required
        [StringLength(200)]  //allowable range
        public string Name { get; set; }
        [Required]   //Tells the system that this is required
        [StringLength(200)]  //allowable range
        public string Description { get; set; }
        [Required]   //Tells the system that this is required
        [Range(1, int.MaxValue)]  //allowable range
        public int SeasonTermId { get; set; }
        [Required]   //Tells the system that this is required
        [Range(1, int.MaxValue)]  //allowable range
        public int TeacherId { get; set; }

    }
}
