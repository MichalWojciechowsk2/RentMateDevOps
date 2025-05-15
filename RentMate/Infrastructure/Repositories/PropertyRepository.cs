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
        public async Task<bool> CreateProperty(PropertyEntity entity)
        {
            try
            {
                await _context.Properties.AddAsync(entity);
                await _context.SaveChangesAsync();
                return true;
            }
            catch(Exception ex)
            {
                return false;
            }
        }
        public async Task<IEnumerable<PropertyEntity>> GetAllProperties()
        {
            return await _context.Properties.ToListAsync();
            
        }
        public async Task<PropertyEntity> GetPropertyById(int id)
        {
            return await _context.Properties
                .Include(p => p.Images)
                .FirstOrDefaultAsync(p => p.Id == id);
        }
        public async Task<bool> UpdatePropertie(int id, PropertyEntity entity)
        {
            try
            {
                var existingProperty = await _context.Properties
                    .FirstOrDefaultAsync(x => x.Id == id);

                if (existingProperty == null)
                {
                    return false;
                }

                existingProperty.Title = entity.Title;
                existingProperty.Description = entity.Description ?? string.Empty;
                existingProperty.Address = entity.Address;
                existingProperty.City = entity.City;
                existingProperty.PostalCode = entity.PostalCode;
                existingProperty.Area = entity.Area;
                existingProperty.RoomCount = entity.RoomCount;
                existingProperty.BasePrice = entity.BasePrice;
                existingProperty.BaseDeposit = entity.BaseDeposit;
                existingProperty.UpdatedAt = entity.UpdatedAt;

                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
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

        public async Task AddPropertyImage(PropertyImageEntity image)
        {
            await _context.PropertyImages.AddAsync(image);
            await _context.SaveChangesAsync();
        }

        public async Task DeletePropertyImage(int imageId)
        {
            var image = await _context.PropertyImages.FindAsync(imageId);
            if (image != null)
            {
                _context.PropertyImages.Remove(image);
                await _context.SaveChangesAsync();
            }
        }

        public async Task DeleteProperty(int propertyId)
        {
            var property = await _context.Properties
                .Include(p => p.Images)
                .FirstOrDefaultAsync(p => p.Id == propertyId);

            if (property != null)
            {
                _context.Properties.Remove(property);
                await _context.SaveChangesAsync();
            }
        }
    }
    public interface IPropertyRepository
    {
        Task<bool> CreateProperty(PropertyEntity entity);
        Task<IEnumerable<PropertyEntity>> GetAllProperties();
        Task<PropertyEntity> GetPropertyById(int id);
        Task<bool> UpdatePropertie(int id, PropertyEntity entity);
        Task<bool> DeleteProperite(int id);
        Task AddPropertyImage(PropertyImageEntity image);
        Task DeletePropertyImage(int imageId);
        Task DeleteProperty(int propertyId);
    }
}

