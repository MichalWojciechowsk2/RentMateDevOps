using System.Text.Json.Serialization;

namespace ApplicationCore.Dto.Message
{
    public class CreateMessageDto
    {
        [JsonPropertyName("receiverId")]
        public int ReceiverId { get; set; }
        [JsonPropertyName("content")]
        public string Content { get; set; }
    }
} 