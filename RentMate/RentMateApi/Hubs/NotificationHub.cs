using Data.Entities;
using Microsoft.AspNetCore.SignalR;

namespace RentMateApi.Hubs
{
    public class NotificationHub : Hub
    {
        public async Task SendNotificationToUser(int userId)
        {
            await Clients.User("ReceiveNotificationCounter", new
            {
                //metoda do liczenia ile nie przeczytanych wiadomości ma user
            })
        }
    }
}
