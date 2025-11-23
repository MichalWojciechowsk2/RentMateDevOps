using Data.Entities;
using System.ComponentModel.DataAnnotations;

namespace ApplicationCore.Dto.Review
{
    public class ReviewDto
    {
        public int Id { get; set; }
        public int? PropertyId { get; set; }
        public int? UserId { get; set; }
        [Range(1, 5)]
        public decimal Rating { get; set; }
        [StringLength(1000)]
        public string Comment { get; set; }
    }
}
