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
        private readonly IUserService _userService;
        private readonly IMapper _mapper;
        public PaymentService (
            IPaymentRepository paymentRepository, 
            IOfferRepository offerRepository,
            IPropertyRepository propertyRepository,
            IUserService userService,
            IMapper mapper)
        {
            _paymentRepository = paymentRepository;
            _offerRepository = offerRepository;
            _propertyRepository = propertyRepository;
            _userService = userService;
            _mapper = mapper;
        }
        public async Task<bool> CreatePayment(CreatePaymentDto dto, int ownerId)
        {
            if(dto.OfferId == -1)
            {
                var offers = await _offerRepository.getActiveAndAcceptedOffersByPropId(dto.PropertyId);
                if(offers == null || !offers.Any())
                {
                    throw new Exception("Brak aktywnych ofert dla tego mieszkania");
                }
                foreach(var of in offers)
                {
                    if (of.Status != OfferStatus.Active) continue;

                    var payment = _mapper.Map<PaymentEntity>(dto);
                    payment.OfferId = of.Id;
                    payment.TenantId = of.TenantId.Value;
                    payment.Id = 0;
                    await _paymentRepository.CreatePayment(payment);
                }
                return true;
            }

            if(dto.OfferId != -1)
            {
                var offer = await _offerRepository.getById(dto.OfferId);
                if (offer == null)
                    throw (new Exception("Oferta nie istnieje"));
                var property = await _propertyRepository.GetPropertieById(offer.PropertyId);
                if (property.OwnerId != ownerId)
                    throw new UnauthorizedAccessException("Nie jesteś właścicielem tego mieszkania");
                var dtoToEntity = _mapper.Map<PaymentEntity>(dto);
                if (offer.Status == OfferStatus.Active)
                    throw new Exception("Oferta nie została zaakceptowana przez najemce");
                if (offer.Status == OfferStatus.Completed)
                    throw new Exception("Oferta wygasła");
                if (offer.Status == OfferStatus.Cancelled)
                    throw new Exception("Oferta została anulowana");
                dtoToEntity.TenantId = offer.TenantId.Value;
                await _paymentRepository.CreatePayment(dtoToEntity);
                return true;
            }
            return false;
        }


        public async Task<IEnumerable<PaymentEntity>> GetAllPayments()
        {
            return await _paymentRepository.GetAllPayments();
        }

        //Nie można za każdym razem iterować po payment bo będzie to spowalniało system, trzeba zrobić osobny system 
        //który będzie sprawdzał czy data płatności minęła, jeżeli tak to zmienia status na failed.
        public async Task<IEnumerable<PaymentDto>> GetPaymentsByActiveUserOffers(int ownerId)
        {
            var payments = await _paymentRepository.GetPaymentsByActiveUserOffers(ownerId);
            var now = DateTime.UtcNow;
            var updated = false;

            foreach (var payment in payments)
            {
                if (payment.Status == PaymentStatus.Pending && payment.DueDate < now)
                {
                    payment.Status = PaymentStatus.Failed;
                    updated = true;
                }
            }
            if (updated)
            {
                await _paymentRepository.SaveChangesAsync();
            }
            var entityToDto = _mapper.Map<IEnumerable<PaymentDto>>(payments);
            return entityToDto;
        }
        //Nie można za każdym razem iterować po payment bo będzie to spowalniało system, trzeba zrobić osobny system 
        //który będzie sprawdzał czy data płatności minęła, jeżeli tak to zmienia status na failed.
        public async Task<IEnumerable<PaymentDtoWithTenantName>> GetAllPaymentsForPropertyByActiveUserOffers(int propertyId)
        {
            var payments = await _paymentRepository.GetAllPaymentsForPropertyByActiveUserOffers(propertyId);
            var now = DateTime.UtcNow;
            var updated = false;

            foreach (var payment in payments)
            {
                if (payment.Status == PaymentStatus.Pending && payment.DueDate < now)
                {
                    payment.Status = PaymentStatus.Failed;
                    updated = true;
                }
            }
            if (updated)
            {
                await _paymentRepository.SaveChangesAsync();
            }
            var result = new List<PaymentDtoWithTenantName>();

            foreach (var payment in payments)
            {
                var dto = _mapper.Map<PaymentDtoWithTenantName>(payment);

                var tenant = await _userService.GetUserById(payment.TenantId);
                dto.TenantName = tenant.FirstName;
                dto.TenantSurname = tenant.LastName;

                result.Add(dto);
            }

            return result;

        }
    }
    public interface IPaymentService
    {
        Task<bool> CreatePayment(CreatePaymentDto dto, int ownerId);
        Task<IEnumerable<PaymentEntity>> GetAllPayments();
        Task<IEnumerable<PaymentDto>> GetPaymentsByActiveUserOffers(int ownerId);
        Task<IEnumerable<PaymentDtoWithTenantName>> GetAllPaymentsForPropertyByActiveUserOffers(int propertyId);
    }
}
