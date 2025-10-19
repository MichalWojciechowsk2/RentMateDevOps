using ApplicationCore.Dto.Message;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Services.Services;
using System.Security.Claims;

namespace RentMateApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class MessageController : ControllerBase
    {
        private readonly IMessageService _messageService;
        private readonly IChatService _chatService;

        public MessageController(IMessageService messageService, IChatService chatService)
        {
            _messageService = messageService;
            _chatService = chatService;
        }


        //rozwa¿yæ czy bêdzie do usuniêcia skoro korzystamy z chatów
        //[HttpGet("conversation")]
        //public async Task<IActionResult> GetConversation([FromQuery] int otherUserId)
        //{
        //    try
        //    {
        //        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
        //        if (userId == 0)
        //            return Unauthorized();

        //        var messages = await _messageService.GetConversation(userId, otherUserId);
        //        return Ok(messages);
        //    }
        //    catch (Exception ex)
        //    {
        //        return BadRequest(ex.Message);
        //    }
        //}
        [HttpGet("chat")]
        public async Task<IActionResult> GetChatWithMessages([FromQuery] int chatId)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                if (userId == 0)
                    return Unauthorized();

                var messages = await _messageService.GetChatWithContent(chatId);
                return Ok(messages);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("send")]
        //public async Task<IActionResult> SendMessage([FromBody] CreateMessageDto createMessageDto)
        public async Task<IActionResult> SendMessage([FromBody] ChatCreateMessageDto createMessageDto)
        {
            try
            {
                var senderId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
                if (senderId == 0)
                    return Unauthorized();

                var message = await _messageService.SendMessage(senderId, createMessageDto);
                await _chatService.SetLastMessageId(message.Id, createMessageDto.ChatId);
                return Ok(message);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("my-messages")]
        public async Task<IActionResult> GetMyMessages()
        {
            try
            {
                var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                if (userId == 0)
                    return Unauthorized();

                var messages = await _messageService.GetUserMessages(userId);
                return Ok(messages);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
        [HttpGet("messageById/{messageId}")]
        public async Task<IActionResult> GetMessageById([FromQuery]int messageId)
        {
            var message = _messageService.GetMessageById(messageId);
            return Ok(message);
        }
    }
} 