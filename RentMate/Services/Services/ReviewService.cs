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
            var review = new ReviewEntity
            {
                PropertyId = reviewDto.PropertyId,
                UserId = reviewDto.UserId,
                AuthorId = authorId,
                Rating = reviewDto.Rating,
                Comment = reviewDto.Comment,
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
        public async Task<IEnumerable<ReviewEntity>> GetLast5ReviewsForUserByUserId(int userId)
        {
            return await _reviewRepository.GetLast5ReviewsForUser(userId);
        }
        public async Task<IEnumerable<ReviewEntity>> GetAllReviewsForProperty(int propertyId)
        {
            return await _reviewRepository.GetAllReviewsForUser(propertyId);
        }
        public async Task<IEnumerable<ReviewEntity>> GetLast5ReviewsForProperty(int propertyId)
        {
            return await _reviewRepository.GetLast5ReviewsForProperty(propertyId);
        }
        public async Task <decimal> GetAvgReview (int objectId, bool isItUser)
        {
            if (isItUser)
            {
                return await _reviewRepository.GetAvgForUser(int objectId);
            }
            else
            {
                return await _reviewRepository.GetAvgForProperty(int objectId);
            }

        }
    }
    public interface IReviewService
    {
        Task<ReviewEntity> CreateReview(ReviewDto reviewDto, int authorId);
        Task<bool> DeleteReviewById(int reviewId);
        Task<ReviewEntity> GetReviewById(int reviewId);
        Task<IEnumerable<ReviewEntity>> GetAllReviewsForUser(int userId);
        Task<IEnumerable<ReviewEntity>> GetLast5ReviewsForUserByUserId(int userId);        
        Task<IEnumerable<ReviewEntity>> GetAllReviewsForProperty(int propertyId);
        Task<IEnumerable<ReviewEntity>> GetLast5ReviewsForProperty(int propertyId);
        Task<decimal> GetAvgReview(int objectId, bool isItUser);

    }
}