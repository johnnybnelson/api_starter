using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Golden.Services.Interfaces;
using Golden.Services;
using Golden.Models.Domain.Friends;
using Golden.Models;
using Golden.Web.Models.Responses;
using System.Data.SqlClient;
using System;
using Golden.Models.Domain.TechCompanies;
using Golden.Models.Requests.Friends;
using Golden.Models.Requests.TechCompanies;
using Golden.Services.Interfaces.Security;
using Golden.Models.Interfaces;

namespace Golden.Web.Api.Controllers
{


    [Route("api/techcompanies")]
    [ApiController]
    public class TechCompanyApiController : BaseApiController //ControllerBase
    {


        private ITechCompanyService _service = null;


        private IAuthenticationService<int> _authService = null;


        public TechCompanyApiController(ITechCompanyService service                 //interface for friends
                , ILogger<TechCompanyApiController> logger                         //<--for getting existing user id
                , IAuthenticationService<int> authService) : base(logger)   //<--for the logger
        {
            _service = service;
            _authService = authService;
        }


        [HttpGet("paginate")]
        public ActionResult<ItemsResponse<Paged<TechCompany>>> Pagination(int pageIndex, int pageSize)
        {
            ActionResult result = null;

            try
            {                //want to return a list of users
                Paged<TechCompany> list = _service.GetPaginated(pageIndex, pageSize);

                if (list == null)
                {
                    ErrorResponse errorResponse = new ErrorResponse("Records Not Found");
                    result = NotFound404(errorResponse);
                }
                else
                {
                    ItemResponse<Paged<TechCompany>> response = new ItemResponse<Paged<TechCompany>>();
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
        public ActionResult<ItemsResponse<Paged<TechCompany>>> PaginationSearch(int pageIndex, int pageSize, string search)
        {
            ActionResult result = null;

            try
            {                //want to return a list of users
                Paged<TechCompany> list = _service.GetPaginatedSearch(pageIndex, pageSize, search);

                if (list == null)
                {
                    ErrorResponse errorResponse = new ErrorResponse("Records Not Found");
                    result = NotFound404(errorResponse);
                }
                else
                {
                    ItemResponse<Paged<TechCompany>> response = new ItemResponse<Paged<TechCompany>>();
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
        public ActionResult<ItemResponse<TechCompany>> GetById(int id)
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                TechCompany sTechCompany = _service.GetById(id);

                if (sTechCompany == null)
                {
                    iCode = 404;
                    response = new ErrorResponse("Friend not found!");
                }
                else
                {
                    response = new ItemResponse<TechCompany> { Item = sTechCompany };
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

        [HttpPost("")]
        public ActionResult<ItemResponse<int>> Create(TechCompanyAddRequest model)
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
        public ActionResult<ItemResponse<int>> Update(TechCompanyUpdateRequest model)
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
