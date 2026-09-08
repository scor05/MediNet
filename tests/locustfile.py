import os
import random
from datetime import date, timedelta

from locust import HttpUser, between, task


class MediNetPatientUser(HttpUser):
    """Patient workload for a local or disposable MediNet environment."""

    wait_time = between(1, 3)

    def on_start(self):
        token = os.environ.get("TEST_TOKEN")
        if not token:
            raise RuntimeError(
                "TEST_TOKEN is required. Export a temporary Supabase access "
                "token before starting Locust."
            )

        self.client.headers.update(
            {
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization": f"Bearer {token}",
            }
        )

        self.patient_id = None
        self.patient_name = None
        self.doctor_id = None
        self.clinic_id = None
        self.has_booked = False
        self.booking_enabled = (
            os.environ.get("LOCUST_ENABLE_BOOKING", "false").lower() == "true"
        )

        self._load_profile(name="/api/profile [session setup]")

    def _load_profile(self, name="/api/profile"):
        with self.client.get("/api/profile", name=name, catch_response=True) as response:
            if response.status_code != 200:
                response.failure(f"Profile returned HTTP {response.status_code}")
                return None

            try:
                profile = response.json()
                self.patient_id = profile["id"]
                self.patient_name = profile["name"]
            except (ValueError, KeyError, TypeError):
                response.failure("Profile response did not contain id and name")
                return None

            return profile

    def _load_doctors(self):
        with self.client.get(
            "/api/public/doctors",
            name="/api/public/doctors",
            catch_response=True,
        ) as response:
            if response.status_code != 200:
                response.failure(f"Doctors returned HTTP {response.status_code}")
                return []

            try:
                doctors = response.json()
                if not isinstance(doctors, list):
                    raise TypeError
            except (ValueError, TypeError):
                response.failure("Doctors response was not a JSON list")
                return []

            if doctors:
                selected_doctor_id = random.choice(doctors)["id"]
                if selected_doctor_id != self.doctor_id:
                    self.doctor_id = selected_doctor_id
                    self.clinic_id = None

            return doctors

    def _load_clinics(self, doctor_id=None):
        params = {"doctor_id": doctor_id} if doctor_id is not None else None

        with self.client.get(
            "/api/public/clinics",
            params=params,
            name="/api/public/clinics",
            catch_response=True,
        ) as response:
            if response.status_code != 200:
                response.failure(f"Clinics returned HTTP {response.status_code}")
                return []

            try:
                clinics = response.json()
                if not isinstance(clinics, list):
                    raise TypeError
            except (ValueError, TypeError):
                response.failure("Clinics response was not a JSON list")
                return []

            if clinics:
                self.clinic_id = random.choice(clinics)["id"]

            return clinics

    def _find_free_slot(self):
        if self.doctor_id is None and not self._load_doctors():
            return None

        if not self._load_clinics(self.doctor_id):
            return None

        first_day = date.today() + timedelta(days=1)
        candidate_days = [first_day + timedelta(days=offset) for offset in range(14)]
        random.shuffle(candidate_days)

        for appointment_date in candidate_days:
            with self.client.get(
                "/api/public/slots",
                params={
                    "doctor_id": self.doctor_id,
                    "clinic_id": self.clinic_id,
                    "date": appointment_date.isoformat(),
                },
                name="/api/public/slots",
                catch_response=True,
            ) as response:
                if response.status_code != 200:
                    response.failure(f"Slots returned HTTP {response.status_code}")
                    continue

                try:
                    free_slots = [
                        slot
                        for slot in response.json()
                        if not slot.get("is_occupied", False)
                    ]
                except (ValueError, TypeError, AttributeError):
                    response.failure("Slots response was not a valid JSON list")
                    continue

                if free_slots:
                    return appointment_date, random.choice(free_slots)

        return None

    @task(1)
    def ping(self):
        with self.client.get(
            "/api/ping", name="/api/ping", catch_response=True
        ) as response:
            if response.status_code != 200:
                response.failure(f"Ping returned HTTP {response.status_code}")
                return

            try:
                if response.json().get("message") != "pong":
                    response.failure("Unexpected ping response")
            except (ValueError, AttributeError):
                response.failure("Ping response was not valid JSON")

    @task(1)
    def profile(self):
        self._load_profile()

    @task(4)
    def public_doctors(self):
        self._load_doctors()

    @task(4)
    def public_clinics(self):
        self._load_clinics(self.doctor_id)

    @task(6)
    def public_calendar(self):
        date_from = date.today()
        date_to = date_from + timedelta(days=13)
        params = {
            "date_from": date_from.isoformat(),
            "date_to": date_to.isoformat(),
        }
        if self.doctor_id is not None:
            params["doctor_id"] = self.doctor_id
        if self.clinic_id is not None:
            params["clinic_id"] = self.clinic_id

        self.client.get(
            "/api/calendar/public",
            params=params,
            name="/api/calendar/public",
        )

    """
    # una cita por cada paciente simulado
    @task(1)
    def create_appointment(self):
        if not self.booking_enabled or self.has_booked:
            return

        if self.patient_id is None or self.patient_name is None:
            if self._load_profile() is None:
                return

        selection = self._find_free_slot()
        if selection is None:
            return

        appointment_date, slot = selection
        with self.client.post(
            "/api/public/appointments",
            name="/api/public/appointments",
            json={
                "id_schedule": slot["schedule_id"],
                "id_patient": self.patient_id,
                "name_patient": self.patient_name,
                "date": appointment_date.isoformat(),
                "start_time": slot["start_time"][:5],
            },
            catch_response=True,
        ) as response:
            if response.status_code == 201:
                self.has_booked = True
            elif response.status_code == 422:
                response.failure("Selected slot became unavailable")
            else:
                response.failure(f"Appointment returned HTTP {response.status_code}")

        """
