"""initial_platform_schema

Revision ID: 0001_initial_platform_schema
Revises: None
Create Date: 2026-03-23 20:20:00.000000

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "0001_initial_platform_schema"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


user_role_enum = sa.Enum(
    "buyer",
    "seller",
    "buyer_seller",
    "operator",
    "box_owner",
    "admin",
    name="userrole",
    native_enum=False,
)


def upgrade() -> None:
    user_role_enum.create(op.get_bind(), checkfirst=True)

    op.create_table(
        "users",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("phone_number", sa.String(), nullable=False),
        sa.Column("first_name", sa.String(), nullable=True),
        sa.Column("last_name", sa.String(), nullable=True),
        sa.Column("full_name", sa.String(), nullable=True),
        sa.Column("date_of_birth", sa.Date(), nullable=True),
        sa.Column("email", sa.String(), nullable=True),
        sa.Column("gender", sa.String(), nullable=True),
        sa.Column("country", sa.String(), nullable=True, server_default="SN"),
        sa.Column("city", sa.String(), nullable=True),
        sa.Column("address", sa.Text(), nullable=True),
        sa.Column("latitude", sa.String(), nullable=True),
        sa.Column("longitude", sa.String(), nullable=True),
        sa.Column("profile_picture_url", sa.String(), nullable=True),
        sa.Column("language", sa.String(), nullable=True, server_default="fr"),
        sa.Column("role", user_role_enum, nullable=False, server_default="buyer_seller"),
        sa.Column("is_verified", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("is_seller_enabled", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("is_buyer_enabled", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column(
            "is_box_owner_enabled",
            sa.Boolean(),
            nullable=False,
            server_default=sa.false(),
        ),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=True),
        sa.Column("last_login", sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_users_id"), "users", ["id"], unique=False)
    op.create_index(op.f("ix_users_phone_number"), "users", ["phone_number"], unique=True)
    op.create_index(op.f("ix_users_email"), "users", ["email"], unique=True)

    op.create_table(
        "listings",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("seller_id", sa.String(), nullable=False),
        sa.Column("title", sa.String(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("price", sa.Float(), nullable=False),
        sa.Column("currency", sa.String(), nullable=False, server_default="XOF"),
        sa.Column("category", sa.String(), nullable=False),
        sa.Column("brand", sa.String(), nullable=True),
        sa.Column("size", sa.String(), nullable=True),
        sa.Column("condition", sa.String(), nullable=False, server_default="good"),
        sa.Column("cover_image_url", sa.String(), nullable=True),
        sa.Column("photo_urls", sa.Text(), nullable=True),
        sa.Column("location_label", sa.String(), nullable=True),
        sa.Column("seller_box_id", sa.String(), nullable=True),
        sa.Column("parcel_size", sa.String(), nullable=False, server_default="M"),
        sa.Column("is_negotiable", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("status", sa.String(), nullable=False, server_default="published"),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_listings_id"), "listings", ["id"], unique=False)
    op.create_index(op.f("ix_listings_seller_id"), "listings", ["seller_id"], unique=False)
    op.create_index(op.f("ix_listings_title"), "listings", ["title"], unique=False)
    op.create_index(op.f("ix_listings_category"), "listings", ["category"], unique=False)
    op.create_index(op.f("ix_listings_brand"), "listings", ["brand"], unique=False)
    op.create_index(op.f("ix_listings_seller_box_id"), "listings", ["seller_box_id"], unique=False)
    op.create_index(op.f("ix_listings_status"), "listings", ["status"], unique=False)

    op.create_table(
        "commerce_orders",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("listing_id", sa.String(), nullable=False),
        sa.Column("buyer_id", sa.String(), nullable=False),
        sa.Column("seller_id", sa.String(), nullable=False),
        sa.Column("buyer_box_id", sa.String(), nullable=True),
        sa.Column("seller_box_id", sa.String(), nullable=True),
        sa.Column("status", sa.String(), nullable=False, server_default="pending_payment"),
        sa.Column("item_price", sa.Float(), nullable=False),
        sa.Column("buyer_fee", sa.Float(), nullable=False, server_default="0"),
        sa.Column("logistics_fee", sa.Float(), nullable=False, server_default="0"),
        sa.Column("platform_fee", sa.Float(), nullable=False, server_default="0"),
        sa.Column("total_amount", sa.Float(), nullable=False),
        sa.Column("currency", sa.String(), nullable=False, server_default="XOF"),
        sa.Column("payment_status", sa.String(), nullable=False, server_default="pending"),
        sa.Column("escrow_status", sa.String(), nullable=False, server_default="pending"),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_commerce_orders_id"), "commerce_orders", ["id"], unique=False)
    op.create_index(
        op.f("ix_commerce_orders_listing_id"),
        "commerce_orders",
        ["listing_id"],
        unique=False,
    )
    op.create_index(op.f("ix_commerce_orders_buyer_id"), "commerce_orders", ["buyer_id"], unique=False)
    op.create_index(op.f("ix_commerce_orders_seller_id"), "commerce_orders", ["seller_id"], unique=False)
    op.create_index(
        op.f("ix_commerce_orders_buyer_box_id"),
        "commerce_orders",
        ["buyer_box_id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_commerce_orders_seller_box_id"),
        "commerce_orders",
        ["seller_box_id"],
        unique=False,
    )
    op.create_index(op.f("ix_commerce_orders_status"), "commerce_orders", ["status"], unique=False)

    op.create_table(
        "boxes",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("city", sa.String(), nullable=False),
        sa.Column("zone", sa.String(), nullable=False),
        sa.Column("address", sa.String(), nullable=True),
        sa.Column("latitude", sa.String(), nullable=True),
        sa.Column("longitude", sa.String(), nullable=True),
        sa.Column("owner_user_id", sa.String(), nullable=True),
        sa.Column("status", sa.String(), nullable=False, server_default="active"),
        sa.Column("total_lockers", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("available_lockers", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("supports_transit", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_boxes_id"), "boxes", ["id"], unique=False)
    op.create_index(op.f("ix_boxes_name"), "boxes", ["name"], unique=False)
    op.create_index(op.f("ix_boxes_city"), "boxes", ["city"], unique=False)
    op.create_index(op.f("ix_boxes_zone"), "boxes", ["zone"], unique=False)
    op.create_index(op.f("ix_boxes_owner_user_id"), "boxes", ["owner_user_id"], unique=False)
    op.create_index(op.f("ix_boxes_status"), "boxes", ["status"], unique=False)

    op.create_table(
        "parcels",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("order_id", sa.String(), nullable=False),
        sa.Column("listing_id", sa.String(), nullable=False),
        sa.Column("seller_id", sa.String(), nullable=False),
        sa.Column("buyer_id", sa.String(), nullable=False),
        sa.Column("origin_box_id", sa.String(), nullable=True),
        sa.Column("destination_box_id", sa.String(), nullable=True),
        sa.Column("current_box_id", sa.String(), nullable=True),
        sa.Column("parcel_size", sa.String(), nullable=False, server_default="M"),
        sa.Column("delivery_mode", sa.String(), nullable=False, server_default="same_zone"),
        sa.Column("status", sa.String(), nullable=False, server_default="awaiting_dropoff"),
        sa.Column(
            "locker_state",
            sa.String(),
            nullable=False,
            server_default="reserved_for_deposit",
        ),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("order_id"),
    )
    op.create_index(op.f("ix_parcels_id"), "parcels", ["id"], unique=False)
    op.create_index(op.f("ix_parcels_order_id"), "parcels", ["order_id"], unique=True)
    op.create_index(op.f("ix_parcels_listing_id"), "parcels", ["listing_id"], unique=False)
    op.create_index(op.f("ix_parcels_seller_id"), "parcels", ["seller_id"], unique=False)
    op.create_index(op.f("ix_parcels_buyer_id"), "parcels", ["buyer_id"], unique=False)
    op.create_index(op.f("ix_parcels_origin_box_id"), "parcels", ["origin_box_id"], unique=False)
    op.create_index(
        op.f("ix_parcels_destination_box_id"),
        "parcels",
        ["destination_box_id"],
        unique=False,
    )
    op.create_index(op.f("ix_parcels_current_box_id"), "parcels", ["current_box_id"], unique=False)
    op.create_index(op.f("ix_parcels_delivery_mode"), "parcels", ["delivery_mode"], unique=False)
    op.create_index(op.f("ix_parcels_status"), "parcels", ["status"], unique=False)
    op.create_index(op.f("ix_parcels_locker_state"), "parcels", ["locker_state"], unique=False)

    op.create_table(
        "shipments",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("parcel_id", sa.String(), nullable=False),
        sa.Column("origin_box_id", sa.String(), nullable=True),
        sa.Column("destination_box_id", sa.String(), nullable=True),
        sa.Column("route_code", sa.String(), nullable=True),
        sa.Column("vehicle_code", sa.String(), nullable=True),
        sa.Column("status", sa.String(), nullable=False, server_default="planned"),
        sa.Column("distance_km", sa.Float(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_shipments_id"), "shipments", ["id"], unique=False)
    op.create_index(op.f("ix_shipments_parcel_id"), "shipments", ["parcel_id"], unique=False)
    op.create_index(
        op.f("ix_shipments_origin_box_id"),
        "shipments",
        ["origin_box_id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_shipments_destination_box_id"),
        "shipments",
        ["destination_box_id"],
        unique=False,
    )
    op.create_index(op.f("ix_shipments_route_code"), "shipments", ["route_code"], unique=False)
    op.create_index(op.f("ix_shipments_vehicle_code"), "shipments", ["vehicle_code"], unique=False)
    op.create_index(op.f("ix_shipments_status"), "shipments", ["status"], unique=False)


def downgrade() -> None:
    op.drop_index(op.f("ix_shipments_status"), table_name="shipments")
    op.drop_index(op.f("ix_shipments_vehicle_code"), table_name="shipments")
    op.drop_index(op.f("ix_shipments_route_code"), table_name="shipments")
    op.drop_index(op.f("ix_shipments_destination_box_id"), table_name="shipments")
    op.drop_index(op.f("ix_shipments_origin_box_id"), table_name="shipments")
    op.drop_index(op.f("ix_shipments_parcel_id"), table_name="shipments")
    op.drop_index(op.f("ix_shipments_id"), table_name="shipments")
    op.drop_table("shipments")

    op.drop_index(op.f("ix_parcels_locker_state"), table_name="parcels")
    op.drop_index(op.f("ix_parcels_status"), table_name="parcels")
    op.drop_index(op.f("ix_parcels_delivery_mode"), table_name="parcels")
    op.drop_index(op.f("ix_parcels_current_box_id"), table_name="parcels")
    op.drop_index(op.f("ix_parcels_destination_box_id"), table_name="parcels")
    op.drop_index(op.f("ix_parcels_origin_box_id"), table_name="parcels")
    op.drop_index(op.f("ix_parcels_buyer_id"), table_name="parcels")
    op.drop_index(op.f("ix_parcels_seller_id"), table_name="parcels")
    op.drop_index(op.f("ix_parcels_listing_id"), table_name="parcels")
    op.drop_index(op.f("ix_parcels_order_id"), table_name="parcels")
    op.drop_index(op.f("ix_parcels_id"), table_name="parcels")
    op.drop_table("parcels")

    op.drop_index(op.f("ix_boxes_status"), table_name="boxes")
    op.drop_index(op.f("ix_boxes_owner_user_id"), table_name="boxes")
    op.drop_index(op.f("ix_boxes_zone"), table_name="boxes")
    op.drop_index(op.f("ix_boxes_city"), table_name="boxes")
    op.drop_index(op.f("ix_boxes_name"), table_name="boxes")
    op.drop_index(op.f("ix_boxes_id"), table_name="boxes")
    op.drop_table("boxes")

    op.drop_index(op.f("ix_commerce_orders_status"), table_name="commerce_orders")
    op.drop_index(op.f("ix_commerce_orders_seller_box_id"), table_name="commerce_orders")
    op.drop_index(op.f("ix_commerce_orders_buyer_box_id"), table_name="commerce_orders")
    op.drop_index(op.f("ix_commerce_orders_seller_id"), table_name="commerce_orders")
    op.drop_index(op.f("ix_commerce_orders_buyer_id"), table_name="commerce_orders")
    op.drop_index(op.f("ix_commerce_orders_listing_id"), table_name="commerce_orders")
    op.drop_index(op.f("ix_commerce_orders_id"), table_name="commerce_orders")
    op.drop_table("commerce_orders")

    op.drop_index(op.f("ix_listings_status"), table_name="listings")
    op.drop_index(op.f("ix_listings_seller_box_id"), table_name="listings")
    op.drop_index(op.f("ix_listings_brand"), table_name="listings")
    op.drop_index(op.f("ix_listings_category"), table_name="listings")
    op.drop_index(op.f("ix_listings_title"), table_name="listings")
    op.drop_index(op.f("ix_listings_seller_id"), table_name="listings")
    op.drop_index(op.f("ix_listings_id"), table_name="listings")
    op.drop_table("listings")

    op.drop_index(op.f("ix_users_email"), table_name="users")
    op.drop_index(op.f("ix_users_phone_number"), table_name="users")
    op.drop_index(op.f("ix_users_id"), table_name="users")
    op.drop_table("users")

    user_role_enum.drop(op.get_bind(), checkfirst=True)
