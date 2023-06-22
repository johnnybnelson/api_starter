using Golden.Models;
using Golden.Models.Domain.Events;
using Golden.Models.Requests.Events;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Services.Interfaces
{
    public interface IEventService
    {

        Paged<Event> Feeds(int pageIndex, int pageSize);

        int Add(EventAddRequest newFriend, int UserId);

        void Update(EventUpdateRequest existingFriend, int UserId);

    }
}
