using Data;
using Data.Entities;
using Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Query;
using Services.Services;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services
{
    public class RecurringPaymentsGenerator 
    {
        private readonly IRecurringPaymentRepository _recurringPaymentRepository;
        private readonly IPaymentRepository _paymentRepository;


        public RecurringPaymentsGenerator(IRecurringPaymentRepository recurringPaymentRepository, IPaymentRepository paymentRepository)
        {
            _recurringPaymentRepository = recurringPaymentRepository;
            _paymentRepository = paymentRepository;
        }

        public async Task GeneratePaymentsAsync()
        {
            var listToGenerate = await CheckIfGenerateAsync();
            foreach (var item in listToGenerate)
            {
                
                _paymentRepository.CreatePayment();
            }

        }

        private async Task<IEnumerable<RecurringPaymentEntity>> CheckIfGenerateAsync()
        {
            var rp = await _recurringPaymentRepository.getAllWithPayment();
            var rpToGenerate = new List<RecurringPaymentEntity>();
            foreach (var item in rp)
            {
                if (item.Payment.CreateDateTime.AddDays(item.NextGenerationInDays) >= DateTime.UtcNow)
                {
                    rpToGenerate.Add(item);
                }
            }
            return rpToGenerate;
        }

    }
}
