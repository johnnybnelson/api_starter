using System;

namespace Golden.Web.Models.Responses
{
    /// <summary>
    /// The Base class for all our Response models. If it is going out the door from our Api it must
    /// inherit form here.
    /// </summary>
    public abstract class BaseResponse
    {
        public bool IsSuccessful { get; set; }

        public string TransactionId { get; set; }

        public BaseResponse()
        {
            //golden: This TxId we are just faking to demo the purpose
            TransactionId = Guid.NewGuid().ToString();
        }
    }
}