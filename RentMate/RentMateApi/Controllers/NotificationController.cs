using ApplicationCore.Dto.Notification;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using RentMateApi.Hubs;
using Services.Services;
using System.Net.Http;
using System.Security.Claims;
using System.Text;
using System.Text.Json;

namespace RentMateApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NotificationController : ControllerBase
    {
        private readonly IHubContext<NotificationHub> _hubContext;
        private readonly INotificationService _notificationService;
        private readonly IUserService _userService;
        public NotificationController(IHubContext<NotificationHub> hubContext, INotificationService notificationService, IUserService userService)
        {
            _hubContext = hubContext;
            _notificationService = notificationService;
            _userService = userService;
        }
        
        [HttpPost]
        public async Task<IActionResult> CreateNotification([FromBody] NotificationDto dto,
        [FromServices] IHubContext<NotificationHub> hubContext)
        {
            var senderIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (senderIdClaim == null || !int.TryParse(senderIdClaim.Value, out int senderId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }
            var sender = await _userService.GetUserById(senderId);
            var senderName = $"{sender.FirstName} {sender.LastName}";

            var notification = await _notificationService.CreateNotification(senderId, dto.ReceiverId, senderName, dto.Type);
            var receiverUnreadNoti = await _notificationService.CountHowMuchNotRead(dto.ReceiverId);

            //var payload = new
            //{
            //    eventType = "SignalRTest",
            //    message = "test",
            //    timestamp = DateTime.UtcNow
            //};


            //var json = JsonSerializer.Serialize(payload);
            //var content = new StringContent(json, Encoding.UTF8, "application/json");

            //var response = await _http.PostAsync("https://eob08tjba1fgk4q.m.pipedream.net", content);
            //response.EnsureSuccessStatusCode();

            await _hubContext.Clients.User(dto.ReceiverId.ToString()).SendAsync("ReceiveUnreadCount", receiverUnreadNoti);
            //await _hubContext.Clients.All.SendAsync("ReceiveUnreadCount", receiverUnreadNoti);

            return Ok(notification);
        }
        [Authorize]
        [HttpGet]
        public async Task<IActionResult> GetListOfNotifications()
        {
            var receiverIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (receiverIdClaim == null || !int.TryParse(receiverIdClaim.Value, out int receiverId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }
            var listOfNotifications = await _notificationService.GetListOfReceiverNotifications(receiverId);
            return Ok(listOfNotifications);
        }
        [Authorize]
        [HttpGet("countUnreadNotification")]
        public async Task<IActionResult> CountUnreadNotification()
        {
            var receiverIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (receiverIdClaim == null || !int.TryParse(receiverIdClaim.Value, out int receiverId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }

            var unreadNoti = await _notificationService.CountHowMuchNotRead(receiverId);
            return Ok(unreadNoti);
        }
    }
}
