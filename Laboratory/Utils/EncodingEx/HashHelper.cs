using System.Security.Cryptography;
using System.Text;

namespace Utils.EncodingEx
{
    public static class HashHelper
    {
        public static string ComputeSHA256Hash(byte[] data)
        {
            using var sha256 = SHA256.Create();
            byte[] hashBytes = sha256.ComputeHash(data);

            // Values like 0x7F, 0x83, 0xB1 in the hash byte array will be converted to the string "7F-83-B1".
            // A complete SHA256 hash(32 bytes) generates a string similar to "7F-83-B1-65-7F-F1-FC-53-...-90-68"(with 31 hyphens).
            // However, the hash value we need is a continuous string without separators, so we must first remove these hyphens.
            return BitConverter.ToString(hashBytes).Replace("-", "").ToLowerInvariant();
        }

        public static string ToHashString(byte[] hashBytes)
        {
            StringBuilder sb = new StringBuilder();
            foreach (byte b in hashBytes)
            {
                sb.Append(b.ToString("x2"));
            }
            return sb.ToString();
        }

        public static string ComputeSHA256Hash(Stream dataStream)
        {
            using var sha256 = SHA256.Create();
            byte[] hashBytes = sha256.ComputeHash(dataStream);
            return ToHashString(hashBytes);
        }

        public static string ComputeSHA256Hash(string input)
        {
            using var sha256 = SHA256.Create();
            byte[] inputBytes = Encoding.UTF8.GetBytes(input);
            byte[] hashBytes = sha256.ComputeHash(inputBytes);
            return ToHashString(hashBytes);
        }

        public static string ComputeMd5Hash(string input)
        {
            using var md5 = MD5.Create();
            byte[] inputBytes = Encoding.UTF8.GetBytes(input);
            byte[] hashBytes = md5.ComputeHash(inputBytes);
            return ToHashString(hashBytes);
        }

        public static string ComputeMd5Hash(byte[] data)
        {
            using var md5 = MD5.Create();
            byte[] hashBytes = md5.ComputeHash(data);
            return ToHashString(hashBytes);
        }

        public static string ComputeMd5Hash(Stream dataStream)
        {
            using var md5 = MD5.Create();
            byte[] hashBytes = md5.ComputeHash(dataStream);
            return ToHashString(hashBytes);
        }
    }
}
