CLASS zcl_alloc_load_seq DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_unit,
             unit_id TYPE string,
             weight  TYPE i,
             fragile TYPE abap_bool,
           END OF ty_unit.
    TYPES ty_unit_tt TYPE STANDARD TABLE OF ty_unit WITH DEFAULT KEY.

    METHODS order
      IMPORTING
        it_units        TYPE ty_unit_tt
      RETURNING
        VALUE(rt_units) TYPE ty_unit_tt.

ENDCLASS.


CLASS zcl_alloc_load_seq IMPLEMENTATION.

  METHOD order.
    DATA lt_heavy TYPE ty_unit_tt.
    DATA lt_frag  TYPE ty_unit_tt.

    " A stable load puts the heavy, non-fragile units at the bottom and the
    " fragile ones on top. Splitting the input first keeps the two rules from
    " having to be expressed in one sort key.
    LOOP AT it_units INTO DATA(ls_unit).
      IF ls_unit-fragile = abap_true.
        APPEND ls_unit TO lt_frag.
      ELSE.
        APPEND ls_unit TO lt_heavy.
      ENDIF.
    ENDLOOP.

    SORT lt_heavy BY weight DESCENDING
                     unit_id ASCENDING.
    SORT lt_frag BY weight ASCENDING
                    unit_id ASCENDING.

    rt_units = lt_heavy.
    APPEND LINES OF lt_frag TO rt_units.
  ENDMETHOD.

ENDCLASS.
