using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Requests.Concerts
{
    public class ConcertUpdateRequest : ConcertAddRequest
    {
        public int Id { get; set; }


    }
}
