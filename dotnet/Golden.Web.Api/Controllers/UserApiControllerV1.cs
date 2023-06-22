using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Golden.Services;
using Golden.Services.Interfaces;
using Golden.Web.Models.Responses;
using System.Collections.Generic;
using System.Data.SqlClient;
using System;
using Golden.Models.Domain.Users;
using Golden.Models;
using Golden.Models.Requests.Users;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using System.Text.RegularExpressions;
using Golden.Services.Interfaces.Security;
using Golden.Models.Interfaces;

namespace Golden.Web.Api.Controllers
{
    [Route("api/users")]
    [ApiController]
    public class UserApiControllerV1 : BaseApiController    //replaces ControllerBase
    {
        private IUserService _service = null;

        private IAuthenticationService<int> _authService = null;

        public UserApiControllerV1(IUserService service                 //interface for users
            , ILogger<UserApiControllerV1> logger                         //<--for getting existing user id
            , IAuthenticationService<int> authService) : base(logger)   //<--for the logger
        {
            _service = service;
            _authService = authService;
        }

        //[HttpGet("")]
        //public ActionResult<ItemsResponse<User>> GetAll()
        //{
        //    int iCode = 200;
        //    BaseResponse response = null;

        //    try
        //    {
        //        //want to return a list of users
        //        List<User> list = _service.GetAll();

        //        if (list == null)
        //        {
        //            iCode = 404;
        //            response = new ErrorResponse("Records not found!");
        //        }
        //        else
        //        {
        //            response = new ItemsResponse<User> { Items = list };
        //        }
        //    }
        //    catch (SqlException argEx)
        //    {
        //        iCode = 500;
        //        response = new ErrorResponse($"SqlException Error: {argEx.Message}.");

        //    }
        //    catch (Exception ex)
        //    {
        //        base.Logger.LogError(ex.ToString());
        //        iCode = 500;
        //        response = new ErrorResponse($"Generic Error: {ex.Message}.");
        //    }
        //    return StatusCode(iCode, response);
        //}


        ////api/users/{id: int}
        //[HttpGet("{id:int}")]  //<--route pattern
        //public ActionResult<ItemResponse<User>> GetById(int id)
        //{
        //    int iCode = 200;
        //    BaseResponse response = null;

        //    try
        //    {
        //        User aUser = _service.Get(id); ;

        //        if (aUser == null)
        //        {
        //            iCode = 404;
        //            response = new ErrorResponse("User not found!");
        //        }
        //        else
        //        {
        //            response = new ItemResponse<User> { Item = aUser };
        //        }
        //    }
        //    catch (SqlException argEx)
        //    {
        //        iCode = 500;
        //        response = new ErrorResponse($"SqlException Error: {argEx.Message}.");
        //    }
        //    catch (ArgumentException argEx)
        //    {
        //        iCode = 500;
        //        response = new ErrorResponse($"ArgumentException Error: {argEx.Message}.");
        //    }
        //    catch (Exception ex)
        //    {
        //        base.Logger.LogError(ex.ToString());
        //        iCode = 500;
        //        response = new ErrorResponse($"Generic Error: {ex.Message}.");
        //    }
        //    return StatusCode(iCode, response);
        //}
        

        [HttpGet("current")]  //<--route pattern
        public ActionResult<ItemResponse<int>> GetCurrentUser()
        {

            //int iCode = 200;
            ObjectResult result = null;

            IUserAuthData user = _authService.GetCurrentUser();

            if (user.Id > 0)
            {
                ItemResponse<int> response = new ItemResponse<int>();
                response.Item = user.Id;
                result = Created201(response);
            }
            else
            {
                ErrorResponse response = new ErrorResponse("Not a valid user!");
                result = StatusCode(500, response);
            }

            return result;
        }


        //api/users/{id: int}
        [HttpGet("{id:int}")]  //<--route pattern
        public ActionResult<ItemResponse<User>> GetbyId(int Id)
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                //IUserAuthData user = _authService.GetCurrentUser();   //may not need ... for obtaining userId
                User aUser = _service.GetUserById(Id); ;

