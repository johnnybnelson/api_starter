using Golden.Models.Domain.Images;
using Golden.Models.Domain.Skills;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;


namespace Golden.Models.Domain.Friends
{
    public class FriendV3
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
        public Image PrimaryImage { get; set; }

        [Required]   //Tells the system that this is required
        //[Range(1, int.MaxValue)]  //allowable range
        public string StatusId { get; set; }

        public int UserId { get; set; }

        public int Id { get; set; }

        [Required]   //Tells the system that this is required
        public DateTime DateCreated { get; set; }

        [Required]   //Tells the system that this is required
        public DateTime DateModified { get; set; }

        public List<Skill> Skills { get; set; }

        private List<string> statuses = new List<string>();

        public FriendV3()
        {

            PrimaryImage = new Image();

            statuses.Add("NotSet");
            statuses.Add("Active");
            statuses.Add("Deleted");
            statuses.Add("Flagged");

        }

        public string StatusString(int statusId)
        {
            return statuses[statusId];
        }
    }
}
