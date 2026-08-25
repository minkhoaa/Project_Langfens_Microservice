namespace gamification_service.Features;

public static class NotificationEndpoint
{
    public static void MapNotificationEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/notifications")
            .WithTags("Notifications")
            .RequireAuthorization();

        group.MapGet("", Handler.GetNotifications)
            .WithName("GetNotifications")
            .WithDescription("Get user's notifications with pagination");

        group.MapGet("/unread-count", Handler.GetUnreadCount)
            .WithName("GetUnreadCount")
            .WithDescription("Get count of unread notifications");

        group.MapPatch("/{notificationId:guid}/read", Handler.MarkAsRead)
            .WithName("MarkNotificationAsRead")
            .WithDescription("Mark a notification as read");

        group.MapPatch("/read-all", Handler.MarkAllAsRead)
            .WithName("MarkAllNotificationsAsRead")
            .WithDescription("Mark all notifications as read");

        group.MapGet("/settings", Handler.GetSettings)
            .WithName("GetNotificationSettings")
            .WithDescription("Get user's notification settings");

        group.MapPut("/settings", Handler.UpdateSettings)
            .WithName("UpdateNotificationSettings")
            .WithDescription("Update user's notification settings");
    }

    private static class Handler
    {
        public static Task<IResult> GetNotifications(
            HttpContext ctx,
            int page = 1,
            int pageSize = 20,
            CancellationToken token = default,
            INotificationService service = default!
        )
        {
            var userId = ctx.User.GetUserId();
            return service.GetNotifications(userId, page, pageSize, token);
        }

        public static Task<IResult> GetUnreadCount(
            HttpContext ctx,
            CancellationToken token,
            INotificationService service
        ) => service.GetUnreadCount(ctx.User.GetUserId(), token);

        public static Task<IResult> MarkAsRead(
            HttpContext ctx,
            Guid notificationId,
            CancellationToken token,
            INotificationService service
        ) => service.MarkAsRead(ctx.User.GetUserId(), notificationId, token);

        public static Task<IResult> MarkAllAsRead(
            HttpContext ctx,
            CancellationToken token,
            INotificationService service
        ) => service.MarkAllAsRead(ctx.User.GetUserId(), token);

        public static Task<IResult> GetSettings(
            HttpContext ctx,
            CancellationToken token,
            INotificationService service
        ) => service.GetSettings(ctx.User.GetUserId(), token);

        public static Task<IResult> UpdateSettings(
            HttpContext ctx,
            UpdateSettingsRequest request,
            CancellationToken token,
            INotificationService service
        ) => service.UpdateSettings(ctx.User.GetUserId(), request, token);
    }
}
