using Golden.Models.Requests.Pets;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Services.Interfaces
{
    public interface IPetService
    {

        int Add(PetAddRequest newJob);

    }
}
