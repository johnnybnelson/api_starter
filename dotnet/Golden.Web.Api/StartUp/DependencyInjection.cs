using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Golden.Data;
using Golden.Services;
using Golden.Services.CodingChallenge;
using Golden.Services.Interfaces;
using Golden.Web.Api.Controllers;
using Golden.Web.Core.Services;
using System;
using Golden.Services.Interfaces.Security;
using Golden.Data.Providers;
using Golden.Data.Interfaces;

namespace Golden.Web.Api.StartUp
{
    public class DependencyInjection
    {
        public static void ConfigureServices(IServiceCollection services, IConfiguration configuration)
        {
            if (configuration is IConfigurationRoot)
            {
                services.AddSingleton(configuration as IConfigurationRoot);   // IConfigurationRoot
            }

            services.AddSingleton(configuration);   // IConfiguration explicitly

            string connString = configuration.GetConnectionString("Default");
            // https://docs.microsoft.com/en-us/aspnet/core/fundamentals/dependency-injection?view=aspnetcore-2.2
            // The are a number of differe Add* methods you can use. Please verify which one you
            // should be using services.AddScoped<IMyDependency, MyDependency>();

            // services.AddTransient<IOperationTransient, Operation>();

            // services.AddScoped<IOperationScoped, Operation>();

            // services.AddSingleton<IOperationSingleton, Operation>();

            services.AddSingleton<IAuthenticationService<int>, WebAuthenticationService>();

            services.AddSingleton<IDataProvider, SqlDataProvider>(delegate (IServiceProvider provider)
            {
                return new SqlDataProvider(connString);
            }
            );

            services.AddSingleton<IIdentityProvider<int>, WebAuthenticationService>();

            services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();
            // Do NOT REMOVE this line below.
            // Edits to the IUserService are OK 
            services.AddSingleton<IUserService, UserService>();

            //NELSON: INJECTING A DEPENDENCY FOR INTERFACES!!!!
            //This section is to associate interfaces with services
            //There was no need to have a separate one for V3 due to
            //the V3 service code being in FriendService.
            //
            services.AddSingleton<IFriendService, FriendService>();
            services.AddSingleton<IAddressService, AddressService>();
            services.AddSingleton<IUserServiceV1, UserServiceV1>();
            services.AddSingleton<ITechCompanyService, TechCompanyService>();
            services.AddSingleton<IJobService, JobService>();
            services.AddSingleton<IEventService, EventService>();
            services.AddSingleton<ICourseService, CourseService>();
            //
            //
        }

        public static void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
        }
    }
}