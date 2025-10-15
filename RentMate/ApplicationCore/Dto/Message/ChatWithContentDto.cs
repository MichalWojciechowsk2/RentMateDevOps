using ApplicationCore.Dto.User;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ApplicationCore.Dto.Message
{
    public class ChatWithContentDto
    {
        public int ChatId {  get; set; }
        public IEnumerable<UserDto> Users { get; set; }
        public IEnumerable<MessageDto> Messages { get; set; }
    }
}
