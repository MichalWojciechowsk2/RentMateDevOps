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
    public class RecurringPaymentRepository : IRecurringPaymentRepository
    {
        private readonly RentMateDbContext _dbContext;
        public RecurringPaymentRepository(RentMateDbContext dbContext)
        {
            _dbContext = dbContext;
        }
        public async Task<bool> CreateRecurringPayment(RecurringPaymentEntity entity)
        {
            try
            {
                await _dbContext.RecurringPayment.AddAsync(entity);
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }
        public async Task<IEnumerable<RecurringPaymentEntity>> getAllWithPayment()
        {
            return await _dbContext.RecurringPayment.Include(p => p.Payment).ToListAsync();
        }
        public async Task<RecurringPaymentEntity> getRecurringPaymentById(int id)
        {
            return await _dbContext.RecurringPayment.Where(rp => rp.Id == id).FirstOrDefaultAsync();
        }

        public async Task<bool> updatePaymentId(int recurringPaymentId, int newPaymentId)
        {
            var recurringPayment = await getRecurringPaymentById(recurringPaymentId);
            if (recurringPayment == null)   return false;
            recurringPayment.Id = newPaymentId;
            recurringPayment.RecurrenceTimes--;
            _dbContext.RecurringPayment.Update(recurringPayment);
            await _dbContext.SaveChangesAsync();
            return true;
        }
    }

    public interface IRecurringPaymentRepository
    {
        Task<bool> CreateRecurringPayment(RecurringPaymentEntity entity);
        Task<IEnumerable<RecurringPaymentEntity>> getAllWithPayment();
        Task<RecurringPaymentEntity> getRecurringPaymentById(int id);
        Task<bool> updatePaymentId(int recurringPaymentId, int newPaymentId);
    }
}
