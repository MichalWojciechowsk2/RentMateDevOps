using Data;
using Data.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Repositories
{
    public class ReviewRepository : IReviewRepository
    {
        private readonly RentMateDbContext _context;
        public ReviewRepository(RentMateDbContext context)
        {
            _context = context;
        }
        public async Task<ReviewEntity> CreateReview(ReviewEntity review)
        {
            await _context.Reviews.AddAsync(review);
            await _context.SaveChangesAsync();
            return review;
        }
        public async Task<ReviewEntity> DeleteReviewById(int reviewId)
        {
            var review = await _context.Reviews
                .FirstOrDefaultAsync(r => r.Id == reviewId);
            if (review == null) return null;
            _context.Reviews.Remove(review);
            await _context.SaveChangesAsync();
            return review;
        }
        public async Task<ReviewEntity> GetReviewById(int id)
        {
            return await _context.Reviews.FirstOrDefaultAsync(r => r.Id == id);
        }
        public async Task<IEnumerable<ReviewEntity>> GetAllReviewsForUser(int userId)
        {
            return await _context.Reviews.Where(r => r.UserId == userId).ToListAsync();
        }
        public async Task<IEnumerable<ReviewEntity>> GetAllReviewsForProperty(int propertyId)
        {
            return await _context.Reviews.Where(r => r.PropertyId == propertyId).ToListAsync();
        }
        //DOPISAĆ GetAvgReviewForUser, pomyśleć jaka ma być logika tego.
        public 

    }
    public interface IReviewRepository
    {
        Task<ReviewEntity> CreateReview(ReviewEntity review);
        Task<ReviewEntity> DeleteReviewById(int reviewId);
        Task<ReviewEntity> GetReviewById(int id);
        Task<IEnumerable<ReviewEntity>> GetAllReviewsForUser(int userId);
        Task<IEnumerable<ReviewEntity>> GetAllReviewsForProperty(int propertyId);
        Task<decimal> GetAvgReviewForUser(int userId);
    }
}
