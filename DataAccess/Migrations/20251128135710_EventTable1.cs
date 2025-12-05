using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class EventTable1 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
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
    }
}
