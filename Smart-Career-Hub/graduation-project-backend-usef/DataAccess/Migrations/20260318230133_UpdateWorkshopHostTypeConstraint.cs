using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class UpdateWorkshopHostTypeConstraint : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_Workshop_HostType",
                table: "Workshops");

            migrationBuilder.AddCheckConstraint(
                name: "CK_Workshop_HostType",
                table: "Workshops",
                sql: "([HostType] = 'University' AND [UniversityId] IS NOT NULL) OR ([HostType] = 'Company' AND [CompanyId] IS NOT NULL)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_Workshop_HostType",
                table: "Workshops");

            migrationBuilder.AddCheckConstraint(
                name: "CK_Workshop_HostType",
                table: "Workshops",
                sql: "([HostType] = 'University' AND [UniversityId] IS NOT NULL AND [CompanyId] IS NULL) OR ([HostType] = 'Company' AND [CompanyId] IS NOT NULL AND [UniversityId] IS NULL)");
        }
    }
}
