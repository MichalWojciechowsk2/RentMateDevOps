using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Data.Migrations
{
    /// <inheritdoc />
    public partial class PropertyChat : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Usuń foreign key i index jeśli istnieją
            migrationBuilder.Sql(@"
                IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Messages_Users_ReceiverId')
                    ALTER TABLE Messages DROP CONSTRAINT FK_Messages_Users_ReceiverId;
            ");

            migrationBuilder.Sql(@"
                IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Messages_ReceiverId' AND object_id = OBJECT_ID('Messages'))
                    DROP INDEX IX_Messages_ReceiverId ON Messages;
            ");

            // Usuń kolumnę tylko jeśli istnieje
            migrationBuilder.Sql(@"
                IF EXISTS (
                    SELECT 1 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_NAME = 'Messages' AND COLUMN_NAME = 'ReceiverId'
                )
                BEGIN
                    ALTER TABLE Messages DROP COLUMN ReceiverId;
                END
            ");

            // Dodaj kolumnę ChatGroupId tylko jeśli nie istnieje
            migrationBuilder.Sql(@"
                IF NOT EXISTS (
                    SELECT 1 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_NAME = 'Properties' AND COLUMN_NAME = 'ChatGroupId'
                )
                BEGIN
                    ALTER TABLE Properties ADD ChatGroupId int NOT NULL DEFAULT 0;
                END
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ChatGroupId",
                table: "Properties");

            migrationBuilder.AddColumn<int>(
                name: "ReceiverId",
                table: "Messages",
                type: "int",
                nullable: true);
        }
    }
}
