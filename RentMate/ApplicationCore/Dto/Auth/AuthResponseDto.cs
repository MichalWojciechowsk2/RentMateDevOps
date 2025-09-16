using ApplicationCore.Dto.Property;
using Data.Entities;

namespace ApplicationCore.Dto.Auth
{
    public class AuthResponseDto
    {
        public UserDto User { get; set; }
        public string Token { get; set; }
    }

    public class UserDto
    {
        public int Id { get; set; }
        public string Email { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string PhoneNumber { get; set; }
        public string Role { get; set; }
        public string AboutMe { get; set; }
        public string PhotoUrl { get; set; }
    }
} 