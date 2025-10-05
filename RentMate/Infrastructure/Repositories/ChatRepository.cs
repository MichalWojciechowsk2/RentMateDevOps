using Data;
using Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Identity.Client;
using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
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
            return await _context.Chats.ToListAsync();
        }
        public async Task<ChatEntity> CreateChat(int firstUserId, int secondUserId)
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
    }
    public interface IChatRepository
    {
        Task<IEnumerable<ChatEntity>> GetUserAllPrivateChats(int userId);
        Task<IEnumerable<ChatEntity>> GetAllChats();
        Task<ChatEntity> CreateChat(int firstUserId, int secondUserId);
    }
}
