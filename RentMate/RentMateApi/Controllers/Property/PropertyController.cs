using ApplicationCore.Dto.Property;
using ApplicationCore.Enums;
using ApplicationCore.Enums.DistrictByCity;
using Microsoft.AspNetCore.Mvc;
using Services.Services;
using static Services.Services.PropertyService;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using System.Linq.Expressions;

namespace RentMateApi.Controllers.Property
{
    [Route("api/[controller]")]
    [ApiController]
    public class PropertyController : ControllerBase
    {
        private readonly IPropertyService _propertyService;
        public PropertyController(IPropertyService propertyService)
        {
            _propertyService = propertyService;
        }

        [HttpPost]
        [Authorize]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> CreateProperty(PropertyDto createPropertyDto)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int ownerId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }

            var result = await _propertyService.CreateProperty(createPropertyDto, ownerId);
            return result == true ? StatusCode(201) : Conflict();
        }
        [HttpPatch("{propertyId}/isActive")]
        public async Task<IActionResult> UpdatePropertyIsActive(int propertyId, [FromBody] bool newIsActive)
        {
            try
            {
                var updateOfferIsActive = await _propertyService.UdpatePropertyIsActiveById(propertyId, newIsActive);
                return Ok(updateOfferIsActive);
            }
            catch (KeyNotFoundException)
            {
                return NotFound();
            }
            catch
            {
                return StatusCode(500, "Wystąpił błąd podczas aktualizacji aktywności.");
            }
        }
        [HttpPatch("{propertyId}/updateProperty")]
        public async Task<IActionResult> UpdateProperty(int propertyId, [FromBody] UpdatePropertyDto dto)
        {
            try
            {
                var updateOffer = await _propertyService.UdpatePropertyById(propertyId, dto);
                return Ok(updateOffer);
            }
            catch (KeyNotFoundException)
            {
                return NotFound();
            }
            catch
            {
                return StatusCode(500, "Wystąpił błąd podczas aktualizacji aktywności.");
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetAllProperties()
        {
            var result = await _propertyService.GetAllActiveProperties();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetPropertyDetails(int id)
        {
            var property = await _propertyService.GetPropertyDetails(id);
            if (property == null)
            {
                return NotFound();
            }
            return Ok(property);
        }

        [HttpGet("my-properties")]
        [Authorize]
        public async Task<IActionResult> GetMyProperties()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int ownerId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }
            var result = await _propertyService.GetPropertiesByOwnerId(ownerId);
            return Ok(result);
        }

        //[HttpGet("search")]
        //public async Task<IActionResult> Search([FromQuery] PropertyFilterDto filters)

        [HttpGet("getPropertyById")]
        public async Task<IActionResult> GetPropertyById(int id)
        {
            var result = await _propertyService.GetPropertyById(id);
            return Ok(result);
        }
        [HttpGet("getPropertyEntityById")]
        public async Task<IActionResult> GetPropertyEntityById(int id)
        {
            var result = await _propertyService.GetOwnerPropertyById(id);
            return Ok(result);
        }
        [HttpGet("getPropertiesByOwnerId")]
        public async Task<IActionResult> GetPropertiesByOwnerId(int ownerId)
        {
            var result = await _propertyService.GetPropertiesByOwnerId(ownerId);
            return Ok(result);
        }
        [HttpGet("filter")]
        public async Task<IActionResult> Filter([FromQuery] PropertyFilterDto filters)

        {
            var result = await _propertyService.SearchProperties(filters);
            return Ok(result);
        }

        [HttpGet("cities")]
        public IActionResult GetCities() => Ok(Enum.GetValues(typeof(City)).Cast<City>().Select(c => new {
            Id = (int)c,
            Name = c.ToString()
        }));

        [HttpGet("districts/{cityId}")]
        public IActionResult GetDistricts(int cityId)
        {
            if (cityId == (int)City.Kraków)
            {
                return Ok(Enum.GetValues(typeof(KrakowDistricts)).Cast<KrakowDistricts>().Select(d => new
                {
                    Id = (int)d,
                    Name = d.GetDisplayName(),
                    EnumName = d.ToString()
                }));
            }
            if (cityId == (int)City.Warszawa)
            {
                return Ok(Enum.GetValues(typeof(WarszawaDistricts)).Cast<WarszawaDistricts>().Select(d => new {
                    Id = (int)d,
                    Name = d.GetDisplayName(),
                    EnumName = d.ToString()
                }));
            }
            return NotFound();
        }
    }
}
