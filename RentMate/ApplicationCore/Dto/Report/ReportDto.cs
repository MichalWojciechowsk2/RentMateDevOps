namespace ApplicationCore.Dto.Report
{
    public class ReportDto
    {
        public int Id { get; set; }
        public int ReportedUserId { get; set; }
        public int ReporterId { get; set; }
        public string Reason { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsResolved { get; set; }
        public DateTime? ResolvedAt { get; set; }
        public int? ResolvedByAdminId { get; set; }
        public string? ReportedUserName { get; set; }
        public string? ReporterName { get; set; }
        public string? ResolvedByAdminName { get; set; }
    }
}

