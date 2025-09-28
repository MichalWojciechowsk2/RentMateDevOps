using ApplicationCore.Dto.Payment;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using RentMateApi.Hubs;
using Services.Services;
using System.Security.Claims;

namespace RentMateApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PaymentController : ControllerBase
    {
        private readonly IPaymentService _paymentService;
        private readonly INotificationService _notificationService;
        private readonly IOfferService _offerService;
        private readonly IUserService _userService;
        private readonly IHubContext<NotificationHub> _hubContext;
        public PaymentController(IPaymentService paymentService, 
            INotificationService notificationService, 
            IOfferService offerService, 
            IUserService userService,
            IHubContext<NotificationHub> hubContext)
        {
            _paymentService = paymentService;
            _notificationService = notificationService;
            _offerService = offerService;
            _userService = userService;
            _hubContext = hubContext;
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreatePayment([FromBody] CreatePaymentDto createPaymentDto)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if(userIdClaim == null || !int.TryParse(userIdClaim.Value, out int ownerId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }
            var result = await _paymentService.CreatePayment(createPaymentDto, ownerId);
            //TenantIdByOfferId
            var tenantId = await _offerService.GetTenantByOfferId(createPaymentDto.OfferId);
            var owner = await _userService.GetUserById(ownerId);
            var ownerNameSurname = owner.FirstName + " " + owner.LastName;
            await _notificationService.CreateNotification(ownerId, tenantId, ownerNameSurname, NotificationType.CreatePayment);
            var receiverUnreadNoti = await _notificationService.CountHowMuchNotRead(tenantId);
            await _hubContext.Clients.User(tenantId.ToString()).SendAsync("ReceiveUnreadCount", receiverUnreadNoti);
            return result == true ? StatusCode(201) : Conflict();
        }
        [HttpGet]
        public async Task<IActionResult> GetAllPayments()
        {
            var payments = await _paymentService.GetAllPayments();
            return Ok(payments);
        }
        [HttpGet("getPaymentsByActiveUserOffers")]
        [Authorize]
        public async Task<IActionResult> GetPaymentsByActiveUserOffers()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int userId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }
            var payments = await _paymentService.GetPaymentsByActiveUserOffers(userId);
            return Ok(payments);
        }

        //Sprawdzić czy użytkownik jest właścicielem mieszkania.
        [HttpGet("getAllPaymentsForPropertyByActiveUserOffers")]
        [Authorize]
        public async Task<IActionResult> GetAllPaymentsForPropertyByActiveUserOffers(int propertyId)
        {
            //var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            //if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int userId))
            //{
            //    return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            //}
            var payments = await _paymentService.GetAllPaymentsForPropertyByActiveUserOffers(propertyId);
            return Ok(payments);
        }
        [HttpGet("getAllRecurringPaymentsByPropertyId")]
        public async Task<IActionResult> GetAllRecurringPaymentsByPropertyId(int propertyId)
        {
            var recurringPayments = await _paymentService.GetAllRecurringPaymentsWithPaymentByPropertyId(propertyId);
            return Ok(recurringPayments);
        }

        [HttpDelete("deleteRecurringPaymentById")]
        public async Task<IActionResult> DeleteRecurringPayment(int recurringPaymentId)
        {
            var result = await _paymentService.DeleteRecurringPaymentById(recurringPaymentId);
            return result ? NoContent() : NotFound();
        }
        [HttpPatch("deactivate")]
        public async Task<IActionResult> DeactivatePayment([FromQuery]int paymentId)
        {
            var result = await _paymentService.DeactivePayment(paymentId);
            if (!result)
                return NotFound(new { message = "Payment not found" });
            return Ok(new { message = "Payment deactivated" });
        }
    }
}
