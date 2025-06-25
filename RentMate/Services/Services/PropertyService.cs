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
        public async Task<bool> CreateProperty(PropertyDto propertyDto, int ownerId)
        {
            var dtoToEntity = _mapper.Map<PropertyEntity>(propertyDto);
            dtoToEntity.OwnerId = ownerId; // Assign the correct OwnerId
            await _propertyRepository.CreateProperty(dtoToEntity);
            return true;
        }

        public async Task<IEnumerable<PropertyDto>> GetAllProperties()
        {
            var entities = await _propertyRepository.GetAllProperties();
            return _mapper.Map<IEnumerable<PropertyDto>>(entities);
        }
        public async Task<PropertyDto> GetPropertyById(int id)
        {
            var property = await _propertyRepository.GetPropertieById(id);
            if (property == null) return null;
            return _mapper.Map<PropertyDto>(property);
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

        public async Task<IEnumerable<PropertyDto>> GetPropertiesByOwnerId(int ownerId)
        {
            var entities = await _propertyRepository.GetPropertiesQueryable()
                                                .Where(p => p.OwnerId == ownerId)
                                                .Include(p => p.Owner)
                                                .ToListAsync();
            return _mapper.Map<IEnumerable<PropertyDto>>(entities);
        }

        public async Task<PropertyDto> GetPropertyDetails(int id)
        {
            var entity = await _propertyRepository.GetPropertiesQueryable()
                                                .Include(p => p.Owner)
                                                .FirstOrDefaultAsync(p => p.Id == id);
            return _mapper.Map<PropertyDto>(entity);
        }

        public interface IPropertyService
        {
            Task<bool> CreateProperty(PropertyDto dto, int ownerId);
            //Task<IEnumerable<PropertyEntity>> GetAllProperties();
            Task<IEnumerable<PropertyDto>> GetAllProperties();
            Task<IEnumerable<PropertyDto>> SearchProperties(PropertyFilterDto filters);
            Task<IEnumerable<PropertyDto>> GetPropertiesByOwnerId(int ownerId);
            Task<PropertyDto> GetPropertyDetails(int id);
            Task<PropertyDto> GetPropertyById(int id);
        }
    }
}
