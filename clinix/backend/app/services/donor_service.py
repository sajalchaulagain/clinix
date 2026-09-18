"""Donor workflows.

Privacy rule (design, not config): donor phone numbers are NEVER stored in
donor profiles and never returned by any donor endpoint. Contact is mediated
by the platform via notifications.
"""
from app.repositories.donor_repository import DonorRepository
from app.repositories.notification_repository import NotificationRepository
from app.schemas.donor import BecomeDonorRequest


class DonorService:
    def __init__(self, donors: DonorRepository, notifications: NotificationRepository) -> None:
        self.donors = donors
        self.notifications = notifications

    async def register(self, uid: str, name: str, payload: BecomeDonorRequest) -> dict:
        return await self.donors.upsert_profile(uid, name, payload.model_dump())

    async def set_availability(self, uid: str, is_available: bool,
                               last_donation_date=None) -> dict | None:
        return await self.donors.update_availability(uid, is_available, last_donation_date)

    async def request_contact(self, donor_id: str, requester_name: str,
                              requester_uid: str, note: str | None) -> dict | None:
        donor = await self.donors.get(donor_id)
        if donor is None:
            return None
        # Mediated ping: donor is notified; their contact details stay private.
        await self.notifications.create(
            donor_id,
            {
                "type": "bloodRequest",
                "title": "Blood donation interest",
                "body": (f"{requester_name or 'A CliniX user'} would like to connect with you "
                          f"about a blood donation."
                          + (f" Note: {note}" if note else "")),
                "payload": {"kind": "donor_contact", "requester_uid": requester_uid},
            },
        )
        return donor
