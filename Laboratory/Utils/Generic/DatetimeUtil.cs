using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Utils.Generic
{
    public static class DatetimeUtil
    {
        public static string GetTimeStamp()
        {
            TimeSpan ts = DateTime.UtcNow - new DateTime(1970, 1, 1, 8, 0, 0, 0);
            var tsStr = Convert.ToInt64(ts.TotalMilliseconds).ToString();
            return tsStr;
        }

        public static long GetTimeStampLong()
        {
            TimeSpan ts = DateTime.UtcNow - new DateTime(1970, 1, 1, 8, 0, 0, 0);
            var tslong = Convert.ToInt64(ts.TotalMilliseconds);
            return tslong;
        }

        public static string GetTimeStamp(DateTime date)
        {
            TimeSpan ts = date - new DateTime(1970, 1, 1, 8, 0, 0, 0);
            var tsStr = Convert.ToInt64(ts.TotalMilliseconds).ToString();
            return tsStr;
        }

        public static string GetTimeStamp(string dateStr)
        {
            var date = Convert.ToDateTime(dateStr);
            TimeSpan ts = date - new DateTime(1970, 1, 1, 8, 0, 0, 0);
            var tsStr = Convert.ToInt64(ts.TotalMilliseconds).ToString();
            return tsStr;
        }

        public static string GetTimeFromStamp(long timeStamp)
        {
            DateTime dtStart = TimeZoneInfo.ConvertTime(new DateTime(1970, 1, 1), TimeZoneInfo.Local);
            TimeSpan timeSpan = new TimeSpan(timeStamp * 10000);
            DateTime targetDt = dtStart.Add(timeSpan).AddHours(8);
            return targetDt.ToString("yyyyMMddhhmmssff");
        }

        public static string GetNow()
        {
            return DateTime.Now.ToString("yyyy-MM-dd hh:mm:ss fff");
        }

        public static string GetTime()
        {
            return DateTime.Now.ToString("hh:mm:ss fff");
        }

        public static bool IsEqualOrGreaterDate(string str1, string str2, string spliter = "-")
        {
            var darr1 = str1?.Split(spliter);
            if (darr1 == null || darr1.Length != 3)
            {
                return false;
            }

            var darr2 = str2?.Split(spliter);
            if (darr2 == null || darr2.Length != 3)
            {
                return true;
            }
            var d1 = new DateTime(darr1[0].ToInt(), darr1[1].ToInt(), darr1[2].Substring(0, 2).ToInt());
            var d2 = new DateTime(darr2[0].ToInt(), darr2[1].ToInt(), darr2[2].Substring(0, 2).ToInt());

            return d1 >= d2;
        }

        public static bool IsEqualOrGreaterThanToday(string dateStr)
        {
            var today = DateTime.Today.ToString("yyyy-MM-dd");
            return IsEqualOrGreaterDate(dateStr, today);
        }

        public static string GetDayOfWeek(DayOfWeek dayOfWeek)
        {
            var dayToday = (int)DateTime.Today.DayOfWeek;
            var targetDayCount = (int)dayOfWeek;
            var targetDay = DateTime.Today.AddDays(-dayToday + targetDayCount);
            return targetDay.ToString("yyyy-MM-dd");
        }

        public static string GetDayOfNextWeek(DayOfWeek dayOfWeek)
        {
            var dayToday = (int)DateTime.Today.DayOfWeek;
            var targetDayCount = (int)dayOfWeek + 7;
            var targetDay = DateTime.Today.AddDays(-dayToday + targetDayCount);
            return targetDay.ToString("yyyy-MM-dd");
        }

        public static string GetToday()
        {
            var today = DateTime.Today;
            return today.ToString("yyyy-MM-dd");
        }

        public static string GetTomorrow()
        {
            var today = DateTime.Today;
            var tomro = today.AddDays(1).ToString("yyyy-MM-dd");
            return tomro;
        }

        public static string GetTargetDate(int day)
        {
            var today = DateTime.Today;
            var targetDay = today.AddDays(day).ToString("yyyy-MM-dd");
            return targetDay;
        }

        public static List<string> GetDateRange(string startDateStr, string endDateStr)
        {
            var startDate = Convert.ToDateTime(startDateStr);
            var endDate = Convert.ToDateTime(endDateStr);

            if (startDate < DateTime.Today)
            {
                startDate = DateTime.Today;
            }

            if (startDate > endDate)
            {
                return new List<string>();
            }

            var result = new List<string>();

            while (startDate <= endDate)
            {
                result.Add(startDate.ToString("yyyy-MM-dd"));

                startDate = startDate.AddDays(1);
            }

            return result;
        }


        public static string GetDateTime(string dateStr, string format)
        {
            var date = Convert.ToDateTime(dateStr);

            return date.ToString(format);
        }

        public static string GetNextWeekday(DayOfWeek dayOfWeek)
        {
            var dayToday = (int)DateTime.Today.DayOfWeek;
            if ((int)dayOfWeek <= dayToday)
            {
                return GetDayOfNextWeek(dayOfWeek);
            }
            return GetDayOfWeek(dayOfWeek);
        }

        public static List<string> GetFutureDays(params DayOfWeek[] days)
        {
            var dayToday = (int)DateTime.Today.DayOfWeek;
            var dateList = new List<string>();
            foreach (var day in days)
            {
                if ((int)day <= dayToday)
                {
                    var dayNextWeek = GetDayOfNextWeek(day);
                    dateList.Add(dayNextWeek);
                    continue;
                    ;
                }
                var dayCurrentWeek = GetDayOfWeek(day);
                dateList.Add(dayCurrentWeek);
            }

            return dateList;
        }

        public static int GetWeek(string date)
        {
            var dayOfWeek = Convert.ToDateTime(date);
            return dayOfWeek.DayOfWeek.ToInt();
        }

        public static int GetAge(string birthdayStr)
        {
            var birthday = Convert.ToDateTime(birthdayStr);
            int age = DateTime.Now.Year - birthday.Year;
            if (DateTime.Now.Month < birthday.Month || (DateTime.Now.Month == birthday.Month && DateTime.Now.Day < birthday.Day))
            {
                age--;
            }

            return age;
        }
    }
}
