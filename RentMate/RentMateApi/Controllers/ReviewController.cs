using ApplicationCore.Dto.Review;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Services.Services;
using System.Security.Claims;

namespace RentMateApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReviewController : ControllerBase
    {
        private readonly IReviewService _reviewService;
        public ReviewController(IReviewService reviewService)
        {
            _reviewService = reviewService;
        }
        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreateReview([FromBody] ReviewDto reviewDto)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int userId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }
            try
            {
                var review = await _reviewService.CreateReview(reviewDto, userId);
                return Ok(review);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while creating the review.", error = ex.Message });
            }
        }
        [HttpDelete("{reviewId}")]
        [Authorize]
        public async Task<IActionResult> DeleteReview(int reviewId)
        {
            try
            {
                var response = await _reviewService.DeleteReviewById(reviewId);
                return Ok(response);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred. ", error = ex.Message });
            }
        }
        [HttpGet]
        [Authorize]
        public async Task<IActionResult> GetReviewById(int reviewId)
        {
            try
            {
                var response = await _reviewService.GetReviewById(reviewId);
                return Ok(response);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred. ", error = ex.Message });
            }
        }
        [HttpGet]
        [Authorize]
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetAllReviewsForUserByUserId(int userId)
        {
            try
            {
                var response = await _reviewService.GetAllReviewsForUser(userId);
                return Ok(response);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred. ", error = ex.Message });
            }
        }
        [HttpGet]
        [Authorize]
        [HttpGet("property/{propertyId}")]
        public async Task<IActionResult> GetAllReviewsForPropertyByPropertyId(int propertyId)
        {
            try
            {
                var response = await _reviewService.GetAllReviewsForProperty(propertyId);
                return Ok(response);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred. ", error = ex.Message });
            }
        }
    }
    
}
