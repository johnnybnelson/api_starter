//using Golden.Models.Domain.Images;
//using Golden.Models.Domain.Skills;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Golden.Models.Requests.Friends
{
    public class FriendAddRequestV3
    {
        [Required]
        [StringLength(120)]
        public string Title { get; set; }

        [Required]
        [StringLength(700)]
        public string Bio { get; set; }

        [Required]
        [StringLength(255)]
        public string Summary { get; set; }

        [Required]
        [StringLength(80)]
        public string Headline { get; set; }

        [Required]
        [StringLength(100)]
        public string Slug { get; set; }

        [Required]
        public string StatusId { get; set; }

        public int UserId { get; set; }

        [Required]
        public DateTime DateCreated { get; set; }

        [Required]
        public DateTime DateModified { get; set; }

        public List<string> Skills { get; set; }

        [Range(1, int.MaxValue)]
        public int ImageTypeId { get; set; }

        [Required]
        [StringLength(256)]
        public string ImageUrl { get; set; }

        private List<string> statuses = new List<string>();

        public FriendAddRequestV3()
        {
            statuses.Add("NotSet");
            statuses.Add("Active");
            statuses.Add("Deleted");
            statuses.Add("Flagged");
        }

        //this is the method to return the numeric
        //index for the text status
        //STATUS TEXT  --  Numeric index / Status Id
        //Not Set      returns     0
        //Active       returns     1
        //Deleted      returns     2
        //Flagged      returns     3
        //
        public int StatusInt()
        {
            for (int i = 0; i < statuses.Count; i++)
            {
                if (StatusId.ToUpper() == statuses[i].ToUpper())
                {
                    return i;
                }
            }
            return 0;
        }
    }
}
