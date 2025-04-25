using System.ComponentModel.DataAnnotations;

namespace Data.Entities
{
    public class PropertyImageEntity
    {
        public int Id { get; set; }
        public int PropertyId { get; set; }
        
        [Required]
        public string ImagePath { get; set; }
        
        public bool IsMainImage { get; set; }
        public DateTime UploadedAt { get; set; }

        public PropertyEntity Property { get; set; }
    }
} 