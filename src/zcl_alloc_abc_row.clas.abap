CLASS zcl_alloc_abc_row DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS format
      IMPORTING
        iv_activity    TYPE string
        iv_cost        TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS is_costly
      IMPORTING
        iv_cost      TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS is_zero
      IMPORTING
        iv_cost      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_abc_row IMPLEMENTATION.

  METHOD format.
    " The report row reads the activity and the cost it carries.
    rv_text = |{ iv_activity }: { iv_cost }|.
  ENDMETHOD.

  METHOD is_costly.
    " An activity is costly once its cost passes the limit.
    rv_ok = xsdbool( iv_cost > iv_limit ).
  ENDMETHOD.

  METHOD is_zero.
    " An activity is nil once its cost is zero.
    rv_ok = xsdbool( iv_cost = 0 ).
  ENDMETHOD.

ENDCLASS.
