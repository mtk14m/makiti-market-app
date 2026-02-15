"""Queue configuration and management using RQ (Redis Queue)."""

from typing import Any, Callable

from rq import Queue as RQQueue
from rq.job import Job
from redis import Redis as SyncRedis

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)


class QueueManager:
    """Manages RQ queues and workers."""

    def __init__(self) -> None:
        """Initialize queue manager."""
        self.queues: dict[str, RQQueue] = {}
        self._redis_client: SyncRedis | None = None

    def _get_redis_client(self) -> SyncRedis:
        """Get synchronous Redis client for RQ."""
        if self._redis_client is None:
            redis_url = settings.BULLMQ_REDIS_URL or settings.REDIS_URL
            # Parse Redis URL
            if redis_url.startswith("redis://"):
                redis_url = redis_url.replace("redis://", "")
            parts = redis_url.split(":")
            host = parts[0] if parts else "localhost"
            port = int(parts[1].split("/")[0]) if len(parts) > 1 else 6379
            db = int(parts[1].split("/")[1]) if "/" in parts[1] else 0

            self._redis_client = SyncRedis(
                host=host,
                port=port,
                db=db,
                decode_responses=True,
            )
        return self._redis_client

    def get_queue(self, queue_name: str) -> RQQueue:
        """Get or create a queue."""
        if queue_name not in self.queues:
            redis_client = self._get_redis_client()
            self.queues[queue_name] = RQQueue(
                queue_name,
                connection=redis_client,
            )
            logger.info("Queue created", queue_name=queue_name)
        return self.queues[queue_name]

    def enqueue(
        self,
        queue_name: str,
        func: Callable,
        *args: Any,
        **kwargs: Any,
    ) -> Job:
        """Enqueue a job to a queue."""
        queue = self.get_queue(queue_name)
        job = queue.enqueue(func, *args, **kwargs)
        logger.info(
            "Job enqueued",
            queue_name=queue_name,
            job_id=job.id,
            func_name=func.__name__,
        )
        return job

    def close_all(self) -> None:
        """Close all queues."""
        if self._redis_client:
            self._redis_client.close()
            self._redis_client = None
        self.queues.clear()
        logger.info("All queues closed")


# Global queue manager instance
queue_manager = QueueManager()

