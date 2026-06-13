using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class TrainingCentersTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "TrainingCenterId",
                table: "Workshops",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "TrainingCenterId",
                table: "Partnerships",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "TrainingCenters",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    OrganizationLogo = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    Name = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    City = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Country = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TrainingCenters", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TrainingCenters_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Workshops_TrainingCenterId",
                table: "Workshops",
                column: "TrainingCenterId");

            migrationBuilder.CreateIndex(
                name: "IX_Partnerships_TrainingCenterId",
                table: "Partnerships",
                column: "TrainingCenterId");

            migrationBuilder.CreateIndex(
                name: "IX_TrainingCenters_UserId",
                table: "TrainingCenters",
                column: "UserId",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Partnerships_TrainingCenters_TrainingCenterId",
                table: "Partnerships",
                column: "TrainingCenterId",
                principalTable: "TrainingCenters",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Workshops_TrainingCenters_TrainingCenterId",
                table: "Workshops",
                column: "TrainingCenterId",
                principalTable: "TrainingCenters",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Partnerships_TrainingCenters_TrainingCenterId",
                table: "Partnerships");

            migrationBuilder.DropForeignKey(
                name: "FK_Workshops_TrainingCenters_TrainingCenterId",
                table: "Workshops");

            migrationBuilder.DropTable(
                name: "TrainingCenters");

            migrationBuilder.DropIndex(
                name: "IX_Workshops_TrainingCenterId",
                table: "Workshops");

            migrationBuilder.DropIndex(
                name: "IX_Partnerships_TrainingCenterId",
                table: "Partnerships");

            migrationBuilder.DropColumn(
                name: "TrainingCenterId",
                table: "Workshops");

            migrationBuilder.DropColumn(
                name: "TrainingCenterId",
                table: "Partnerships");
        }
    }
}
