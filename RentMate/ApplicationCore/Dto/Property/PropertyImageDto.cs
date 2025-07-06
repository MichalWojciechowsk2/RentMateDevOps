namespace ApplicationCore.Dto.Property
{
    public class PropertyImageDto
    {
        public int Id { get; set; }
        public int PropertyId { get; set; }
        public string ImageUrl { get; set; }
        public bool IsMainImage { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreatePropertyImageDto
    {
        public int PropertyId { get; set; }
        public bool IsMainImage { get; set; }
    }
} 