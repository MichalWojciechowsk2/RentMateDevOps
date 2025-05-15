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
                TempData["Error"] = "Nie wybrano żadnych zdjęć.";
                return RedirectToAction(nameof(PropertyDetails), new { id = propertyId });
            }

            var property = await _propertyService.GetPropertyById(propertyId);
            if (property == null)
            {
                return NotFound();
            }

            foreach (var image in images)
            {
                if (image.Length > 0)
                {
                    var fileName = Path.GetRandomFileName() + Path.GetExtension(image.FileName);
                    var filePath = Path.Combine("uploads", "properties", fileName);
                    var fullPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", filePath);

                    Directory.CreateDirectory(Path.GetDirectoryName(fullPath));
                    using (var stream = new FileStream(fullPath, FileMode.Create))
                    {
                        await image.CopyToAsync(stream);
                    }

                    var propertyImage = new PropertyImageEntity
                    {
                        PropertyId = propertyId,
                        ImagePath = filePath,
                        IsMainImage = !property.Images.Any() // Pierwsze zdjęcie będzie głównym
                    };

                    await _propertyService.AddPropertyImage(propertyImage);
                }
            }

            TempData["Success"] = "Zdjęcia zostały dodane pomyślnie.";
            return RedirectToAction(nameof(PropertyDetails), new { id = propertyId });
        }

        [HttpPost]
        public async Task<IActionResult> SetMainImage(int imageId, int propertyId)
        {
            var property = await _propertyService.GetPropertyById(propertyId);
            if (property == null)
            {
                return NotFound();
            }

            var image = property.Images.FirstOrDefault(i => i.Id == imageId);
            if (image == null)
            {
                return NotFound();
            }

            await _propertyService.SetMainImage(propertyId, imageId);
            TempData["Success"] = "Zdjęcie główne zostało zaktualizowane.";
            return RedirectToAction(nameof(PropertyDetails), new { id = propertyId });
        }

        [HttpPost]
        public async Task<IActionResult> DeleteImage(int imageId, int propertyId)
        {
            var property = await _propertyService.GetPropertyById(propertyId);
            if (property == null)
            {
                return NotFound();
            }

            var image = property.Images.FirstOrDefault(i => i.Id == imageId);
            if (image == null)
            {
                return NotFound();
            }

            await _propertyService.DeletePropertyImage(imageId);
            
            // Usuń plik fizyczny
            var fullPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", image.ImagePath);
            if (System.IO.File.Exists(fullPath))
            {
                System.IO.File.Delete(fullPath);
            }

            TempData["Success"] = "Zdjęcie zostało usunięte.";
            return RedirectToAction(nameof(PropertyDetails), new { id = propertyId });
        }

        [HttpPost]
        public async Task<IActionResult> DeleteProperty(int propertyId)
        {
            var property = await _propertyService.GetPropertyById(propertyId);
            if (property == null)
            {
                return NotFound();
            }

            // Usuń wszystkie zdjęcia fizycznie
            foreach (var image in property.Images)
            {
                var fullPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", image.ImagePath);
                if (System.IO.File.Exists(fullPath))
                {
                    System.IO.File.Delete(fullPath);
                }
            }

            await _propertyService.DeleteProperty(propertyId);
            TempData["Success"] = "Mieszkanie zostało usunięte.";
            return RedirectToAction(nameof(MyProperties));
        }

        public async Task<IActionResult> EditProperty(int id)
        {
            var property = await _context.Properties
                .FirstOrDefaultAsync(p => p.Id == id);

            if (property == null)
            {
                return NotFound();
            }

            return View(property);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditProperty(PropertyEntity property)
        {

            try
            {
                var success = await _propertyService.UpdateProperty(property);
                if (success)
                {
                    TempData["Success"] = "Mieszkanie zostało zaktualizowane pomyślnie.";
                    return RedirectToAction(nameof(MyProperties));
                }
                else
                {
                    ModelState.AddModelError("", "Nie udało się zaktualizować mieszkania. Spróbuj ponownie.");
                    return View(property);
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", "Wystąpił błąd podczas zapisywania zmian. Spróbuj ponownie.");
                return View(property);
            }
        }

        public async Task<IActionResult> PropertyDetails(int id)
        {
            var property = await _context.Properties
                .Include(p => p.Images)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (property == null)
            {
                return NotFound();
            }

            return View(property);
        }
    }
}