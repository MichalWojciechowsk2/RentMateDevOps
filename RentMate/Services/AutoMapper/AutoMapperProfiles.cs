using ApplicationCore.Dto.Property;
using AutoMapper;
using Data.Entities;


namespace Services.AutoMapper
{
    public class AutoMapperProfiles : Profile
    {
        public AutoMapperProfiles()
        {
            CreateMap<PropertyDto, PropertyEntity>();
            CreateMap<PropertyEntity, PropertyDto>();
        }
    }
}
