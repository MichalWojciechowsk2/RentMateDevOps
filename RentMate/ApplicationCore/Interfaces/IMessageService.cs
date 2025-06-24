using ApplicationCore.Dto.Message;

namespace ApplicationCore.Interfaces
{
    public interface IMessageService
    {
        Task<IEnumerable<MessageDto>> GetConversation(int userId, int otherUserId);
        Task<MessageDto> SendMessage(int senderId, CreateMessageDto createMessageDto);
        Task<IEnumerable<MessageDto>> GetUserMessages(int userId);
    }
} 