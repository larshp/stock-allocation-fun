CLASS zcl_alloc_drv_total DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS total
      IMPORTING
        it_values       TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS count
      IMPORTING
        it_values       TYPE ty_values_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS is_empty
      IMPORTING
        it_values    TYPE ty_values_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_drv_total IMPLEMENTATION.

  METHOD total.
    " The driver total adds the quantities of every driver together.
    LOOP AT it_values INTO DATA(lv_value).
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( it_values ).
  ENDMETHOD.

  METHOD is_empty.
    " A driver set is empty once it holds no quantities.
    rv_ok = xsdbool( lines( it_values ) = 0 ).
  ENDMETHOD.

ENDCLASS.
