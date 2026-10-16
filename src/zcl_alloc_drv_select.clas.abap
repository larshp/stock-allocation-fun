CLASS zcl_alloc_drv_select DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS choose
      IMPORTING
        iv_volume        TYPE i
        iv_value         TYPE i
      RETURNING
        VALUE(rv_driver) TYPE string.

    METHODS is_volume
      IMPORTING
        iv_driver    TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS reason
      IMPORTING
        iv_driver        TYPE string
      RETURNING
        VALUE(rv_reason) TYPE string.

ENDCLASS.


CLASS zcl_alloc_drv_select IMPLEMENTATION.

  METHOD choose.
    " The driver with the larger quantity is the one to allocate on.
    IF iv_volume >= iv_value AND iv_volume > 0.
      rv_driver = 'VOLUME'.
    ELSEIF iv_value > 0.
      rv_driver = 'VALUE'.
    ELSE.
      rv_driver = 'NONE'.
    ENDIF.
  ENDMETHOD.

  METHOD is_volume.
    " A volume driver is chosen on usage.
    rv_ok = xsdbool( iv_driver = 'VOLUME' ).
  ENDMETHOD.

  METHOD reason.
    " Each driver carries the reason it was chosen.
    CASE iv_driver.
      WHEN 'VOLUME'.
        rv_reason = 'usage based'.
      WHEN 'VALUE'.
        rv_reason = 'value based'.
      WHEN OTHERS.
        rv_reason = 'unassigned'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
