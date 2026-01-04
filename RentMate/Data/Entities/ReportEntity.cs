using System;
using System.ComponentModel.DataAnnotations;

namespace Data.Entities
{
    public class ReportEntity
    {
        public int Id { get; set; }
        public int ReportedUserId { get; set; }
        public int ReporterId { get; set; }
        [StringLength(2000)]
        public string Reason { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsResolved { get; set; } = false;
        public DateTime? ResolvedAt { get; set; }
        public int? ResolvedByAdminId { get; set; }

        // Navigation properties
        public UserEntity ReportedUser { get; set; }
        public UserEntity Reporter { get; set; }
        public UserEntity? ResolvedByAdmin { get; set; }
    }
}

