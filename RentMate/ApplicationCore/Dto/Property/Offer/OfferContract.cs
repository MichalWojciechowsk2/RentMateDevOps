using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ApplicationCore.Dto.Property.Offer
{
    public class OfferContract
    {
        public string CreatedAt { get; set; }
        public string City { get; set; }
        public string OwnerNameSurname { get; set; }
        public string TenantNameSurname { get; set; }
        public string PropertyCity { get; set; }
        public string PropertyAdressStreet { get; set; }
        public string PropertyRoomCount { get; set; }
        public string PropertyArea { get; set; }
        public string RentalStartDate { get; set; }
        public string RentalEndDate { get; set; }
        public string RentAmount { get; set; }
    }
}
