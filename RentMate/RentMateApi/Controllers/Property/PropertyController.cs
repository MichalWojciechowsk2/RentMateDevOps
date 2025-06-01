using ApplicationCore.Dto.Property;
using Microsoft.AspNetCore.Http;
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
    }
}
