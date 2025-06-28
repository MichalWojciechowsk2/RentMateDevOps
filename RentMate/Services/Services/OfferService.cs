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
    }
    public interface IOfferService
    {
        Task<bool> CreateOffer(CreateOfferDto offerDto);
    }
}
