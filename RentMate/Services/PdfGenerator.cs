using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using System.Text.RegularExpressions;
using System.Xml;

public class PdfGenerator
{
    public byte[] GenerateOfferContractPdf(string contractText)
    {
        var matches = Regex.Matches(contractText, @"<(h2|h3|p)([^>]*)>(.*?)</\1>", RegexOptions.Singleline | RegexOptions.IgnoreCase);

        var document = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Margin(50);
                page.Size(PageSizes.A4);
                page.PageColor(Colors.White);
                page.DefaultTextStyle(x => x.FontSize(12).FontColor(Colors.Black));

                page.Content()
                    .PaddingVertical(10)
                    .Column(column =>
                    {
                        foreach (Match match in matches)
                        {
                            //Formating OfferContract
                            string tag = match.Groups[1].Value.ToLower();
                            string attributes = match.Groups[2].Value.ToLower();
                            string content = match.Groups[3].Value;
                            content = Regex.Replace(content, @"<br\s*/?>", "\n", RegexOptions.IgnoreCase);
                            content = Regex.Replace(content, "<.*?>", string.Empty).Trim();

                            if (tag == "h2")
                            {
                                column.Item()
                                    .Padding(5)
                                    .Text(content)
                                    .FontSize(18)
                                    .AlignCenter();

                            }
                            else if (tag == "h3")
                            {
                                column.Item()
                                .PaddingTop(8)
                                .Text(content)
                                .FontSize(12)
                                .AlignCenter();
                            }
                            else if (tag == "p")
                            {
                                column.Item()
                                    .Text(content)
                                    .FontSize(10)
                                    .AlignLeft();
                            }
                        }
                    });

                page.Footer()
                    .AlignCenter()
                    .Text("RentMate")
                    .FontSize(10)
                    .Italic();
            });
        });


        return document.GeneratePdf();
    }

    //public string RemoveHtmlTags(string input)
    //{
    //    return Regex.Replace(input, "<.*?>", string.Empty);
    //}
}