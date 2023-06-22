using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.IO;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using System.Net.Http;
using System.Linq;
using Golden.Web.Models.Responses;


namespace Golden.Web.Api.Controllers
{
    [Route("api/files")]
    [ApiController]
    public class UploadFileApiController : ControllerBase
    {
        IWebHostEnvironment _environment = null;

        public UploadFileApiController(IWebHostEnvironment environment)
        {
            _environment = environment;
        }

        [HttpPost]
        public async Task<IActionResult> UploadFile(IFormFile file)
        {
            ActionResult result = null;
            string publicUrl = "";

            if (file == null || file.Length == 0)
                return BadRequest("Invalid file");

            try
            {   
                //Upload the file
                //
                string uploadPath = Path.Combine(_environment.ContentRootPath, "uploads");
                string filePath = Path.Combine(uploadPath, file.FileName);
                using (FileStream stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }
                //
                //file uploaded



                //Get NGROK path to file using the second parameter in the ngrok.yml file
                //
                //ngrok.yml file below
                //====================
                //version: "2"
                //authtoken: <<YOUR TOKEN>>
                //tunnels:
                // first:
                //  addr: 50001
                //  proto: http
                // second:
                //  addr: file:///C:\Users\Ryzen5\source\repos\Starter.connecting-to-db-dotnet\dotnet\Golden.Web.Api\uploads    //<--your own path to the upload file
                //  proto: http
                //====================

                string ngrokApiUrl = "http://127.0.0.1:4040/api/tunnels"; // The URL of the ngrok API endpoint
                string tunnelName = "second"; // The name of the ngrok tunnel you want to fetch

                // Create a new HTTP client and send a GET request to the ngrok API endpoint
                HttpClient httpClient = new HttpClient();

                var response = await httpClient.GetAsync(ngrokApiUrl);
                if (!response.IsSuccessStatusCode)
                {
                    result = StatusCode(500, new ErrorResponse($"Could not generate return URL!"));
                }
                else
                {
                    // Parse the response content as a JSON object
                    string responseContent = await response.Content.ReadAsStringAsync();
                    JToken tunnels = JObject.Parse(responseContent)["tunnels"];

                    // Find the tunnel with the specified name
                    var tunnel = tunnels.FirstOrDefault(t => (string)t["name"] == tunnelName);
                    if (tunnel == null)
                    {
                        result = StatusCode(500, new ErrorResponse($"{tunnelName} doesn't exist!"));
                    } else
                    {
                        // Extract the public URL from the tunnel information
                        publicUrl = (string)tunnel["public_url"];
                        Console.WriteLine($"ngrok forwarding address: {publicUrl}");

                        result = Ok(publicUrl + "/" + file.FileName);
                    }
                }
            }
            catch (Exception ex)
            {
                result = StatusCode(500, new ErrorResponse($"Generic Error: {ex.Message}.")); 
            }
            return result;
        }
    }
}
