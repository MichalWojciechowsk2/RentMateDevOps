using Data.Entities;
using Infrastructure.Repositories;



namespace Services.Services
{
    public class NotificationService : INotificationService
    {
        private readonly INotificationRepository _notificationRepository;

        public NotificationService(INotificationRepository notificationRepository)
        {
            _notificationRepository = notificationRepository;
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
    }
    public interface INotificationService
    {
        Task<NotificationEntity> CreateNotification(int senderId, int receiverId, string senderName, NotificationType type);
        Task<IEnumerable<NotificationEntity>> GetListOfReceiverNotifications(int receiverId);
    }
}
