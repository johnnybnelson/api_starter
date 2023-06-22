using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Requests.Pets
{
    public class PetAddRequest
    {

        public string Breed { get; set; }

        public string Size { get; set; }

        public string Color { get; set; }

        public string Url { get; set; }


    }
}
