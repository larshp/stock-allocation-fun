CLASS zcl_alloc_conf_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        is_confidence  TYPE zcl_alloc_confidence=>ty_confidence
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_conf_json IMPLEMENTATION.

  METHOD build.
    rv_json = '{'.
    rv_json = rv_json && |"requirements":{ is_confidence-requirements },|.
    rv_json = rv_json && |"coverage_pct":{ is_confidence-coverage_pct },|.
    rv_json = rv_json && |"fill_rate_pct":{ is_confidence-fill_rate_pct },|.
    rv_json = rv_json && |"score":{ is_confidence-score }|.
    rv_json = rv_json && '}'.
  ENDMETHOD.

ENDCLASS.
