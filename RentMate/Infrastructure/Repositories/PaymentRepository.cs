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
        public async Task<PaymentEntity?> CreatePayment(PaymentEntity entity)
        {
                await _context.Payments.AddAsync(entity);
                await _context.SaveChangesAsync();
                return entity;
        }
        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
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
                .Where(p => p.TenantId == userId && p.Offer.Status == OfferStatus.Accepted)
                .ToListAsync();
        }
        public async Task<IEnumerable<PaymentEntity>> GetAllPaymentsForPropertyByActiveUserOffers(int propertyId)
        {
            return await _context.Properties
                .Where(p => p.Id == propertyId)
                .SelectMany(p => p.Offers)
                .Where(o=>o.Status == OfferStatus.Accepted && o.Payments != null)
                .SelectMany(o => o.Payments)
                .ToListAsync();
        }
    }
    public interface IPaymentRepository
    {
        Task<PaymentEntity?> CreatePayment(PaymentEntity entity);
        Task SaveChangesAsync();
        Task UpdateAsync(PaymentEntity entity);
        Task<IEnumerable<PaymentEntity>> GetAllPayments();
        Task<IEnumerable<PaymentEntity>> GetAllPaymentsByOfferId(int id);
        Task<PaymentEntity> GetPaymentById(int id);
        Task<IEnumerable<PaymentEntity>> GetPaymentsByActiveUserOffers(int userId);
        Task<IEnumerable<PaymentEntity>> GetAllPaymentsForPropertyByActiveUserOffers(int propertyId);

    }
}
