using ApplicationCore.Dto.CreateReq;
using AutoMapper;
using Data.Entities;
using Infrastructure.Repositories;

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
        public async Task<bool> CreateProperty(CreatePropertyDto propertyDto)
        {
            var dtoToEntity = _mapper.Map<PropertyEntity>(propertyDto);
            dtoToEntity.OwnerId = 1; // CHANGE IN FUTURE!
            await _propertyRepository.CreateProperty(dtoToEntity);
            return true;
        }

        public async Task<IEnumerable<PropertyEntity>> GetAllProperties()
        {
            return await _propertyRepository.GetAllProperties();
        }

        public async Task<bool> UpdateProperty(PropertyEntity property)
        {
            property.UpdatedAt = DateTime.UtcNow;
            return await _propertyRepository.UpdatePropertie(property.Id, property);
        }

        public async Task<PropertyEntity> GetPropertyById(int id)
        {
            return await _propertyRepository.GetPropertyById(id);
        }

        public async Task AddPropertyImage(PropertyImageEntity image)
        {
            await _propertyRepository.AddPropertyImage(image);
        }

        public async Task SetMainImage(int propertyId, int imageId)
        {
            var property = await _propertyRepository.GetPropertyById(propertyId);
            if (property == null)
            {
                throw new ArgumentException("Property not found");
            }

            var images = property.Images;
            foreach (var image in images)
            {
                image.IsMainImage = image.Id == imageId;
            }

            await _propertyRepository.UpdatePropertie(propertyId,property);
        }

        public async Task DeletePropertyImage(int imageId)
        {
            await _propertyRepository.DeletePropertyImage(imageId);
        }

        public async Task DeleteProperty(int propertyId)
        {
            await _propertyRepository.DeleteProperty(propertyId);
        }
    }
    public interface IPropertyService
    {
        Task<bool> CreateProperty(CreatePropertyDto dto);
        Task<IEnumerable<PropertyEntity>> GetAllProperties();
        Task<bool> UpdateProperty(PropertyEntity property);
        Task<PropertyEntity> GetPropertyById(int id);
        Task AddPropertyImage(PropertyImageEntity image);
        Task SetMainImage(int propertyId, int imageId);
        Task DeletePropertyImage(int imageId);
        Task DeleteProperty(int propertyId);
    }
}
