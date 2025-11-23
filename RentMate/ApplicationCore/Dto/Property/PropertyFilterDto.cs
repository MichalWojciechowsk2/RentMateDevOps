using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ApplicationCore.Dto.Property
{
    public class PropertyFilterDto
    {
        public string? City { get; set; }
        public string? District {  get; set; }
        public decimal? PriceFrom { get; set; }
        public decimal? PriceTo { get; set; }
        public int? Rooms { get; set; }
        public decimal? AreaFrom { get; set; }
        public decimal? AreaTo { get; set; }
    }
}
