namespace ApplicationCore.Dto.Admin
{
    public class AdminReviewDto
    {
        public int Id { get; set; }
        public int? PropertyId { get; set; }
        public int? UserId { get; set; }
        public int AuthorId { get; set; }
        public decimal? Rating { get; set; }
        public string Comment { get; set; }
        public DateTime CreatedAt { get; set; }
        public string? AuthorName { get; set; }
        public string? PropertyAddress { get; set; }
        public string? ReviewedUserName { get; set; }
    }
}

