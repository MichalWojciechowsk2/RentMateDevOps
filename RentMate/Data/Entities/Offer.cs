using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class Offer
    {
        public int Id { get; set; }
        public int PropertyId { get; set; }
        public decimal MonthlyPrice { get; set; }
        public decimal Deposit { get; set; }
        public DateTime AvailableFrom { get; set; }
        public DateTime? AvailableTo { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        public Property Property { get; set; }
        public ICollection<Payment> Payments { get; set; }
    }
}
