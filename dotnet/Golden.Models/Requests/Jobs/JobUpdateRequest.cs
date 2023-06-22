using Golden.Models.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Requests.Jobs
{
    public class JobUpdateRequest : JobAddRequest, IModelIdentifier
    {
        public int Id { get; set; }
    }
}
