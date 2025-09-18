using ApplicationCore.Dto.Notification;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using RentMateApi.Hubs;

namespace RentMateApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NotificationController : ControllerBase
    {
        private readonly IHubContext<NotificationHub> _hubContext;
        public NotificationController(IHubContext<NotificationHub> hubContext)
        {
            _hubContext = hubContext;
        }
        [HttpPost]
        public async Task<IActionResult> PostNotification([FromBody] NotificationDto dto)
        {
            await _hubContext.Clients.All.SendAsync("ReceiveNotification", new
            {
                dto.Title,
                dto.Message,
                TimeStamp = DateTime.UtcNow,
            });
            return Ok(new { Status = "Sent" });
        }
    }
}
