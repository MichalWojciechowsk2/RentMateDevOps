using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Data.Migrations
{
    /// <inheritdoc />
    public partial class RecurringPaymentEntity : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "RecurringPaymentId",
                table: "Payments",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "RecurringPayment",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PaymentId = table.Column<int>(type: "int", nullable: false),
                    ClosestDateTimeRun = table.Column<DateTime>(type: "datetime2", nullable: false),
                    RecurrenceTimes = table.Column<int>(type: "int", nullable: false),
                    isActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RecurringPayment", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RecurringPayment_Payments_PaymentId",
                        column: x => x.PaymentId,
                        principalTable: "Payments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Payments_RecurringPaymentId",
                table: "Payments",
                column: "RecurringPaymentId");

            migrationBuilder.CreateIndex(
                name: "IX_RecurringPayment_PaymentId",
                table: "RecurringPayment",
                column: "PaymentId");

            migrationBuilder.AddForeignKey(
                name: "FK_Payments_RecurringPayment_RecurringPaymentId",
                table: "Payments",
                column: "RecurringPaymentId",
                principalTable: "RecurringPayment",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Payments_RecurringPayment_RecurringPaymentId",
                table: "Payments");

            migrationBuilder.DropTable(
                name: "RecurringPayment");

            migrationBuilder.DropIndex(
                name: "IX_Payments_RecurringPaymentId",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "RecurringPaymentId",
                table: "Payments");
        }
    }
}
