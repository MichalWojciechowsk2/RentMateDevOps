using Data;
using Data.Entities;
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
    }
    public interface IOfferRepository
    {
        Task<bool> CreateOffer(OfferEntity entity);
    }
}
