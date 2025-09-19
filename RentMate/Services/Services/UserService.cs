using ApplicationCore.Dto.Property;
using ApplicationCore.Dto.User;
using AutoMapper;
using Data.Entities;
using Infrastructure.Repositories;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore.Metadata.Internal;

namespace Services.Services
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;
        private readonly IMapper _mapper;
        public UserService(IUserRepository userRepository, IMapper mapper)
        {
            _userRepository = userRepository;
            _mapper = mapper;
        }
        public async Task<UserDto> GetUserById(int id)
        {
            var user = await _userRepository.GetUserById(id);
            if (user == null) return null;
            return _mapper.Map<UserDto>(user);
        }
        public async Task<string> UploadUserPhoto(int userId, IFormFile photo)
        {
            var user = await _userRepository.GetUserById(userId);
            if (user == null) throw new ArgumentException($"User with id {userId} not found");
            if (photo == null) throw new ArgumentException("No images provided");
            var uploadPath = Path.Combine(Directory.GetCurrentDirectory(), "uploads", "UserPhoto");
            if (!Directory.Exists(uploadPath))
            {
                Directory.CreateDirectory(uploadPath);
            }

            var allowedTypes = new[] { "image/jpeg", "image/jpg", "image/png", "image/gif" };
            if (!allowedTypes.Contains(photo.ContentType.ToLower()))
            {
                throw new ArgumentException($"File type {photo.ContentType} is not allowed. Only JPEG, JPG, PNG, and GIF files are allowed.");
            }
            if (photo.Length > 5 * 1024 * 1024)
            {
                throw new ArgumentException("File size cannot exceed 5MB");
            }
            var fileName = $"{Guid.NewGuid()}{Path.GetExtension(photo.FileName)}";
            var filePath = Path.Combine(uploadPath, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await photo.CopyToAsync(stream);
            }
            await _userRepository.UpdateUserPhoto(userId, $"/uploads/UserPhoto/{fileName}");
            return filePath; 
        }
        public async Task<string> GetUserPhoto (int userId)
        {
            return await _userRepository.GetUserPhotoUrl(userId);
        }
        public async Task<UserDto> UpdateUser(int userId, UserFieldToUpdate field, string value)
        {
            var user = await _userRepository.GetUserById(userId);
            if (user == null)
                throw new KeyNotFoundException($"User with id {userId} not found");

            switch (field)
            {
                case UserFieldToUpdate.AboutMe:
                    user.AboutMe = value;
                    break;
                case UserFieldToUpdate.PhoneNumber:
                    user.PhoneNumber = value;
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(field), field, null);
            }

            await _userRepository.Update(user);

            return _mapper.Map<UserDto>(user);
        }
    }
    public interface IUserService
    {
        Task<UserDto> GetUserById(int id);
        Task<string> UploadUserPhoto(int userId, IFormFile photo);
        Task<string> GetUserPhoto(int userId);
        Task<UserDto> UpdateUser(int userId, UserFieldToUpdate field, string value);
    }
}
