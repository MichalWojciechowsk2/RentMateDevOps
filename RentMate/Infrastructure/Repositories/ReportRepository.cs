using Data;
using Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories
{
    public class ReportRepository : IReportRepository
    {
        private readonly RentMateDbContext _context;

        public ReportRepository(RentMateDbContext context)
        {
            _context = context;
        }

        public async Task<ReportEntity> CreateReport(ReportEntity report)
        {
            _context.Reports.Add(report);
            await _context.SaveChangesAsync();
            return report;
        }

        public async Task<List<ReportEntity>> GetAllReports()
        {
            return await _context.Reports
                .Include(r => r.ReportedUser)
                .Include(r => r.Reporter)
                .Include(r => r.ResolvedByAdmin)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();
        }

        public async Task<List<ReportEntity>> GetUnresolvedReports()
        {
            return await _context.Reports
                .Where(r => !r.IsResolved)
                .Include(r => r.ReportedUser)
                .Include(r => r.Reporter)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();
        }

        public async Task<ReportEntity?> GetReportById(int reportId)
        {
            return await _context.Reports
                .Include(r => r.ReportedUser)
                .Include(r => r.Reporter)
                .Include(r => r.ResolvedByAdmin)
                .FirstOrDefaultAsync(r => r.Id == reportId);
        }

        public async Task<bool> ResolveReport(int reportId, int adminId)
        {
            var report = await _context.Reports.FindAsync(reportId);
            if (report == null) return false;

            report.IsResolved = true;
            report.ResolvedAt = DateTime.UtcNow;
            report.ResolvedByAdminId = adminId;
            await _context.SaveChangesAsync();
            return true;
        }
    }

    public interface IReportRepository
    {
        Task<ReportEntity> CreateReport(ReportEntity report);
        Task<List<ReportEntity>> GetAllReports();
        Task<List<ReportEntity>> GetUnresolvedReports();
        Task<ReportEntity?> GetReportById(int reportId);
        Task<bool> ResolveReport(int reportId, int adminId);
    }
}

