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
                    OtherUserName = otherUser.FirstName + " " + otherUser.LastName,
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
        // TODO: Dodać chat który tworzyć się będzie podczas tworzenia mieszkania tj. Mieszkanie -> Chat z jedną osobą (właścicielem mieszkania) -> podczas tworzenia oferty automatycznie do chatu dodawany jest user -> podczas zmiany statusu oferty na expired 
        // usuwa się user z chatu. Zamieścić w widoku: dla najemcy i wynajmującego ale nie tym chat. To będzie taka dynamiczna grupa gdzie zmieniać się będzie w zależności od najemców.
        public async Task<ChatEntity> CreateChatBeforeProperty(int firstUserId,)
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
        public async Task<bool> SetLastMessageId(int messageId, int chatId)
        {
            var chat = await _chatRepository.GetChatById(chatId);
            if (chat == null) throw new KeyNotFoundException($"Chat z id: {chatId} nie został znaleziony");
            chat.LastMessageId = messageId;
            await _chatRepository.UpdateAsync(chat);
            return true;
        }
        public async Task<int?> CheckIfPrivateChatExists(int firstUserId, int secondUserId)
        {
            var chats = await _chatRepository.GetAllChats();

            var existingChat = chats
                .Where(c => !c.IsGroup)
                .FirstOrDefault(c =>
            c.ChatUsers.Any(u => u.UserId == firstUserId) &&
            c.ChatUsers.Any(u => u.UserId == secondUserId));

            return existingChat?.Id;
        }
    }
    public interface IChatService
    {
        Task<IEnumerable<UserPrivateChats>> GetAllPrivateChatsForUser(int userId, int? sendToUserId = null);
        Task<ChatEntity> CreateChat(int firstUserId, int secondUserId);
        Task <bool> SetLastMessageId(int messageId, int chatId);
        Task<int?> CheckIfPrivateChatExist(int firstUserId, int secondUserId);
    }
    
}
