using Data;
using Data.Entities;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;
using ApplicationCore.Dto.Auth;

namespace Services.Services
{
    public class AuthService
    {
        private readonly RentMateDbContext _context;

        public AuthService(RentMateDbContext context)
        {
            _context = context;
        }

        // Helper method for password hashing (for demonstration, use a robust library in production)
        private string HashPassword(string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password); // Requires BCrypt.Net package
        }

        // Helper method for password verification
        private bool VerifyPassword(string password, string hashedPassword)
        {
            return BCrypt.Net.BCrypt.Verify(password, hashedPassword); // Requires BCrypt.Net package
        }

        public async Task<User> Register(RegisterDto registerDto)
        {
            // Check if user already exists
            if (await _context.Users.AnyAsync(u => u.Email == registerDto.Email))
            {
                throw new Exception("User with this email already exists.");
            }

            var userEntity = new UserEntity
            {
                Email = registerDto.Email,
                PasswordHash = HashPassword(registerDto.Password),
                FirstName = registerDto.FirstName,
                LastName = registerDto.LastName,
                PhoneNumber = registerDto.PhoneNumber,
                Role = (UserRole)Enum.Parse(typeof(UserRole), registerDto.Role),
                CreatedAt = DateTime.UtcNow,
                LastLoginAt = DateTime.UtcNow
            };

            _context.Users.Add(userEntity);
            await _context.SaveChangesAsync();

            // For simplicity, we are returning a basic User object. In a real app, you might map this to a UserDto
            return new User
            {
                Id = userEntity.Id.ToString(), // Assuming User model has string Id
                Email = userEntity.Email,
                FirstName = userEntity.FirstName,
                LastName = userEntity.LastName,
                PhoneNumber = userEntity.PhoneNumber,
                Role = userEntity.Role.ToString()
            };
        }

        public async Task<User> Login(LoginDto loginDto)
        {
            var userEntity = await _context.Users.SingleOrDefaultAsync(u => u.Email == loginDto.Email);

            if (userEntity == null || !VerifyPassword(loginDto.Password, userEntity.PasswordHash))
            {
                throw new Exception("Invalid credentials.");
            }

            userEntity.LastLoginAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return new User
            {
                Id = userEntity.Id.ToString(),
                Email = userEntity.Email,
                FirstName = userEntity.FirstName,
                LastName = userEntity.LastName,
                PhoneNumber = userEntity.PhoneNumber,
                Role = userEntity.Role.ToString()
            };
        }

        public async Task<User?> GetUserById(int id)
        {
            var userEntity = await _context.Users.FindAsync(id);
            if (userEntity == null) return null;

            return new User
            {
                Id = userEntity.Id.ToString(),
                Email = userEntity.Email,
                FirstName = userEntity.FirstName,
                LastName = userEntity.LastName,
                PhoneNumber = userEntity.PhoneNumber,
                Role = userEntity.Role.ToString()
            };
        }
    }

    // Temporary Flutter User model to match C# backend structure
    // This should be replaced with the actual Flutter User model import once it's finalized.
    public class User
    {
        public string Id { get; set; }
        public string Email { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string PhoneNumber { get; set; }
        public string Role { get; set; }
    }
} 