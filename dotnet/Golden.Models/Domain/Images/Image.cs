using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Domain.Images
{
    public class Image : BaseImage
    {
        //the image ID is populated on retrieval
        //not for push/put
        //
        [Range(1, int.MaxValue)]  //allowable range
        public int Id { get; set; }
    }
}
