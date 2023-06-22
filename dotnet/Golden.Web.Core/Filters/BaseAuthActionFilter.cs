using Microsoft.AspNetCore.Mvc.Filters;
using Golden.Models.Enums;
using System;
using System.Collections.Generic;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Web.Core.Filters
{
    public abstract class BaseAuthActionFilter : Attribute, IAsyncActionFilter
    {

        /// <summary>
        /// The parameter name to look for in the Request that holds the Id of the given entity.
        /// </summary>
        public string EntityIdField { get; set; }

        public EntityType EntityTypeId { get; set; }

        public EntityActionType Action { get; set; }

        public abstract Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next);


    }
}
