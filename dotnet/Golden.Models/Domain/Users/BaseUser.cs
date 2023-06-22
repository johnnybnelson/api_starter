using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Domain.Users
{
    public class BaseUser
    {
        [Range(1, int.MaxValue)]  //allowable range
        public int Id { get; set; }
    }
}
