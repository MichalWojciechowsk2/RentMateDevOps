using System.ComponentModel.DataAnnotations;

namespace ApplicationCore.Enums
{
    public static class EnumExtensions
    {
        public static string GetDisplayName(this Enum enumValue)
        {
            var memberInfo = enumValue.GetType().GetMember(enumValue.ToString()).FirstOrDefault();
            if(memberInfo != null)
            {
                var displayAtribute = memberInfo.GetCustomAttributes(typeof(DisplayAttribute), false)
                    .Cast<DisplayAttribute>().FirstOrDefault();
                return displayAtribute?.Name ?? enumValue.ToString();
            }
            return enumValue.ToString();
        }
    }
}
