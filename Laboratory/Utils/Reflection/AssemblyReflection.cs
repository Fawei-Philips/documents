using System.Reflection;

namespace Utils.Reflection
{
    public static class AssemblyReflection
    {
        public static Type FindClass(string assemblyName, string classPath)
        {
            try
            {
                if (string.IsNullOrEmpty(assemblyName))
                {
                    throw new ArgumentException("assemblyName is null", nameof(assemblyName));
                }

                Assembly assembly = Assembly.Load(assemblyName);
                if (assembly == null)
                {
                    throw new TypeLoadException("未找到Data.AppDbContext类型");
                }

                if (string.IsNullOrEmpty(classPath))
                {
                    throw new ArgumentException("classPath is null", nameof(classPath));
                }

                Type? dbContextType = assembly.GetType(classPath);
                if (dbContextType == null)
                {
                    throw new TypeLoadException("未找到Data.AppDbContext类型");
                }

                return dbContextType;
            }
            catch (FileNotFoundException ex)
            {
                throw new Exception($"程序集Db.React.Study加载失败: {ex.Message}");
            }
            catch (Exception ex)
            {
                throw new Exception($"反射查找类型时发生错误: {ex.Message}");
            }
        }
    }
}
