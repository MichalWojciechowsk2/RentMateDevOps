using Data.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ApplicationCore.Dto.Message
{
    public class UserPrivateChats
    {
        public int ChatId { get; set; }
        public string ChatName { get; set; }
        public string? LastMessageContent { get; set; }
        public DateTime? LastMessageCreatedAt { get; set; }
        public string OtherUserPhotoUrl { get; set; }
        public string OtherUserName {  get; set; }
    }
}
