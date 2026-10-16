CLASS zcl_alloc_val_report_line DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS format
      IMPORTING
        iv_material    TYPE string
        iv_value       TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS is_valuable
      IMPORTING
        iv_value     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS is_zero
      IMPORTING
        iv_value     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_val_report_line IMPLEMENTATION.

  METHOD format.
    " The report line reads the material and the value it carries.
    rv_text = |{ iv_material }: { iv_value }|.
  ENDMETHOD.

  METHOD is_valuable.
    " A line carries value once its value is positive.
    rv_ok = xsdbool( iv_value > 0 ).
  ENDMETHOD.

  METHOD is_zero.
    " A line is nil once its value is zero.
    rv_ok = xsdbool( iv_value = 0 ).
  ENDMETHOD.

ENDCLASS.
