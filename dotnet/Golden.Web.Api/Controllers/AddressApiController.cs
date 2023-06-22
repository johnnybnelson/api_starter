using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SendGrid;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Net;
using System.Text.RegularExpressions;
using Golden.Models.Domain.Addresses;
using Golden.Web.Models.Responses;
using Golden.Models.Requests.Addresses;
using Golden.Models.Interfaces;
using Golden.Services.Interfaces;
using Golden.Services.Interfaces.Security;
using Golden.Services;

namespace Golden.Web.Api.Controllers
{
    [Route("api/addresses")]
    [ApiController]
    public class AddressApiController : BaseApiController                       //ControllerBase
    {

        private IAddressService _service = null;
        private IAuthenticationService<int> _authService = null;

        public AddressApiController(IAddressService service
            , ILogger<AddressApiController> logger
            , IAuthenticationService<int> authService) : base(logger)
        {
            _service = service;
            _authService = authService;
        }


        //ENDPOINTS FOLLOW!!!!

        //HTTP -> GET -> api/addresses + ""
        //The URL with the Route (api/addresses) with the HttpGet all in combination
        //invokes the GetRandomAddresses() method of IAddressService interface
        //
        [HttpGet("")]
        public ActionResult<ItemsResponse<Address>> GetAll()
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {

                //want to return a list of addresses
                List<Address> list = _service.GetRandomAddresses();

                if (list == null)
                {
                    iCode = 404;
                    response = new ErrorResponse("Record not found!");
                }

                else
                {
                    response = new ItemsResponse<Address> { Items = list };
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

        //api/addresses/{id: int}
        [HttpGet("{id:int}")]  //<--route pattern
        public ActionResult<ItemResponse<Address>> Get(int id)
        {
            int iCode = 200;
            BaseResponse response = null;

            try
            {

                Address anAddress = _service.Get(id); ;

                if(anAddress == null)
                {
                    iCode = 404;
                    response = new ErrorResponse("Record not found!");
                }
                else
                {
                    response = new ItemResponse<Address> { Item = anAddress };
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


        [HttpPost("")]
        public ActionResult<ItemResponse<int>> Create(AddressAddRequest model) {

            ObjectResult result = null;

            try
            {
                IUserAuthData user = _authService.GetCurrentUser();   //safer..test for nulls
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
        public ActionResult<ItemResponse<int>> Update(AddressUpdateRequest model)   //no need to put ID in JSON, but it will need to be in the URL
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
