using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class UpdateInterviewStructure : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Time",
                table: "Interviews");

            migrationBuilder.RenameColumn(
                name: "Date",
                table: "Interviews",
                newName: "ScheduledAt");

            migrationBuilder.RenameIndex(
                name: "IX_Interviews_Date",
                table: "Interviews",
                newName: "IX_Interviews_ScheduledAt");

            migrationBuilder.AlterColumn<string>(
                name: "Status",
                table: "Interviews",
                type: "nvarchar(450)",
                nullable: false,
                defaultValue: "Pending",
                oldClrType: typeof(string),
                oldType: "nvarchar(50)",
                oldMaxLength: 50,
                oldDefaultValue: "Scheduled");

            migrationBuilder.AlterColumn<string>(
                name: "Location",
                table: "Interviews",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(500)",
                oldMaxLength: 500);

            migrationBuilder.AddColumn<string>(
                name: "Feedback",
                table: "Interviews",
                type: "nvarchar(2000)",
                maxLength: 2000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MeetingLink",
                table: "Interviews",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Result",
                table: "Interviews",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "None");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Feedback",
                table: "Interviews");

            migrationBuilder.DropColumn(
                name: "MeetingLink",
                table: "Interviews");

            migrationBuilder.DropColumn(
                name: "Result",
                table: "Interviews");

            migrationBuilder.RenameColumn(
                name: "ScheduledAt",
                table: "Interviews",
                newName: "Date");

            migrationBuilder.RenameIndex(
                name: "IX_Interviews_ScheduledAt",
                table: "Interviews",
                newName: "IX_Interviews_Date");

            migrationBuilder.AlterColumn<string>(
                name: "Status",
                table: "Interviews",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "Scheduled",
                oldClrType: typeof(string),
                oldType: "nvarchar(450)",
                oldDefaultValue: "Pending");

            migrationBuilder.AlterColumn<string>(
                name: "Location",
                table: "Interviews",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(500)",
                oldMaxLength: 500,
                oldNullable: true);

            migrationBuilder.AddColumn<TimeSpan>(
                name: "Time",
                table: "Interviews",
                type: "time",
                nullable: false,
                defaultValue: new TimeSpan(0, 0, 0, 0, 0));
        }
    }
}
