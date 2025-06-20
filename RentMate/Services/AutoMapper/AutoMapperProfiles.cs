using ApplicationCore.Dto.Property;
using ApplicationCore.Dto.User;
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

            CreateMap<UserDto, UserEntity>();
            CreateMap<UserEntity, UserDto>();
        }
    }
}
