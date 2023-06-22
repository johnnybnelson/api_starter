using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Domain.Users
{
    public class User : BaseUser
    {
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

        [Required]   //Tells the system that this is required
        public DateTime DateCreated { get; set; }

        [Required]   //Tells the system that this is required
        public DateTime DateModified { get; set; }

        [StringLength(30)]  //allowable range
        public string TenantId { get; set; }

        [StringLength(50)]  //allowable range
        public string Roles { get; set; }
    }
}
