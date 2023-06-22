using Golden.Models.Domain.Users;
using Golden.Models.Requests.Users;
using System.Threading.Tasks;

namespace Golden.Services.Interfaces
{
    public interface IUserService
    {
        int Create(UserAddRequest userModel);

        //added by John Nelson 4/26/2023
        User GetUserById(int id);

        void LogOut();

        Task<bool> LogInAsync(string email, string password);

        /// <summary>
        /// ** This method should never be removed from this Interface **
        /// An Instructor will remove it when appropriate.
        /// </summary>
        /// <param name="email"></param>
        /// <param name="password"></param>
        /// <param name="id"></param>
        /// <param name="roles"></param>
        /// <returns></returns>
        Task<bool> LogInTest(string email, string password, int id, string[] roles = null);
    }
}