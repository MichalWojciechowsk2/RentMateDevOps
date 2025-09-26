using ApplicationCore.Dto.Notification;
using Data.Entities;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace RentMateApi.Hubs
{
    [Authorize]
    public class NotificationHub : Hub
    {
        
    }

}
