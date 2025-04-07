using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class Review
    {
        public int Id { get; set; }
        public int PropertyId { get; set; }
        public int AuthorId { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; }
        public DateTime CreatedAt { get; set; }

        public Property Property { get; set; }
        public User Author { get; set; }
    }
}
