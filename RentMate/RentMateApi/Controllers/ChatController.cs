using Infrastructure.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Services.Services;
using System;
using System.Runtime.CompilerServices;
using System.Security.Claims;

namespace RentMateApi.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class ChatController : ControllerBase
    {
        private readonly IChatService _chatService;
        private readonly IUserService _userService;
        public ChatController(IChatService chatService, IUserService userService)
        {
            _chatService = chatService;
            _userService = userService;
        }

        [HttpGet("activeUserChats")]
        public async Task<IActionResult> GetChatsForUser() 
        {
            var activeUserIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (activeUserIdClaim == null || !int.TryParse(activeUserIdClaim.Value, out int activeUserId))
            {

                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }
            
            var chats = await _chatService.GetAllPrivateChatsForUser(activeUserId);
            return Ok(chats);
        }
        [HttpPost("privateChat")]
        public async Task<IActionResult> CreatePrivateChat([FromQuery]int otherUserId)
        {
            var activeUserIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (activeUserIdClaim == null || !int.TryParse(activeUserIdClaim.Value, out int activeUserId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }
            var chat = await _chatService.CreateChat(activeUserId, otherUserId);
            return Ok(chat);
        }
        
    }
}
