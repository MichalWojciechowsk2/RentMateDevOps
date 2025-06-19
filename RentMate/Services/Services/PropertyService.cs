using ApplicationCore.Dto.Property;
using AutoMapper;
using Data.Entities;
using Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using static Services.Services.PropertyService;

namespace Services.Services
{
    public class PropertyService : IPropertyService
    {
        private readonly IPropertyRepository _propertyRepository;
        private readonly IMapper _mapper;
        public PropertyService(IPropertyRepository propertyRepository, IMapper mapper)
        {
            _propertyRepository = propertyRepository;
            _mapper = mapper;
        }
        public async Task<bool> CreateProperty(PropertyDto propertyDto)
        {
            var dtoToEntity = _mapper.Map<PropertyEntity>(propertyDto);
            dtoToEntity.OwnerId = 2; // CHANGE IN FUTURE!
            await _propertyRepository.CreateProperty(dtoToEntity);
            return true;
        }

        public async Task<IEnumerable<PropertyEntity>> GetAllProperties()
        {
            return await _propertyRepository.GetAllProperties();
        }
        public async Task<PropertyEntity> GetPropertyById(int id)
        {
            return await _propertyRepository.GetPropertieById(id);
        }
        public async Task<IEnumerable<PropertyDto>> SearchProperties(PropertyFilterDto filters)
        {
            var query = _propertyRepository.GetPropertiesQueryable();
            if (!string.IsNullOrEmpty(filters.City))
                query = query.Where(p => p.City == filters.City);
            if (!string.IsNullOrEmpty(filters.District))
                query = query.Where(p => p.District == filters.District);
            if (filters.PriceFrom.HasValue)
                query = query.Where(p => p.BasePrice >= filters.PriceFrom.Value);

            if (filters.PriceTo.HasValue)
                query = query.Where(p => p.BasePrice <= filters.PriceTo.Value);

            if (filters.Rooms.HasValue)
                query = query.Where(p => p.RoomCount == filters.Rooms.Value);
            var entities = await query.ToListAsync();
            return _mapper.Map<IEnumerable<PropertyDto>>(entities);
        }
        public interface IPropertyService
        {
            Task<bool> CreateProperty(PropertyDto dto);
            Task<IEnumerable<PropertyEntity>> GetAllProperties();
            Task<IEnumerable<PropertyDto>> SearchProperties(PropertyFilterDto filters);
            Task<PropertyEntity> GetPropertyById(int id);
        }
    }
}
