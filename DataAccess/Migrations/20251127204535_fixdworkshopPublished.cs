using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class fixdworkshopPublished : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsPublished",
                table: "Workshops",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "TotalActivities",
                table: "Workshops",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "TotalMaterials",
                table: "Workshops",
                type: "int",
                nullable: false,
                defaultValue: 0);

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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsPublished",
                table: "Workshops");

            migrationBuilder.DropColumn(
                name: "TotalActivities",
                table: "Workshops");

            migrationBuilder.DropColumn(
                name: "TotalMaterials",
                table: "Workshops");

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 27, 14, 24, 23, 193, DateTimeKind.Local).AddTicks(2028));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 27, 14, 24, 23, 193, DateTimeKind.Local).AddTicks(2107));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 27, 14, 24, 23, 193, DateTimeKind.Local).AddTicks(2111));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 27, 14, 24, 23, 193, DateTimeKind.Local).AddTicks(2115));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 27, 14, 24, 23, 193, DateTimeKind.Local).AddTicks(2119));

            migrationBuilder.UpdateData(
                table: "Universities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 27, 14, 24, 23, 193, DateTimeKind.Local).AddTicks(2123));
        }
    }
}
