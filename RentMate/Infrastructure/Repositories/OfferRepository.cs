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
        public async Task<OfferEntity> getById(int id)
        {
            return await _context.Offers.Where(o => o.Id == id).FirstOrDefaultAsync();
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
                return await _context.Offers.Include(o => o.Tenant)
                    .Where(o => o.PropertyId == propertyId &&
                    (o.Status == OfferStatus.Active || o.Status == OfferStatus.Accepted)).ToListAsync();
            }
            catch(Exception ex)
            {
                Console.Error.WriteLine($"Błąd podczas pobierania oferty dla propertyId {propertyId}: {ex.Message}");
                return null;
            }
        }
        public async Task<IEnumerable<OfferEntity>> getOfferByUserId(int userId)
        {
            try
            {
                return await _context.Offers
                    .Where(o => o.TenantId == userId).ToListAsync();
            }
            catch(Exception ex)
            {
                Console.Error.WriteLine($"Błąd podczas pobierania oferty dla userId {userId}: {ex.Message}");
                return null;
            }
        }
        public async Task<OfferEntity> getOfferById(int offerId)
        {
            return await _context.Offers.FirstOrDefaultAsync(o => o.Id == offerId);
        }
        public async Task UpdateAsync(OfferEntity offer)
        {
            _context.Set<OfferEntity>().Update(offer);
            await _context.SaveChangesAsync();
        }
    }
    public interface IOfferRepository
    {
        Task<OfferEntity> getById(int id);
        Task<bool> CreateOffer(OfferEntity entity);
        Task<IEnumerable<OfferEntity>> getActiveAndAcceptedOffersByPropId(int propertyId);
        Task<IEnumerable<OfferEntity>> getOfferByUserId(int userId);
        Task<OfferEntity> getOfferById(int offerId);
        Task UpdateAsync(OfferEntity offer);
    }
}
