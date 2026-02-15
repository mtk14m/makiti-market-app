"""Redis configuration and connection management."""

import redis.asyncio as aioredis
from redis.asyncio import Redis

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

# Global Redis connection
redis_client: Redis | None = None


async def init_redis() -> None:
    """Initialize Redis connection."""
    global redis_client
    try:
        redis_url = settings.BULLMQ_REDIS_URL or settings.REDIS_URL
        redis_client = await aioredis.from_url(
            redis_url,
            encoding="utf-8",
            decode_responses=True,
            max_connections=10,
        )
        # Test connection
        await redis_client.ping()
        logger.info("Redis connection established")
    except Exception as e:
        logger.error("Failed to connect to Redis", error=str(e))
        raise


async def get_redis() -> Redis:
    """Get Redis client instance."""
    if redis_client is None:
        await init_redis()
    return redis_client


async def close_redis() -> None:
    """Close Redis connection."""
    global redis_client
    if redis_client:
        await redis_client.close()
        redis_client = None
        logger.info("Redis connection closed")


