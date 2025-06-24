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

            return await _context.Properties.Include(p => p.Owner).ToListAsync();
        }
        public async Task<PropertyEntity> GetPropertieById(int id)
        {
            return await _context.Properties.FirstOrDefaultAsync(x => x.Id == id);
        }
        public async Task<bool> UpdatePropertie(int id, PropertyEntity entity)
        {
            try
            {
                _context.ChangeTracker.Clear();
                _context.Entry(entity).State = EntityState.Modified;
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

        public IQueryable<PropertyEntity> GetPropertiesQueryable()
        {
            return _context.Properties.AsQueryable();
        }

    }
    public interface IPropertyRepository
    {
        Task<bool> CreateProperty(PropertyEntity entity);
        Task<IEnumerable<PropertyEntity>> GetAllProperties();
        Task<PropertyEntity> GetPropertieById(int id);
        Task<bool> UpdatePropertie(int id, PropertyEntity entity);
        Task<bool> DeleteProperite(int id);
        IQueryable<PropertyEntity> GetPropertiesQueryable();
    }
}

