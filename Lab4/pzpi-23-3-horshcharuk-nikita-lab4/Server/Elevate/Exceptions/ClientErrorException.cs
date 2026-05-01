namespace Elevate.Exceptions;

public sealed class ClientErrorException : Exception
{
    public string MessageKey { get; }
    public IReadOnlyDictionary<string, string>? MessageParams { get; }

    public ClientErrorException(string messageKey, IReadOnlyDictionary<string, string>? messageParams = null)
        : base(messageKey)
    {
        MessageKey = messageKey;
        MessageParams = messageParams;
    }
}
