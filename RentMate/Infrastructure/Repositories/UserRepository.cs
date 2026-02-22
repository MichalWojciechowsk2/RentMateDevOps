using Data;
using Data.Entities;
using Microsoft.EntityFrameworkCore;
using static System.Net.Mime.MediaTypeNames;


namespace Infrastructure.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly RentMateDbContext _context;
        public UserRepository(RentMateDbContext context)
        {
            _context = context;
        }
        public async Task<UserEntity> GetUserById(int id)
        {
            return await _context.Users.FirstOrDefaultAsync(x => x.Id == id);
        }
        public async Task<UserEntity> UpdateUserPhoto(int userId, string photoUrl)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return null;
            user.PhotoUrl = photoUrl;
            await _context.SaveChangesAsync();
            return user;
        }
        public async Task<string> GetUserPhotoUrl(int userId)
        {
            var photoUrl = await _context.Users.Where(u => u.Id == userId).Select(u => u.PhotoUrl).FirstOrDefaultAsync();
            if (photoUrl == null) return null;
            return photoUrl;
        }
        public async Task<UserEntity?> Update(UserEntity user)
        {
            _context.Users.Update(user);
            await _context.SaveChangesAsync();
            return user;
        }
        public async Task<List<UserEntity>> SearchUsersByName(string searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
            {
                return new List<UserEntity>();
            }
            
            var term = searchTerm.Trim().ToLower();
            return await _context.Users
                .Where(u => 
                    (u.FirstName != null && u.FirstName.ToLower().Contains(term)) ||
                    (u.LastName != null && u.LastName.ToLower().Contains(term)) ||
                    (u.FirstName != null && u.LastName != null && 
                     (u.FirstName + " " + u.LastName).ToLower().Contains(term)))
                .OrderBy(u => u.FirstName)
                .ThenBy(u => u.LastName)
                .Take(20) // Limit do 20 wyników
                .ToListAsync();
        }

        public async Task<List<UserEntity>> GetAllUsers()
        {
            return await _context.Users
                .OrderBy(u => u.FirstName)
                .ThenBy(u => u.LastName)
                .ToListAsync();
        }

        public async Task<bool> DeleteUser(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return false;

            // Usuń wszystkie powiązane rekordy przed usunięciem użytkownika
            
            // 1. Usuń wszystkie zgłoszenia związane z użytkownikiem
            var reports = await _context.Reports
                .Where(r => r.ReporterId == userId || r.ReportedUserId == userId || r.ResolvedByAdminId == userId)
                .ToListAsync();
            _context.Reports.RemoveRange(reports);

            // 2. Usuń wszystkie powiadomienia związane z użytkownikiem
            var notifications = await _context.Notifications
                .Where(n => n.SenderId == userId || n.ReceiverId == userId)
                .ToListAsync();
            _context.Notifications.RemoveRange(notifications);

            // 3. Usuń wszystkie zaproszenia związane z użytkownikiem
            var invitations = await _context.Invitation
                .Where(i => i.SenderId == userId || i.ReceiverId == userId)
                .ToListAsync();
            _context.Invitation.RemoveRange(invitations);

            // 4. Usuń wszystkie wiadomości wysłane przez użytkownika
            var messages = await _context.Messages
                .Where(m => m.SenderId == userId)
                .ToListAsync();
            _context.Messages.RemoveRange(messages);

            // 5. Usuń wszystkie oceny związane z użytkownikiem (jako autor lub oceniany)
            var reviews = await _context.Reviews
                .Where(r => r.AuthorId == userId || r.UserId == userId)
                .ToListAsync();
            _context.Reviews.RemoveRange(reviews);

            // 6. Usuń wszystkie płatności związane z użytkownikiem (jako najemca)
            // Najpierw usuń powiązane cykliczne płatności
            var payments = await _context.Payments
                .Where(p => p.TenantId == userId)
                .ToListAsync();
            
            if (payments.Any())
            {
                var paymentIds = payments.Select(p => p.Id).ToList();
                var recurringPayments = await _context.RecurringPayment
                    .Where(rp => paymentIds.Contains(rp.PaymentId))
                    .ToListAsync();
                _context.RecurringPayment.RemoveRange(recurringPayments);
                _context.Payments.RemoveRange(payments);
            }

            // 6a. Zaktualizuj oferty, gdzie użytkownik jest najemcą - usuń powiązanie
            var offersWithTenant = await _context.Offers
                .Where(o => o.TenantId == userId)
                .ToListAsync();
            
            foreach (var offer in offersWithTenant)
            {
                // Usuń powiązanie użytkownika z ofertą (ustaw na null)
                offer.TenantId = null;
            }

            // 7. Usuń wszystkie problemy związane z użytkownikiem (jako najemca)
            var issues = await _context.Issues
                .Where(i => i.TenantId == userId)
                .ToListAsync();
            _context.Issues.RemoveRange(issues);

            // 8. Usuń wszystkie nieruchomości należące do użytkownika (właściciela)
            // Najpierw usuń powiązane oferty i obrazy (cascade)
            var properties = await _context.Properties
                .Where(p => p.OwnerId == userId)
                .ToListAsync();
            _context.Properties.RemoveRange(properties);

            // 9. Usuń tokeny resetowania hasła (jeśli istnieją w kontekście)
            //try
            //{
            //    var passwordResetTokens = await _context.Set<PasswordResetTokenEntity>()
            //        .Where(t => t.UserId == userId)
            //        .ToListAsync();
            //    if (passwordResetTokens.Any())
            //    {
            //        _context.Set<PasswordResetTokenEntity>().RemoveRange(passwordResetTokens);
            //    }
            //}
            //catch
            //{
            //    // Jeśli PasswordResetTokenEntity nie istnieje w kontekście, zignoruj
            //}

            // 10. ChatUsersEntity ma Cascade, więc zostanie usunięte automatycznie

            // Teraz można bezpiecznie usunąć użytkownika
            _context.Users.Remove(user);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> BanUser(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return false;
            
            user.IsBanned = true;
            
            // Jeśli użytkownik jest właścicielem, ukryj wszystkie jego mieszkania
            if (user.Role == UserRole.Owner)
            {
                var properties = await _context.Properties
                    .Where(p => p.OwnerId == userId)
                    .ToListAsync();
                
                foreach (var property in properties)
                {
                    property.IsHidden = true;
                }
            }
            
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> UnbanUser(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return false;
            
            user.IsBanned = false;
            
            // Jeśli użytkownik jest właścicielem, pokaż wszystkie jego mieszkania
            if (user.Role == UserRole.Owner)
            {
                var properties = await _context.Properties
                    .Where(p => p.OwnerId == userId)
                    .ToListAsync();
                
                foreach (var property in properties)
                {
                    property.IsHidden = false;
                }
            }
            
            await _context.SaveChangesAsync();
            return true;
        }

    }
    public interface IUserRepository
    {
        Task<UserEntity> GetUserById(int id);
        Task<UserEntity> UpdateUserPhoto(int userId, string photoUrl);
        Task<string> GetUserPhotoUrl(int userId);
        Task<UserEntity?> Update(UserEntity user);
        Task<List<UserEntity>> SearchUsersByName(string searchTerm);
        Task<List<UserEntity>> GetAllUsers();
        Task<bool> DeleteUser(int userId);
        Task<bool> BanUser(int userId);
        Task<bool> UnbanUser(int userId);
    }
    public enum UserFieldToUpdate
    {
        AboutMe,
        PhoneNumber,
        FirstName,
        LastName
    }
}
