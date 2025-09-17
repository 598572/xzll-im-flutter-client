// 时间工具类
class TimeUtils {
  // 格式化时间显示
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // 格式化日期时间显示
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (targetDate == today) {
      // 今天：显示时间
      return '今天 ${formatTime(dateTime)}';
    } else if (targetDate == yesterday) {
      // 昨天：显示昨天 + 时间
      return '昨天 ${formatTime(dateTime)}';
    } else if (now.difference(dateTime).inDays < 7) {
      // 一周内：显示星期几 + 时间
      return '${_getWeekday(dateTime.weekday)} ${formatTime(dateTime)}';
    } else if (dateTime.year == now.year) {
      // 今年：显示月日 + 时间
      return '${dateTime.month}月${dateTime.day}日 ${formatTime(dateTime)}';
    } else {
      // 其他：显示完整日期 + 时间
      return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${formatTime(dateTime)}';
    }
  }

  // 格式化日期显示（不包含时间）
  static String formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (targetDate == today) {
      return '今天';
    } else if (targetDate == yesterday) {
      return '昨天';
    } else if (now.difference(dateTime).inDays < 7) {
      return _getWeekday(dateTime.weekday);
    } else if (dateTime.year == now.year) {
      return '${dateTime.month}月${dateTime.day}日';
    } else {
      return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
    }
  }

  // 格式化相对时间（如：刚刚、5分钟前、2小时前）
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return formatDate(dateTime);
    }
  }

  // 获取星期几的中文
  static String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return '周一';
      case 2:
        return '周二';
      case 3:
        return '周三';
      case 4:
        return '周四';
      case 5:
        return '周五';
      case 6:
        return '周六';
      case 7:
        return '周日';
      default:
        return '';
    }
  }

  // 检查是否为今天
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return targetDate == today;
  }

  // 检查是否为昨天
  static bool isYesterday(DateTime dateTime) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return targetDate == yesterday;
  }
}
