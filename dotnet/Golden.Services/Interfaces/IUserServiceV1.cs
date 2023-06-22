using Golden.Models;
using Golden.Models.Domain.Users;
using Golden.Models.Requests.Users;
using System.Collections.Generic;

namespace Golden.Services.Interfaces
{
    public interface IUserServiceV1
    {
        //stubs - these param/arg signatures must match those in UserServiceV1
        //they are linked in DependencyInjection.cs
        //
        int Add(UserAddRequest newUser);

        void Delete(int deleteId);

        User Get(int id);

        List<User> GetAll();

        Paged<User> GetPaginated(int pageIndex, int pageSize);

        Paged<User> GetPaginatedSearch(int pageIndex, int pageSize, string searchString);

        void Update(UserUpdateRequest existingUser);

        User Login(UserLogin user);
    }
}