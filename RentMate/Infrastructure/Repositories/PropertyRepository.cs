using Data;
using Data.Entities;
using Microsoft.EntityFrameworkCore;


namespace Infrastructure.Repositories
{
    public class PropertyReporitory : IPropertyRepository
    {
        private readonly RentMateDbContext _context;
        public PropertyReporitory(RentMateDbContext context)
        {
            _context = context;
        }
        public async Task<PropertyEntity> CreateProperty(PropertyEntity entity)
        {
            try
            {
                await _context.Properties.AddAsync(entity);
                await _context.SaveChangesAsync();
                return entity;
            }
            catch(Exception ex)
            {
                throw new Exception("Failed to create property", ex);
            }
        }
        public async Task UpdateAsync(PropertyEntity entity)
        {
            _context.Properties.Update(entity);
            await _context.SaveChangesAsync();
        }
        public async Task<IEnumerable<PropertyEntity>> GetAllProperties()
        {

            return await _context.Properties.Include(p => p.Owner).ToListAsync();
        }
        public async Task<PropertyEntity> GetPropertieById(int id)
        {
            return await _context.Properties.FirstOrDefaultAsync(x => x.Id == id);
        }
        public async Task<bool> DeleteProperite(int id)
        {
            try
            {
                    var entity = await _context.Properties.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
                    if(entity != null)
                    {
                        _context.Properties.Remove(entity);
                        await _context.SaveChangesAsync();
                        return true;
                    }
                    return false;
            }
            catch( Exception ex)
            {
                return false;
            }
        }

        public IQueryable<PropertyEntity> GetPropertiesQueryable()
        {
            return _context.Properties.AsQueryable();
        }

        public async Task<PropertyImageEntity> AddPropertyImage(PropertyImageEntity imageEntity)
        {
            await _context.PropertyImages.AddAsync(imageEntity);
            await _context.SaveChangesAsync();
            return imageEntity;
        }

        public async Task<PropertyImageEntity> GetPropertyImageById(int imageId)
        {
            return await _context.PropertyImages.FirstOrDefaultAsync(x => x.Id == imageId);
        }

        public async Task<bool> DeletePropertyImage(int imageId)
        {
            var image = await _context.PropertyImages.FirstOrDefaultAsync(x => x.Id == imageId);
            if (image != null)
            {
                _context.PropertyImages.Remove(image);
                await _context.SaveChangesAsync();
                return true;
            }
            return false;
        }
        public async Task<PropertyImageEntity> GetMainPropertyImageByPropertyId(int propertyId)
        {
            return await _context.PropertyImages.FirstOrDefaultAsync(x => x.PropertyId == propertyId && x.IsMainImage);
        }
        public async Task<IEnumerable<PropertyImageEntity>> GetPhotos(int propertyId)
        {
            return await _context.PropertyImages.Where(i => i.PropertyId == propertyId).ToListAsync();
        }

        public async Task SetMainImageAsync(int propertyId, int imageId)
        {
            var images = await _context.PropertyImages.Where(i => i.PropertyId == propertyId).ToListAsync();
            foreach (var img in images)
            {
                img.IsMainImage = img.Id == imageId;
            }
            await _context.SaveChangesAsync();
        }

    }
    public interface IPropertyRepository
    {
        Task<PropertyEntity> CreateProperty(PropertyEntity entity);
        Task UpdateAsync(PropertyEntity entity);
        Task<IEnumerable<PropertyEntity>> GetAllProperties();
        Task<PropertyEntity> GetPropertieById(int id);
        Task<bool> DeleteProperite(int id);
        IQueryable<PropertyEntity> GetPropertiesQueryable();
        Task<PropertyImageEntity> AddPropertyImage(PropertyImageEntity imageEntity);
        Task<PropertyImageEntity> GetPropertyImageById(int imageId);
        Task<bool> DeletePropertyImage(int imageId);
        Task<PropertyImageEntity> GetMainPropertyImageByPropertyId(int propertyId);
        Task<IEnumerable<PropertyImageEntity>> GetPhotos(int propertyId);
        Task SetMainImageAsync(int propertyId, int imageId);
    }
}

