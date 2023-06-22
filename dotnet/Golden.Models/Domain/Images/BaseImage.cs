using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Domain.Images
{
    public class BaseImage
    {
        [Range(1, int.MaxValue)]  //allowable range
        public int ImageTypeId { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(256)]  //allowable range
        public string ImageUrl { get; set; }
    }
}
