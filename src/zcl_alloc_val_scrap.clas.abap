CLASS zcl_alloc_val_scrap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS value
      IMPORTING
        iv_original_value TYPE i
        iv_scrap_percent  TYPE i
      RETURNING
        VALUE(rv_value)   TYPE i.

    METHODS scrap_percent
      IMPORTING
        iv_original_value TYPE i
        iv_scrap_value    TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_scrapped
      IMPORTING
        iv_scrap_percent TYPE i
      RETURNING
        VALUE(rv_ok)     TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_val_scrap IMPLEMENTATION.

  METHOD value.
    " Scrap keeps only a share of the original value.
    IF iv_scrap_percent <= 0.
      RETURN.
    ENDIF.

    IF iv_scrap_percent > 100.
      rv_value = iv_original_value.
    ELSE.
      rv_value = iv_original_value * iv_scrap_percent DIV 100.
    ENDIF.
  ENDMETHOD.

  METHOD scrap_percent.
    " The scrap share is the part of the original that is kept.
    IF iv_original_value <= 0.
      RETURN.
    ENDIF.

    rv_percent = iv_scrap_value * 100 DIV iv_original_value.
  ENDMETHOD.

  METHOD is_scrapped.
    " Anything with a scrap share is scrapped.
    rv_ok = xsdbool( iv_scrap_percent > 0 ).
  ENDMETHOD.

ENDCLASS.
