using ApplicationCore.Dto.Issue;
using Data.Entities;
using Infrastructure.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using RentMateApi.Hubs;
using Services.Services;
using System;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace RentMateApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class IssueController : ControllerBase
    {
        private readonly IIssueService _issueService;
        private readonly IPropertyRepository _propertyRepository;
        private readonly INotificationService _notificationService;
        private readonly IUserService _userService;
        private readonly IHubContext<NotificationHub> _hubContext;

        public IssueController(
            IIssueService issueService,
            IPropertyRepository propertyRepository,
            INotificationService notificationService,
            IUserService userService,
            IHubContext<NotificationHub> hubContext)
        {
            _issueService = issueService;
            _propertyRepository = propertyRepository;
            _notificationService = notificationService;
            _userService = userService;
            _hubContext = hubContext;
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreateIssue([FromBody] CreateIssueDto dto)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int tenantId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }

            try
            {
                var issue = await _issueService.CreateIssue(dto, tenantId);
                
                // Pobierz właściciela mieszkania
                var property = await _propertyRepository.GetPropertieById(dto.PropertyId);
                if (property != null)
                {
                    var tenant = await _userService.GetUserById(tenantId);
                    var tenantName = $"{tenant.FirstName} {tenant.LastName}";
                    
                    // Wyślij powiadomienie do właściciela
                    await _notificationService.CreateNotification(
                        tenantId,
                        property.OwnerId,
                        tenantName,
                        NotificationType.CreateIssue
                    );
                    
                    // Zaktualizuj licznik nieprzeczytanych powiadomień
                    var unreadCount = await _notificationService.CountHowMuchNotRead(property.OwnerId);
                    await _hubContext.Clients.User(property.OwnerId.ToString()).SendAsync("ReceiveUnreadCount", unreadCount);
                }

                return StatusCode(201, new
                {
                    id = issue.Id,
                    propertyId = issue.PropertyId,
                    tenantId = issue.TenantId,
                    title = issue.Title,
                    description = issue.Description,
                    status = (int)issue.Status,
                    urgency = (int)issue.Urgency,
                    createdAt = issue.CreatedAt,
                    resolvedAt = issue.ResolvedAt
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while creating the issue.", error = ex.Message });
            }
        }

        [HttpGet("property/{propertyId}")]
        [Authorize]
        public async Task<IActionResult> GetIssuesByPropertyId(int propertyId)
        {
            try
            {
                var issues = await _issueService.GetIssuesByPropertyId(propertyId);
                var result = issues.Select(i => new
                {
                    id = i.Id,
                    propertyId = i.PropertyId,
                    tenantId = i.TenantId,
                    title = i.Title,
                    description = i.Description,
                    status = (int)i.Status,
                    urgency = (int)i.Urgency,
                    createdAt = i.CreatedAt,
                    resolvedAt = i.ResolvedAt
                });
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while getting issues.", error = ex.Message });
            }
        }

        [HttpGet("tenant")]
        [Authorize]
        public async Task<IActionResult> GetIssuesByTenantId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int tenantId))
            {
                return Unauthorized(new { message = "User not authenticated or invalid user ID." });
            }

            try
            {
                var issues = await _issueService.GetIssuesByTenantId(tenantId);
                var result = issues.Select(i => new
                {
                    id = i.Id,
                    propertyId = i.PropertyId,
                    tenantId = i.TenantId,
                    title = i.Title,
                    description = i.Description,
                    status = (int)i.Status,
                    urgency = (int)i.Urgency,
                    createdAt = i.CreatedAt,
                    resolvedAt = i.ResolvedAt
                });
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while getting issues.", error = ex.Message });
            }
        }

        [HttpPatch("{issueId}/status")]
        [Authorize]
        public async Task<IActionResult> UpdateIssueStatus(int issueId, [FromBody] int statusValue)
        {
            try
            {
                var issue = await _issueService.UpdateIssueStatus(issueId, (IssueStatus)statusValue);
                return Ok(new
                {
                    id = issue.Id,
                    propertyId = issue.PropertyId,
                    tenantId = issue.TenantId,
                    title = issue.Title,
                    description = issue.Description,
                    status = (int)issue.Status,
                    urgency = (int)issue.Urgency,
                    createdAt = issue.CreatedAt,
                    resolvedAt = issue.ResolvedAt
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while updating issue status.", error = ex.Message });
            }
        }
    }
}

