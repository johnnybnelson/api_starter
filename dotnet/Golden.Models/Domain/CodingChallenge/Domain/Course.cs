using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Domain.CodingChallenge.Domain
{
    public class Course
    {
        [Required]   //Tells the system that this is required
        [Range(1, int.MaxValue)]  //allowable range
        public int Id { get; set; }
        [Required]   //Tells the system that this is required
        [StringLength(200)]  //allowable range
        public string Name { get; set; }
        [Required]   //Tells the system that this is required
        [StringLength(200)]  //allowable range
        public string Description { get; set; }
        [Required]   //Tells the system that this is required
        [StringLength(200)]  //allowable range

        public string SeasonTerm { get; set; }
        [Required]   //Tells the system that this is required
        [StringLength(200)]  //allowable range

        public string Teacher { get; set; }
        public List<Student> Students { get; set; }

    }
}
