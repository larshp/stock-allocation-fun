CLASS zcl_alloc_bom_compare DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             component TYPE string,
             qty       TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS compare
      IMPORTING
        it_before        TYPE ty_line_tt
        it_after         TYPE ty_line_tt
      RETURNING
        VALUE(rv_choice) TYPE string.

    METHODS added
      IMPORTING
        it_before       TYPE ty_line_tt
        it_after        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS removed
      IMPORTING
        it_before       TYPE ty_line_tt
        it_after        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_bom_compare IMPLEMENTATION.

  METHOD compare.
    " The BOM is unchanged while nothing has been added or removed.
    IF added( it_before = it_before it_after = it_after ) = 0
       AND removed( it_before = it_before it_after = it_after ) = 0.
      rv_choice = 'SAME'.
    ELSE.
      rv_choice = 'CHANGED'.
    ENDIF.
  ENDMETHOD.

  METHOD added.
    DATA lv_found TYPE abap_bool.

    " A component is added once the new BOM holds one the old did not.
    LOOP AT it_after INTO DATA(ls_after).
      lv_found = abap_false.
      LOOP AT it_before INTO DATA(ls_before).
        IF ls_before-component = ls_after-component.
          lv_found = abap_true.
        ENDIF.
      ENDLOOP.
      IF lv_found = abap_false.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD removed.
    DATA lv_found TYPE abap_bool.

    " A component is removed once the old BOM held one the new does not.
    LOOP AT it_before INTO DATA(ls_before).
      lv_found = abap_false.
      LOOP AT it_after INTO DATA(ls_after).
        IF ls_after-component = ls_before-component.
          lv_found = abap_true.
        ENDIF.
      ENDLOOP.
      IF lv_found = abap_false.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
