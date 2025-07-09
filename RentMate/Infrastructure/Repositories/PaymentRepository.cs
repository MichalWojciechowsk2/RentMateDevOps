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
    public class PaymentRepository : IPaymentRepository
    {
        private readonly RentMateDbContext _context;
        public PaymentRepository(RentMateDbContext context)
        {
            _context = context;
        }
        public async Task<bool> CreatePayment(PaymentEntity entity)
        {
            try
            {
                await _context.Payments.AddAsync(entity);
                await _context.SaveChangesAsync();
                return true;
            }
            catch(Exception ex)
            {
                return false;
            }
        }
        public async Task UpdateAsync(PaymentEntity entity)
        {
            _context.Payments.Update(entity);
            await _context.SaveChangesAsync();
        }
        public async Task<IEnumerable<PaymentEntity>> GetAllPayments()
        {
            return await _context.Payments.ToListAsync();
        }
        public async Task<IEnumerable<PaymentEntity>> GetAllPaymentsByOfferId(int id)
        {
            return await _context.Payments.Where(p => p.OfferId == id).ToListAsync();
        }
        public async Task<PaymentEntity> GetPaymentById(int id)
        {
            return await _context.Payments.Where(p => p.Id == id).FirstOrDefaultAsync();
        }
        public async Task<IEnumerable<PaymentEntity>> GetPaymentsByActiveUserOffers(int userId)
        {
            return await _context.Payments.Include(p => p.Offer)
                .Where(p => p.TenantId == userId && p.Offer.Status == OfferStatus.Active)
                .ToListAsync();
        }
    }
    public interface IPaymentRepository
    {
        Task<bool> CreatePayment(PaymentEntity entity);
        Task UpdateAsync(PaymentEntity entity);
        Task<IEnumerable<PaymentEntity>> GetAllPayments();
        Task<IEnumerable<PaymentEntity>> GetAllPaymentsByOfferId(int id);
        Task<PaymentEntity> GetPaymentById(int id);
        Task<IEnumerable<PaymentEntity>> GetPaymentsByActiveUserOffers(int userId);

    }
}
