using ApplicationCore.Dto.Message;
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

            CreateMap<PropertyEntity, PropertyDto>()
    .ForMember(dest => dest.OwnerId, opt => opt.MapFrom(src => src.OwnerId))
    .ForMember(dest => dest.OwnerUsername, opt => opt.MapFrom(src => src.Owner.FirstName + " " + src.Owner.LastName));

            CreateMap<MessageEntity, MessageDto>()
                .ForMember(dest => dest.SenderUsername, opt => opt.MapFrom(src => $"{src.Sender.FirstName} {src.Sender.LastName}"))
                .ForMember(dest => dest.ReceiverUsername, opt => opt.MapFrom(src => $"{src.Receiver.FirstName} {src.Receiver.LastName}"));

            CreateMap<UserDto, UserEntity>();
            CreateMap<UserEntity, UserDto>();

        }
    }
}
