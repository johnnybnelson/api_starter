using Golden.Models.Domain.Skills;
using Golden.Models.Domain.TechCompanies;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Models.Domain.Jobs
{
    public class Job : BaseJob
    {

        [StringLength(100)]  //allowable range
        public string Title { get; set; }

        [StringLength(500)]  //allowable range
        public string Description { get; set; }

        [StringLength(256)]  //allowable range
        public string Summary { get; set; }

        [StringLength(10)]  //allowable range
        public string Pay { get; set; }

        [StringLength(50)]  //allowable range
        public string Slug { get; set; }

        [StringLength(10)]  //allowable range
        public string StatusId { get; set; }

        public int TechCompanyId { get; set; }

        public List<Skill> Skills { get; set; }

        public TechCompany TechCompany { get; set; }


    }
}
