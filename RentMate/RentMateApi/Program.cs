
using Data;
using Infrastructure.Repositories;
using Services.AutoMapper;
using Services.Services;

namespace RentMateApi
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.

            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();
            builder.Services.AddDbContext<RentMateDbContext>();
            builder.Services.AddScoped<IPropertyRepository, PropertyReporitory>();
            builder.Services.AddScoped<IPropertyService , PropertyService>();
            builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());
            builder.Services.AddAutoMapper(typeof(AutoMapperProfiles));

            var app = builder.Build();
            RentMateApi.Seed.SeedData.EnsureSeeded(app);

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseHttpsRedirection();

            app.UseAuthorization();


            app.MapControllers();

            app.Run();
        }
    }
}
