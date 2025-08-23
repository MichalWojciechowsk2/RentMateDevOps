using Data.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ApplicationCore.Dto.Payment
{
    public class PaymentDtoWithTenantName
    {
        public int Id { get; set; }
        public int OfferId { get; set; }
        public int TenantId { get; set; }
        public string TenantName { get; set; }
        public string TenantSurname { get; set; }
        public decimal Amount { get; set; }
        public string Description { get; set; }
        public PaymentStatus Status { get; set; }
        public DateTime DueDate { get; set; }
        public DateTime? PaidAt { get; set; }
        public string PaymentMethod { get; set; }
        public string? TransactionId { get; set; }

    }
}
