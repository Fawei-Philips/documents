using System.Text;

namespace Utils.Enumerable
{
    public static class EnumerableExt
    {
        extension<T>(IEnumerable<T>? list)
        {
            public bool HasItem()
            {
                if (list == null)
                {
                    return false;
                }

                return list.Count() > 0;
            }

            public string NotNullString(string separater = ",")
            {
                if (!list.HasItem())
                {
                    return string.Empty;
                }

                var sb = new StringBuilder();
                sb.AppendJoin(separater, list!.ToArray());

                return sb.ToString();
            }
        }
    }
}
