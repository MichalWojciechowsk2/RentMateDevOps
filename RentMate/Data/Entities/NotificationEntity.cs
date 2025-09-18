﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Entities
{
    public class NotificationEntity
    {
            public int Id { get; set; }
            public int SenderId { get; set; }
            public int ReceiverId { get; set; }
            public string Title { get; set; }
            public string Message { get; set; }
            public DateTime CreatedAt { get; set; }
            public bool IsRead { get; set; }
            public NotificationType Type { get; set; }
            public UserEntity Sender { get; set; }
            public UserEntity Receiver { get; set; }

            public void SetContent(string senderName = "Użytkownik")
            {
                switch (Type)
                {
                    case NotificationType.SendOffer:
                        Title = "Nowa oferta";
                        Message = $"{senderName} wysłał Ci zaproszenie.";
                        break;
                    case NotificationType.PaymentDue:
                        Title = "Przypomnienie o płatności";
                        Message = "Twoja płatność wkrótce minie.";
                        break;
                    case NotificationType.InvitationAccepted:
                        Title = "Zaproszenie zaakceptowane";
                        Message = $"{senderName} zaakceptował Twoje zaproszenie.";
                        break;
                    default:
                        Title = "Powiadomienie";
                        Message = "";
                        break;
                }
            }
        }      
    }

public enum NotificationType
    {
        SendOffer,
        PaymentDue,
        InvitationAccepted,
        Other,
    }

