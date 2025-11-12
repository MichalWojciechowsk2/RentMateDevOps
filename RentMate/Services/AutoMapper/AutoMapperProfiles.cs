using ApplicationCore.Dto.Message;
using ApplicationCore.Dto.Payment;
using ApplicationCore.Dto.Property;
using ApplicationCore.Dto.Property.Offer;
using ApplicationCore.Dto.User;
using ApplicationCore.Dto.Issue;
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
                .ForMember(dest => dest.OwnerUsername, opt => opt.MapFrom(src => src.Owner.FirstName + " " + src.Owner.LastName))
                .ForMember(dest => dest.OwnerPhoneNumber, opt => opt.MapFrom(src => src.Owner.PhoneNumber))
                .ForMember(dest => dest.Images, opt => opt.MapFrom(src => src.PropertyImages));

            //PropertyImage
            CreateMap<PropertyImageEntity, PropertyImageDto>();
            CreateMap<CreatePropertyImageDto, PropertyImageEntity>();

            //Message
            CreateMap<MessageEntity, MessageDto>()
                .ForMember(dest => dest.SenderUsername, opt => opt.MapFrom(src => $"{src.Sender.FirstName} {src.Sender.LastName}"));
                //.ForMember(dest => dest.ReceiverUsername, opt => opt.MapFrom(src => $"{src.Receiver.FirstName} {src.Receiver.LastName}"));

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

            //Issue
            CreateMap<CreateIssueDto, IssueEntity>();
            CreateMap<IssueEntity, IssueDto>();

            CreateMap<PaymentEntity, PaymentDtoWithTenantName>();
            CreateMap<PaymentEntity, PaymentEntity>();

            CreateMap<RecurringPaymentEntity, RecurringPaymentDto>()
            .ForMember(dest => dest.Payment, opt => opt.MapFrom(src => src.Payment));

            //Chat
            CreateMap<MessageEntity, MessageDto>()
            .ForMember(dest => dest.SenderId, opt => opt.MapFrom(src => src.SenderId));

            CreateMap<UserEntity, UserDto>();
        }
    }
}
