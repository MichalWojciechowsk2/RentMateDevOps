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
        public async Task<IEnumerable<OfferEntity>> GetActiveAndAcceptedOfferByPropId(int propertyId)
        {
            var offers = await _offerRepository.getActiveAndAcceptedOffersByPropId(propertyId);
            if (offers == null) return null;
            return offers;
        }
        public async Task<IEnumerable<OfferEntity>> GetOfferByUserId(int userId)
        {
            var offer = await _offerRepository.getOfferByUserId(userId);
            if (offer == null) return null;
            return offer;
        }
    }
    public interface IOfferService
    {
        Task<bool> CreateOffer(CreateOfferDto offerDto);
        Task<IEnumerable<OfferEntity>> GetActiveAndAcceptedOfferByPropId(int propertyId);
        Task<IEnumerable<OfferEntity>> GetOfferByUserId(int userId)
    }
}
