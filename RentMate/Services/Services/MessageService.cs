using ApplicationCore.Dto.Message;
using ApplicationCore.Interfaces;
using AutoMapper;
using Data.Entities;
using Infrastructure.Repositories;

namespace Services.Services
{
    public class MessageService : IMessageService
    {
        private readonly MessageRepository _messageRepository;
        private readonly IMapper _mapper;

        public MessageService(MessageRepository messageRepository, IMapper mapper)
        {
            _messageRepository = messageRepository;
            _mapper = mapper;
        }

        public async Task<IEnumerable<MessageDto>> GetConversation(int userId, int otherUserId)
        {
            var messages = await _messageRepository.GetConversation(userId, otherUserId);
            return _mapper.Map<IEnumerable<MessageDto>>(messages);
        }

        public async Task<MessageDto> SendMessage(int senderId, CreateMessageDto createMessageDto)
        {
            var message = new MessageEntity
            {
                SenderId = senderId,
                ReceiverId = createMessageDto.ReceiverId,
                Content = createMessageDto.Content,
                CreatedAt = DateTime.UtcNow,
                IsRead = false
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
    }
} 