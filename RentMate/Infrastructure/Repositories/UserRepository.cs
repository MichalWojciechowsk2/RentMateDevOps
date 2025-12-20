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

    }
    public interface IUserRepository
    {
        Task<UserEntity> GetUserById(int id);
        Task<UserEntity> UpdateUserPhoto(int userId, string photoUrl);
        Task<string> GetUserPhotoUrl(int userId);
        Task<UserEntity?> Update(UserEntity user);
        Task<List<UserEntity>> SearchUsersByName(string searchTerm);
    }
    public enum UserFieldToUpdate
    {
        AboutMe,
        PhoneNumber,
        FirstName,
        LastName
    }
}
