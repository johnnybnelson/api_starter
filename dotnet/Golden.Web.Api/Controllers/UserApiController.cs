using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Golden.Services.Interfaces;
using Golden.Services;
using Golden.Services.Interfaces.Security;

namespace Golden.Web.Api.Controllers
{
    [Route("api/userauth")]
    [ApiController]
    public class UserApiController : BaseApiController    //ControllerBase
    {

        private IUserServiceV1 _service = null;

        private IAuthenticationService<int> _authService = null;

        public UserApiController(IUserServiceV1 service                 //interface for users
            , ILogger<UserApiControllerV1> logger                         //<--for getting existing user id
            , IAuthenticationService<int> authService) : base(logger)   //<--for the logger
        {
            _service = service;
            _authService = authService;
        }


    }
}
