using Data.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ApplicationCore.Dto.Payment
{
    public class CreatePaymentDto
    {
        public int OfferId { get; set; }
        public decimal Amount { get; set; }
        public string Description { get; set; }
        public DateTime DueDate {  get; set; }
        public string PaymentMethod { get; set; }
    }
}
