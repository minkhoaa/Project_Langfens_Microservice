using System;
using System.Linq;
using System.Reflection;

class Program
{
    static void Main()
    {
        var asm = Assembly.LoadFrom("/home/khoa/.nuget/packages/whisper.net/1.9.0-preview2/lib/net8.0/Whisper.net.dll");
        var types = asm.GetTypes().Where(t => t.Name.Contains("Whisper"));
        foreach (var t in types)
        {
            Console.WriteLine($"TYPE: {t.FullName} sealed:{t.IsSealed} abstract:{t.IsAbstract}");
            foreach (var m in t.GetMethods(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly))
            {
                Console.WriteLine($"  METHOD: {m.Name} virtual:{m.IsVirtual} return:{m.ReturnType}");
            }
        }
    }
}
