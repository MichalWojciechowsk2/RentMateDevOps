using ApplicationCore.Dto.Payment;
using AutoMapper;
using Data.Entities;
using Infrastructure.Repositories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace Services.Services
{
    public class PaymentService : IPaymentService
    {
        private readonly IPaymentRepository _paymentRepository;
        private readonly IOfferRepository _offerRepository;
        private readonly IPropertyRepository _propertyRepository;
        private readonly IMapper _mapper;
        public PaymentService (
            IPaymentRepository paymentRepository, 
            IOfferRepository offerRepository,
            IPropertyRepository propertyRepository,
            IMapper mapper)
        {
            _paymentRepository = paymentRepository;
            _offerRepository = offerRepository;
            _propertyRepository = propertyRepository;
            _mapper = mapper;
        }
        public async Task<bool> CreatePayment(CreatePaymentDto dto, int ownerId)
        {
            var offer = await _offerRepository.getById(dto.OfferId);
            if (offer == null)
                throw (new Exception("Oferta nie istnieje"));
            var property = await _propertyRepository.GetPropertieById(offer.PropertyId);
            if (property.OwnerId != ownerId)
                throw new UnauthorizedAccessException("Nie jesteś właścicielem tego mieszkania");
            var dtoToEntity = _mapper.Map<PaymentEntity>(dto);
            if (!offer.TenantId.HasValue)
                throw new Exception("Oferta nie została zaakceptowana przez najemce");
            dtoToEntity.TenantId = offer.TenantId.Value;
            await _paymentRepository.CreatePayment(dtoToEntity);
            return true;
        }
    }
    public interface IPaymentService
    {
        Task<bool> CreatePayment(CreatePaymentDto dto, int ownerId);
    }
}
