from app.repositories.blood_repository import BloodRepository
from app.repositories.doctor_repository import DoctorRepository
from app.repositories.donor_repository import DonorRepository
from app.repositories.hospital_repository import HospitalRepository
from app.repositories.user_repository import UserRepository
from app.schemas.admin import AdminStats


class AdminService:
    def __init__(self, users: UserRepository, donors: DonorRepository,
                 blood: BloodRepository, hospitals: HospitalRepository,
                 doctors: DoctorRepository) -> None:
        self.users = users
        self.donors = donors
        self.blood = blood
        self.hospitals = hospitals
        self.doctors = doctors

    async def stats(self) -> AdminStats:
        return AdminStats(
            total_donors=await self.donors.count(),
            available_blood_units=await self.blood.total_units(),
            total_blood_requests=await self.blood.count_requests(),
            registered_hospitals=await self.hospitals.count(),
            pending_requests=await self.blood.count_requests("pending"),
            total_users=await self.users.count(),
        )

    async def all_users(self):
        return await self.users.all_profiles()
