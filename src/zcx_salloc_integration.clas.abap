CLASS zcx_salloc_integration DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    DATA operation TYPE string READ-ONLY.
    DATA reason TYPE string READ-ONLY.
    METHODS constructor
      IMPORTING
        iv_operation TYPE string
        iv_reason TYPE string.
ENDCLASS.

CLASS zcx_salloc_integration IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    operation = iv_operation.
    reason = iv_reason.
  ENDMETHOD.
ENDCLASS.
