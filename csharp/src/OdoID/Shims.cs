// IsExternalInit is required for C# 9 'record' and 'init' properties on netstandard2.1.
// This shim makes those features available without a NuGet dependency.
// See: https://developercommunity.visualstudio.com/t/error-cs0518-predefined-type/1244809
namespace System.Runtime.CompilerServices
{
    internal static class IsExternalInit { }
}
