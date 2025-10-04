using Data.Entities;
using Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.Identity.Client;
using System.ComponentModel;
using System.Threading.Tasks;



namespace Services.Services
{
    public class NotificationService : INotificationService
    {
        private readonly INotificationRepository _notificationRepository;

        public NotificationService(INotificationRepository notificationRepository)
        {
            _notificationRepository = notificationRepository;

        }

        public async Task MarkAsReadIfNot(int notiId)
        {
            var noti = await _notificationRepository.GetNotificationById(notiId);
            if (noti != null && !noti.IsRead)
            {
                await _notificationRepository.SetReadNotiTrue(notiId);
            }
        }
        public async Task<NotificationEntity> CreateNotification(int senderId, int receiverId, string senderName, NotificationType type)
        {
            var notification = new NotificationEntity
            {
                SenderId = senderId,
                ReceiverId = receiverId,
                Type = type,
                CreatedAt = DateTime.UtcNow,
                IsRead = false,
            };
            notification.SetContent(senderName);
            await _notificationRepository.createNotification(notification);
            
            return notification;
        }

        public async Task<IEnumerable<NotificationEntity>> GetListOfReceiverNotifications(int receiverId)
        {
            var notifications = await _notificationRepository.GetNotificationsByReceiverId(receiverId);
            return notifications;
        }

        public async Task<int> CountHowMuchNotRead(int receirverId)
        {
            var notifications = await _notificationRepository.GetNotificationsByReceiverId(receirverId);
            int unreadNoti = 0;
            foreach(var notification in notifications)
            {
                if (notification.IsRead == false) unreadNoti++;
            }
            return unreadNoti;
        }
        public async Task<bool> DeleteNotification(int notificationId)
        {
            try
            {
                var result = await _notificationRepository.DeleteNotification(notificationId);
                return result;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
    public interface INotificationService
    {
        Task MarkAsReadIfNot(int notiId);
        Task<NotificationEntity> CreateNotification(int senderId, int receiverId, string senderName, NotificationType type);
        Task<IEnumerable<NotificationEntity>> GetListOfReceiverNotifications(int receiverId);
        Task<int> CountHowMuchNotRead(int receirverId);
        Task<bool> DeleteNotification(int notificationId);
    }
}
