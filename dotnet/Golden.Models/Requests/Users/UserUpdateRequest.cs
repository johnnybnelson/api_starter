//using System;
//using System.Collections.Generic;
using Golden.Models.Interfaces;
using System.ComponentModel.DataAnnotations;
//using System.Linq;
//using System.Text;
//using System.Threading.Tasks;

namespace Golden.Models.Requests.Users
{
    //this class is used with update and delete
    public class UserUpdateRequest : IModelIdentifier     //<-- IModelIdentifier will allow the /id in the URL to be placed into
    {                                                                   // the ID of the "model" for updates
        public int Id { get; set; }

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
        [StringLength(256)]  //allowable range
        public string AvatarUrl { get; set; }
    }
}
