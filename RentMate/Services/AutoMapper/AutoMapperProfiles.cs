using ApplicationCore.Dto.CreateReq;
using AutoMapper;
using Data.Entities;


namespace Services.AutoMapper
{
    public class AutoMapperProfiles : Profile
    {
        public AutoMapperProfiles()
        {
            CreateMap<CreatePropertyDto, PropertyEntity>();
        }
    }
}
