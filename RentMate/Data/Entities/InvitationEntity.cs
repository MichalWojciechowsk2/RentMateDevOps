using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class InvitationEntity
    {
        public int Id { get; set; }
        public int SenderId { get; set; }
        public int ReceiverId { get; set; }
        public int? OfferId { get; set; }
        public InvitationStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? RespondedAt { get; set; }
        public UserEntity Sender { get; set; }
        public UserEntity Receiver { get; set; }
        public OfferEntity Offer { get; set; }
    }
    public enum InvitationStatus
    {
        Pending,
        Accepted,
        Rejected
    }
}
