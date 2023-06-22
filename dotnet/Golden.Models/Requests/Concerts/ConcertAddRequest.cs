using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Requests.Concerts
{
    public class ConcertAddRequest
    {

        public string Name { get; set; }
        public string Description { get; set; }
        public bool IsFree { get; set; }
        public string Address { get; set; }
        public int Cost { get; set; }
        public DateTime DateOfEvent { get; set; }

    }
}
