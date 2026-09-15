CLASS zcl_alloc_req_split DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS split
      IMPORTING
        is_requirement  TYPE zif_requirement_reader=>ty_requirement
        iv_max_qty      TYPE menge_d
      RETURNING
        VALUE(rt_parts) TYPE zif_requirement_reader=>ty_requirement_tt.

ENDCLASS.


CLASS zcl_alloc_req_split IMPLEMENTATION.

  METHOD split.
    DATA ls_part      TYPE zif_requirement_reader=>ty_requirement.
    DATA lv_remaining TYPE menge_d.
    DATA lv_qty       TYPE menge_d.

    IF iv_max_qty <= 0.
      APPEND is_requirement TO rt_parts.
      RETURN.
    ENDIF.

    lv_remaining = is_requirement-requested_qty.
    IF lv_remaining <= 0.
      APPEND is_requirement TO rt_parts.
      RETURN.
    ENDIF.

    WHILE lv_remaining > 0.
      lv_qty = iv_max_qty.
      IF lv_qty > lv_remaining.
        lv_qty = lv_remaining.
      ENDIF.

      CLEAR ls_part.
      ls_part = is_requirement.
      ls_part-requested_qty = lv_qty.
      APPEND ls_part TO rt_parts.

      lv_remaining = lv_remaining - lv_qty.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
