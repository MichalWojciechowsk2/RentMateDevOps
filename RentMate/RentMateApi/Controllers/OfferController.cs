using ApplicationCore.Dto.Property;
using ApplicationCore.Dto.Property.Offer;
using Data.Entities;
using Microsoft.AspNetCore.Mvc;
using Services.Services;
using System.Security.Claims;
using System.Text.RegularExpressions;
using static Services.Services.PropertyService;

namespace RentMateApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OfferController : ControllerBase
    {
        private readonly IOfferService _offerService;
        private readonly IPropertyService _propertyService;
        private readonly IUserService _userService;
        public OfferController(IOfferService offerService, IPropertyService propertyService,IUserService userService)
        {
            _offerService = offerService;
            _propertyService = propertyService;
            _userService = userService;
        }
        [HttpPost]
        public async Task<IActionResult> CreateOffer(CreateOfferDto createOfferDto)
        {
            var result = await _offerService.CreateOffer(createOfferDto);
            
            var offerContract = await _offerService.GetOfferAndTenantByOfferId(result.Id);
            var property = await _propertyService.GetPropertyById(offerContract.PropertyId);
            var propertyCity = property.City;

            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int ownerId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }
            var owner = await _userService.GetUserById(ownerId);

            var data = new Dictionary<string, string>
            {
                {"CreatedAt", offerContract.CreatedAt.ToString("yyyy-MM-dd")},
                {"City", propertyCity},
                {"OwnerNameSurname", String.Concat(owner.FirstName," ", owner.LastName)},
                {"TenantNameSurname", String.Concat(offerContract.Tenant.FirstName," ", offerContract.Tenant.LastName)},
                {"PropertyCity", propertyCity},
                {"PropertyAdressStreet", property.Address},
                {"PropertyRoomCount",property.RoomCount.ToString()},
                {"PropertyArea",property.Area.ToString()},
                {"RentalStartDate", offerContract.RentalPeriodStart.ToString("dd-MM-yyyy")},
                {"RentalEndDate", offerContract.RentalPeriodEnd.ToString("dd-MM-yyyy")},
                {"RentAmount", offerContract.RentAmount.ToString()},
            };

            var contract = _offerService.GenerateOfferContract(data);
            await _offerService.AddOfferContractToOffer(offerContract.Id, contract);

            return Ok(new { message = "Offer and contract generated successfully" });
        }
        [HttpGet("{offerId}/offerContract/pdf")]
        public async Task<IActionResult> DownloadOfferContractPdf(int offerId)
        {
            var offer = await _offerService.GetOfferById(offerId);

            if (offer == null || string.IsNullOrEmpty(offer.OfferContract))
                return NotFound("Offer or contract not found.");

            var pdfBytes = _offerService.GenerateOfferContractPdf(offer.OfferContract);

            return File(pdfBytes, "application/pdf", $"Umowa_Najmu_{offerId}.pdf");
        }

        [HttpGet]
        [Route("getActiveAndAcceptedOffersByPropId")]
        public async Task<IActionResult> GetActiveAndAcceptedOfferByPropId(int propertyId)
        {
            var offers = await _offerService.GetActiveAndAcceptedOfferByPropId(propertyId);
            return Ok(offers);
        }
        [HttpGet]
        [Route("getOfferByUserId")]
        public async Task<IActionResult> GetOfferByUserId(int userId)
        {
            var offer = await _offerService.GetOfferByUserId(userId);
            return Ok(offer);
        }
        [HttpPatch("{offerId}/status")]
        public async Task<IActionResult> UpdateStatus(int offerId, [FromBody] OfferStatus status)
        {
            try
            {
                var updatedOffer = await _offerService.UpdateOfferStatus(offerId, status);
                return Ok(updatedOffer);
            }
            catch (KeyNotFoundException) 
            {
                return NotFound();
            }
            catch
            {
                return StatusCode(500, "Wystąpił błąd podczas aktualizacji statusu.");
            }
        }
    }
}
