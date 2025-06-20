using Data;
using Data.Entities;
using Microsoft.EntityFrameworkCore;

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
    }
    public interface IUserRepository
    {
        Task<UserEntity> GetUserById(int id);
    }
}
