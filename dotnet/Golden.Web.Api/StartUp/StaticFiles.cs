using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;

namespace Golden.Web.Api.StartUp
{
    public class StaticFiles
    {
        public static void ConfigureServices(IServiceCollection services)
        {
        }

        public static void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            app.UseStaticFiles();
        }
    }
}