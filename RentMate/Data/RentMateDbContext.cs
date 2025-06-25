using Data.Entities;
using Microsoft.EntityFrameworkCore;

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

         optionsBuilder.UseSqlServer("Data Source=DESKTOP-GI765C2;Initial Catalog=RentMate;Integrated Security=True;Encrypt=True;Trust Server Certificate=True");

        }

        public DbSet<UserEntity> Users { get; set; }
        public DbSet<PropertyEntity> Properties { get; set; }
        public DbSet<OfferEntity> Offers { get; set; }
        public DbSet<PaymentEntity> Payments { get; set; }
        public DbSet<IssueEntity> Issues { get; set; }
        public DbSet<ReviewEntity> Reviews { get; set; }
        public DbSet<MessageEntity> Messages { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
           

            // konfiguracja usera
            modelBuilder.Entity<UserEntity>()
                .HasIndex(u => u.Email)
                .IsUnique();

            // konfiguracja property
            modelBuilder.Entity<PropertyEntity>()
                .HasOne(p => p.Owner)
                .WithMany()
                .HasForeignKey(p => p.OwnerId)
                .OnDelete(DeleteBehavior.Restrict);

            // konfiguracja offer
            modelBuilder.Entity<OfferEntity>()
                .HasOne(o => o.Property)
                .WithMany(p => p.Offers)
                .HasForeignKey(o => o.PropertyId)
                .OnDelete(DeleteBehavior.Cascade);

            // konfiguracja payment
            modelBuilder.Entity<PaymentEntity>()
                .HasOne(p => p.Offer)
                .WithMany(o => o.Payments)
                .HasForeignKey(p => p.OfferId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<PaymentEntity>()
                .HasOne(p => p.Tenant)
                .WithMany()
                .HasForeignKey(p => p.TenantId)
                .OnDelete(DeleteBehavior.Restrict);

            // konfiguracja issue
            modelBuilder.Entity<IssueEntity>()
                .HasOne(i => i.Property)
                .WithMany(p => p.Issues)
                .HasForeignKey(i => i.PropertyId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<IssueEntity>()
                .HasOne(i => i.Tenant)
                .WithMany()
                .HasForeignKey(i => i.TenantId)
                .OnDelete(DeleteBehavior.Restrict);

            // konfiguracja review
            modelBuilder.Entity<ReviewEntity>()
                .HasOne(r => r.Property)
                .WithMany(p => p.Reviews)
                .HasForeignKey(r => r.PropertyId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<ReviewEntity>()
                .HasOne(r => r.Author)
                .WithMany()
                .HasForeignKey(r => r.AuthorId)
                .OnDelete(DeleteBehavior.Restrict);

            // konfiguracja message
            modelBuilder.Entity<MessageEntity>()
                .HasOne(m => m.Sender)
                .WithMany()
                .HasForeignKey(m => m.SenderId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<MessageEntity>()
                .HasOne(m => m.Receiver)
                .WithMany()
                .HasForeignKey(m => m.ReceiverId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<MessageEntity>()
                .HasOne(m => m.Issue)
                .WithMany(i => i.Messages)
                .HasForeignKey(m => m.IssueId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
