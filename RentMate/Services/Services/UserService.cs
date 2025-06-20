using ApplicationCore.Dto.User;
using AutoMapper;
using Data.Entities;
using Infrastructure.Repositories;

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
    }
    public interface IUserService
    {
        Task<UserDto> GetUserById(int id);
    }
}
