using ApplicationCore.Dto.Property;
using ApplicationCore.Enums;
using ApplicationCore.Enums.DistrictByCity;
using Microsoft.AspNetCore.Mvc;
using Services.Services;
using static Services.Services.PropertyService;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

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

        [HttpGet]
        public async Task<IActionResult> GetAllProperties()
        {
            var result = await _propertyService.GetAllProperties();
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

        [HttpGet("search")]
        public async Task<IActionResult> Search([FromQuery] PropertyFilterDto filters)
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
            if (cityId == (int)City.Krakow)
            {
                return Ok(Enum.GetValues(typeof(KrakowDistricts)).Cast<KrakowDistricts>().Select(d => new {
                    Id = (int)d,
                    Name = d.ToString()
                }));
            }
            if (cityId == (int)City.Warszawa)
            {
                return Ok(Enum.GetValues(typeof(WarszawaDistricts)).Cast<WarszawaDistricts>().Select(d => new {
                    Id = (int)d,
                    Name = d.ToString()
                }));
            }
            return NotFound();
        }
    }
}
