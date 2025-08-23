using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Data.Migrations
{
    /// <inheritdoc />
    public partial class RecurringPayment2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Payments_RecurringPayment_RecurringPaymentId",
                table: "Payments");

            migrationBuilder.DropForeignKey(
                name: "FK_RecurringPayment_Payments_PaymentId",
                table: "RecurringPayment");

            migrationBuilder.DropIndex(
                name: "IX_Payments_RecurringPaymentId",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "ClosestDateTimeRun",
                table: "RecurringPayment");

            migrationBuilder.DropColumn(
                name: "isActive",
                table: "RecurringPayment");

            migrationBuilder.DropColumn(
                name: "RecurringPaymentId",
                table: "Payments");

            migrationBuilder.AddColumn<int>(
                name: "NextGenerationInDays",
                table: "RecurringPayment",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddForeignKey(
                name: "FK_RecurringPayment_Payments_PaymentId",
                table: "RecurringPayment",
                column: "PaymentId",
                principalTable: "Payments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_RecurringPayment_Payments_PaymentId",
                table: "RecurringPayment");

            migrationBuilder.DropColumn(
                name: "NextGenerationInDays",
                table: "RecurringPayment");

            migrationBuilder.AddColumn<DateTime>(
                name: "ClosestDateTimeRun",
                table: "RecurringPayment",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<bool>(
                name: "isActive",
                table: "RecurringPayment",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "RecurringPaymentId",
                table: "Payments",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Payments_RecurringPaymentId",
                table: "Payments",
                column: "RecurringPaymentId");

            migrationBuilder.AddForeignKey(
                name: "FK_Payments_RecurringPayment_RecurringPaymentId",
                table: "Payments",
                column: "RecurringPaymentId",
                principalTable: "RecurringPayment",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_RecurringPayment_Payments_PaymentId",
                table: "RecurringPayment",
                column: "PaymentId",
                principalTable: "Payments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
