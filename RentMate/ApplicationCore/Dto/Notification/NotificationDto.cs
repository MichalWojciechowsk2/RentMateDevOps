using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ApplicationCore.Dto.Notification
{
    public class NotificationDto
    {
        public int ReceiverId { get; set; }
        public NotificationType Type { get; set; }
    }
}
