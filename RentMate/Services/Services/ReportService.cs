using ApplicationCore.Dto.Report;
using AutoMapper;
using Data.Entities;
using Infrastructure.Repositories;

namespace Services.Services
{
    public class ReportService : IReportService
    {
        private readonly IReportRepository _reportRepository;
        private readonly IUserRepository _userRepository;
        private readonly IMapper _mapper;

        public ReportService(
            IReportRepository reportRepository,
            IUserRepository userRepository,
            IMapper mapper)
        {
            _reportRepository = reportRepository;
            _userRepository = userRepository;
            _mapper = mapper;
        }

        public async Task<ReportDto> CreateReport(CreateReportDto dto, int reporterId)
        {
            // Sprawdź czy zgłaszany użytkownik istnieje
            var reportedUser = await _userRepository.GetUserById(dto.ReportedUserId);
            if (reportedUser == null)
                throw new KeyNotFoundException($"User with id {dto.ReportedUserId} not found");

            // Nie można zgłosić samego siebie
            if (reportedUser.Id == reporterId)
                throw new ArgumentException("Nie można zgłosić samego siebie");

            var report = new ReportEntity
            {
                ReportedUserId = dto.ReportedUserId,
                ReporterId = reporterId,
                Reason = dto.Reason,
                CreatedAt = DateTime.UtcNow,
                IsResolved = false
            };

            var createdReport = await _reportRepository.CreateReport(report);
            var reportWithDetails = await _reportRepository.GetReportById(createdReport.Id);
            return _mapper.Map<ReportDto>(reportWithDetails);
        }

        public async Task<List<ReportDto>> GetAllReports()
        {
            var reports = await _reportRepository.GetAllReports();
            return _mapper.Map<List<ReportDto>>(reports);
        }

        public async Task<List<ReportDto>> GetUnresolvedReports()
        {
            var reports = await _reportRepository.GetUnresolvedReports();
            return _mapper.Map<List<ReportDto>>(reports);
        }

        public async Task<bool> ResolveReport(int reportId, int adminId)
        {
            return await _reportRepository.ResolveReport(reportId, adminId);
        }
    }

    public interface IReportService
    {
        Task<ReportDto> CreateReport(CreateReportDto dto, int reporterId);
        Task<List<ReportDto>> GetAllReports();
        Task<List<ReportDto>> GetUnresolvedReports();
        Task<bool> ResolveReport(int reportId, int adminId);
    }
}

