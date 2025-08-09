using ApplicationCore.Dto.Property.Offer;
using AutoMapper;
using Data.Entities;
using Infrastructure.Repositories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services.Services
{
    public class OfferService : IOfferService
    {
        private readonly IOfferRepository _offerRepository;
        private readonly IMapper _mapper;
        private readonly string _templatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "OfferTemplates", "rental_contract_v1.txt");
        public OfferService(IOfferRepository offerRepository, IMapper mapper)
        {
            _offerRepository = offerRepository;
            _mapper = mapper;
        }
        public async Task<bool> CreateOffer(CreateOfferDto offerDto)
        {
            var dtoToEntity = _mapper.Map<OfferEntity>(offerDto);
            dtoToEntity.CreatedAt = DateTime.Now;
            dtoToEntity.Status = OfferStatus.Active;
            await _offerRepository.CreateOffer(dtoToEntity);
            return true;
        }
        public async Task<IEnumerable<OfferDto>> GetActiveAndAcceptedOfferByPropId(int propertyId)
        {
            var offers = await _offerRepository.getActiveAndAcceptedOffersByPropId(propertyId);

            if (offers == null) return null;
            return _mapper.Map<IEnumerable<OfferDto>>(offers);
        }
        public async Task<IEnumerable<OfferEntity>> GetOfferByUserId(int userId)
        {
            var offer = await _offerRepository.getOfferByUserId(userId);
            if (offer == null) return null;
            return offer;
        }
        public async Task<OfferDto> GetOfferById(int offerId)
        {
            var offer = await _offerRepository.getOfferById(offerId);
            if (offer == null) return null;
            return _mapper.Map<OfferDto>(offer);
        }
        public async Task<OfferEntity> UpdateOfferStatus(int offerId, OfferStatus newStatus)
        {
            var offer = await _offerRepository.getById(offerId);
            if (offer == null) throw new KeyNotFoundException($"Oferta o ID {offerId} nie istnieje");
            offer.Status = newStatus;
            offer.AcceptedAt = DateTime.Now;
            await _offerRepository.UpdateAsync(offer);
            return offer;
        }
        public string GenerateOfferContract(Dictionary<string, string> data)
        {
            string template = File.ReadAllText(_templatePath);
            foreach (var entry in data)
            {
                template = template.Replace($"{{{{{entry.Key}}}}}", entry.Value ?? string.Empty);
            }
            return template;
        }
    }
    public interface IOfferService
    {
        Task<bool> CreateOffer(CreateOfferDto offerDto);
        Task<IEnumerable<OfferDto>> GetActiveAndAcceptedOfferByPropId(int propertyId);
        Task<IEnumerable<OfferEntity>> GetOfferByUserId(int userId);
        Task<OfferDto> GetOfferById(int offerId);
        Task<OfferEntity> UpdateOfferStatus(int offerId, OfferStatus newStatus);
        public string GenerateOfferContract(Dictionary<string, string> data);
    }
}
