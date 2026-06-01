using System.Collections.Concurrent;
using System.Runtime.CompilerServices;
using System.Text.Json;
using Utils.Generic;
using Utils.Json;

namespace Utils.Enumerable
{
    public static class DictionaryExt
    {
        #region Dictionary

        private static readonly ConditionalWeakTable<object, object> _lockTable = new();

        extension<TKey, TValue>(Dictionary<TKey, TValue> dic) where TKey : notnull
        {
            public void AddOrUpdate(TKey key, TValue value)
            {
                ArgumentNullException.ThrowIfNull(dic, nameof(dic));
                ArgumentNullException.ThrowIfNull(key, nameof(key));

                // thread-safe update
                object lockObj = _lockTable.GetValue(dic, _ => new object());
                lock (lockObj)
                {
                    dic[key] = value;
                }
            }

            public void AddOrUpdate(Dictionary<TKey, TValue> dicToAdd)
            {
                ArgumentNullException.ThrowIfNull(dic, nameof(dic));

                if (dicToAdd == null || dicToAdd.Count == 0)
                {
                    return;
                }

                object lockObj = _lockTable.GetValue(dic, _ => new object());

                lock (lockObj)
                {
                    foreach ((TKey key, TValue value) in dicToAdd)
                    {
                        dic[key] = value;
                    }
                }
            }

            public bool HasItem()
            {
                if (dic == null)
                {
                    return false;
                }

                return dic.Count > 0;
            }
        }


        extension(Dictionary<string, object> dic)
        {
            public string ToJson()
            {
                var json = JsonSerializer.Serialize(dic, JsonEncoder.JsonOption);
                return json;
            }

            public string? GetString(string key)
            {
                if (dic == null || key == null)
                {
                    return null;
                }

                if (!dic.ContainsKey(key))
                {
                    return null;
                }

                if (dic[key] == null)
                {
                    return null;
                }
                return dic[key].ToString();
            }

            public int GetInt(string key)
            {
                var strValue = dic.GetString(key);
                return strValue.ToInt();
            }

            public object? GetValue(string key)
            {
                if (dic == null || key == null)
                {
                    return null;
                }

                if (!dic.ContainsKey(key))
                {
                    return null;
                }
                return dic[key];
            }
        }

        #endregion Dictionary

        #region ConcurrentDictionary

        extension<TKey, TValue>(ConcurrentDictionary<TKey, TValue> dic) where TKey : notnull
        {
            public void AddOrUpdate(TKey key, TValue value)
            {
                ArgumentNullException.ThrowIfNull(dic, nameof(dic));
                ArgumentNullException.ThrowIfNull(key, nameof(key));
                dic.AddOrUpdate(key, value, (_, _) => value);
            }
        }

        extension(ConcurrentDictionary<string, object> dic)
        {
            public string ToJson()
            {
                var json = JsonSerializer.Serialize(JsonEncoder.JsonOption);
                return json;
            }

            public bool HasItem()
            {
                if (dic == null)
                {
                    return false;
                }

                return dic.Count > 0;
            }

            public string? GetString(string key)
            {
                if (dic == null || key == null)
                {
                    return null;
                }

                if (!dic.ContainsKey(key))
                {
                    return null;
                }
                return dic[key].ToString();
            }

            public object? GetValue(string key)
            {
                if (dic == null || key == null)
                {
                    return null;
                }

                if (!dic.ContainsKey(key))
                {
                    return null;
                }
                return dic[key];
            }
        }

        #endregion ConcurrentDictionary
    }
}
