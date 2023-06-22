using Golden.Models;
using Golden.Models.Domain.Friends;
using Golden.Models.Requests.Friends;
using System.Collections.Generic;

namespace Golden.Services.Interfaces
{
    //stubs - these param/arg signatures must match those in UserServiceV1
    //they are linked in DependencyInjection.cs
    //
    public interface IFriendService
    {
        int Add(FriendAddRequest newFriend, int UserId);


        void Delete(int deleteId);


        Friend Get(int id);

        List<Friend> GetAll();

        void Update(FriendUpdateRequest existingFriend, int UserId);

        Paged<Friend> GetPaginated(int pageIndex, int pageSize);

        Paged<Friend> GetPaginatedSearch(int pageIndex, int pageSize, string queryString);

        FriendV3 GetV3(int id);

        List<FriendV3> GetAllV3();

        Paged<FriendV3> GetPaginatedV3(int pageIndex, int pageSize);

        Paged<FriendV3> GetPaginatedSearchV3(int pageIndex, int pageSize, string queryString);

        int AddV3(FriendAddRequestV3 newFriend, int UserId);

        void UpdateV3(FriendUpdateRequestV3 existingFriend, int UserId);

        void DeleteV3(int deleteId);
    }
}