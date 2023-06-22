using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Golden.Services.Interfaces;
using Golden.Services;
using Golden.Models.Domain.Friends;
using Golden.Web.Models.Responses;
using System.Collections.Generic;
using System.Data.SqlClient;
using System;
using Golden.Models.Domain.Events;
using Golden.Models.Requests.Friends;
using Golden.Models;
using Golden.Models.Requests.Events;
using Golden.Models.Requests.Jobs;
using Microsoft.AspNetCore.Http.HttpResults;
using Golden.Models.Domain.TechCompanies;
using Golden.Services.Interfaces.Security;
using Golden.Models.Interfaces;

namespace Golden.Web.Api.Controllers
{
    [Route("api/events")]
    [ApiController]
    public class EventApiController : BaseApiController //ControllerBase
    {

        private IEventService _service = null;

        private IAuthenticationService<int> _authService = null;

        public EventApiController(IEventService service                         //interface for events
                , ILogger<EventApiController> logger                            //<--for getting existing user id
                , IAuthenticationService<int> authService) : base(logger)       //<--for the logger
        {
            _service = service;
            _authService = authService;
        }

        [HttpGet("")]
        public ActionResult<ItemsResponse<Paged<Event>>> Feeds(int pageIndex, int pageSize)
        {
            ActionResult result = null;

            try
            {
                //want to return a list of events
                Paged<Event> list = _service.Feeds(pageIndex, pageSize);

                if (list == null)
                {
                    ErrorResponse errorResponse = new ErrorResponse("Records Not Found");
                    result = NotFound404(errorResponse);
                }
                else
                {
                    ItemResponse<Paged<Event>> response = new ItemResponse<Paged<Event>>();
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
        public ActionResult<ItemResponse<int>> Create(EventAddRequest model)
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

        [HttpPut("{id:int}")]
        public ActionResult<ItemResponse<int>> Update(EventUpdateRequest model)   //no need to put ID in JSON, but it will need to be in the URL
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
