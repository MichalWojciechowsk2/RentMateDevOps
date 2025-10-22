using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class PropertyEntity
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
        public decimal Area {  get; set; }
        public string District { get; set; }
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
        //dodano chatGroup
        public int ChatGroupId { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        public UserEntity Owner { get; set; }
        public ICollection<OfferEntity> Offers { get; set; }
        public ICollection<IssueEntity> Issues { get; set; }
        public ICollection<ReviewEntity> Reviews { get; set; }
        public ICollection<PropertyImageEntity> PropertyImages { get; set; }
    }
}
