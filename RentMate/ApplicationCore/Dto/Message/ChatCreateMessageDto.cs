using Microsoft.Identity.Client;
using System.Text.Json.Serialization;

namespace ApplicationCore.Dto.Message
{
    public class ChatCreateMessageDto
    {
        public int ChatId {  get; set; }
        public string Content { get; set; }
    }
}