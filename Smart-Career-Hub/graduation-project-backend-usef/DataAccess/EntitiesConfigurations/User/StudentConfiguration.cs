using DataAccess.Entities.Users;
using DataAccess.Entities.RoadMap;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataAccess.Configuration
{
    public class StudentConfiguration : IEntityTypeConfiguration<Student>
    {
        public void Configure(EntityTypeBuilder<Student> builder)
        {
            builder.HasKey(s => s.Id);

            builder.HasOne(s => s.User)
         .WithOne(u => u.StudentProfile)
         .HasForeignKey<Student>(s => s.UserId)
         .IsRequired()
         .OnDelete(DeleteBehavior.Cascade);

            builder.Property(s => s.Major).HasMaxLength(100).IsRequired();
            builder.Property(s => s.Degree).HasMaxLength(50).IsRequired();
            builder.Property(s => s.University).HasMaxLength(150).IsRequired(false);
            builder.Property(s => s.GitHub).HasMaxLength(250).IsRequired(false);
            builder.Property(s => s.LinkedIn).HasMaxLength(250).IsRequired(false);
            builder.Property(s => s.ExpectedGraduation).IsRequired(false);
            builder.Property(s => s.ProfileImage)
       .HasMaxLength(250)  
       .IsRequired(false);

        }
    }

    
   
}
