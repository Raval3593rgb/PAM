
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


# Преобразование записи SQLite в JSON для Flutter
def _to_json(row):
    return {
        "id": row["id"],
        "ownerId": row["user_id"],
        "name": row["name"],
        "species": row["species"],
        "birthDate": row["birth_date"],
        "photoUrl": row["photo_url"],
        "createdAt": row["created_at"],
    }


# Поиск питомца, принадлежащего текущему пользователю
def _find(user_id: int, pet_id: str):
    try:
        parsed_id = int(pet_id)
    except (TypeError, ValueError):
        return None

    return conn.execute(
        "SELECT * FROM pets WHERE id = ? AND user_id = ?",
        (parsed_id, user_id),
    ).fetchone()


def _int_or(value: Optional[str], default: int) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def _pet_data(body):
    name = string_field(body, "name")
    species = string_field(body, "species")

    if name is None or species is None:
        raise validation_error("name and species are required")

    birth_date = body.get("birthDate", "")
    photo_url = body.get("photoUrl", "")

    if not isinstance(birth_date, str) or not isinstance(photo_url, str):
        raise validation_error("Invalid pet fields")

    return name, species, birth_date, photo_url


# GET /pets — список, поиск, пагинация
@router.get("/pets")
async def list_pets(request: Request, user_id: int = Depends(require_auth)):
    query = request.query_params

    page = max(_int_or(query.get("page"), 1), 1)
    limit = min(max(_int_or(query.get("limit"), 20), 1), 100)
    search = query.get("search", "")

    where = "user_id = ? AND (name LIKE ? OR species LIKE ?)"
    args = (user_id, f"%{search}%", f"%{search}%")

    total = conn.execute(
        "SELECT COUNT(*) AS n FROM pets WHERE " + where, args
    ).fetchone()["n"]

    rows = conn.execute(
        "SELECT * FROM pets WHERE " + where
        + " ORDER BY id DESC LIMIT ? OFFSET ?",
        args + (limit, (page - 1) * limit),
    ).fetchall()

    return json_response({
        "items": [_to_json(row) for row in rows],
        "page": page,
        "limit": limit,
        "total": total,
    })


# POST /pets — создание питомца
@router.post("/pets")
async def create_pet(request: Request, user_id: int = Depends(require_auth)):
    body = await read_json_body(request)

    if body is None:
        raise validation_error("Body must be a JSON object")

    name, species, birth_date, photo_url = _pet_data(body)

    cursor = conn.execute(
        """INSERT INTO pets
           (user_id, name, species, birth_date, photo_url, created_at)
           VALUES (?, ?, ?, ?, ?, ?)""",
        (user_id, name, species, birth_date, photo_url, now_iso()),
    )

    row = _find(user_id, str(cursor.lastrowid))
    return json_response(_to_json(row), status=201)


# GET /pets/{id} — получение питомца
@router.get("/pets/{pet_id}")
async def get_pet(pet_id: str, user_id: int = Depends(require_auth)):
    row = _find(user_id, pet_id)

    if row is None:
        raise not_found("Pet not found")

    return json_response(_to_json(row))


# PUT /pets/{id} — обновление питомца
@router.put("/pets/{pet_id}")
async def update_pet(
    pet_id: str,
    request: Request,
    user_id: int = Depends(require_auth),
):
    row = _find(user_id, pet_id)

    if row is None:
        raise not_found("Pet not found")

    body = await read_json_body(request)

    if body is None:
        raise validation_error("Body must be a JSON object")

    name, species, birth_date, photo_url = _pet_data(body)

    conn.execute(
        """UPDATE pets
           SET name = ?, species = ?, birth_date = ?, photo_url = ?
           WHERE id = ? AND user_id = ?""",
        (name, species, birth_date, photo_url, row["id"], user_id),
    )

    updated = _find(user_id, pet_id)
    return json_response(_to_json(updated))


# DELETE /pets/{id} — удаление питомца
@router.delete("/pets/{pet_id}")
async def delete_pet(pet_id: str, user_id: int = Depends(require_auth)):
    row = _find(user_id, pet_id)

    if row is None:
        raise not_found("Pet not found")

    conn.execute(
        "DELETE FROM pets WHERE id = ? AND user_id = ?",
        (row["id"], user_id),
    )

    return Response(status_code=204)
