using Data;
using Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Identity.Client;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Repositories
{
    public class NotificationRepository : INotificationRepository
    {
        private readonly RentMateDbContext _context;
        public NotificationRepository (RentMateDbContext context)
        {
            _context = context;
        }
        public async Task<NotificationEntity> GetNotificationById(int id)
        {
            return await _context.Notifications.FirstOrDefaultAsync(n=> n.Id == id);
        }
        public async Task SetReadNotificationTrue(int id)
        {
            var noti = await _context.Notifications.FirstOrDefaultAsync(n => n.Id == id);
            noti.IsRead = true;
            await _context.SaveChangesAsync();
        }
        public async Task <IEnumerable<NotificationEntity>> GetNotificationsForReceiver(int receiverId)
        {
            return await _context.Notifications.Where(n => n.ReceiverId == receiverId)
                .OrderByDescending(n => n.CreatedAt).ToListAsync();
        }
        public async Task<NotificationEntity> createNotification(NotificationEntity notificationEntity)
        {
            _context.Notifications.Add(notificationEntity);
            await _context.SaveChangesAsync();
            return notificationEntity;
        }
        public async Task<NotificationEntity> SetReadNotiTrue(int notificationId)
        {
            var notification = await _context.Notifications.FirstOrDefaultAsync(n=> n.Id == notificationId);
            if (notification == null) return null;
            notification.IsRead = true;
            await _context.SaveChangesAsync();
            return notification;
        }
        public async Task<IEnumerable<NotificationEntity>> GetNotificationsByReceiverId(int receiverId)
        {
            var notifications = await _context.Notifications.Where(n=>n.ReceiverId == receiverId).ToListAsync();
            if(notifications == null) return null;
            return notifications;
        }
        public async Task<bool> DeleteNotification(int notificationId)
        {
            try
            {
                var entity = await _context.Notifications.AsNoTracking().FirstOrDefaultAsync(x => x.Id == notificationId);
                if(entity != null)
                {
                    _context.Notifications.Remove(entity);
                    await _context.SaveChangesAsync();
                    return true;
                }
                return false;
            }
            catch(Exception ex)
            {
                return false;
            }
        }
    }
    public interface INotificationRepository
    {
        Task<NotificationEntity> GetNotificationById(int id);
        Task SetReadNotificationTrue(int id);
        Task<IEnumerable<NotificationEntity>> GetNotificationsForReceiver(int receiverId);
        Task<NotificationEntity> createNotification(NotificationEntity notificationEntity);
        Task<NotificationEntity> SetReadNotiTrue(int notificationId);
        Task<IEnumerable<NotificationEntity>> GetNotificationsByReceiverId(int receiverId);
        Task<bool> DeleteNotification(int notificationId);
    }
}
