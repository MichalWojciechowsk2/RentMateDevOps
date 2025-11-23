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
            // Pobierz wszystkie czaty, w których użytkownik uczestniczy
            var userChatIds = await _context.ChatUsers
                .Where(cu => cu.UserId == userId)
                .Select(cu => cu.ChatId)
                .ToListAsync();

            // Pobierz wszystkie wiadomości z tych czatów
            return await _context.Messages
                .Where(m => userChatIds.Contains(m.ChatId ?? 0))
                .Include(m => m.Sender)
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

        public async Task<int> GetUnreadMessagesCount(int userId)
        {
            // Pobierz wszystkie czaty, w których użytkownik uczestniczy
            var userChatIds = await _context.ChatUsers
                .Where(cu => cu.UserId == userId)
                .Select(cu => cu.ChatId)
                .ToListAsync();

            // Policz nieprzeczytane wiadomości z tych czatów, które nie zostały wysłane przez użytkownika
            return await _context.Messages
                .Where(m => userChatIds.Contains(m.ChatId ?? 0) 
                    && m.SenderId != userId 
                    && m.IsRead == false)
                .CountAsync();
        }

        public async Task MarkMessagesAsRead(int chatId, int userId)
        {
            // Oznacz wszystkie nieprzeczytane wiadomości w czacie jako przeczytane
            // (tylko te, które nie zostały wysłane przez użytkownika)
            var unreadMessages = await _context.Messages
                .Where(m => m.ChatId == chatId 
                    && m.SenderId != userId 
                    && m.IsRead == false)
                .ToListAsync();

            foreach (var message in unreadMessages)
            {
                message.IsRead = true;
            }

            if (unreadMessages.Any())
            {
                await _context.SaveChangesAsync();
            }
        }
    }
} 