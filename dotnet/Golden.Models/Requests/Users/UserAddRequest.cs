//using System;
//using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
//using System.Linq;
//using System.Text;
//using System.Threading.Tasks;

namespace Golden.Models.Requests.Users
{
    //this class is used with insert/add of a user record
    public class UserAddRequest
    {
        [Required]
        [StringLength(30)]  //allowable range
        public string TenantId { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(100)]  //allowable range
        public string FirstName { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(100)]  //allowable range
        public string LastName { get; set; }

        [Required]   //Tells the system that this is required
        [EmailAddress(ErrorMessage = "Invalid email address")]
        [StringLength(100)]  //allowable range
        public string Email { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(64)]  //allowable range
        public string Password { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(64)]  //allowable range
        [Compare("Password")]
        public string PasswordConfirm { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(256)]  //allowable range
        public string AvatarUrl { get; set; }
    }
}
