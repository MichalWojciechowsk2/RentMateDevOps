using Data;
using Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Identity.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

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
        public async Task<bool> DeleteReviewById(int reviewId)
        {
            var review = await _context.Reviews
                .FirstOrDefaultAsync(r => r.Id == reviewId);
            if (review == null) return false;
            _context.Reviews.Remove(review);
            await _context.SaveChangesAsync();
            return true;
        }
        public async Task<ReviewEntity> GetReviewById(int id)
        {
            return await _context.Reviews.FirstOrDefaultAsync(r => r.Id == id);
        }
        public async Task<IEnumerable<ReviewEntity>> GetAllReviewsForUser(int userId)
        {
            return await _context.Reviews.Where(r => r.UserId == userId).ToListAsync();
        }
        public async Task<IEnumerable<ReviewEntity>> GetLast5ReviewsForUser(int userId)
        {
            return await _context.Reviews.Where(r => r.UserId == userId).OrderByDescending(r => r.CreatedAt).Take(5).ToListAsync();
        }
        public async Task<IEnumerable<ReviewEntity>> GetAllReviewsForProperty(int propertyId)
        {
            return await _context.Reviews.Where(r => r.PropertyId == propertyId).ToListAsync();
        }
        public async Task<IEnumerable<ReviewEntity>> GetLast5ReviewsForProperty(int propertyId)
        {
            return await _context.Reviews.Where(r => r.PropertyId == propertyId).OrderByDescending(r => r.CreatedAt).Take(5).ToListAsync();
        }
        public async Task<decimal> GetAvgForUser(int userId)
        {
            return await _context.Reviews.Where(r => r.UserId == userId).AverageAsync(r => (decimal)r.Rating);
        }
        public async Task<decimal> GetAvgForProperty(int propertyId)
        {
            return await _context.Reviews.Where(r => r.PropertyId == propertyId).AverageAsync(r => (decimal)r.Rating);
        }
    }
    public interface IReviewRepository
    {
        Task<ReviewEntity> CreateReview(ReviewEntity review);
        Task<bool> DeleteReviewById(int reviewId);
        Task<ReviewEntity> GetReviewById(int id);
        Task<IEnumerable<ReviewEntity>> GetAllReviewsForUser(int userId);
        Task<IEnumerable<ReviewEntity>> GetLast5ReviewsForUser(int userId);
        Task<IEnumerable<ReviewEntity>> GetAllReviewsForProperty(int propertyId);
        Task<IEnumerable<ReviewEntity>> GetLast5ReviewsForProperty(int propertyId);
        Task<decimal> GetAvgForUser(int userId);
        Task<decimal> GetAvgForProperty(int propertyId);
    }
}
