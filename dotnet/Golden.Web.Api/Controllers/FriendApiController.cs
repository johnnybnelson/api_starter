using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Golden.Services.Interfaces;
using Golden.Web.Models.Responses;
using System.Collections.Generic;
using System.Data.SqlClient;
using System;
using Golden.Models.Domain.Friends;
using Golden.Models.Requests.Friends;
using Golden.Models;
using Golden.Models.Interfaces;
using Golden.Services;

namespace Golden.Web.Api.Controllers
{
    [Route("api/friends")]
    [ApiController]
    public class FriendApiController : BaseApiController                    //replaces ControllerBase
    {
        private IFriendService _service = null;

        private IAuthenticationService<int> _authService = null;

        public FriendApiController(IFriendService service                   //interface for friends
            , ILogger<FriendApiController> logger                           //<--for getting existing user id
            , IAuthenticationService<int> authService) : base(logger)       //<--for the logger
        {
            _service = service;
            _authService = authService;
        }

        [HttpGet("")]
        public ActionResult<ItemsResponse<Friend>> GetAll()
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                //want to return a list of friends
                List<Friend> list = _service.GetAll();

                if (list == null)
                {
                    iCode = 404;
                    response = new ErrorResponse("Records not found!");
                }
                else
                {
                    response = new ItemsResponse<Friend> { Items = list };
                }
            }
            catch (SqlException argEx)
            {
                iCode = 500;
                response = new ErrorResponse($"SqlException Error: {argEx.Message}.");
            }
            catch (Exception ex)
            {
                base.Logger.LogError(ex.ToString());
                iCode = 500;
                response = new ErrorResponse($"Generic Error: {ex.Message}.");
            }
            return StatusCode(iCode, response);
        }

        //api/friends/{id: int}
        [HttpGet("{id:int}")]  //<--route pattern
        public ActionResult<ItemResponse<Friend>> GetById(int id)
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                Friend sFriend = _service.Get(id); ;

                if (sFriend == null)
                {
                    iCode = 404;
                    response = new ErrorResponse("Friend not found!");
                }
                else
                {
                    response = new ItemResponse<Friend> { Item = sFriend };
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


        [HttpGet("paginate")]
        public ActionResult<ItemsResponse<Paged<Friend>>> GetPaginated(int pageIndex, int pageSize)
        {
            ActionResult result = null;

            try
            {
                //want to return a list of users
                Paged<Friend> list = _service.GetPaginated(pageIndex, pageSize);

                if (list == null)
                {
                    ErrorResponse errorResponse = new ErrorResponse("Records Not Found");
                    result = NotFound404(errorResponse);
                }
                else
                {
                    ItemResponse<Paged<Friend>> response = new ItemResponse<Paged<Friend>>();
                    response.Item = list;
                    result = Ok200(response);
                }
            }
            catch (SqlException argEx)
            {
                result = StatusCode(500, new ErrorResponse($"SqlException Error: {argEx.Message}.")); // new ErrorResponse($"Generic Error: {ex.Message}.");

            }
            catch (Exception ex)
            {
                base.Logger.LogError(ex.ToString());
                result = StatusCode(500, new ErrorResponse($"Generic Error: {ex.Message}.")); // new ErrorResponse($"Generic Error: {ex.Message}.");
            }
            return result;
        }


        [HttpGet("search")]
        public ActionResult<ItemsResponse<Paged<Friend>>> GetPaginatedSearch(int pageIndex, int pageSize, string queryString)
        {
            ActionResult result = null;

            try
            {
                //want to return a list of users
                Paged<Friend> list = _service.GetPaginatedSearch(pageIndex, pageSize, queryString);

                if (list == null)
                {
                    //iCode = 404;
                    ErrorResponse errorResponse = new ErrorResponse("Records Not Found");
                    result = NotFound404(errorResponse);
                }
                else
                {
                    ItemResponse<Paged<Friend>> response = new ItemResponse<Paged<Friend>>();
                    response.Item = list;
                    result = Ok200(response);
                }
            }
            catch (SqlException argEx)
            {
                result = StatusCode(500, new ErrorResponse($"SqlException Error: {argEx.Message}.")); // new ErrorResponse($"Generic Error: {ex.Message}.");

            }
            catch (Exception ex)
            {
                base.Logger.LogError(ex.ToString());
                //iCode = 500;
                result = StatusCode(500, new ErrorResponse($"Generic Error: {ex.Message}.")); // new ErrorResponse($"Generic Error: {ex.Message}.");
            }
            return result;
        }


        [HttpPost("")]
        public ActionResult<ItemResponse<int>> Create(FriendAddRequest model)
        {

            ObjectResult result = null;

            try
            {
                IUserAuthData user = _authService.GetCurrentUser();   //may not need ... for obtaining userId
                int id = _service.Add(model, user.Id);
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


        [HttpDelete("{id:int}")]
        public ActionResult<ItemResponse<int>> Delete(int id)
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                //no return since the method is void
                _service.Delete(id);

                //generic success response
                response = new SuccessResponse();

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


        [HttpPut("{id:int}")]
        public ActionResult<ItemResponse<int>> Update(FriendUpdateRequest model)   //no need to put ID in JSON, but it will need to be in the URL
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                IUserAuthData user = _authService.GetCurrentUser();   //safer..test for nulls

                _service.Update(model, user.Id);

                response = new SuccessResponse();
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
    }
}
