using Infrastructure.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Identity.Client;
using RentMateApi.requests;
using Services.Services;
using System.Security.Claims;
using static Services.Services.PropertyService;

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
        [HttpPost("uploadUserPhoto")]
        [Authorize]
        public async Task<IActionResult> UploadUserPhoto(IFormFile photo)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int userId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }
            try
            {
                var result = await _userService.UploadUserPhoto(userId, photo);
                return Ok(result);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while uploading photo.", error = ex.Message });
            }
        }
        [HttpGet("userPhoto")]
        public async Task<IActionResult> GetUserPhoto()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int userId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }
            var photo = await _userService.GetUserPhoto(userId);
            if (photo == null)
            {
                return NotFound();
            }
            var baseUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}";
            var fullUrl = $"{baseUrl}{photo}";
            return Ok(fullUrl);
        }
        [HttpPatch("patchUserAboutMeOrPhoneNumber")]
        [Authorize]
        public async Task<IActionResult> UpdateUserFields([FromBody] UpdateUserFieldRequest request)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int userId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }
            try
            {
                var result = await _userService.UpdateUser(userId, request.Field, request.Value);
                return Ok(result);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message});
            }
        }
    }
}
