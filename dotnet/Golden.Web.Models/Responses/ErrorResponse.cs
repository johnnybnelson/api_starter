using System;
using System.Collections.Generic;

namespace Golden.Web.Models.Responses
{
    public class ErrorResponse : BaseResponse
    {
        public List<string> Errors { get; set; }

        public ErrorResponse(string errMsg)
        {
            Errors = new List<string>();

            Errors.Add(errMsg);
            IsSuccessful = false;
        }

        public ErrorResponse(IEnumerable<string> errMsg)
        {
            Errors = new List<string>();

            Errors.AddRange(errMsg);
            IsSuccessful = false;
        }
    }
}