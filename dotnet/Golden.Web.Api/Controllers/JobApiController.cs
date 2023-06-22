using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Golden.Services.Interfaces;
using Golden.Services;
using Microsoft.Extensions.Logging;
using Golden.Models.Domain.TechCompanies;
using Golden.Models;
using Golden.Web.Models.Responses;
using System.Data.SqlClient;
using System;
using Golden.Models.Domain.Jobs;
using Golden.Models.Requests.TechCompanies;
using Golden.Models.Requests.Jobs;
using Golden.Services.Interfaces.Security;
using Golden.Models.Interfaces;

namespace Golden.Web.Api.Controllers
{
    [Route("api/jobs")]
    [ApiController]
    public class JobApiController : BaseApiController    //ControllerBase
    {

        private IJobService _service = null;

        private IAuthenticationService<int> _authService = null;


        public JobApiController(IJobService service                 //interface for friends
            , ILogger<JobApiController> logger                         //<--for getting existing user id
            , IAuthenticationService<int> authService) : base(logger)   //<--for the logger
        {
            _service = service;
            _authService = authService;
        }

        [HttpGet("paginate")]
        public ActionResult<ItemsResponse<Paged<Job>>> Pagination(int pageIndex, int pageSize)
        {
            ActionResult result = null;

            try
            {                //want to return a list of users
                Paged<Job> list = _service.GetPaginated(pageIndex, pageSize);

                if (list == null)
                {
                    ErrorResponse errorResponse = new ErrorResponse("Records Not Found");
                    result = NotFound404(errorResponse);
                }
                else
                {
                    ItemResponse<Paged<Job>> response = new ItemResponse<Paged<Job>>();
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
        public ActionResult<ItemsResponse<Paged<Job>>> PaginationSearch(int pageIndex, int pageSize, string search)
        {
            ActionResult result = null;

            try
            {                //want to return a list of users
                Paged<Job> list = _service.GetPaginatedSearch(pageIndex, pageSize, search);

                if (list == null)
                {
                    ErrorResponse errorResponse = new ErrorResponse("Records Not Found");
                    result = NotFound404(errorResponse);
                }
                else
                {
                    ItemResponse<Paged<Job>> response = new ItemResponse<Paged<Job>>();
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


        [HttpGet("{id:int}")]  //<--route pattern
        public ActionResult<ItemResponse<Job>> GetById(int id)
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                Job sJob = _service.GetById(id);

                if (sJob == null)
                {
                    iCode = 404;
                    response = new ErrorResponse("Friend not found!");
                }
                else
                {
                    response = new ItemResponse<Job> { Item = sJob };
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


        [HttpPut("{id}/{status}")]
        public ActionResult<ItemResponse<int>> SetStatus(int Id, string status)
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                //no return since the method is void
                _service.SetStatus(Id, status);

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


        public ActionResult<ItemResponse<int>> Create(JobAddRequest model)
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
        public ActionResult<ItemResponse<int>> Update(JobUpdateRequest model)
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
