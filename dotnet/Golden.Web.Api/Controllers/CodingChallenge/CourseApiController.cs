using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Golden.Models;
using Golden.Models.Domain.Jobs;
using Golden.Services;
using Golden.Web.Models.Responses;
using System.Data.SqlClient;
using System;
using Golden.Models.Requests.Jobs;
using Golden.Models.Domain.CodingChallenge.Domain;
using Golden.Models.Domain.CodingChallenge.Requests;
using Golden.Services.CodingChallenge;
using Golden.Services.Interfaces.Security;
using Golden.Models.Interfaces;

namespace Golden.Web.Api.Controllers.CodingChallenge
{
    [Route("api/courses")]
    [ApiController]
    public class CourseApiController : BaseApiController    //ControllerBase
    {


        private ICourseService _service = null;

        private IAuthenticationService<int> _authService = null;

        public CourseApiController(ICourseService service                 //interface for users
            , ILogger<CourseApiController> logger                         //<--for getting existing user id
            , IAuthenticationService<int> authService) : base(logger)   //<--for the logger
        {
            _service = service;
            _authService = authService;
        }


        [HttpGet("{id:int}")]  //<--route pattern
        public ActionResult<ItemResponse<Course>> GetById(int id)
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                Course thisJob = _service.GetCourseById(id);

                if (thisJob == null)
                {
                    iCode = 404;
                    response = new ErrorResponse("Courses not found!");
                }
                else
                {
                    response = new ItemResponse<Course> { Item = thisJob };
                }
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
        public ActionResult<ItemResponse<int>> Create(CourseAddRequest model)
        {

            ObjectResult result = null;

            try
            {
                IUserAuthData user = _authService.GetCurrentUser();   //may not need ... for obtaining userId
                int id = _service.AddCourse(model);
                ItemResponse<int> response = new ItemResponse<int>();
                response.Item = id;
                result = Created201(response);
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
        public ActionResult<ItemResponse<int>> Update(CourseUpdateRequest model)
        {

            int iCode = 200;
            BaseResponse response = null;

            try
            {
                IUserAuthData user = _authService.GetCurrentUser();   //safer..test for nulls

                _service.UpdateCourse(model);

                response = new SuccessResponse();
            }
            catch (Exception ex)
            {
                base.Logger.LogError(ex.ToString());
                iCode = 500;
                response = new ErrorResponse($"Generic Error: {ex.Message}.");
            }

            return StatusCode(iCode, response);
        }


        [HttpDelete("students/{id:int}")]
        public ActionResult<ItemResponse<int>> Delete(int id)
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {
                //no return since the method is void
                _service.DeleteStudent(id);

                //generic success response
                response = new SuccessResponse();
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
        public ActionResult<ItemsResponse<Paged<Course>>> Pagination(int pageIndex, int pageSize)
        {
            ActionResult result = null;

            try
            {                //want to return a list of users
                Paged<Course> list = _service.GetCoursesByPage(pageIndex, pageSize);

                if (list == null)
                {
                    ErrorResponse errorResponse = new ErrorResponse("Records Not Found");
                    result = NotFound404(errorResponse);
                }
                else
                {
                    ItemResponse<Paged<Course>> response = new ItemResponse<Paged<Course>>();
                    response.Item = list;
                    result = Ok200(response);
                }
            }
            catch (Exception ex)
            {
                base.Logger.LogError(ex.ToString());
                result = StatusCode(500, new ErrorResponse($"Generic Error: {ex.Message}.")); // new ErrorResponse($"Generic Error: {ex.Message}.");
            }
            return result;
        }


    }
}
