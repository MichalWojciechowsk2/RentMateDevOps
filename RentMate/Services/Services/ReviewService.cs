using ApplicationCore.Dto.Review;
using Data.Entities;
using Infrastructure.Repositories;

namespace Services.Services
{
    public class ReviewService : IReviewService
    {
        private IReviewRepository _reviewRepository;
        public ReviewService(IReviewRepository reviewRepository)
        {
            _reviewRepository = reviewRepository;
        }
        public async Task<ReviewEntity> CreateReview(ReviewDto reviewDto, int authorId)
        {
            // Walidacja - przynajmniej jedno z PropertyId lub UserId musi być ustawione
            if (!reviewDto.PropertyId.HasValue && !reviewDto.UserId.HasValue)
            {
                throw new ArgumentException("Either PropertyId or UserId must be provided.");
            }

            // Walidacja - Rating musi być w zakresie 1-5
            if (reviewDto.Rating < 1 || reviewDto.Rating > 5)
            {
                throw new ArgumentException("Rating must be between 1 and 5.");
            }

            var review = new ReviewEntity
            {
                PropertyId = reviewDto.PropertyId,
                UserId = reviewDto.UserId,
                AuthorId = authorId,
                Rating = reviewDto.Rating,
                Comment = string.IsNullOrWhiteSpace(reviewDto.Comment) ? string.Empty : reviewDto.Comment.Trim(),
                CreatedAt = DateTime.UtcNow
            };
            return await _reviewRepository.CreateReview(review);
        }
        public async Task<bool> DeleteReviewById(int reviewId)
        {
            return await _reviewRepository.DeleteReviewById(reviewId);
        }
        public async Task<ReviewEntity> GetReviewById(int reviewId)
        {
            return await _reviewRepository.GetReviewById(reviewId);
        }
        public async Task<IEnumerable<ReviewEntity>> GetAllReviewsForUser(int userId)
        {
            return await _reviewRepository.GetAllReviewsForUser(userId);
        }
        public async Task<IEnumerable<ReviewEntity>> GetAllReviewsForProperty(int propertyId)
        {
            return await _reviewRepository.GetAllReviewsForUser(propertyId);
        }
    }
    public interface IReviewService
    {
        Task<ReviewEntity> CreateReview(ReviewDto reviewDto, int authorId);
        Task<bool> DeleteReviewById(int reviewId);
        Task<ReviewEntity> GetReviewById(int reviewId);
        Task<IEnumerable<ReviewEntity>> GetAllReviewsForUser(int userId);
        Task<IEnumerable<ReviewEntity>> GetAllReviewsForProperty(int propertyId);
    }
}