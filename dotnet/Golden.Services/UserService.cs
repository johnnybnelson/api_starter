using Golden.Services.Interfaces;
using Golden.Services.Interfaces.Security;
using Golden.Data;
using Golden.Data.Providers;
using Golden.Models;
using Golden.Models.Domain;
using Golden.Models.Domain.Users;
using Golden.Models.Requests.Users;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Golden.Models.Interfaces;
using Golden.Data.Interfaces;
using Golden.Data.Extensions;

namespace Golden.Services
{
    public class UserService : IUserService
    {
        private IAuthenticationService<int> _authenticationService;
        private IDataProvider _dataProvider;

        public UserService(IAuthenticationService<int> authService, IDataProvider dataProvider)
        {
            _authenticationService = authService;
            _dataProvider = dataProvider;
        }

        //log out function
        public async void LogOut()
        {
            await _authenticationService.LogOutAsync();
        }

        //Changed from Task<bool> to Task<User> by John Nelson 4/26/2023
        //
        public async Task<bool> LogInAsync(string email, string password)
        {

            bool isSuccessful = false;

            //User thisUser = null;

            //Lets see if this user is legit!
            //
            IUserAuthData response = Get(email, password);

            //if there was data returned with proper
            //password checks, log in with the authentication service
            //
            if (response != null)
            {
                //wait for authentication to be completed
                await _authenticationService.LogInAsync(response);
                isSuccessful = true;
            }

            //Everything is good...go get the complete user record
            //based on this user id
            //
            //thisUser = GetUserById(response.Id);

            return isSuccessful;
        }

        #region - DO NOT REMOVE - DO NOT EDIT - EVER

        public User GetUserById(int id)
        {
            User thisUser = null;

            string procName = "[dbo].[Users_SelectById]";

            _dataProvider.ExecuteCmd(procName, delegate (SqlParameterCollection paramCollection)
            {
                //param mapper takes data in one shape and produces another shape
                //int->param(int)
                paramCollection.AddWithValue("@Id", id);

            }, delegate (IDataReader reader, short set)
            {
                int startIndex = 0;
                thisUser = new User();

                thisUser.Id = reader.GetSafeInt32(startIndex++);
                thisUser.FirstName = reader.GetSafeString(startIndex++);
                thisUser.LastName = reader.GetSafeString(startIndex++);
                thisUser.Email = reader.GetSafeString(startIndex++);
                thisUser.AvatarUrl = reader.GetSafeString(startIndex++);
                thisUser.TenantId = reader.GetSafeString(startIndex++);
                thisUser.DateCreated = reader.GetSafeDateTime(startIndex++);
                thisUser.DateModified = reader.GetSafeDateTime(startIndex++);
                thisUser.Roles = reader.GetSafeString(startIndex++);
            }
            );
            return thisUser;
        }

        /// <summary>
        /// ** This method should never be removed from this Interface or this class **
        /// An Instructor will remove it when appropriate.
        /// If you ever do anything to break this method, you need to fix it right away.
        /// </summary>
        /// <param name="email"></param>
        /// <param name="password"></param>
        /// <param name="id"></param>
        /// <param name="roles"></param>
        /// <returns></returns>
        public async Task<bool> LogInTest(string email, string password, int id, string[] roles = null)
        {
            bool isSuccessful = false;
            var testRoles = new[] { "User", "Super", "Content Manager" };

            var allRoles = roles == null ? testRoles : testRoles.Concat(roles);

            IUserAuthData response = new UserBase
            {
                Id = id
                ,
                Name = email
                ,
                Roles = allRoles
                ,
                TenantId = "Acme Corp UId"
            };

            Claim fullName = new Claim("CustomClaim", "Golden");
            await _authenticationService.LogInAsync(response, new Claim[] { fullName });

            return isSuccessful;
        }

        #endregion

        public int Create(UserAddRequest userModel)
        {
            int userId = 0;
            string password = userModel.Password;
            string salt = BCrypt.BCryptHelper.GenerateSalt();
            string hashedPassword = BCrypt.BCryptHelper.HashPassword(password, salt);

            //password has been "hashed" and passed back
            userModel.Password = hashedPassword;

            //DB provider call to create user and get us a user id
            string procName = "[dbo].[Users_Insert]";
            _dataProvider.ExecuteNonQuery(procName, inputParamMapper: delegate (SqlParameterCollection paramCollection)
            {
                paramCollection.AddWithValue("@FirstName", userModel.FirstName);
                paramCollection.AddWithValue("@LastName", userModel.LastName);
                paramCollection.AddWithValue("@Email", userModel.Email);
                paramCollection.AddWithValue("@Password", userModel.Password);
                paramCollection.AddWithValue("@AvatarUrl", userModel.AvatarUrl);
                paramCollection.AddWithValue("@TenantId", userModel.TenantId);

                //setting up an output parameter
                SqlParameter idOut = new SqlParameter("@Id", SqlDbType.Int);
                idOut.Direction = ParameterDirection.Output;

                //add it to the collection
                paramCollection.Add(idOut);

            }, returnParameters: delegate (SqlParameterCollection returnCollection)
            {
                //value is an object
                object oId = returnCollection["@Id"].Value;

                //convert the object to an int
                int.TryParse(oId.ToString(), out userId);
            }
            );

            //return the userID of the record just created
            return userId;
        }

        /// <summary>
        /// Gets the Data call to get a give user
        /// </summary>
        /// <param name="email"></param>
        /// <param name="passwordHash"></param>
        /// <returns></returns>
        private IUserAuthData Get(string email, string password)
        {
            UserBase user = new UserBase();

            //Created a new class UserWithPassword because the existing User model 
            //does not have password as a property
            //UserWithPassword inherits from User
            //
            UserWithPassword thisUser = GetExistingUser(email);

            //if(thisUser == null)

            //check the password -- unhash it and compare --
            string passwordFromDb = thisUser == null ? "" : thisUser.Password;
            bool isValidCredentials = BCrypt.BCryptHelper.CheckPassword(password, passwordFromDb);

            if (isValidCredentials)
            {
                user.TenantId = new object();
                user.TenantId = thisUser.TenantId;
                user.Name = thisUser.FirstName + " " + thisUser.LastName;
                user.Id = thisUser.Id;
            }
            //populate the UserBase object
            //remember, in UserBase, TenantId is an object
            return user;
        }

        public UserWithPassword GetExistingUser(string email)
        {
            //this stored proc returns match based on email
            //
            string procName = "[dbo].[Users_ByEmail]";

            UserWithPassword thisUser = null;

            _dataProvider.ExecuteCmd(procName, delegate (SqlParameterCollection paramCollection)
            {
                paramCollection.AddWithValue("@email", email);

            }, delegate (IDataReader reader, short set)
            {

                int startIndex = 0;


                thisUser = new UserWithPassword();
                thisUser.Id = reader.GetSafeInt32(startIndex++);
                thisUser.FirstName = reader.GetSafeString(startIndex++);
                thisUser.LastName = reader.GetSafeString(startIndex++);
                thisUser.Email = reader.GetSafeString(startIndex++);
                thisUser.Password = reader.GetSafeString(startIndex++);
                thisUser.AvatarUrl = reader.GetSafeString(startIndex++);
                thisUser.TenantId = reader.GetSafeString(startIndex++);
                thisUser.DateCreated = reader.GetSafeDateTime(startIndex++);
                thisUser.DateModified = reader.GetSafeDateTime(startIndex++);
            }
            );
            return thisUser;
        }
    }
}