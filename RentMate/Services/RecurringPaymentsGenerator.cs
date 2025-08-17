using AutoMapper;
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
        private readonly IMapper _mapper;


        public RecurringPaymentsGenerator(IRecurringPaymentRepository recurringPaymentRepository, IPaymentRepository paymentRepository, IMapper mapper)
        {
            _recurringPaymentRepository = recurringPaymentRepository;
            _paymentRepository = paymentRepository;
            _mapper = mapper;
        }

        public async Task GeneratePaymentsAsync()
        {
            var listToGenerate = await CheckIfGenerateAsync();
            foreach (var item in listToGenerate)
            {
                var payment = _mapper.Map<PaymentEntity>(item.Payment);
                //To chyba nie jest konieczne bo data ustawia się automatycznie dobrze.
                payment.CreateDateTime = DateTime.UtcNow;
                payment.Id = 0;
                //var payment = item.Payment;
                //payment.CreateDateTime = DateTime.UtcNow;
                var createdPayment = await _paymentRepository.CreatePayment(payment);
                await _recurringPaymentRepository.updatePaymentId(item.Id, createdPayment.Id);
            }
        }

        private async Task<IEnumerable<RecurringPaymentEntity>> CheckIfGenerateAsync()
        {
            var rp = await _recurringPaymentRepository.getAllWithPayment();
            var rpToGenerate = new List<RecurringPaymentEntity>();
            foreach (var item in rp)
            {
                //if (item.Payment.CreateDateTime.AddDays(item.NextGenerationInDays) <= DateTime.UtcNow)
                //{
                //    rpToGenerate.Add(item);
                //}
                if (item.RecurrenceTimes > 0) rpToGenerate.Add(item);
            }
            return rpToGenerate;
        }

    }
}
