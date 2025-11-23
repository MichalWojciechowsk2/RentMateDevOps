using Data;
using Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.SqlServer.Query.Internal;
using Microsoft.Identity.Client;
using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Repositories
{
    public class ChatRepository : IChatRepository
    {
        private readonly RentMateDbContext _context;
        public ChatRepository(RentMateDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<ChatEntity>> GetUserAllPrivateChats(int userId)
        {
            return await _context.Chats
                .Include(c => c.ChatUsers)
                    .ThenInclude(cu => cu.User)
                .Include(c => c.Messages)
                .Where(c => !c.IsGroup && c.ChatUsers.Any(cu => cu.UserId == userId))
                .ToListAsync();
        }
        public async Task<IEnumerable<ChatEntity>> GetAllChats()
        {
            return await _context.Chats
                .Include(c => c.ChatUsers)
                .ToListAsync();
        }
        public async Task<ChatEntity> CreatePrivateChat(int firstUserId, int secondUserId)
        {
            var chat = new ChatEntity
            {
                Name = "Prywatny czat",
                IsGroup = false,
                CreatedAt = DateTime.UtcNow
            };

            _context.Chats.Add(chat);
            await _context.SaveChangesAsync();

            var chatUsers = new List<ChatUsersEntity>
            {
                new ChatUsersEntity { ChatId = chat.Id, UserId = firstUserId },
                new ChatUsersEntity { ChatId = chat.Id, UserId = secondUserId }
            };

            _context.ChatUsers.AddRange(chatUsers);
            await _context.SaveChangesAsync();

            chat.ChatUsers = chatUsers;
            return chat;
        }
        public async Task<ChatUsersEntity> AddUserToChat(int chatId, int userId)
        {
            var chatUser = new ChatUsersEntity { ChatId = chatId, UserId = userId };
            _context.ChatUsers.Add(chatUser);
            await _context.SaveChangesAsync();
            return chatUser;
        }
        public async Task<bool> DeleteUserFromChat(int chatId, int userId)
        {
            var chatUser = await _context.ChatUsers
                .FirstOrDefaultAsync(cu => cu.ChatId == chatId && cu.UserId == userId);

            if (chatUser == null)
                return false;

            _context.ChatUsers.Remove(chatUser);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<ChatEntity> CreatePropertyChat(int propertyOwnerId)
        {
            var chat = new ChatEntity
            {
                Name = "Czat mieszkania",
                IsGroup = true,
                CreatedAt = DateTime.UtcNow
            };
            _context.Chats.Add(chat);
            await _context.SaveChangesAsync();
            var chatUser = new ChatUsersEntity { ChatId = chat.Id, UserId = propertyOwnerId };

            _context.ChatUsers.Add(chatUser);
            await _context.SaveChangesAsync();
            return chat;

        }
        public async Task<bool> DeleteChat(int chatId)
        {
            try
            {
                var chat = await _context.Chats.AsNoTracking().FirstOrDefaultAsync(c => c.Id == chatId);
                if (chat != null)
                {
                    _context.Chats.Remove(chat);
                    await _context.SaveChangesAsync();
                    return true;
                }
                return false;
            }
            catch (Exception ex)
            {
                return false;
            }
        }
        public async Task<IEnumerable<UserEntity>> GetChatUsers(int chatId)
        {
            return await _context.ChatUsers
                .Where(cu => cu.ChatId == chatId)
                .Include(cu => cu.User)
                .Select(cu => cu.User)
                .ToListAsync();
        }

        public async Task<ChatEntity> GetChatById(int chatId)
        {
            return await _context.Chats.Where(c => c.Id == chatId).FirstOrDefaultAsync();
        }
        public async Task UpdateAsync(ChatEntity entity)
        {
            _context.Chats.Update(entity);
            await _context.SaveChangesAsync();
        }
    }
    public interface IChatRepository
    {
        Task<IEnumerable<ChatEntity>> GetUserAllPrivateChats(int userId);
        Task<IEnumerable<ChatEntity>> GetAllChats();
        Task<ChatEntity> CreatePrivateChat(int firstUserId, int secondUserId);
        Task<ChatUsersEntity> AddUserToChat(int chatId, int userId);
        Task<bool> DeleteUserFromChat(int chatId, int userId);
        Task<ChatEntity> CreatePropertyChat(int propertyId);
        Task<bool> DeleteChat(int chatId);
        Task<IEnumerable<UserEntity>> GetChatUsers(int chatId);
        Task<ChatEntity> GetChatById(int chatId);
        Task UpdateAsync(ChatEntity entity);
    }
}
