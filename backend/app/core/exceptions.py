"""Custom exception classes."""

from fastapi import HTTPException, status


class MakitiException(HTTPException):
    """Base exception for Makiti Market API."""

    def __init__(
        self,
        status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail: str = "An error occurred",
    ) -> None:
        """Initialize exception."""
        super().__init__(status_code=status_code, detail=detail)


class NotFoundError(MakitiException):
    """Resource not found exception."""

    def __init__(self, resource: str = "Resource") -> None:
        """Initialize not found error."""
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"{resource} not found",
        )


class ValidationError(MakitiException):
    """Validation error exception."""

    def __init__(self, detail: str = "Validation error") -> None:
        """Initialize validation error."""
        super().__init__(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=detail,
        )


class UnauthorizedError(MakitiException):
    """Unauthorized error exception."""

    def __init__(self, detail: str = "Unauthorized") -> None:
        """Initialize unauthorized error."""
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=detail,
        )


class ForbiddenError(MakitiException):
    """Forbidden error exception."""

    def __init__(self, detail: str = "Forbidden") -> None:
        """Initialize forbidden error."""
        super().__init__(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=detail,
        )


