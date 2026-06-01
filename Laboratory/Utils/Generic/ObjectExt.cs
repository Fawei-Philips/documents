namespace Utils.Generic
{
    public static class ObjectExt
    {
        extension(object? obj)
        {
            public int ToInt()
            {
                if (obj == null)
                {
                    return 0;
                }

                var intResult = int.TryParse(obj.ToString(), out int result);
                if (!intResult)
                {
                    var doubleResult = double.TryParse(obj.ToString(), out double doubleTry);
                    if (doubleResult)
                    {
                        return Convert.ToInt32(doubleTry);
                    }
                }
                return Convert.ToInt32(obj);
            }

            public double ToDouble()
            {
                if (obj == null)
                {
                    return 0;
                }

                var doubleResult = double.TryParse(obj.ToString(), out double result);
                if (doubleResult)
                {
                    return result;
                }
                return Convert.ToDouble(obj);
            }

            public string NotNullString()
            {
                var strSource = obj?.ToString();
                return strSource ?? string.Empty;
            }
        }
    }
}
