CLASS zcl_alloc_format_default DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_consumer TYPE c LENGTH 20.

    METHODS default_for
      IMPORTING
        iv_consumer      TYPE ty_consumer
      RETURNING
        VALUE(rv_format) TYPE zcl_alloc_format_registry=>ty_format.

ENDCLASS.


CLASS zcl_alloc_format_default IMPLEMENTATION.

  METHOD default_for.
    CASE iv_consumer.
      WHEN 'EMAIL'.
        rv_format = 'HTML'.
      WHEN 'API'.
        rv_format = 'JSON'.
      WHEN 'PRINT'.
        rv_format = 'FW'.
      WHEN OTHERS.
        rv_format = 'CSV'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
