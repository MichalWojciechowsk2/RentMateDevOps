using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class RecurringPaymentEntity
    {
        public int Id { get; set; }
        public int PaymentId { get; set; }
        public PaymentEntity Payment { get; set; }
        public int RecurrenceTimes { get; set; }
    }
}
