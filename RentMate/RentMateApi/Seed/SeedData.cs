using Data;
using Data.Entities;

namespace RentMateApi.Seed
{
    public static class SeedData
    {
        public static void EnsureSeeded(IApplicationBuilder app)
        {
            using var scope = app.ApplicationServices.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<RentMateDbContext>();

            if(!context.Users.Any(u => u.Email == "testuser1@gmail.com"))
            {
                var user = new UserEntity
                {
                    Email = "testuser1@gmail.com",
                    PasswordHash = "123",
                    FirstName = "Test",
                    LastName = "Test",
                    PhoneNumber = "123456789012345",
                };
                context.Users.Add(user);
                context.SaveChanges();
            }
        }
    }
}
