using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Domain.Users
{
    public class UserLogin
    {

        //[Required]   //Tells the system that this is required
        //[EmailAddress(ErrorMessage = "Invalid email address")]
        //[StringLength(100)]  //allowable range
        public string Email { get; set; }

        //[Required]   //Tells the system that this is required
        //[StringLength(64)]  //allowable range
        public string Password { get; set; }



    }
}
