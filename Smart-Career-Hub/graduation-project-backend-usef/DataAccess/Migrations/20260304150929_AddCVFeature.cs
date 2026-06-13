using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class AddCVFeature : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Enrollment_Roadmaps_RoadmapId",
                table: "Enrollment");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Enrollment",
                table: "Enrollment");

            migrationBuilder.RenameTable(
                name: "Enrollment",
                newName: "enrollments");

            migrationBuilder.RenameIndex(
                name: "IX_Enrollment_RoadmapId",
                table: "enrollments",
                newName: "IX_enrollments_RoadmapId");

            migrationBuilder.AddColumn<int>(
                name: "CVTemplateId",
                table: "UserCVs",
                type: "int",
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_enrollments",
                table: "enrollments",
                column: "Id");

            migrationBuilder.CreateTable(
                name: "CVTemplates",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    FileName = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: false),
                    FilePath = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ContentType = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    UploadedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    CompanyId = table.Column<string>(type: "nvarchar(450)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CVTemplates", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CVTemplates_Users_CompanyId",
                        column: x => x.CompanyId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_UserCVs_CVTemplateId",
                table: "UserCVs",
                column: "CVTemplateId");

            migrationBuilder.CreateIndex(
                name: "IX_CVTemplates_CompanyId",
                table: "CVTemplates",
                column: "CompanyId");

            migrationBuilder.AddForeignKey(
                name: "FK_enrollments_Roadmaps_RoadmapId",
                table: "enrollments",
                column: "RoadmapId",
                principalTable: "Roadmaps",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserCVs_CVTemplates_CVTemplateId",
                table: "UserCVs",
                column: "CVTemplateId",
                principalTable: "CVTemplates",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_enrollments_Roadmaps_RoadmapId",
                table: "enrollments");

            migrationBuilder.DropForeignKey(
                name: "FK_UserCVs_CVTemplates_CVTemplateId",
                table: "UserCVs");

            migrationBuilder.DropTable(
                name: "CVTemplates");

            migrationBuilder.DropIndex(
                name: "IX_UserCVs_CVTemplateId",
                table: "UserCVs");

            migrationBuilder.DropPrimaryKey(
                name: "PK_enrollments",
                table: "enrollments");

            migrationBuilder.DropColumn(
                name: "CVTemplateId",
                table: "UserCVs");

            migrationBuilder.RenameTable(
                name: "enrollments",
                newName: "Enrollment");

            migrationBuilder.RenameIndex(
                name: "IX_enrollments_RoadmapId",
                table: "Enrollment",
                newName: "IX_Enrollment_RoadmapId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Enrollment",
                table: "Enrollment",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Enrollment_Roadmaps_RoadmapId",
                table: "Enrollment",
                column: "RoadmapId",
                principalTable: "Roadmaps",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
