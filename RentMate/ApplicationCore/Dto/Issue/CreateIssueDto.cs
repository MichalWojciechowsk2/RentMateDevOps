using System.ComponentModel.DataAnnotations;

namespace ApplicationCore.Dto.Issue
{
    public class CreateIssueDto
    {
        [Required]
        public int PropertyId { get; set; }
        
        [Required]
        [StringLength(150)]
        public string Title { get; set; }
        
        [Required]
        [StringLength(2000)]
        public string Description { get; set; }
        
        [Required]
        public int Urgency { get; set; } // 0 = Low, 1 = Medium, 2 = High, 3 = Critical
    }
}

