using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Domain.Friends
{
    public class Friend : BaseFriend    //  <--extends BaseFriend, whch only has the Id
    {
        [Required]   //Tells the system that this is required
        [StringLength(120)]  //allowable range
        public string Title { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(700)]  //allowable range
        public string Bio { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(255)]  //allowable range
        public string Summary { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(80)]  //allowable range
        public string Headline { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(100)]  //allowable range
        public string Slug { get; set; }

        [Required]   //Tells the system that this is required
        [StringLength(256)]  //allowable range
        public string PrimaryImageUrl { get; set; }

        [Required]   //Tells the system that this is required
        [Range(1, int.MaxValue)]  //allowable range
        public int StatusId { get; set; }

        public int UserId { get; set; }

        [Required]   //Tells the system that this is required
        public DateTime DateCreated { get; set; }

        [Required]   //Tells the system that this is required
        public DateTime DateModified { get; set; }
    }
}
