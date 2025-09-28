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
        //public override async Task OnConnectedAsync()
        //{
        //    var userId = Context.UserIdentifier;
        //    Console.WriteLine($"[SignalR] User connected: {userId}, ConnectionId: {Context.ConnectionId}");
        //    await base.OnConnectedAsync();
        //}

        //public override async Task OnDisconnectedAsync(Exception? exception)
        //{
        //    Console.WriteLine($"[SignalR] User disconnected: {Context.UserIdentifier}, ConnId: {Context.ConnectionId}");
        //    await base.OnDisconnectedAsync(exception);
        //}
    }

}
