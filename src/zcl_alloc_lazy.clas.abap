CLASS zcl_alloc_lazy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS load
      IMPORTING
        iv_value        TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.

    METHODS get
      RETURNING
        VALUE(rv_value) TYPE string.

    METHODS is_loaded
      RETURNING
        VALUE(rv_loaded) TYPE abap_bool.

    METHODS reset.

  PRIVATE SECTION.
    DATA mv_loaded TYPE abap_bool.
    DATA mv_value  TYPE string.

ENDCLASS.


CLASS zcl_alloc_lazy IMPLEMENTATION.

  METHOD load.
    IF mv_loaded = abap_false.
      mv_value = iv_value.
      mv_loaded = abap_true.
    ENDIF.

    rv_value = mv_value.
  ENDMETHOD.

  METHOD get.
    rv_value = mv_value.
  ENDMETHOD.

  METHOD is_loaded.
    rv_loaded = mv_loaded.
  ENDMETHOD.

  METHOD reset.
    mv_loaded = abap_false.
    CLEAR mv_value.
  ENDMETHOD.

ENDCLASS.
