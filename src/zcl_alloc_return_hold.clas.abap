CLASS zcl_alloc_return_hold DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_hold,
             material TYPE matnr,
             reason   TYPE string,
           END OF ty_hold.
    TYPES ty_hold_tt TYPE STANDARD TABLE OF ty_hold WITH DEFAULT KEY.

    METHODS place
      IMPORTING
        it_holds        TYPE ty_hold_tt
        iv_material     TYPE matnr
        iv_reason       TYPE string
      RETURNING
        VALUE(rt_holds) TYPE ty_hold_tt.

    METHODS is_on_hold
      IMPORTING
        it_holds     TYPE ty_hold_tt
        iv_material  TYPE matnr
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS hold_count
      IMPORTING
        it_holds        TYPE ty_hold_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_hold IMPLEMENTATION.

  METHOD place.
    DATA ls_hold TYPE ty_hold.

    " A hold needs both a material and a reason; anything else leaves the set as
    " it was.
    rt_holds = it_holds.

    IF iv_material IS INITIAL OR iv_reason IS INITIAL.
      RETURN.
    ENDIF.

    ls_hold-material = iv_material.
    ls_hold-reason = iv_reason.
    APPEND ls_hold TO rt_holds.
  ENDMETHOD.

  METHOD is_on_hold.
    LOOP AT it_holds INTO DATA(ls_hold).
      IF ls_hold-material = iv_material.
        rv_ok = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD hold_count.
    rv_count = lines( it_holds ).
  ENDMETHOD.

ENDCLASS.
