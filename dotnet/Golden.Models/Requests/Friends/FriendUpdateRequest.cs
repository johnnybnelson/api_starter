using Golden.Models.Interfaces;

namespace Golden.Models.Requests.Friends
{
    //extends FriendAddRequest
    //only contains an ID
    public class FriendUpdateRequest : FriendAddRequest, IModelIdentifier     //<-- IModelIdentifier will allow the /id in the URL to be placed into
    {                                                                       // the ID of the "model" for updates
        public int Id { get; set; }
    }
}
