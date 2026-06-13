using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class EventTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Events",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    BannerUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    EventType = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Mode = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    StartDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndDate = table.Column<DateTime>(type: "datetime2", nullable: true),
                    StartTime = table.Column<TimeSpan>(type: "time", nullable: false),
                    EndTime = table.Column<TimeSpan>(type: "time", nullable: true),
                    MinimumRequiredPoints = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    CompletedRoadmap = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    Completed50PercentCourses = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    HighCommunicationSkills = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    HighTechnicalSkills = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    Top30PercentProgress = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    InviteOnlyEligibleStudents = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    EligibleStudentsCount = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    ExpectedAttendees = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    CurrentRegistrations = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    MaxCapacity = table.Column<int>(type: "int", nullable: false),
                    AllowWaitingList = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    SendAutoEmailToEligibleStudents = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    PointsForAttendance = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    PointsForFullParticipation = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    IsPublished = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Events", x => x.Id);
                });

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 14, 34, 9, 576, DateTimeKind.Local).AddTicks(5816));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 14, 34, 9, 576, DateTimeKind.Local).AddTicks(5872));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 14, 34, 9, 576, DateTimeKind.Local).AddTicks(5876));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 14, 34, 9, 576, DateTimeKind.Local).AddTicks(5880));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 14, 34, 9, 576, DateTimeKind.Local).AddTicks(5885));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 28, 14, 34, 9, 576, DateTimeKind.Local).AddTicks(5889));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Events");

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 27, 22, 45, 32, 79, DateTimeKind.Local).AddTicks(3462));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 27, 22, 45, 32, 79, DateTimeKind.Local).AddTicks(3532));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 27, 22, 45, 32, 79, DateTimeKind.Local).AddTicks(3536));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 27, 22, 45, 32, 79, DateTimeKind.Local).AddTicks(3539));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 27, 22, 45, 32, 79, DateTimeKind.Local).AddTicks(3700));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 27, 22, 45, 32, 79, DateTimeKind.Local).AddTicks(3705));
        }
    }
}
