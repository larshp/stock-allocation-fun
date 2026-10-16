CLASS zcl_alloc_stdcost_revise DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS revise
      IMPORTING
        iv_current    TYPE i
        iv_percent    TYPE i
      RETURNING
        VALUE(rv_new) TYPE i.

    METHODS is_revised
      IMPORTING
        iv_current   TYPE i
        iv_new       TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS revision_count
      IMPORTING
        it_costs        TYPE ty_values_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_stdcost_revise IMPLEMENTATION.

  METHOD revise.
    DATA lv_step TYPE i.

    " The revised standard cost moves by the given percentage.
    IF iv_current = 0 OR iv_percent = 0.
      rv_new = iv_current.
      RETURN.
    ENDIF.

    lv_step = iv_current * iv_percent DIV 100.
    rv_new = iv_current + lv_step.
  ENDMETHOD.

  METHOD is_revised.
    " The standard cost is revised once the new differs from the current.
    rv_ok = xsdbool( iv_new <> iv_current ).
  ENDMETHOD.

  METHOD revision_count.
    " The revision count is the number of cost values on file.
    rv_count = lines( it_costs ).
  ENDMETHOD.

ENDCLASS.
