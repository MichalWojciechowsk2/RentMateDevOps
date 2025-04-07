using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class Offer
    {
        public int Id { get; set; }
        public int PropertyId { get; set; }

        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal RentAmount { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal DepositAmount { get; set; }

        public DateTime RentalPeriodStart { get; set; }
        public DateTime RentalPeriodEnd { get; set; }

        // Status oferty
        public OfferStatus Status { get; set; }

        // Dane najemcy (gdy oferta zostanie zaakceptowana)
        public int? TenantId { get; set; }
        public User Tenant { get; set; }

        public DateTime CreatedAt { get; set; }
        public DateTime? AcceptedAt { get; set; }

        public Property Property { get; set; }
        public ICollection<Payment> Payments { get; set; }
    }

    public enum OfferStatus
    {
        Active,         // Oferta jest aktywna i czeka na najemcę
        Accepted,       // Oferta została zaakceptowana przez najemcę
        Completed,      // Umowa została zakończona
        Cancelled       // Oferta została anulowana
    }
}