                if (aUser == null)
                {
                    iCode = 404;
                    response = new ErrorResponse("User not found!");
                }
                else
                {
                    response = new ItemResponse<User> { Item = aUser };
                }
            }
            catch (SqlException argEx)
            {
                iCode = 500;
                response = new ErrorResponse($"SqlException Error: {argEx.Message}.");
            }
            catch (ArgumentException argEx)
            {
                iCode = 500;
                response = new ErrorResponse($"ArgumentException Error: {argEx.Message}.");
            }
            catch (Exception ex)
            {
                base.Logger.LogError(ex.ToString());
                iCode = 500;
                response = new ErrorResponse($"Generic Error: {ex.Message}.");
            }
            return StatusCode(iCode, response);
        }

        [HttpGet("logout")]  //<--route pattern
        public void LogOut()
        {
            _service.LogOut();
        }


        //api/users/{id: int}
        [AllowAnonymous]
        [HttpPost("login")]  //<--route pattern
        public ActionResult<ItemResponse<bool>> Login(UserLogin tryUser)
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                //Had to use Task<user> due to calling an async function
                //
                Task<bool> aUser = _service.LogInAsync(tryUser.Email,tryUser.Password); ;

                if (aUser.Equals(false))
                {
                    iCode = 404;
                    response = new ErrorResponse("Login failed!");
                }
                else
                {   
                    response = new ItemResponse<Task<bool>> { Item = aUser };
                }
            }
            catch (SqlException argEx)
            {
                iCode = 500;
                response = new ErrorResponse($"SqlException Error: {argEx.Message}.");
            }
            catch (ArgumentException argEx)
            {
                iCode = 500;
                response = new ErrorResponse($"ArgumentException Error: {argEx.Message}.");
            }
            catch (Exception ex)
            {
                base.Logger.LogError(ex.ToString());
                iCode = 500;
                response = new ErrorResponse($"Generic Error: {ex.Message}.");
            }
            return StatusCode(iCode, response);
        }

        //api/users/{id: int}
        //[HttpGet("getcurrent")]  //<--route pattern
        //public ActionResult<ItemResponse<User>> Login(UserLogin tryUser)
        //{
        //    int iCode = 200;
        //    BaseResponse response = null;

        //    try
        //    {
        //        User aUser = _service.Login(tryUser); ;

        //        if (aUser == null)
        //        {
        //            iCode = 404;
        //            response = new ErrorResponse("User not found!");
        //        }
        //        else
        //        {
        //            response = new ItemResponse<User> { Item = aUser };
        //        }
        //    }
        //    catch (SqlException argEx)
        //    {
        //        iCode = 500;
        //        response = new ErrorResponse($"SqlException Error: {argEx.Message}.");
        //    }
        //    catch (ArgumentException argEx)
        //    {
        //        iCode = 500;
        //        response = new ErrorResponse($"ArgumentException Error: {argEx.Message}.");
        //    }
        //    catch (Exception ex)
        //    {
        //        base.Logger.LogError(ex.ToString());
        //        iCode = 500;
        //        response = new ErrorResponse($"Generic Error: {ex.Message}.");
        //    }
        //    return StatusCode(iCode, response);
        //}


        //[HttpGet("paginate")]
        //public ActionResult<ItemsResponse<Paged<User>>> GetPaginated(int pageIndex, int pageSize)
        //{
        //    ActionResult result = null;

        //    try
        //    {
        //        //want to return a list of users
        //        Paged<User> list = _service.GetPaginated(pageIndex, pageSize);

        //        if (list == null)
        //        {
        //            //iCode = 404;
        //            ErrorResponse errorResponse = new ErrorResponse("Records Not Found");   
        //            result = NotFound404(errorResponse);
        //        }
        //        else
        //        {
        //            ItemResponse<Paged<User>> response = new ItemResponse<Paged<User>>();
        //            response.Item = list;
        //            result = Ok200(response);
        //        }
        //    }
        //    catch (SqlException argEx)
        //    {
        //        result = StatusCode(500, new ErrorResponse($"SqlException Error: {argEx.Message}.")); // new ErrorResponse($"Generic Error: {ex.Message}.");
        //    }
        //    catch (Exception ex)
        //    {
        //        base.Logger.LogError(ex.ToString());
        //        result = StatusCode(500, new ErrorResponse($"Generic Error: {ex.Message}.")); // new ErrorResponse($"Generic Error: {ex.Message}.");
        //    }
        //    return result;
        //}


        //[HttpGet("search")]
        //public ActionResult<ItemsResponse<Paged<User>>> GetPaginatedSearch(int pageIndex, int pageSize, string queryString)
        //{
        //    ActionResult result = null;

        //    try
        //    {
        //        //want to return a list of users
        //        Paged<User> list = _service.GetPaginatedSearch(pageIndex, pageSize, queryString);

        //        if (list == null)
        //        {
        //            ErrorResponse errorResponse = new ErrorResponse("Records Not Found");
        //            result = NotFound404(errorResponse);
        //        }
        //        else
        //        {
        //            ItemResponse<Paged<User>> response = new ItemResponse<Paged<User>>();
        //            response.Item = list;
        //            result = Ok200(response);
        //        }
        //    }
        //    catch (SqlException argEx)
        //    {
        //        result = StatusCode(500, new ErrorResponse($"SqlException Error: {argEx.Message}.")); // new ErrorResponse($"Generic Error: {ex.Message}.");
        //    }
        //    catch (Exception ex)
        //    {
        //        base.Logger.LogError(ex.ToString());
        //        result = StatusCode(500, new ErrorResponse($"Generic Error: {ex.Message}.")); // new ErrorResponse($"Generic Error: {ex.Message}.");
        //    }
        //    return result;
        //}

        [AllowAnonymous]
        [HttpPost("")]
        public ActionResult<ItemResponse<int>> Create(UserAddRequest model)
        {
            ObjectResult result = null;

            try
            {
                int id = _service.Create(model);
                ItemResponse<int> response = new ItemResponse<int>();
                response.Item = id;
                result = Created201(response);
            }
            catch (SqlException argEx)
            {
                ErrorResponse response = new ErrorResponse(argEx.Message);
                result = StatusCode(500, response);
            }
            catch (ArgumentException argEx)
            {
                ErrorResponse response = new ErrorResponse(argEx.Message);
                result = StatusCode(500, response);
            }
            catch (Exception ex)
            {
                base.Logger.LogError(ex.ToString());
                ErrorResponse response = new ErrorResponse(ex.Message);
                result = StatusCode(500, response);
            }
            return result;
        }


        //[HttpDelete("{id:int}")]
        //public ActionResult<ItemResponse<int>> DeleteById(int id)
        //{
        //    int iCode = 200;
        //    BaseResponse response = null;

        //    try
        //    {
        //        //no return since the method is void
        //        _service.Delete(id);

        //        //generic success response
        //        response = new SuccessResponse();
        //    }
        //    catch (SqlException argEx)
        //    {
        //        iCode = 500;
        //        response = new ErrorResponse($"SqlException Error: {argEx.Message}.");
        //    }
        //    catch (ArgumentException argEx)
        //    {
        //        iCode = 500;
        //        response = new ErrorResponse($"ArgumentException Error: {argEx.Message}.");
        //    }
        //    catch (Exception ex)
        //    {
        //        base.Logger.LogError(ex.ToString());
        //        iCode = 500;
        //        response = new ErrorResponse($"Generic Error: {ex.Message}.");
        //    }
        //    return StatusCode(iCode, response);
        //}


        //[HttpPut("{id:int}")]
        //public ActionResult<ItemResponse<int>> Update(UserUpdateRequest model)   //no need to put ID in JSON, but it will need to be in the URL
        //{

        //    int iCode = 200;
        //    BaseResponse response = null;

        //    try
        //    {
        //        _service.Update(model);

        //        response = new SuccessResponse();
        //    }
        //    catch (SqlException argEx)
        //    {
        //        iCode = 500;
        //        response = new ErrorResponse($"SqlException Error: {argEx.Message}.");
        //    }
        //    catch (ArgumentException argEx)
        //    {
        //        iCode = 500;
        //        response = new ErrorResponse($"ArgumentException Error: {argEx.Message}.");
        //    }
        //    catch (Exception ex)
        //    {
        //        base.Logger.LogError(ex.ToString());
        //        iCode = 500;
        //        response = new ErrorResponse($"Generic Error: {ex.Message}.");
        //    }
        //    return StatusCode(iCode, response);
        //}
    }
}
