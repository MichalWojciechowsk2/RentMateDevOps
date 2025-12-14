using ApplicationCore.Dto.Issue;
using AutoMapper;
using Data.Entities;
using Infrastructure.Repositories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Services.Services
{
    public class IssueService : IIssueService
    {
        private readonly IIssueRepository _issueRepository;
        private readonly IPropertyRepository _propertyRepository;
        private readonly IMapper _mapper;

        public IssueService(
            IIssueRepository issueRepository,
            IPropertyRepository propertyRepository,
            IMapper mapper)
        {
            _issueRepository = issueRepository;
            _propertyRepository = propertyRepository;
            _mapper = mapper;
        }

        public async Task<IssueEntity> CreateIssue(CreateIssueDto dto, int tenantId)
        {
            // Sprawdź czy mieszkanie istnieje
            var property = await _propertyRepository.GetPropertieById(dto.PropertyId);
            if (property == null)
            {
                throw new Exception("Mieszkanie nie istnieje");
            }

            var issue = new IssueEntity
            {
                PropertyId = dto.PropertyId,
                TenantId = tenantId,
                Title = dto.Title.Trim(),
                Description = dto.Description.Trim(),
                Status = IssueStatus.New,
                Urgency = (IssueUrgency)dto.Urgency,
                CreatedAt = DateTime.UtcNow,
                ResolvedAt = null
            };

            return await _issueRepository.CreateIssue(issue);
        }

        public async Task<IssueEntity?> GetIssueById(int id)
        {
            return await _issueRepository.GetIssueById(id);
        }

        public async Task<IEnumerable<IssueEntity>> GetIssuesByPropertyId(int propertyId)
        {
            return await _issueRepository.GetIssuesByPropertyId(propertyId);
        }

        public async Task<IEnumerable<IssueEntity>> GetIssuesByTenantId(int tenantId)
        {
            return await _issueRepository.GetIssuesByTenantId(tenantId);
        }

        public async Task<IssueEntity> UpdateIssueStatus(int issueId, IssueStatus newStatus)
        {
            var issue = await _issueRepository.GetIssueById(issueId);
            if (issue == null)
            {
                throw new Exception("Problem nie istnieje");
            }

            issue.Status = newStatus;
            if (newStatus == IssueStatus.Resolved || newStatus == IssueStatus.Closed)
            {
                issue.ResolvedAt = DateTime.UtcNow;
            }
            else
            {
                issue.ResolvedAt = null;
            }

            return await _issueRepository.UpdateIssue(issue);
        }
    }

    public interface IIssueService
    {
        Task<IssueEntity> CreateIssue(CreateIssueDto dto, int tenantId);
        Task<IssueEntity?> GetIssueById(int id);
        Task<IEnumerable<IssueEntity>> GetIssuesByPropertyId(int propertyId);
        Task<IEnumerable<IssueEntity>> GetIssuesByTenantId(int tenantId);
        Task<IssueEntity> UpdateIssueStatus(int issueId, IssueStatus newStatus);
    }
}

