using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class Issue
    {
        public int Id { get; set; }
        public int PropertyId { get; set; }
        public int TenantId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public IssueStatus Status { get; set; }
        public IssueUrgency Urgency { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ResolvedAt { get; set; }

        public Property Property { get; set; }
        public User Tenant { get; set; }
        public ICollection<Message> Messages { get; set; }
    }

    public enum IssueStatus
    {
        New,
        InProgress,
        Resolved,
        Closed
    }

    public enum IssueUrgency
    {
        Low,
        Medium,
        High,
        Critical
    }
}
