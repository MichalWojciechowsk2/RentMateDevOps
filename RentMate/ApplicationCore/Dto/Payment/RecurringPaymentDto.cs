using Data.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace ApplicationCore.Dto.Payment
{
    public class RecurringPaymentDto
    {
        public int Id { get; set; }
        public int PaymentId { get; set; }
        public int RecurrenceTimes { get; set; }
        public PaymentDto Payment { get; set; }
    }
}