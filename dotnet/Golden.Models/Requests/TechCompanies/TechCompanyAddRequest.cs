using Golden.Models.Domain.Images;
using Golden.Models.Domain.Urls;
using Golden.Models.Domain.Contacts;
using Golden.Models.Domain.Friends;
using Golden.Models.Domain.Tags;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Requests.TechCompanies
{
    public class TechCompanyAddRequest
    {

        [StringLength(100)]  //allowable range
        public string Name { get; set; }

        [StringLength(700)]  //allowable range
        public string Profile { get; set; }

        [StringLength(256)]  //allowable range
        public string Summary { get; set; }

        [StringLength(100)]  //allowable range
        public string Headline { get; set; }


        public string ContactInformation { get; set; }

        [StringLength(50)]  //allowable range
        public string Slug { get; set; }

        [StringLength(10)]  //allowable range
        public string StatusId { get; set; }

        public List<BaseImage> Images { get; set; }

        public List<BaseUrl> Urls { get; set; }

        public int UserId { get; set; }

    }
}
