using Data;
using Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Identity.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Repositories
{
    public class NotificationRepository
    {
        private readonly RentMateDbContext _context;
        public NotificationRepository (RentMateDbContext context)
        {
            _context = context;
        }

        public async Task <IEnumerable<NotificationEntity>> GetNotificationsForReceiver(int receiverId)
        {
            return await _context.Notifications.Where(n => n.ReceiverId == receiverId)
                .OrderByDescending(n => n.CreatedAt).ToListAsync();
        }
        public async Task<NotificationEntity> createNotification(NotificationEntity notificationEntity)
        {
            _context.Notifications.Add(notificationEntity);
            _context.SaveChangesAsync();
            return notificationEntity;
        }
        public async Task<NotificationEntity> SetReadNotificationTrue(int notificationId)
        {
            var notification = await _context.Notifications.FirstOrDefaultAsync(n=> n.Id == notificationId);
            if (notification == null) return null;
            notification.IsRead = true;
            _context.SaveChangesAsync();
            return notification;
        }
    }
    public interface INotificationRepository
    {
        Task<IEnumerable<NotificationEntity>> GetNotificationsForReceiver(int receiverId);
        Task<NotificationEntity> createNotification(NotificationEntity notificationEntity);
        Task<NotificationEntity> SetReadNotificationTrue(int notificationId);
    }
}
