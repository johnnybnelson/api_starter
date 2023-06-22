using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Domain.Skills
{
    public class BatchSkill
    {
        [Required]   //Tells the system that this is required
        [StringLength(100)]  //allowable range
        public string Name { get; set; }
    }
}
