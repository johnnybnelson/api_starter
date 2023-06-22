//using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Golden.Models.Domain.Friends;
using Golden.Web.Models.Responses;
using System.Collections.Generic;
using System.Data.SqlClient;
using System;
using Microsoft.Extensions.Logging;
using Golden.Services.Interfaces;
using Golden.Services;
using Golden.Models;
using Golden.Models.Requests.Friends;
using Golden.Services.Interfaces.Security;
using Golden.Models.Interfaces;

namespace Golden.Web.Api.Controllers
{
    [Route("api/v3/friends")]
    [ApiController]
    public class FriendApiControllerV3 : BaseApiController    //replaces ControllerBase
    {

        private IFriendService _service = null;

        private IAuthenticationService<int> _authService = null;

        public FriendApiControllerV3(IFriendService service                 //interface for friends
            , ILogger<FriendApiControllerV3> logger                         //<--for getting existing user id
            , IAuthenticationService<int> authService) : base(logger)   //<--for the logger
        {
            _service = service;
            _authService = authService;
        }

        //V3 STARTS HERE
        //
        //api/friends/{id: int}
        [HttpGet("{id:int}")]  //<--route pattern
        public ActionResult<ItemResponse<FriendV3>> GetV3(int id)
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                FriendV3 sFriend = _service.GetV3(id);

                if (sFriend == null)
                {
                    iCode = 404;
                    response = new ErrorResponse("Friend not found!");
                }
                else
                {
                    response = new ItemResponse<FriendV3> { Item = sFriend };
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


        [HttpGet("")]
        public ActionResult<ItemsResponse<FriendV3>> GetAllV3()
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                //want to return a list of friends
                List<FriendV3> list = _service.GetAllV3();


                if (list == null)
                {
                    iCode = 404;
                    response = new ErrorResponse("Records not found!");
                }
                else
                {
                    response = new ItemsResponse<FriendV3> { Items = list };
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


        [HttpGet("paginate")]
        public ActionResult<ItemsResponse<Paged<FriendV3>>> PaginationV3(int pageIndex, int pageSize)
        {
            ActionResult result = null;

            try
            {
                //want to return a list of users
                Paged<FriendV3> list = _service.GetPaginatedV3(pageIndex, pageSize);

                if (list == null)
                {
                    ErrorResponse errorResponse = new ErrorResponse("Records Not Found");
                    result = NotFound404(errorResponse);
                }
                else
                {
                    ItemResponse<Paged<FriendV3>> response = new ItemResponse<Paged<FriendV3>>();
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
        public ActionResult<ItemsResponse<Paged<FriendV3>>> SearchPaginatedV3(int pageIndex, int pageSize, string query)
        {
            ActionResult result = null;

            try
            {
                //want to return a list of users
                Paged<FriendV3> list = _service.GetPaginatedSearchV3(pageIndex, pageSize, query);

                if (list == null)
                {
                    ErrorResponse errorResponse = new ErrorResponse("Records Not Found");
                    result = NotFound404(errorResponse);
                }
                else
                {
                    ItemResponse<Paged<FriendV3>> response = new ItemResponse<Paged<FriendV3>>();
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

        [HttpPost("")]
        public ActionResult<ItemResponse<int>> Create(FriendAddRequestV3 model)
        {

            ObjectResult result = null;

            try
            {
                IUserAuthData user = _authService.GetCurrentUser();   //may not need ... for obtaining userId
                int id = _service.AddV3(model, user.Id);
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

        [HttpPut("{id:int}")]
        public ActionResult<ItemResponse<int>> Update(FriendUpdateRequestV3 model)   //no need to put ID in JSON, but it will need to be in the URL
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                IUserAuthData user = _authService.GetCurrentUser();   //safer..test for nulls

                _service.UpdateV3(model, user.Id);

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

        [HttpDelete("{id:int}")]
        public ActionResult<ItemResponse<int>> DeleteV3(int id)
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                //no return since the method is void
                _service.DeleteV3(id);

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
    }
}
