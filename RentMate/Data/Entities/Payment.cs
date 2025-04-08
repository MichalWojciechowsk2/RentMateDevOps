using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class Payment
    {
        public int Id { get; set; }
        public int OfferId { get; set; }
        public int TenantId { get; set; }
        public decimal Amount { get; set; }
        public PaymentStatus Status { get; set; }
        public DateTime DueDate { get; set; }
        public DateTime? PaidAt { get; set; }
        public string PaymentMethod { get; set; }
        public string TransactionId { get; set; }

        public Offer Offer { get; set; }
        public User Tenant { get; set; }
    }

    public enum PaymentStatus
    {
        Pending,
        Completed,
        Failed,
        Cancelled
    }
}
