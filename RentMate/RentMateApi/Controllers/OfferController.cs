using ApplicationCore.Dto.Property.Offer;
using Data.Entities;
using Microsoft.AspNetCore.Mvc;
using Services.Services;

namespace RentMateApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OfferController : ControllerBase
    {
        private readonly IOfferService _offerService;
        public OfferController(IOfferService offerService)
        {
            _offerService = offerService;
        }
        [HttpPost]
        public async Task<IActionResult> CreateOffer(CreateOfferDto createOfferDto)
        {
            var result = await _offerService.CreateOffer(createOfferDto);
            return Ok(result);
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
    }
}
