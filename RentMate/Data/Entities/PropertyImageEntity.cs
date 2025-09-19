using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Data.Entities
{
    public class PropertyImageEntity
    {
        public int Id { get; set; }
        
        [Required]
        public int PropertyId { get; set; }
        
        [Required]
        [StringLength(500)]
        public string ImageUrl { get; set; }

        public bool IsMainImage { get; set; }
        
        public DateTime CreatedAt { get; set; }
        
        public PropertyEntity Property { get; set; }
    }
} 