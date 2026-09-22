// RunSeeder.cs — minimal console to execute ReadingSeeder
// dotnet script scripts/RunSeeder.cs
using System;
using System.Security.Cryptography;
using System.Text;

// Compute deterministic GUIDs for verification
var slug = "ielts-reading-standard-test";
var keys = new[] { "s1q1","s1q2","s1q3","s1q4","s1q5","s2q1","s2q2","s2q3","s2q4","s2q5","s3q1","s3q2","s3q3","s3q4","s3q5","s3q6","s4q1","s4q2","s4q3","s4q4","s5q1","s5q2","s5q3","s5q4","s5q5" };
foreach (var k in keys)
{
    using var md5 = MD5.Create();
    var hash = md5.ComputeHash(Encoding.UTF8.GetBytes($"{slug}:question:{k}"));
    Console.WriteLine($"{k}: {new Guid(hash)}");
}
