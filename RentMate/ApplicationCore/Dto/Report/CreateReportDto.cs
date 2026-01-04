using System.ComponentModel.DataAnnotations;

namespace ApplicationCore.Dto.Report
{
    public class CreateReportDto
    {
        [Required]
        public int ReportedUserId { get; set; }
        
        [Required]
        [StringLength(2000)]
        public string Reason { get; set; }
    }
}

