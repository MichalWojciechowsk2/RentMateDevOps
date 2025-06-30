using Data.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ApplicationCore.Dto.Property.Offer
{
    public class CreateOfferDto
    {
        public int PropertyId { get; set; }
        public decimal RentAmount { get; set; }
        public decimal DepositAmount { get; set; }
        public DateTime RentalPeriodStart { get; set; }
        public DateTime RentalPeriodEnd { get; set; }
        public int? TenantId { get; set; }
    }
}
