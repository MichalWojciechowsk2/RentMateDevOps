using Microsoft.AspNetCore.Mvc;
using Services.Services;
using ApplicationCore.Dto.CreateReq;
using Data;
using Data.Entities;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;

namespace WebApp.Controllers
{
    public class PropertyOwnerController : Controller
    {
        private readonly IPropertyService _propertyService;
        private readonly RentMateDbContext _context;
        private readonly IWebHostEnvironment _webHostEnvironment;

        public PropertyOwnerController(IPropertyService propertyService, RentMateDbContext context, IWebHostEnvironment webHostEnvironment)
        {
            _propertyService = propertyService;
            _context = context;
            _webHostEnvironment = webHostEnvironment;
        }

        public IActionResult Dashboard()
        {
            return View();
        }

        public IActionResult AddProperty()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> AddProperty(CreatePropertyDto propertyDto, List<IFormFile> images)
        {
            if (!ModelState.IsValid)
            {
                return View(propertyDto);
            }

            var propertyEntity = new PropertyEntity
            {
                Title = propertyDto.Title,
                Description = propertyDto.Description,
                Address = propertyDto.Address,
                Area = propertyDto.Area,
                RoomCount = propertyDto.RoomCount,
                City = propertyDto.City,
                PostalCode = propertyDto.PostalCode,
                BasePrice = propertyDto.BasePrice,
                BaseDeposit = propertyDto.BaseDeposit,
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                OwnerId = 1 
            };

            // Dodajemy mieszkanie do bazy i zapisujemy zmiany
            await _context.Properties.AddAsync(propertyEntity);
            await _context.SaveChangesAsync();

            // Teraz mamy już ID mieszkania i możemy dodać zdjęcia
            if (images != null && images.Any())
            {
                var uploadPath = Path.Combine(_webHostEnvironment.WebRootPath, "uploads", "properties", propertyEntity.Id.ToString());
                Directory.CreateDirectory(uploadPath);

                foreach (var image in images)
                {
                    if (image.Length > 0)
                    {
                        var fileName = Guid.NewGuid().ToString() + Path.GetExtension(image.FileName);
                        var filePath = Path.Combine(uploadPath, fileName);

                        using (var stream = new FileStream(filePath, FileMode.Create))
                        {
                            await image.CopyToAsync(stream);
                        }

                        var propertyImage = new PropertyImageEntity
                        {
                            PropertyId = propertyEntity.Id,
                            ImagePath = Path.Combine("uploads", "properties", propertyEntity.Id.ToString(), fileName),
                            IsMainImage = !await _context.PropertyImages.AnyAsync(pi => pi.PropertyId == propertyEntity.Id),
                            UploadedAt = DateTime.UtcNow
                        };

                        await _context.PropertyImages.AddAsync(propertyImage);
                    }
                }

                await _context.SaveChangesAsync();
            }

            return RedirectToAction(nameof(Dashboard));
        }

        public async Task<IActionResult> MyProperties()
        {
            var properties = await _context.Properties
                .Include(p => p.Images)
                .ToListAsync();
            return View(properties);
        }

        [HttpPost]
        public async Task<IActionResult> UploadImages(int propertyId, List<IFormFile> images)
        {
            if (images == null || !images.Any())
            {
                return BadRequest("Nie wybrano żadnych zdjęć.");
            }

            var property = await _context.Properties.FindAsync(propertyId);
            if (property == null)
            {
                return NotFound("Nie znaleziono mieszkania.");
            }

            var uploadPath = Path.Combine(_webHostEnvironment.WebRootPath, "uploads", "properties", propertyId.ToString());
            Directory.CreateDirectory(uploadPath);

            foreach (var image in images)
            {
                if (image.Length > 0)
                {
                    var fileName = Guid.NewGuid().ToString() + Path.GetExtension(image.FileName);
                    var filePath = Path.Combine(uploadPath, fileName);

                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await image.CopyToAsync(stream);
                    }

                    var propertyImage = new PropertyImageEntity
                    {
                        PropertyId = propertyId,
                        ImagePath = Path.Combine("uploads", "properties", propertyId.ToString(), fileName),
                        IsMainImage = !await _context.PropertyImages.AnyAsync(pi => pi.PropertyId == propertyId),
                        UploadedAt = DateTime.UtcNow
                    };

                    await _context.PropertyImages.AddAsync(propertyImage);
                }
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(MyProperties));
        }

        [HttpPost]
        public async Task<IActionResult> SetMainImage(int imageId, int propertyId)
        {
            var images = await _context.PropertyImages.Where(pi => pi.PropertyId == propertyId).ToListAsync();
            foreach (var image in images)
            {
                image.IsMainImage = image.Id == imageId;
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(MyProperties));
        }

        [HttpPost]
        public async Task<IActionResult> DeleteImage(int imageId)
        {
            var image = await _context.PropertyImages.FindAsync(imageId);
            if (image == null)
            {
                return NotFound();
            }

            var filePath = Path.Combine(_webHostEnvironment.WebRootPath, image.ImagePath);
            if (System.IO.File.Exists(filePath))
            {
                System.IO.File.Delete(filePath);
            }

            _context.PropertyImages.Remove(image);
            await _context.SaveChangesAsync();

            return RedirectToAction(nameof(MyProperties));
        }
    }
}