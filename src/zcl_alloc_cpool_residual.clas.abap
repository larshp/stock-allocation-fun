CLASS zcl_alloc_cpool_residual DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS residual
      IMPORTING
        iv_pool            TYPE i
        iv_assigned        TYPE i
      RETURNING
        VALUE(rv_residual) TYPE i.

    METHODS is_cleared
      IMPORTING
        iv_residual  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS count
      IMPORTING
        it_residuals    TYPE ty_values_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cpool_residual IMPLEMENTATION.

  METHOD residual.
    " The residual is the pool cost not yet assigned out.
    IF iv_assigned >= iv_pool.
      RETURN.
    ENDIF.

    rv_residual = iv_pool - iv_assigned.
  ENDMETHOD.

  METHOD is_cleared.
    " A pool is cleared once nothing is left unassigned.
    rv_ok = xsdbool( iv_residual = 0 ).
  ENDMETHOD.

  METHOD count.
    " The count gathers the pools that still carry a residual.
    LOOP AT it_residuals INTO DATA(lv_residual).
      IF lv_residual <> 0.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
