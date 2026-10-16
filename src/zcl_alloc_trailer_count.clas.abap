CLASS zcl_alloc_trailer_count DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS trailers
      IMPORTING
        iv_pallets      TYPE i
        iv_per_trailer  TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS full_trailers
      IMPORTING
        iv_pallets      TYPE i
        iv_per_trailer  TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS last_trailer
      IMPORTING
        iv_pallets        TYPE i
        iv_per_trailer    TYPE i
      RETURNING
        VALUE(rv_pallets) TYPE i.

ENDCLASS.


CLASS zcl_alloc_trailer_count IMPLEMENTATION.

  METHOD trailers.
    IF iv_pallets <= 0 OR iv_per_trailer <= 0.
      RETURN.
    ENDIF.

    rv_count = ( iv_pallets + iv_per_trailer - 1 ) DIV iv_per_trailer.
  ENDMETHOD.

  METHOD full_trailers.
    IF iv_pallets <= 0 OR iv_per_trailer <= 0.
      RETURN.
    ENDIF.

    rv_count = iv_pallets DIV iv_per_trailer.
  ENDMETHOD.

  METHOD last_trailer.
    DATA lv_rest TYPE i.

    IF iv_pallets <= 0 OR iv_per_trailer <= 0.
      RETURN.
    ENDIF.

    lv_rest = iv_pallets MOD iv_per_trailer.
    IF lv_rest = 0.
      rv_pallets = iv_per_trailer.
    ELSE.
      rv_pallets = lv_rest.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
