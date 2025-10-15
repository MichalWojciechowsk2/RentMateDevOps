using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class MessageEntity
    {
        public int Id { get; set; }
        public int SenderId { get; set; }
        //Pomyśleć czy tego nie usunąć skoro tworzymy chaty
        //public int? ReceiverId { get; set; }
        public int? IssueId { get; set; }
        [Required]
        [StringLength(4000)]
        public string Content { get; set; }
        public bool IsRead { get; set; }
        public DateTime CreatedAt { get; set; }
        public int? ChatId { get; set; }

        public UserEntity Sender { get; set; }
        //public UserEntity Receiver { get; set; }
        public IssueEntity Issue { get; set; }
        public ChatEntity Chat { get; set; }
    }
}
