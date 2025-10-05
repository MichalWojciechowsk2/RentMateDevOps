using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class ChatEntity
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public bool IsGroup { get; set; }
        public DateTime CreatedAt { get; set; }
        public int LastMessageId { get; set; }
        public ICollection<ChatUsersEntity> ChatUsers { get; set; } = new List<ChatUsersEntity>();
        public ICollection<MessageEntity> Messages { get; set; } = new List<MessageEntity>();
    }

}
