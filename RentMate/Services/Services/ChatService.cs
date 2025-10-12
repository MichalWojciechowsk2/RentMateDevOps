using ApplicationCore.Dto.Message;
using AutoMapper;
using Data.Entities;
using Infrastructure.Repositories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services.Services
{
    public class ChatService : IChatService
    {
        private IChatRepository _chatRepository;
        public ChatService (IChatRepository chatRepository)
        {
            _chatRepository = chatRepository;
        }

        public async Task<IEnumerable<UserPrivateChats>> GetAllPrivateChatsForUser(int userId, int? chatIdToOpen = null)
        {
            var chats = await _chatRepository.GetUserAllPrivateChats(userId);
            if (chatIdToOpen == null)
            {
                foreach (var chat in chats)
                {
                    if (chat.LastMessageId == 0) await _chatRepository.DeleteChat(chat.Id);
                }
            }

            var result = chats.Select(chat =>
            {
                var lastMessage = chat.Messages.FirstOrDefault(m => m.Id == chat.LastMessageId);
                var otherUser = chat.ChatUsers.Select(cu => cu.User).FirstOrDefault(u => u.Id != userId);

                return new UserPrivateChats
                {
                    ChatId = chat.Id,
                    ChatName = chat.Name,
                    LastMessageContent = lastMessage?.Content,
                    LastMessageCreatedAt = lastMessage?.CreatedAt,
                    OtherUserPhotoUrl = otherUser.PhotoUrl,
                };
            }).ToList();
            return result;
        }
        public async Task<ChatEntity> CreateChat(int firstUserId, int secondUserId)
        {
            var existingChat = await _chatRepository.
                GetUserAllPrivateChats(firstUserId) ?? Enumerable.Empty<ChatEntity>();

            var chat = existingChat.FirstOrDefault(c =>
                !c.IsGroup &&
                (c.ChatUsers?.Any(u => u.UserId == secondUserId) ?? false));

            if (chat != null)
            {
                return chat;
            }
            return await _chatRepository.CreateChat(firstUserId, secondUserId);
        }
    }
    public interface IChatService
    {
        Task<IEnumerable<UserPrivateChats>> GetAllPrivateChatsForUser(int userId, int? sendToUserId = null);
        Task<ChatEntity> CreateChat(int firstUserId, int secondUserId);
    }
    
}
