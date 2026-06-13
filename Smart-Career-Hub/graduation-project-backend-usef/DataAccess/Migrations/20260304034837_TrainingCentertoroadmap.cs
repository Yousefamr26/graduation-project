using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class TrainingCentertoroadmap : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "TrainingCenterId",
                table: "Roadmaps",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Roadmaps_TrainingCenterId",
                table: "Roadmaps",
                column: "TrainingCenterId");

            migrationBuilder.AddForeignKey(
                name: "FK_Roadmaps_TrainingCenters_TrainingCenterId",
                table: "Roadmaps",
                column: "TrainingCenterId",
                principalTable: "TrainingCenters",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Roadmaps_TrainingCenters_TrainingCenterId",
                table: "Roadmaps");

            migrationBuilder.DropIndex(
                name: "IX_Roadmaps_TrainingCenterId",
                table: "Roadmaps");

            migrationBuilder.DropColumn(
                name: "TrainingCenterId",
                table: "Roadmaps");
        }
    }
}
