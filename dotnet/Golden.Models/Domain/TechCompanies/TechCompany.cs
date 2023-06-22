using Golden.Models.Domain.Contacts;
using Golden.Models.Domain.Friends;
using Golden.Models.Domain.Images;
using Golden.Models.Domain.Tags;
using Golden.Models.Domain.Urls;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;


namespace Golden.Models.Domain.TechCompanies
{
    public class TechCompany : BaseTechCompany
    {
        [StringLength(100)]  //allowable range
        public string Name { get; set; }

        [StringLength(700)]  //allowable range
        public string Profile { get; set; }

        [StringLength(256)]  //allowable range
        public string Summary { get; set; }

        [StringLength(100)]  //allowable range
        public string Headline { get; set; }

        public ContactInformation contactInformation { get; set; }

        [StringLength(50)]  //allowable range
        public string Slug { get; set; }

        [StringLength(10)]  //allowable range
        public string StatusId { get; set; }

        public List<Image> Images { get; set; }

        public List<Url> Urls { get; set; }

        public List<Tag> Tags { get; set; }

        public List<FriendV3> Friends { get; set; }

        [Required]   //Tells the system that this is required
        public int UserId { get; set; }

        [Required]   //Tells the system that this is required
        public DateTime DateCreated { get; set; }

        [Required]   //Tells the system that this is required
        public DateTime DateModified { get; set; }
    }
}
