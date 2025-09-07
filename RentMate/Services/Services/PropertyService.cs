using ApplicationCore.Dto.Property;
using AutoMapper;
using Data.Entities;
using Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using static Services.Services.PropertyService;
using Microsoft.AspNetCore.Http;

namespace Services.Services
{
    public class PropertyService : IPropertyService
    {
        private readonly IPropertyRepository _propertyRepository;
        private readonly IMapper _mapper;
        public PropertyService(IPropertyRepository propertyRepository, IMapper mapper)
        {
            _propertyRepository = propertyRepository;
            _mapper = mapper;
        }
        public async Task<PropertyDto> CreateProperty(PropertyDto propertyDto, int ownerId)
        {
            var dtoToEntity = _mapper.Map<PropertyEntity>(propertyDto);
            dtoToEntity.OwnerId = ownerId; // Assign the correct OwnerId
            dtoToEntity.CreatedAt = DateTime.UtcNow;
            var createdEntity = await _propertyRepository.CreateProperty(dtoToEntity);
            return _mapper.Map<PropertyDto>(createdEntity);
        }

        public async Task<IEnumerable<PropertyDto>> GetAllActiveProperties()
        {
            var entities = await _propertyRepository.GetPropertiesQueryable()
                .Include(p => p.Owner)
                .Include(p => p.PropertyImages)
                .Where(p => p.IsActive)
                .ToListAsync();
            return _mapper.Map<IEnumerable<PropertyDto>>(entities);
        }
        public async Task<PropertyDto> GetPropertyById(int id)
        {
            var property = await _propertyRepository.GetPropertiesQueryable()
                .Include(p => p.Owner)
                .Include(p => p.PropertyImages)
                .FirstOrDefaultAsync(p => p.Id == id);
            if (property == null) return null;
            return _mapper.Map<PropertyDto>(property);
        }
        public async Task<PropertyEntity> GetOwnerPropertyById(int id)
        {
            var property = await _propertyRepository.GetPropertieById(id);
            if (property == null) return null;
            return property;
        }
        public async Task<IEnumerable<PropertyDto>> SearchProperties(PropertyFilterDto filters)
        {
            var query = _propertyRepository.GetPropertiesQueryable();
            
            if (!string.IsNullOrEmpty(filters.City))
                query = query.Where(p => p.City == filters.City);
            if (!string.IsNullOrEmpty(filters.District))
                query = query.Where(p => p.District == filters.District);
            if (filters.PriceFrom.HasValue)
                query = query.Where(p => p.BasePrice >= filters.PriceFrom.Value);

            if (filters.PriceTo.HasValue)
                query = query.Where(p => p.BasePrice <= filters.PriceTo.Value);

            if (filters.Rooms.HasValue)
                query = query.Where(p => p.RoomCount == filters.Rooms.Value);
            
            var entities = await query
                .Include(p => p.Owner)
                .Include(p => p.PropertyImages)
                .ToListAsync();
            return _mapper.Map<IEnumerable<PropertyDto>>(entities);
        }

        public async Task<IEnumerable<PropertyDto>> GetPropertiesByOwnerId(int ownerId)
        {
            var entities = await _propertyRepository.GetPropertiesQueryable()
                                                .Include(p => p.Owner)
                                                .Include(p => p.PropertyImages)
                                                .Where(p => p.OwnerId == ownerId)
                                                .ToListAsync();
            return _mapper.Map<IEnumerable<PropertyDto>>(entities);
        }

        public async Task<PropertyDto> GetPropertyDetails(int id)
        {
            var entity = await _propertyRepository.GetPropertiesQueryable()
                                                .Include(p => p.Owner)
                                                .Include(p => p.PropertyImages)
                                                .FirstOrDefaultAsync(p => p.Id == id);
            return _mapper.Map<PropertyDto>(entity);
        }
        public async Task<PropertyDto> UdpatePropertyIsActiveById(int id, bool updateIsActive)
        {
            var entity = await _propertyRepository.GetPropertieById(id);
            if (entity == null) throw new KeyNotFoundException($"Mieszkanie z id: {id} nie zostało znalezione");
            entity.IsActive = updateIsActive;
            await _propertyRepository.UpdateAsync(entity);
            return _mapper.Map<PropertyDto>(entity);
        }
        public async Task<PropertyDto> UdpatePropertyById(int id, UpdatePropertyDto dto)
        {
            var entity = await _propertyRepository.GetPropertieById(id);
            if (entity == null) throw new KeyNotFoundException($"Mieszkanie z id: {id} nie zostało znalezione");
            entity = _mapper.Map(dto, entity);
            entity.UpdatedAt = DateTime.Now;
            await _propertyRepository.UpdateAsync(entity);
            return _mapper.Map<PropertyDto>(entity);
        }

