
from typing import Optional

from fastapi import APIRouter, Depends, Request, Response

from .auth import require_auth
from .db import conn, now_iso
from .errors import (
    json_response,
    not_found,
    read_json_body,
    string_field,
    validation_error,
)

router = APIRouter()


# Преобразование SQLite в JSON для Flutter
def _to_json(row):
    return {
        "id": row["id"],
        "petId": row["pet_id"],
        "date": row["date"],
        "reason": row["reason"],
        "diagnosis": row["diagnosis"],
        "cost": float(row["cost"]),
        "createdAt": row["created_at"],
    }


# Поиск посещения текущего пользователя
def _find(user_id: int, visit_id: str):
    try:
        parsed_id = int(visit_id)
    except (TypeError, ValueError):
        return None

    return conn.execute(
        "SELECT * FROM vet_visits WHERE id = ? AND user_id = ?",
        (parsed_id, user_id),
    ).fetchone()


def _int_or(value: Optional[str], default: int) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


# Проверка данных посещения
def _validate(body, user_id):
    pet_id = body.get("petId")

    if type(pet_id) is not int or pet_id <= 0:
        raise validation_error("Valid petId is required")

    pet = conn.execute(
        "SELECT id FROM pets WHERE id = ? AND user_id = ?",
        (pet_id, user_id),
    ).fetchone()

    if pet is None:
        raise not_found("Pet not found")

    date = string_field(body, "date")
    reason = string_field(body, "reason")
    diagnosis = body.get("diagnosis", "")
    cost = body.get("cost", 0)

    if not date or not reason:
        raise validation_error("Date and reason are required")

    if not isinstance(diagnosis, str):
        raise validation_error("Invalid diagnosis")

    if type(cost) not in (int, float) or not (0 <= cost < 1e12):
        raise validation_error("Invalid cost")

    return pet_id, date, reason, diagnosis, float(cost)


# GET /vet-visits — список, поиск, пагинация
@router.get("/vet-visits")
async def list_visits(
    request: Request,
    user_id: int = Depends(require_auth),
):
    query = request.query_params

    page = max(_int_or(query.get("page"), 1), 1)
    limit = min(max(_int_or(query.get("limit"), 20), 1), 100)
    search = query.get("search", "")

    where = "user_id = ? AND (reason LIKE ? OR diagnosis LIKE ?)"
    args = [user_id, f"%{search}%", f"%{search}%"]

    if query.get("petId") is not None:
        try:
            pet_id = int(query["petId"])
        except ValueError:
            raise validation_error("Invalid petId")

        where += " AND pet_id = ?"
        args.append(pet_id)

    total = conn.execute(
        "SELECT COUNT(*) AS n FROM vet_visits WHERE " + where,
        args,
    ).fetchone()["n"]

    rows = conn.execute(
        "SELECT * FROM vet_visits WHERE " + where
        + " ORDER BY id DESC LIMIT ? OFFSET ?",
        args + [limit, (page - 1) * limit],
    ).fetchall()

    return json_response({
        "items": [_to_json(row) for row in rows],
        "page": page,
        "limit": limit,
        "total": total,
    })


# POST /vet-visits — создание посещения
@router.post("/vet-visits")
async def create_visit(
    request: Request,
    user_id: int = Depends(require_auth),
):
    body = await read_json_body(request)

    if body is None:
        raise validation_error("Invalid JSON")

    pet_id, date, reason, diagnosis, cost = _validate(body, user_id)

    cursor = conn.execute(
        """INSERT INTO vet_visits
           (user_id, pet_id, date, reason, diagnosis, cost, created_at)
           VALUES (?, ?, ?, ?, ?, ?, ?)""",
        (user_id, pet_id, date, reason, diagnosis, cost, now_iso()),
    )

    row = _find(user_id, str(cursor.lastrowid))
    return json_response(_to_json(row), status=201)


# GET /vet-visits/{id}
@router.get("/vet-visits/{visit_id}")
async def get_visit(
    visit_id: str,
    user_id: int = Depends(require_auth),
):
    row = _find(user_id, visit_id)

    if row is None:
        raise not_found("Visit not found")

    return json_response(_to_json(row))


# PUT /vet-visits/{id}
@router.put("/vet-visits/{visit_id}")
async def update_visit(
    visit_id: str,
    request: Request,
    user_id: int = Depends(require_auth),
):
    row = _find(user_id, visit_id)

    if row is None:
        raise not_found("Visit not found")

    body = await read_json_body(request)

    if body is None:
        raise validation_error("Invalid JSON")

    pet_id, date, reason, diagnosis, cost = _validate(body, user_id)

    conn.execute(
        """UPDATE vet_visits
           SET pet_id = ?, date = ?, reason = ?, diagnosis = ?, cost = ?
           WHERE id = ? AND user_id = ?""",
        (pet_id, date, reason, diagnosis, cost, row["id"], user_id),
    )

    updated = _find(user_id, visit_id)
    return json_response(_to_json(updated))


# DELETE /vet-visits/{id}
@router.delete("/vet-visits/{visit_id}")
async def delete_visit(
    visit_id: str,
    user_id: int = Depends(require_auth),
):
    row = _find(user_id, visit_id)

    if row is None:
        raise not_found("Visit not found")

    conn.execute(
        "DELETE FROM vet_visits WHERE id = ? AND user_id = ?",
        (row["id"], user_id),
    )

    return Response(status_code=204)
