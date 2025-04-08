﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
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
        [Range(1, 5)]
        public int Rating { get; set; }
        [StringLength(1000)]
        public string Comment { get; set; }
        public DateTime CreatedAt { get; set; }

        public Property Property { get; set; }
        public User Author { get; set; }
    }
}
