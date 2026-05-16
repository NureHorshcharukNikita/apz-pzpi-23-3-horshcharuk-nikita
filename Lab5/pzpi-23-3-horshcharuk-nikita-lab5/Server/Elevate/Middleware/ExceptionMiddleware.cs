using System.Text.Json;

namespace Elevate.Middleware;

public class ExceptionMiddleware
{
    private readonly RequestDelegate _next;

    public ExceptionMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task Invoke(HttpContext context)
    {
        try
        {
            await _next(context);

            if (context.Response.HasStarted)
                return;

            if (context.Response.StatusCode == StatusCodes.Status400BadRequest)
            {
                await Write(context, 400, "Bad request");
                return;
            }

            if (context.Response.StatusCode == StatusCodes.Status401Unauthorized)
            {
                await Write(context, 401, "Unauthorized");
                return;
            }

            if (context.Response.StatusCode == StatusCodes.Status403Forbidden)
            {
                await Write(context, 403, "Access denied");
                return;
            }

            if (context.Response.StatusCode == StatusCodes.Status404NotFound)
            {
                await Write(context, 404, "Resource not found");
                return;
            }

            if (context.Response.StatusCode == StatusCodes.Status405MethodNotAllowed)
            {
                await Write(context, 405, "Method not allowed");
                return;
            }

            if (context.Response.StatusCode == StatusCodes.Status415UnsupportedMediaType)
            {
                await Write(context, 415, "Unsupported media type");
                return;
            }

            if (context.Response.StatusCode == StatusCodes.Status422UnprocessableEntity)
            {
                await Write(context, 422, "Validation failed");
                return;
            }
        }
        catch (UnauthorizedAccessException ex)
        {
            await Write(context, 401, ex.Message);
        }
        catch (ArgumentException ex)
        {
            await Write(context, 400, ex.Message);
        }
        catch (InvalidOperationException ex)
        {
            await Write(context, 400, ex.Message);
        }
        catch (KeyNotFoundException ex)
        {
            await Write(context, 404, ex.Message);
        }
        catch (NotImplementedException)
        {
            await Write(context, 501, "Not implemented");
        }
        catch (Exception)
        {
            await Write(context, 500, "Internal server error");
        }
    }

    private static async Task Write(HttpContext context, int statusCode, string message)
    {
        if (context.Response.HasStarted)
            return;

        context.Response.Clear();
        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json; charset=utf-8";

        var json = JsonSerializer.Serialize(new
        {
            message
        });

        await context.Response.WriteAsync(json);
    }
}
