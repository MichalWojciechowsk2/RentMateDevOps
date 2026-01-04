using System;

namespace ApplicationCore.Dto.Issue
{
    public class IssueDto
    {
        public int Id { get; set; }
        public int PropertyId { get; set; }
        public int TenantId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int Status { get; set; } // 0 = New, 1 = InProgress, 2 = Resolved, 3 = Closed
        public int Urgency { get; set; } // 0 = Low, 1 = Medium, 2 = High, 3 = Critical
        public DateTime CreatedAt { get; set; }
        public DateTime? ResolvedAt { get; set; }
    }
}


