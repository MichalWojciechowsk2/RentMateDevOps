using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Services.Services;
using System.Security.Claims;
using ApplicationCore.Dto.Report;

namespace RentMateApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ReportController : ControllerBase
    {
        private readonly IReportService _reportService;

        public ReportController(IReportService reportService)
        {
            _reportService = reportService;
        }

        [HttpPost]
        public async Task<IActionResult> CreateReport([FromBody] CreateReportDto dto)
        {
            try
            {
                var reporterId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                if (reporterId == 0) return Unauthorized();

                var report = await _reportService.CreateReport(dto, reporterId);
                return Ok(report);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("all")]
        [Authorize(Roles = "Administrator")]
        public async Task<IActionResult> GetAllReports()
        {
            try
            {
                var reports = await _reportService.GetAllReports();
                return Ok(reports);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("unresolved")]
        [Authorize(Roles = "Administrator")]
        public async Task<IActionResult> GetUnresolvedReports()
        {
            try
            {
                var reports = await _reportService.GetUnresolvedReports();
                return Ok(reports);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{reportId}/resolve")]
        [Authorize(Roles = "Administrator")]
        public async Task<IActionResult> ResolveReport(int reportId)
        {
            try
            {
                var adminId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                if (adminId == 0) return Unauthorized();

                var result = await _reportService.ResolveReport(reportId, adminId);
                if (result)
                    return Ok(new { message = "Zgłoszenie zostało oznaczone jako rozwiązane" });
                return NotFound(new { message = "Zgłoszenie nie zostało znalezione" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}

