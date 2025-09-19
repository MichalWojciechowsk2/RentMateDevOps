using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class PaymentEntity
    {
        public int Id { get; set; }
        public int OfferId { get; set; }
        public int TenantId { get; set; }
        //public int? RecurringPaymentId { get; set; }
        public decimal Amount { get; set; }
        public string Description { get; set; }
        public PaymentStatus Status { get; set; }
        public DateTime DueDate { get; set; }
        public DateTime CreateDateTime { get; set; }
        public DateTime? PaidAt { get; set; }
        public string PaymentMethod { get; set; }
        public string? TransactionId { get; set; }
        public OfferEntity Offer { get; set; }
        public UserEntity Tenant { get; set; }
        
    }

    public enum PaymentStatus
    {
        Pending,
        Completed,
        Failed,
        Cancelled
    }
}
