using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class ChatUsersEntity
    {
        public int Id { get; set; }
        public int ChatId { get; set; }
        public int UserId { get; set; }
        [JsonIgnore]
        public ChatEntity Chat { get; set; }
        public UserEntity User { get; set; }
    }
}
