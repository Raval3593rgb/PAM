
from fastapi import APIRouter, Depends, Request, Response

from .auth import require_auth
from .db import conn, now_iso
from .errors import (
    json_response, not_found, read_json_body,
    string_field, validation_error
)

router = APIRouter()


def _to_json(row):
    return {
        "id": row["id"],
        "petId": row["pet_id"],
        "name": row["name"],
        "date": row["date"],
        "nextDueDate": row["next_due_date"],
        "createdAt": row["created_at"],
    }


def _find(user_id, vaccination_id):
    try:
        record_id = int(vaccination_id)
    except (TypeError, ValueError):
        return None

    return conn.execute(
        "SELECT * FROM vaccinations WHERE id = ? AND user_id = ?",
        (record_id, user_id)
    ).fetchone()


def _validate(body, user_id):
    pet_id = body.get("petId")

    if type(pet_id) is not int or pet_id <= 0:
        raise validation_error("Valid petId is required")

    pet = conn.execute(
        "SELECT id FROM pets WHERE id = ? AND user_id = ?",
        (pet_id, user_id)
    ).fetchone()

    if pet is None:
        raise not_found("Pet not found")

    name = string_field(body, "name")
    date = string_field(body, "date")
    next_date = string_field(body, "nextDueDate")

    if not all([name, date, next_date]):
        raise validation_error("Missing vaccination fields")

    return pet_id, name, date, next_date


# GET /vaccinations — список и поиск
@router.get("/vaccinations")
async def list_vaccinations(
    request: Request,
    user_id: int = Depends(require_auth)
):
    query = request.query_params

    try:
        page = max(int(query.get("page", 1)), 1)
        limit = min(max(int(query.get("limit", 20)), 1), 100)
    except ValueError:
        raise validation_error("Invalid pagination")

    search = query.get("search", "")

    where = "user_id = ? AND name LIKE ?"
    args = [user_id, f"%{search}%"]

    if query.get("petId") is not None:
        try:
            pet_id = int(query["petId"])
        except ValueError:
            raise validation_error("Invalid petId")

        where += " AND pet_id = ?"
        args.append(pet_id)

    total = conn.execute(
        "SELECT COUNT(*) AS n FROM vaccinations WHERE " + where,
        args
    ).fetchone()["n"]

    rows = conn.execute(
        "SELECT * FROM vaccinations WHERE " + where
        + " ORDER BY id DESC LIMIT ? OFFSET ?",
        args + [limit, (page - 1) * limit]
    ).fetchall()

    return json_response({
        "items": [_to_json(row) for row in rows],
        "page": page,
        "limit": limit,
        "total": total,
    })


# POST /vaccinations — создание
@router.post("/vaccinations")
async def create_vaccination(
    request: Request,
    user_id: int = Depends(require_auth)
):
    body = await read_json_body(request)

    if body is None:
        raise validation_error("Invalid JSON")

    pet_id, name, date, next_date = _validate(body, user_id)

    cursor = conn.execute(
        """INSERT INTO vaccinations
           (user_id, pet_id, name, date, next_due_date, created_at)
           VALUES (?, ?, ?, ?, ?, ?)""",
        (user_id, pet_id, name, date, next_date, now_iso())
    )

    row = _find(user_id, cursor.lastrowid)
    return json_response(_to_json(row), status=201)


# GET /vaccinations/{id}
@router.get("/vaccinations/{vaccination_id}")
async def get_vaccination(
    vaccination_id: str,
    user_id: int = Depends(require_auth)
):
    row = _find(user_id, vaccination_id)

    if row is None:
        raise not_found("Vaccination not found")

    return json_response(_to_json(row))


# PUT /vaccinations/{id}
@router.put("/vaccinations/{vaccination_id}")
async def update_vaccination(
    vaccination_id: str,
    request: Request,
    user_id: int = Depends(require_auth)
):
    row = _find(user_id, vaccination_id)

    if row is None:
        raise not_found("Vaccination not found")

    body = await read_json_body(request)

    if body is None:
        raise validation_error("Invalid JSON")

    pet_id, name, date, next_date = _validate(body, user_id)

    conn.execute(
        """UPDATE vaccinations
           SET pet_id = ?, name = ?, date = ?, next_due_date = ?
           WHERE id = ? AND user_id = ?""",
        (pet_id, name, date, next_date, row["id"], user_id)
    )

    updated = _find(user_id, vaccination_id)
    return json_response(_to_json(updated))


# DELETE /vaccinations/{id}
@router.delete("/vaccinations/{vaccination_id}")
async def delete_vaccination(
    vaccination_id: str,
    user_id: int = Depends(require_auth)
):
    row = _find(user_id, vaccination_id)

    if row is None:
        raise not_found("Vaccination not found")

    conn.execute(
        "DELETE FROM vaccinations WHERE id = ? AND user_id = ?",
        (row["id"], user_id)
    )

    return Response(status_code=204)
