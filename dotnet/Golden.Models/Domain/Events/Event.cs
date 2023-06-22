using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Domain.Events
{
    public class Event : BaseEvent
    {

        public string Name { get; set; }
        public string Description { get; set; }
        public string Summary { get; set; }
        public string Headline { get; set; }
        public string Slug { get; set; }
        public string StatusId { get; set; }
        public string ZipCode { get; set; }
        public string Address { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public DateTime DateStart { get; set; }
        public DateTime DateEnd { get; set; }

    }
}
