using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ApplicationCore.Dto.Property
{
    public class PropertyDto
    {
        public string? Id { get; set; }
        public string? OwnerId { get; set; }
        [Required]
        [StringLength(150)]
        public string Title { get; set; }

        [StringLength(2000)]
        public string Description { get; set; }

        [Required]
        [StringLength(200)]
        public string Address { get; set; }
        public decimal Area { get; set; }
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
        public bool isActive { get; set; }

        public string? OwnerUsername { get; set; }
        
        public List<PropertyImageDto>? Images { get; set; }
        public int ChatGroupId { get; set; }
    }
}
