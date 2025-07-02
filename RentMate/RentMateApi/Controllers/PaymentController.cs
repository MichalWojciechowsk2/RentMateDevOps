using ApplicationCore.Dto.Payment;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Services.Services;
using System.Security.Claims;

namespace RentMateApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PaymentController : ControllerBase
    {
        private readonly IPaymentService _paymentService;
        public PaymentController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreatePayment(CreatePaymentDto createPaymentDto)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if(userIdClaim == null || !int.TryParse(userIdClaim.Value, out int ownerId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }
            var result = await _paymentService.CreatePayment(createPaymentDto, ownerId);
            return result == true ? StatusCode(201) : Conflict();
        }
    }
}
