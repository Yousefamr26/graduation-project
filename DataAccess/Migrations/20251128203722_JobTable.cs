using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class JobTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Jobs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    RequiredSkills = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    ExperienceLevel = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    JobType = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Location = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    SalaryRange = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    CompanyLogo = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Jobs", x => x.Id);
                });

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 22, 37, 17, 328, DateTimeKind.Local).AddTicks(3588));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 22, 37, 17, 328, DateTimeKind.Local).AddTicks(3649));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 22, 37, 17, 328, DateTimeKind.Local).AddTicks(3653));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 22, 37, 17, 328, DateTimeKind.Local).AddTicks(3657));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 22, 37, 17, 328, DateTimeKind.Local).AddTicks(3660));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 22, 37, 17, 328, DateTimeKind.Local).AddTicks(3664));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Jobs");

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 15, 57, 9, 852, DateTimeKind.Local).AddTicks(8748));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 15, 57, 9, 852, DateTimeKind.Local).AddTicks(8822));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 15, 57, 9, 852, DateTimeKind.Local).AddTicks(8825));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 15, 57, 9, 852, DateTimeKind.Local).AddTicks(8828));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 15, 57, 9, 852, DateTimeKind.Local).AddTicks(8832));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 15, 57, 9, 852, DateTimeKind.Local).AddTicks(8835));
        }
    }
}
