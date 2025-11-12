using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class ReviewEntity
    {
        //Opinie można dodać do mieszkania lub do konkretnego użytkownika
        public int Id { get; set; }
        public int? PropertyId { get; set; }
        public int? UserId { get; set; }
        public int AuthorId { get; set; }
        [Range(1, 5)]
        public decimal Rating { get; set; }
        [StringLength(1000)]
        public string Comment { get; set; }
        public DateTime CreatedAt { get; set; }

        public PropertyEntity? Property { get; set; }
        //Użytkownik dla którego została wystawniona opinia
        public UserEntity? User { get; set; }
        public UserEntity Author { get; set; }
    }
}
