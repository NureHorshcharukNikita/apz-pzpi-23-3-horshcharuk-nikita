using Elevate.Data;
using Elevate.Entities;
using Elevate.Middleware;
using Elevate.Services.Actions;
using Elevate.Services.Admin;
using Elevate.Services.Analytics;
using Elevate.Services.Auth.Core;
using Elevate.Services.Auth.Tokens;
using Elevate.Services.Gamification;
using Elevate.Services.IoT;
using Elevate.Services.Leaderboard;
using Elevate.Services.Teams;
using Elevate.Services.Users;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Security.Claims;
using System.Text;
using ActionEventValidator = Elevate.Services.Actions.ActionEventValidator;

namespace Elevate
{
    public class Program
    {
        public static async Task Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            ConfigureServices(builder);

            var app = builder.Build();

            await SeedDatabaseAsync(app);
            ConfigureMiddleware(app);

            await app.RunAsync();
        }

        private static void ConfigureServices(WebApplicationBuilder builder)
        {
            builder.Services.Configure<JwtOptions>(
                builder.Configuration.GetSection(JwtOptions.SectionName));
            builder.Services.Configure<WebAdministrationOptions>(
                builder.Configuration.GetSection(WebAdministrationOptions.SectionName));

            builder.Services.AddCors(options =>
            {
                options.AddPolicy("ElevateWeb", policy =>
                {
                    policy.AllowAnyOrigin()
                        .AllowAnyHeader()
                        .AllowAnyMethod();
                });
            });

            ConfigureDatabase(builder);
            ConfigureApplicationServices(builder.Services);
            ConfigureAuthentication(builder);
        }

        private static void ConfigureDatabase(WebApplicationBuilder builder)
        {
            var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

            if (string.IsNullOrWhiteSpace(connectionString))
            {
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine("Using InMemory database (connection string not configured).");
                Console.ResetColor();

                builder.Services.AddDbContext<ElevateDbContext>(options =>
                    options.UseInMemoryDatabase("ElevateDb"));
            }
            else
            {
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine("Using SQL Server database.");
                Console.WriteLine("Connection string:");
                Console.WriteLine(connectionString);
                Console.ResetColor();

                builder.Services.AddDbContext<ElevateDbContext>(options =>
                    options.UseSqlServer(connectionString));
            }
        }

        private static void ConfigureApplicationServices(IServiceCollection services)
        {
            services.AddScoped<DataSeeder>();
            services.AddScoped<IJwtTokenService, JwtTokenService>();

            services.AddScoped<UserRepository>();
            services.AddScoped<UserValidator>();
            services.AddScoped<IAuthService, AuthService>();

            services.AddScoped<IUserService, UserService>();
            services.AddScoped<IMobileOverviewService, MobileOverviewService>();
            services.AddScoped<IUserProfileService, UserProfileService>();
            services.AddScoped<TeamServiceShared>();
            services.AddScoped<ITeamCatalogService, TeamCatalogService>();
            services.AddScoped<ITeamLifecycleService, TeamLifecycleService>();
            services.AddScoped<ITeamRosterService, TeamRosterService>();
            services.AddScoped<ITeamMemberBadgeService, TeamMemberBadgeService>();
            services.AddScoped<ITeamGamificationSetupService, TeamGamificationSetupService>();
            services.AddScoped<ITeamJoinRequestService, TeamJoinRequestService>();
            services.AddScoped<ITeamService, TeamService>();
            services.AddScoped<ILeaderboardService, LeaderboardService>();
            services.AddScoped<IGamificationService, GamificationService>();
            services.AddScoped<ActionEventValidator>();
            services.AddScoped<IActionEventService, ActionEventService>();
            services.AddScoped<IAnalyticsService, AnalyticsService>();
            services.AddScoped<IIoTService, IoTService>();
            services.AddScoped<IAdminUserService, AdminUserService>();
            services.AddScoped<IAdminTeamService, AdminTeamService>();
            services.AddScoped<IAdminDeviceService, AdminDeviceService>();
            services.AddScoped<ITeamLevelsAdminService, TeamLevelsAdminService>();
            services.AddScoped<ITeamBadgesAdminService, TeamBadgesAdminService>();
            services.AddScoped<IActionTypesAdminService, ActionTypesAdminService>();
            services.AddScoped<IAdminAuditService, AdminAuditService>();
            services.AddScoped<IAdminBackupService, AdminBackupService>();
            services.AddScoped<IPasswordHasher<User>, PasswordHasher<User>>();

            services.AddControllers()
                .AddJsonOptions(options =>
                {
                    options.JsonSerializerOptions.ReferenceHandler =
                        System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
                    options.JsonSerializerOptions.PropertyNamingPolicy =
                        System.Text.Json.JsonNamingPolicy.CamelCase;
                });
            services.AddEndpointsApiExplorer();
            services.AddSwaggerGen(c =>
            {
                c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
                {
                    Description = "JWT Authorization header using the Bearer scheme. Example: \"Bearer {token}\"",
                    Name = "Authorization",
                    In = ParameterLocation.Header,
                    Type = SecuritySchemeType.Http,
                    Scheme = "bearer",
                    BearerFormat = "JWT"
                });

                c.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = "Bearer"
                            },
                            Scheme = "bearer",
                            Name = "Bearer",
                            In = ParameterLocation.Header
                        },
                        Array.Empty<string>()
                    }
                });
            });
        }

        private static void ConfigureAuthentication(WebApplicationBuilder builder)
        {
            var jwtOptions = builder.Configuration
                .GetSection(JwtOptions.SectionName)
                .Get<JwtOptions>();

            var signingKey = jwtOptions?.SigningKey
                             ?? throw new InvalidOperationException("JWT signing key is missing");

            builder.Services
                .AddAuthentication(options =>
                {
                    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                })
                .AddJwtBearer(options =>
                {
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = true,
                        ValidateAudience = true,
                        ValidateIssuerSigningKey = true,
                        ValidIssuer = jwtOptions.Issuer,
                        ValidAudience = jwtOptions.Audience,
                        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signingKey)),
                        RoleClaimType = ClaimTypes.Role
                    };
                });

            builder.Services.AddAuthorization();
        }

        private static async Task SeedDatabaseAsync(WebApplication app)
        {
            using var scope = app.Services.CreateScope();
            var seeder = scope.ServiceProvider.GetRequiredService<DataSeeder>();
            await seeder.SeedAsync();
        }

        private static void ConfigureMiddleware(WebApplication app)
        {
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }
            else
            {
                var urls = app.Configuration["ASPNETCORE_URLS"]
                           ?? Environment.GetEnvironmentVariable("ASPNETCORE_URLS")
                           ?? string.Empty;
                if (urls.Contains("https://", StringComparison.OrdinalIgnoreCase))
                    app.UseHttpsRedirection();
            }

            app.UseCors("ElevateWeb");

            app.UseMiddleware<ExceptionMiddleware>();

            app.UseAuthentication();
            app.UseAuthorization();

            app.MapGet("/health", () => Results.Text("ok", "text/plain"));

            app.MapControllers();
        }
    }
}
