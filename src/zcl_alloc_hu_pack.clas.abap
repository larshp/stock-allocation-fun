CLASS zcl_alloc_hu_pack DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_unit,
             unit_no  TYPE i,
             quantity TYPE menge_d,
           END OF ty_unit.
    TYPES ty_unit_tt TYPE STANDARD TABLE OF ty_unit WITH DEFAULT KEY.

    METHODS pack
      IMPORTING
        iv_quantity     TYPE menge_d
        iv_capacity     TYPE menge_d
      RETURNING
        VALUE(rt_units) TYPE ty_unit_tt.

    METHODS unit_count
      IMPORTING
        it_units        TYPE ty_unit_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_hu_pack IMPLEMENTATION.

  METHOD pack.
    DATA ls_unit TYPE ty_unit.
    DATA lv_left TYPE menge_d.
    DATA lv_fill TYPE menge_d.

    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    " A non-positive capacity means "do not split": everything goes into one
    " handling unit instead of looping forever.
    IF iv_capacity <= 0.
      ls_unit-unit_no = 1.
      ls_unit-quantity = iv_quantity.
      APPEND ls_unit TO rt_units.
      RETURN.
    ENDIF.

    lv_left = iv_quantity.
    WHILE lv_left > 0.
      IF lv_left < iv_capacity.
        lv_fill = lv_left.
      ELSE.
        lv_fill = iv_capacity.
      ENDIF.

      CLEAR ls_unit.
      ls_unit-unit_no = lines( rt_units ) + 1.
      ls_unit-quantity = lv_fill.
      APPEND ls_unit TO rt_units.

      lv_left = lv_left - lv_fill.
    ENDWHILE.
  ENDMETHOD.

  METHOD unit_count.
    rv_count = lines( it_units ).
  ENDMETHOD.

ENDCLASS.
