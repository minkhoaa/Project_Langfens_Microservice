using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace auth_service.Models
{
    public class User : IdentityUser { }
    public class Role : IdentityRole { }
    public class AppDbContext : IdentityDbContext<User, Role, string>
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        protected override void OnModelCreating(ModelBuilder mb)
        {
            base.OnModelCreating(mb);
            mb.Entity<User>().ToTable("users");
            mb.Entity<Role>().ToTable("roles");
            mb.Entity<IdentityUserRole<string>>().ToTable("user_roles");
            mb.Entity<IdentityUserClaim<string>>().ToTable("user_claims");
            mb.Entity<IdentityUserLogin<string>>().ToTable("user_logins");
            mb.Entity<IdentityRoleClaim<string>>().ToTable("role_claims");
            mb.Entity<IdentityUserToken<string>>().ToTable("user_tokens");

        }
    }
}