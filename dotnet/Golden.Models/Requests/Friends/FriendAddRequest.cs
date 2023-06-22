using System;
using System.ComponentModel.DataAnnotations;

namespace Golden.Models.Requests.Friends
{
    public class FriendAddRequest
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
        [StringLength(256)]
        public string PrimaryImageUrl { get; set; }

        [Required]
        [Range(1, int.MaxValue)]
        public int StatusId { get; set; }

        public int UserId { get; set; }
    }
}
