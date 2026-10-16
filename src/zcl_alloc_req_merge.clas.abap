CLASS zcl_alloc_req_merge DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS merge
      IMPORTING
        it_requirements  TYPE zif_requirement_reader=>ty_requirement_tt
      RETURNING
        VALUE(rt_merged) TYPE zif_requirement_reader=>ty_requirement_tt.

ENDCLASS.


CLASS zcl_alloc_req_merge IMPLEMENTATION.

  METHOD merge.
    DATA lt_sorted  TYPE zif_requirement_reader=>ty_requirement_tt.
    DATA ls_merged  TYPE zif_requirement_reader=>ty_requirement.
    DATA lv_started TYPE abap_bool.

    lt_sorted = it_requirements.
    SORT lt_sorted BY id ASCENDING.

    LOOP AT lt_sorted INTO DATA(ls_requirement).
      IF lv_started = abap_false OR ls_requirement-id <> ls_merged-id.
        IF lv_started = abap_true.
          APPEND ls_merged TO rt_merged.
        ENDIF.
        CLEAR ls_merged.
        ls_merged = ls_requirement.
        lv_started = abap_true.
      ELSE.
        ls_merged-requested_qty = ls_merged-requested_qty
          + ls_requirement-requested_qty.
      ENDIF.
    ENDLOOP.

    IF lv_started = abap_true.
      APPEND ls_merged TO rt_merged.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
