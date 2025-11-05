using ApplicationCore.Dto.Message;
using ApplicationCore.Dto.User;
//using ApplicationCore.Interfaces;
using AutoMapper;
using Data.Entities;
using Infrastructure.Repositories;

namespace Services.Services
{
    public class MessageService : IMessageService
    {
        private readonly MessageRepository _messageRepository;
        private readonly IChatRepository _chatRepository;
        private readonly IMapper _mapper;

        public MessageService(MessageRepository messageRepository, IMapper mapper, IChatRepository chatRepository)
        {
            _messageRepository = messageRepository;
            _mapper = mapper;
            _chatRepository = chatRepository;
        }

        //public async Task<IEnumerable<MessageDto>> GetConversation(int userId, int otherUserId)
        //{
        //    var messages = await _messageRepository.GetConversation(userId, otherUserId);
        //    return _mapper.Map<IEnumerable<MessageDto>>(messages);
        //}
        
        public async Task<ChatWithContentDto> GetChatWithContent(int chatId, int skip, int take)
        {
            var messages = await _messageRepository.GetConversationByChatId(chatId, skip, take);
            var users = await _chatRepository.GetChatUsers(chatId);

            var chatWithContent = new ChatWithContentDto
            {
                ChatId = chatId,
                Users = _mapper.Map<IEnumerable<UserDto>>(users),
                Messages = _mapper.Map<IEnumerable<MessageDto>>(messages)
            };

            return chatWithContent;
        }
        //public async Task<MessageDto> SendMessage(int senderId, CreateMessageDto createMessageDto)
        public async Task<MessageDto> SendMessage(int senderId, ChatCreateMessageDto createMessageDto)
        {
            var message = new MessageEntity
            {
                SenderId = senderId,
                //ReceiverId = createMessageDto.ReceiverId,
                Content = createMessageDto.Content,
                IsRead = false,
                CreatedAt = DateTime.UtcNow,
                ChatId = createMessageDto.ChatId,
            };

            var savedMessage = await _messageRepository.AddMessage(message);
            var messageWithDetails = await _messageRepository.GetMessageById(savedMessage.Id);
            return _mapper.Map<MessageDto>(messageWithDetails);
        }

        public async Task<IEnumerable<MessageDto>> GetUserMessages(int userId)
        {
            var messages = await _messageRepository.GetUserMessages(userId);
            return _mapper.Map<IEnumerable<MessageDto>>(messages);
        }
        public async Task<string> GetMessageById(int messageId)
        {
            var message = await _messageRepository.GetMessageById(messageId);
            return message.Content;
        }
    }
    public interface IMessageService
    {
        //Task<IEnumerable<MessageDto>> GetConversation(int userId, int otherUserId);
        //Task<MessageDto> SendMessage(int senderId, CreateMessageDto createMessageDto);
        Task<MessageDto> SendMessage(int senderId, ChatCreateMessageDto createMessageDto);
        Task<IEnumerable<MessageDto>> GetUserMessages(int userId);
        Task<string> GetMessageById(int messageId);
        Task<ChatWithContentDto> GetChatWithContent(int chatId, int skip, int take);
    }
} 