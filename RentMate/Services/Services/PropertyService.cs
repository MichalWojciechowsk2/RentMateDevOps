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
            dtoToEntity.OwnerId = 2; // CHANGE IN FUTURE!
            await _propertyRepository.CreateProperty(dtoToEntity);
            return true;
        }

        public async Task<IEnumerable<PropertyEntity>> GetAllProperties()
        {
            return await _propertyRepository.GetAllProperties();
        }
    }
    public interface IPropertyService
    {
        Task<bool> CreateProperty(CreatePropertyDto dto);
        Task<IEnumerable<PropertyEntity>> GetAllProperties();
    }
}
