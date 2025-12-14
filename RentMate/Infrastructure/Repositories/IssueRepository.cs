using Data;
using Data.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Infrastructure.Repositories
{
    public class IssueRepository : IIssueRepository
    {
        private readonly RentMateDbContext _context;
        
        public IssueRepository(RentMateDbContext context)
        {
            _context = context;
        }

        public async Task<IssueEntity> CreateIssue(IssueEntity issue)
        {
            await _context.Issues.AddAsync(issue);
            await _context.SaveChangesAsync();
            return issue;
        }

        public async Task<IssueEntity?> GetIssueById(int id)
        {
            return await _context.Issues
                .Include(i => i.Property)
                .Include(i => i.Tenant)
                .FirstOrDefaultAsync(i => i.Id == id);
        }

        public async Task<IEnumerable<IssueEntity>> GetIssuesByPropertyId(int propertyId)
        {
            return await _context.Issues
                .Include(i => i.Tenant)
                .Where(i => i.PropertyId == propertyId)
                .OrderByDescending(i => i.CreatedAt)
                .ToListAsync();
        }

        public async Task<IEnumerable<IssueEntity>> GetIssuesByTenantId(int tenantId)
        {
            return await _context.Issues
                .Include(i => i.Property)
                .Where(i => i.TenantId == tenantId)
                .OrderByDescending(i => i.CreatedAt)
                .ToListAsync();
        }

        public async Task<IssueEntity> UpdateIssue(IssueEntity issue)
        {
            _context.Issues.Update(issue);
            await _context.SaveChangesAsync();
            return issue;
        }
    }

    public interface IIssueRepository
    {
        Task<IssueEntity> CreateIssue(IssueEntity issue);
        Task<IssueEntity?> GetIssueById(int id);
        Task<IEnumerable<IssueEntity>> GetIssuesByPropertyId(int propertyId);
        Task<IEnumerable<IssueEntity>> GetIssuesByTenantId(int tenantId);
        Task<IssueEntity> UpdateIssue(IssueEntity issue);
    }
}

