"""Example worker tasks."""

import time

from app.core.logging import get_logger

logger = get_logger(__name__)


def example_task(message: str, delay: int = 1) -> dict[str, str]:
    """Example background task."""
    logger.info("Starting example task", message=message, delay=delay)
    time.sleep(delay)
    result = {"status": "completed", "message": message}
    logger.info("Example task completed", result=result)
    return result


def send_notification(user_id: str, message: str) -> dict[str, str]:
    """Send a notification to a user."""
    logger.info("Sending notification", user_id=user_id, message=message)
    # TODO: Implement notification sending logic
    time.sleep(0.5)  # Simulate API call
    result = {"status": "sent", "user_id": user_id, "message": message}
    logger.info("Notification sent", result=result)
    return result


