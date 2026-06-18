using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class fixedRple : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Type",
                table: "LearningMaterials",
                newName: "MaterialType");

            migrationBuilder.RenameColumn(
                name: "Durationpdf",
                table: "LearningMaterials",
                newName: "VideoDuration");

            migrationBuilder.RenameColumn(
                name: "Duration",
                table: "LearningMaterials",
                newName: "PdfDuration");

            migrationBuilder.RenameIndex(
                name: "IX_LearningMaterials_Type",
                table: "LearningMaterials",
                newName: "IX_LearningMaterials_MaterialType");

            migrationBuilder.RenameIndex(
                name: "IX_LearningMaterials_RoadmapId_Type",
                table: "LearningMaterials",
                newName: "IX_LearningMaterials_RoadmapId_MaterialType");

            migrationBuilder.AddCheckConstraint(
                name: "CK_Roadmaps_TargetRole",
                table: "Roadmaps",
                sql: "[TargetRole] IN ('Student','Graduate','Both')");

            migrationBuilder.AddCheckConstraint(
                name: "CK_RequiredSkills_Level",
                table: "RequiredSkills",
                sql: "[Level] IN ('Beginner','Intermediate','Advanced')");

            migrationBuilder.AddCheckConstraint(
                name: "CK_Quizzes_Type",
                table: "Quizzes",
                sql: "[Type] IN ('TrueandFalse','Mcq','Mixed')");

            migrationBuilder.AddCheckConstraint(
                name: "CK_Projects_Difficulty",
                table: "Projects",
                sql: "[Difficulty] IN ('Easy','Medium','Hard')");

            migrationBuilder.AddCheckConstraint(
                name: "CK_LearningMaterials_PdfDuration",
                table: "LearningMaterials",
                sql: "[PdfDuration] IS NULL OR [PdfDuration] IN ('Short','Medium','Long')");

            migrationBuilder.AddCheckConstraint(
                name: "CK_LearningMaterials_Type",
                table: "LearningMaterials",
                sql: "[MaterialType] IN ('Video','PDF')");

            migrationBuilder.AddCheckConstraint(
                name: "CK_LearningMaterials_VideoDuration",
                table: "LearningMaterials",
                sql: "[VideoDuration] IS NULL OR [VideoDuration] IN ('Short','Medium','Long','VeryLong')");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_Roadmaps_TargetRole",
                table: "Roadmaps");

            migrationBuilder.DropCheckConstraint(
                name: "CK_RequiredSkills_Level",
                table: "RequiredSkills");

            migrationBuilder.DropCheckConstraint(
                name: "CK_Quizzes_Type",
                table: "Quizzes");

            migrationBuilder.DropCheckConstraint(
                name: "CK_Projects_Difficulty",
                table: "Projects");

            migrationBuilder.DropCheckConstraint(
                name: "CK_LearningMaterials_PdfDuration",
                table: "LearningMaterials");

            migrationBuilder.DropCheckConstraint(
                name: "CK_LearningMaterials_Type",
                table: "LearningMaterials");

            migrationBuilder.DropCheckConstraint(
                name: "CK_LearningMaterials_VideoDuration",
                table: "LearningMaterials");

            migrationBuilder.RenameColumn(
                name: "VideoDuration",
                table: "LearningMaterials",
                newName: "Durationpdf");

            migrationBuilder.RenameColumn(
                name: "PdfDuration",
                table: "LearningMaterials",
                newName: "Duration");

            migrationBuilder.RenameColumn(
                name: "MaterialType",
                table: "LearningMaterials",
                newName: "Type");

            migrationBuilder.RenameIndex(
                name: "IX_LearningMaterials_RoadmapId_MaterialType",
                table: "LearningMaterials",
                newName: "IX_LearningMaterials_RoadmapId_Type");

            migrationBuilder.RenameIndex(
                name: "IX_LearningMaterials_MaterialType",
                table: "LearningMaterials",
                newName: "IX_LearningMaterials_Type");
        }
    }
}
