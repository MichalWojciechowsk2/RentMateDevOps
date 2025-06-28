using Data;
using Data.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Repositories
{
    public class OfferRepository : IOfferRepository
    {
        private readonly RentMateDbContext _context;
        public OfferRepository(RentMateDbContext context)
        {
            _context = context;
        }
        public async Task<bool> CreateOffer(OfferEntity entity)
        {
            try
            {
                await _context.Offers.AddAsync(entity);
                await _context.SaveChangesAsync();
                return true;
            }
            catch(Exception ex)
            {
                return false;
            }
        }
        public async Task<IEnumerable<OfferEntity>> getActiveAndAcceptedOffersByPropId(int propertyId)
        {
            try
            {
                return await _context.Offers
                    .Where(o => o.PropertyId == propertyId &&
                    (o.Status == OfferStatus.Active || o.Status == OfferStatus.Accepted))
                    .ToListAsync();
            }
            catch(Exception ex)
            {
                throw;
            }
        }
    }
    public interface IOfferRepository
    {
        Task<bool> CreateOffer(OfferEntity entity);
        Task<IEnumerable<OfferEntity>> getActiveAndAcceptedOffersByPropId(int propertyId);
    }
}
