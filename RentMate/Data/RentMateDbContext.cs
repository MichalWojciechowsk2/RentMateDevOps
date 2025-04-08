using Data.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data
{
    public class RentMateDbContext : DbContext
    {


        public RentMateDbContext(DbContextOptions<RentMateDbContext> options)
        : base(options)
        {
        }

        public RentMateDbContext()
        {
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {

         optionsBuilder.UseSqlServer("Data Source=HP;Initial Catalog=RentMate;Integrated Security=True;Trust Server Certificate=True");

        }

        public DbSet<User> Users { get; set; }
        public DbSet<Property> Properties { get; set; }
        public DbSet<Offer> Offers { get; set; }
        public DbSet<Payment> Payments { get; set; }
        public DbSet<Issue> Issues { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<Message> Messages { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // konfiguracja usera
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            // konfiguracja property
            modelBuilder.Entity<Property>()
                .HasOne(p => p.Owner)
                .WithMany()
                .HasForeignKey(p => p.OwnerId)
                .OnDelete(DeleteBehavior.Restrict);

            // konfiguracja offer
            modelBuilder.Entity<Offer>()
                .HasOne(o => o.Property)
                .WithMany(p => p.Offers)
                .HasForeignKey(o => o.PropertyId)
                .OnDelete(DeleteBehavior.Cascade);

            // konfiguracja payment
            modelBuilder.Entity<Payment>()
                .HasOne(p => p.Offer)
                .WithMany(o => o.Payments)
                .HasForeignKey(p => p.OfferId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Payment>()
                .HasOne(p => p.Tenant)
                .WithMany()
                .HasForeignKey(p => p.TenantId)
                .OnDelete(DeleteBehavior.Restrict);

            // konfiguracja issue
            modelBuilder.Entity<Issue>()
                .HasOne(i => i.Property)
                .WithMany(p => p.Issues)
                .HasForeignKey(i => i.PropertyId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Issue>()
                .HasOne(i => i.Tenant)
                .WithMany()
                .HasForeignKey(i => i.TenantId)
                .OnDelete(DeleteBehavior.Restrict);

            // konfiguracja review
            modelBuilder.Entity<Review>()
                .HasOne(r => r.Property)
                .WithMany(p => p.Reviews)
                .HasForeignKey(r => r.PropertyId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Review>()
                .HasOne(r => r.Author)
                .WithMany()
                .HasForeignKey(r => r.AuthorId)
                .OnDelete(DeleteBehavior.Restrict);

            // konfiguracja message
            modelBuilder.Entity<Message>()
                .HasOne(m => m.Sender)
                .WithMany()
                .HasForeignKey(m => m.SenderId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Message>()
                .HasOne(m => m.Receiver)
                .WithMany()
                .HasForeignKey(m => m.ReceiverId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Message>()
                .HasOne(m => m.Issue)
                .WithMany(i => i.Messages)
                .HasForeignKey(m => m.IssueId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
