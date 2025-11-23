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
        [HttpGet("activeUserChatsFirstMessage")]
        public async Task<IActionResult> SendFirstPrivateMessage(int chatIdToOpen)
        
        {
            var activeUserIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (activeUserIdClaim == null || !int.TryParse(activeUserIdClaim.Value, out int activeUserId))
            {

                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }

            var chats = await _chatService.GetAllPrivateChatsForUser(activeUserId, chatIdToOpen);
            return Ok(chats);
        }
        [HttpPost("privateChat")]
        public async Task<IActionResult> CreatePrivateChat([FromQuery]int otherUserId)
        {
            try
            {
                var activeUserIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (activeUserIdClaim == null || !int.TryParse(activeUserIdClaim.Value, out int activeUserId))
                {
                    return Unauthorized(new { message = "User not authenticated or invalid user ID." });
                }
                if (activeUserId == otherUserId) return BadRequest(new { message = "Cannot create chat with yourself." });
                
                // Sprawdź, czy prywatny czat już istnieje
                var existingChatId = await _chatService.CheckIfPrivateChatExists(activeUserId, otherUserId);

                if (existingChatId == null)
                {
                    // Utwórz nowy prywatny czat
                    var chat = await _chatService.CreateChat(activeUserId, otherUserId);
                    return Ok(chat);
                }
                else
                {
                    var existingChat = await _chatService.GetChatById(existingChatId.Value);
                    if (existingChat == null)
                    {
                        var chat = await _chatService.CreateChat(activeUserId, otherUserId);
                        return Ok(chat);
                    }
                    return Ok(existingChat);
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Error creating private chat: {ex.Message}" });
            }
        }
        /*[HttpPost("groupChat")]
        public async Task<IActionResult> CreateGroupChatForProperty()
        {
            await _chatService.CreateChat
        }
        [HttpPost("groupChat")]
        public async Task<IActionResult> CreateGroupChatForProperty()
        {
            await _chatService.CreateChat
        }*/
    }
}
