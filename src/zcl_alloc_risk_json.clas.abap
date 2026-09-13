CLASS zcl_alloc_risk_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        is_risk        TYPE zcl_alloc_risk=>ty_risk
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_risk_json IMPLEMENTATION.

  METHOD build.
    rv_json = '{'.
    rv_json = rv_json && |"lines":{ is_risk-lines },|.
    rv_json = rv_json && |"shortage_qty":{ is_risk-shortage_qty },|.
    rv_json = rv_json && |"risk_pct":{ is_risk-risk_pct },|.
    rv_json = rv_json && |"level":"{ is_risk-level }"|.
    rv_json = rv_json && '}'.
  ENDMETHOD.

ENDCLASS.
