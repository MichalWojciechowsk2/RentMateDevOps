using ApplicationCore.Dto.Admin;
using AutoMapper;
using Data.Entities;
using Infrastructure.Repositories;

namespace Services.Services
{
    public class AdminService : IAdminService
    {
        private readonly IUserRepository _userRepository;
        private readonly IReviewRepository _reviewRepository;
        private readonly IMapper _mapper;

        public AdminService(
            IUserRepository userRepository,
            IReviewRepository reviewRepository,
            IMapper mapper)
        {
            _userRepository = userRepository;
            _reviewRepository = reviewRepository;
            _mapper = mapper;
        }

        public async Task<List<AdminUserDto>> GetAllUsers()
        {
            var users = await _userRepository.GetAllUsers();
            return _mapper.Map<List<AdminUserDto>>(users);
        }

        public async Task<bool> BanUser(int userId)
        {
            var user = await _userRepository.GetUserById(userId);
            if (user == null) throw new KeyNotFoundException($"User with id {userId} not found");
            if (user.Role == UserRole.Administrator) 
                throw new UnauthorizedAccessException("Cannot ban administrator");
            
            return await _userRepository.BanUser(userId);
        }

        public async Task<bool> UnbanUser(int userId)
        {
            var user = await _userRepository.GetUserById(userId);
            if (user == null) throw new KeyNotFoundException($"User with id {userId} not found");
            
            return await _userRepository.UnbanUser(userId);
        }

        public async Task<bool> DeleteUser(int userId, int adminId)
        {
            if (userId == adminId) 
                throw new UnauthorizedAccessException("Cannot delete your own account");
            
            var user = await _userRepository.GetUserById(userId);
            if (user == null) throw new KeyNotFoundException($"User with id {userId} not found");
            if (user.Role == UserRole.Administrator) 
                throw new UnauthorizedAccessException("Cannot delete administrator account");
            
            return await _userRepository.DeleteUser(userId);
        }

        public async Task<List<AdminReviewDto>> GetAllReviews()
        {
            var reviews = await _reviewRepository.GetAllReviews();
            return _mapper.Map<List<AdminReviewDto>>(reviews);
        }

        public async Task<bool> DeleteReview(int reviewId)
        {
            return await _reviewRepository.DeleteReviewById(reviewId);
        }
    }

    public interface IAdminService
    {
        Task<List<AdminUserDto>> GetAllUsers();
        Task<bool> BanUser(int userId);
        Task<bool> UnbanUser(int userId);
        Task<bool> DeleteUser(int userId, int adminId);
        Task<List<AdminReviewDto>> GetAllReviews();
        Task<bool> DeleteReview(int reviewId);
    }
}

