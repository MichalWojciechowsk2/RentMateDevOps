using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Identity.Client;
using Services.Services;

namespace RentMateApi.Controllers.User
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;
        public UserController(IUserService userService)
        {
            _userService = userService;
        }
        [HttpGet("getUserById")]
        public async Task<IActionResult> GetUserById(int id) 
        {
            var result = await _userService.GetUserById(id);
            return Ok(result);
        }
    }
}
