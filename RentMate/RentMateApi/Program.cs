using Data;
using Infrastructure.Repositories;
using Services.AutoMapper;
using Services.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using static Services.Services.PropertyService;
using ApplicationCore.Interfaces;
using Microsoft.Extensions.FileProviders;

namespace RentMateApi
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowAll",
                    builder =>
                    {
                        builder.AllowAnyOrigin()
                               .AllowAnyMethod()
                               .AllowAnyHeader();
                    });
            });

            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();
            builder.Services.AddDbContext<RentMateDbContext>();
            //repositories and services
            builder.Services.AddScoped<IPropertyRepository, PropertyReporitory>();
          
            builder.Services.AddScoped<IPropertyService, PropertyService>();
            builder.Services.AddScoped<AuthService>();
            builder.Services.AddScoped<MessageRepository>();
            builder.Services.AddScoped<IMessageService, MessageService>();
            builder.Services.AddScoped<IOfferService, OfferService>();

            builder.Services.AddScoped<IUserRepository , UserRepository>();
            builder.Services.AddScoped<IUserService , UserService>();
            builder.Services.AddScoped<IOfferRepository, OfferRepository>();
            //mapper

            builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());
            builder.Services.AddAutoMapper(typeof(AutoMapperProfiles));

            /*builder.Services.AddControllers().AddJsonOptions(options =>
            {
                options.JsonSerializerOptions.PropertyNamingPolicy = null; // lub JsonNamingPolicy.CamelCase
                options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
            });*/

            // Configure JWT Authentication
            builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddJwtBearer(options =>
                {
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = true,
                        ValidateAudience = true,
                        ValidateLifetime = true,
                        ValidateIssuerSigningKey = true,
                        ValidIssuer = builder.Configuration["Jwt:Issuer"],
                        ValidAudience = builder.Configuration["Jwt:Audience"],
                        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
                    };
                });

            builder.Services.AddAuthorization();

            var app = builder.Build();
            RentMateApi.Seed.SeedData.EnsureSeeded(app);

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseHttpsRedirection();

            app.UseStaticFiles();
            app.UseStaticFiles(new StaticFileOptions
            {
                FileProvider = new PhysicalFileProvider(
                    Path.Combine(Directory.GetCurrentDirectory(), "uploads")),
                RequestPath = "/uploads",
                OnPrepareResponse = context =>
                {
                    context.Context.Response.Headers.Add("Access-Control-Allow-Origin", "*");
                    context.Context.Response.Headers.Add("Access-Control-Allow-Methods", "GET");
                    context.Context.Response.Headers.Add("Access-Control-Allow-Headers", "Content-Type");
                }
            });

            app.UseCors("AllowAll");

            app.UseAuthentication();
            app.UseAuthorization();

            app.MapControllers();

            app.Run();
        }
    }
}