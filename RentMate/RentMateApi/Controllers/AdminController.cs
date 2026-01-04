using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Services.Services;
using System.Security.Claims;
using ApplicationCore.Dto.Admin;

namespace RentMateApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class AdminController : ControllerBase
    {
        private readonly IAdminService _adminService;

        public AdminController(IAdminService adminService)
        {
            _adminService = adminService;
        }

        private bool IsAdmin()
        {
            var role = User.FindFirst(ClaimTypes.Role)?.Value;
            return role == "Administrator";
        }

        [HttpGet("users")]
        public async Task<IActionResult> GetAllUsers()
        {
            if (!IsAdmin()) return Forbid();

            try
            {
                var users = await _adminService.GetAllUsers();
                return Ok(users);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("users/{userId}/ban")]
        public async Task<IActionResult> BanUser(int userId)
        {
            if (!IsAdmin()) return Forbid();

            try
            {
                var result = await _adminService.BanUser(userId);
                if (result)
                    return Ok(new { message = "User banned successfully" });
                return NotFound(new { message = "User not found" });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("users/{userId}/unban")]
        public async Task<IActionResult> UnbanUser(int userId)
        {
            if (!IsAdmin()) return Forbid();

            try
            {
                var result = await _adminService.UnbanUser(userId);
                if (result)
                    return Ok(new { message = "User unbanned successfully" });
                return NotFound(new { message = "User not found" });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("users/{userId}")]
        public async Task<IActionResult> DeleteUser(int userId)
        {
            if (!IsAdmin()) return Forbid();

            try
            {
                var adminId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                var result = await _adminService.DeleteUser(userId, adminId);
                if (result)
                    return Ok(new { message = "User deleted successfully" });
                return NotFound(new { message = "User not found" });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("reviews")]
        public async Task<IActionResult> GetAllReviews()
        {
            if (!IsAdmin()) return Forbid();

            try
            {
                var reviews = await _adminService.GetAllReviews();
                return Ok(reviews);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("reviews/{reviewId}")]
        public async Task<IActionResult> DeleteReview(int reviewId)
        {
            if (!IsAdmin()) return Forbid();

            try
            {
                var result = await _adminService.DeleteReview(reviewId);
                if (result)
                    return Ok(new { message = "Review deleted successfully" });
                return NotFound(new { message = "Review not found" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}

