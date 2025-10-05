using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace RentMateApi.Hubs
{
    [Authorize]
    public class MessageHub : Hub
    {
    }
}
