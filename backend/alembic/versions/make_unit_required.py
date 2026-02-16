"""make_unit_required

Revision ID: make_unit_required
Revises: dd1f01635543
Create Date: 2026-02-15 23:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'make_unit_required'
down_revision: Union[str, None] = 'dd1f01635543'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Mettre à jour les produits existants sans unité avec "pièce" par défaut
    op.execute("UPDATE products SET unit = 'pièce' WHERE unit IS NULL OR unit = ''")
    
    # Rendre le champ unit non nullable avec valeur par défaut
    op.alter_column('products', 'unit',
                    existing_type=sa.String(),
                    nullable=False,
                    server_default='pièce')


def downgrade() -> None:
    # Revenir à nullable
    op.alter_column('products', 'unit',
                    existing_type=sa.String(),
                    nullable=True,
                    server_default=None)

