using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class Property
    {
        public int Id { get; set; }
        public int OwnerId { get; set; }

        [Required]
        [StringLength(150)]
        public string Title { get; set; }

        [StringLength(2000)]
        public string Description { get; set; }

        [Required]
        [StringLength(200)]
        public string Address { get; set; }
        public decimal Area { get; set; }
        public int RoomCount { get; set; }

        [Required]
        [StringLength(100)]
        public string City { get; set; }

        [Required]
        [StringLength(10)]
        public string PostalCode { get; set; }

        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal BasePrice { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal BaseDeposit { get; set; } //kaucja
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        public User Owner { get; set; }
        public ICollection<Offer> Offers { get; set; }
        public ICollection<Issue> Issues { get; set; }
        public ICollection<Review> Reviews { get; set; }
    }
}
