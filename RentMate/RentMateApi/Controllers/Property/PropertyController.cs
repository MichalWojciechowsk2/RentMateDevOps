using ApplicationCore.Dto.Property;
using ApplicationCore.Enums;
using ApplicationCore.Enums.DistrictByCity;
using Microsoft.AspNetCore.Mvc;
using Services.Services;
using static Services.Services.PropertyService;

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
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> CreateProperty(PropertyDto createPropertyDto)
        {
            var result = await _propertyService.CreateProperty(createPropertyDto);
            return result == true ? StatusCode(201) : Conflict();
        }

        [HttpGet]
        public async Task<IActionResult> GetAllProperties()
        {
            var result = await _propertyService.GetAllProperties();
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
