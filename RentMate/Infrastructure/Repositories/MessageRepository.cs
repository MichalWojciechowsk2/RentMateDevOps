using Data;
using Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories
{
    public class MessageRepository
    {
        private readonly RentMateDbContext _context;

        public MessageRepository(RentMateDbContext context)
        {
            _context = context;
        }

        //public async Task<IEnumerable<MessageEntity>> GetConversation(int userId, int otherUserId)
        //{
        //    return await _context.Messages
        //        .Where(m => (m.SenderId == userId && m.ReceiverId == otherUserId) ||
        //                   (m.SenderId == otherUserId && m.ReceiverId == userId))
        //        .Include(m => m.Sender)
        //        .Include(m => m.Receiver)
        //        .OrderBy(m => m.CreatedAt)
        //        .ToListAsync();
        //}
        public async Task<IEnumerable<MessageEntity>> GetConversationByChatId(int chatId)
        {
            return await _context.Messages.Where(m=> (m.ChatId == chatId))
                .OrderBy(m=> m.CreatedAt)
                .ToListAsync();
        }

        public async Task<IEnumerable<MessageEntity>> GetUserMessages(int userId)
        {
            return await _context.Messages
                .Where(m => m.SenderId == userId)/* || m.ReceiverId == userId)*/
                .Include(m => m.Sender)
                //.Include(m => m.Receiver)
                .OrderByDescending(m => m.CreatedAt)
                .ToListAsync();
        }

        public async Task<MessageEntity> AddMessage(MessageEntity message)
        {
            _context.Messages.Add(message);
            await _context.SaveChangesAsync();
            return message;
        }

        public async Task<MessageEntity> GetMessageById(int id)
        {
            return await _context.Messages
                .Include(m => m.Sender)
                //.Include(m => m.Receiver)
                .FirstOrDefaultAsync(m => m.Id == id);
        }
    }
} 