        public async Task<List<PropertyImageDto>> UploadPropertyImages(int propertyId, int userId, List<IFormFile> images)
        {
            var property = await _propertyRepository.GetPropertieById(propertyId);
            if (property == null) throw new ArgumentException($"Property with id {propertyId} not found");
            if (property.OwnerId != userId) throw new UnauthorizedAccessException("You don't have permission to upload images for this property");

            if (images == null || images.Count == 0) throw new ArgumentException("No images provided");

            var uploadedImages = new List<PropertyImageDto>();
            var uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "uploads", "images");
            
            if (!Directory.Exists(uploadsPath))
            {
                Directory.CreateDirectory(uploadsPath);
            }

            foreach (var image in images)
            {
                if (image.Length > 0)
                {
                    var allowedTypes = new[] { "image/jpeg", "image/jpg", "image/png", "image/gif" };
                    if (!allowedTypes.Contains(image.ContentType.ToLower()))
                    {
                        throw new ArgumentException($"File type {image.ContentType} is not allowed. Only JPEG, JPG, PNG, and GIF files are allowed.");
                    }

                    if (image.Length > 5 * 1024 * 1024)
                    {
                        throw new ArgumentException("File size cannot exceed 5MB");
                    }

                    var fileName = $"{Guid.NewGuid()}{Path.GetExtension(image.FileName)}";
                    var filePath = Path.Combine(uploadsPath, fileName);

                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await image.CopyToAsync(stream);
                    }

                    var imageEntity = new PropertyImageEntity
                    {
                        PropertyId = propertyId,
                        ImageUrl = $"/uploads/images/{fileName}",
                        IsMainImage = uploadedImages.Count == 0,
                        CreatedAt = DateTime.UtcNow
                    };

                    await _propertyRepository.AddPropertyImage(imageEntity);
                    uploadedImages.Add(_mapper.Map<PropertyImageDto>(imageEntity));
                }
            }

            return uploadedImages;
        }

        public async Task DeletePropertyImage(int imageId, int userId)
        {
            var image = await _propertyRepository.GetPropertyImageById(imageId);
            if (image == null) throw new ArgumentException($"Image with id {imageId} not found");

            var property = await _propertyRepository.GetPropertieById(image.PropertyId);
            if (property == null || property.OwnerId != userId) 
                throw new UnauthorizedAccessException("You don't have permission to delete this image");

            var uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "uploads", "images");
            var fileName = Path.GetFileName(image.ImageUrl);
            var filePath = Path.Combine(uploadsPath, fileName);
            
            if (File.Exists(filePath))
            {
                File.Delete(filePath);
            }

            await _propertyRepository.DeletePropertyImage(imageId);
        }

        public async Task<PropertyImageEntity?> GetPropertyMainImageByPropertyId(int propertyId)
        {
            return await _propertyRepository.GetMainPropertyImageByPropertyId(propertyId);
        }
        public async Task<IEnumerable<PropertyImageEntity>> GetAllImages(int propertyId)
        {
            return await _propertyRepository.GetPhotos(propertyId);
        }

        public interface IPropertyService
        {
            Task<PropertyDto> CreateProperty(PropertyDto dto, int ownerId);
            Task<IEnumerable<PropertyDto>> GetAllActiveProperties();
            Task<IEnumerable<PropertyDto>> SearchProperties(PropertyFilterDto filters);
            Task<IEnumerable<PropertyDto>> GetPropertiesByOwnerId(int ownerId);
            Task<PropertyDto> GetPropertyDetails(int id);
            Task<PropertyDto> GetPropertyById(int id);
            Task<PropertyEntity> GetOwnerPropertyById(int id);
            Task<PropertyDto> UdpatePropertyIsActiveById(int id, bool updateIsActive);
            Task<PropertyDto> UdpatePropertyById(int id, UpdatePropertyDto dto);
            Task<List<PropertyImageDto>> UploadPropertyImages(int propertyId, int userId, List<IFormFile> images);
            Task DeletePropertyImage(int imageId, int userId);
            Task<PropertyImageEntity?> GetPropertyMainImageByPropertyId(int propertyId);
            Task<IEnumerable<PropertyImageEntity>> GetAllImages(int propertyId);
        }
    }
}
