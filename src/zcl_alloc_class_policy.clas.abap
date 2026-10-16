CLASS zcl_alloc_class_policy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS policy_of
      IMPORTING
        iv_abc_class     TYPE string
      RETURNING
        VALUE(rv_policy) TYPE string.

    METHODS is_strict
      IMPORTING
        iv_abc_class TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS service_of
      IMPORTING
        iv_abc_class      TYPE string
      RETURNING
        VALUE(rv_service) TYPE i.

ENDCLASS.


CLASS zcl_alloc_class_policy IMPLEMENTATION.

  METHOD policy_of.
    " The replenishment cycle shortens as the class moves to the front.
    CASE iv_abc_class.
      WHEN 'A'.
        rv_policy = 'DAILY'.
      WHEN 'B'.
        rv_policy = 'WEEKLY'.
      WHEN OTHERS.
        rv_policy = 'MONTHLY'.
    ENDCASE.
  ENDMETHOD.

  METHOD is_strict.
    " The top two classes carry the strictest control.
    rv_ok = xsdbool( iv_abc_class = 'A' OR iv_abc_class = 'B' ).
  ENDMETHOD.

  METHOD service_of.
    " The service target falls from the front class to the tail.
    CASE iv_abc_class.
      WHEN 'A'.
        rv_service = 98.
      WHEN 'B'.
        rv_service = 95.
      WHEN OTHERS.
        rv_service = 90.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
