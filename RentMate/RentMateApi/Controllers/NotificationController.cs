using ApplicationCore.Dto.Notification;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using RentMateApi.Hubs;
using Services.Services;
using System.Security.Claims;

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
            await _hubContext.Clients.User(dto.ReceiverId.ToString()).SendAsync("ReceiveUnreadCount", receiverUnreadNoti);

            return Ok(notification);
        }
        [HttpGet]
        public async Task<IActionResult> GetListOfNotifications()
        {
            var receiverIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (receiverIdClaim == null || !int.TryParse(receiverIdClaim.Value, out int receiverId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }
            var listOfNotifications = _notificationService.GetListOfReceiverNotifications(receiverId);
            return Ok(listOfNotifications);
        }
    }
}
