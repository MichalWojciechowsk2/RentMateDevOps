using ApplicationCore.Dto.Message;
using ApplicationCore.Dto.Payment;
using ApplicationCore.Dto.Property;
using ApplicationCore.Dto.Property.Offer;
using ApplicationCore.Dto.User;
using AutoMapper;
using Data.Entities;


namespace Services.AutoMapper
{
    public class AutoMapperProfiles : Profile
    {
        public AutoMapperProfiles()
        {
            //Property
            CreateMap<PropertyDto, PropertyEntity>();
            CreateMap<UpdatePropertyDto, PropertyEntity>();
            CreateMap<PropertyEntity, UpdatePropertyDto>();


            CreateMap<PropertyEntity, PropertyDto>()
                .ForMember(dest => dest.OwnerId, opt => opt.MapFrom(src => src.OwnerId))
                .ForMember(dest => dest.OwnerUsername, opt => opt.MapFrom(src => src.Owner.FirstName + " " + src.Owner.LastName));

            //Message
            CreateMap<MessageEntity, MessageDto>()
                .ForMember(dest => dest.SenderUsername, opt => opt.MapFrom(src => $"{src.Sender.FirstName} {src.Sender.LastName}"))
                .ForMember(dest => dest.ReceiverUsername, opt => opt.MapFrom(src => $"{src.Receiver.FirstName} {src.Receiver.LastName}"));

            //Users
            CreateMap<UserDto, UserEntity>();
            CreateMap<UserEntity, UserDto>();

            //Offer
            CreateMap<CreateOfferDto, OfferEntity>();
            CreateMap<OfferEntity, OfferDto>();

            //Payment
            CreateMap<PaymentEntity, CreatePaymentDto>();
            CreateMap<CreatePaymentDto, PaymentEntity>()
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => PaymentStatus.Pending));

            CreateMap<PaymentDto, PaymentEntity>();
            CreateMap<PaymentEntity, PaymentDto>();

            CreateMap<PaymentEntity, PaymentDtoWithTenantName>();
            CreateMap<PaymentEntity, PaymentEntity>();
        }
    }
}
