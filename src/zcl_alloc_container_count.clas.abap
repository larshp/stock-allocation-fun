CLASS zcl_alloc_container_count DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS needed
      IMPORTING
        iv_pieces            TYPE i
        iv_per_container     TYPE i
      RETURNING
        VALUE(rv_containers) TYPE i.

    METHODS outstanding
      IMPORTING
        iv_out         TYPE i
        iv_in          TYPE i
      RETURNING
        VALUE(rv_open) TYPE i.

ENDCLASS.


CLASS zcl_alloc_container_count IMPLEMENTATION.

  METHOD needed.
    IF iv_pieces <= 0 OR iv_per_container <= 0.
      RETURN.
    ENDIF.

    rv_containers = ( iv_pieces + iv_per_container - 1 ) DIV iv_per_container.
  ENDMETHOD.

  METHOD outstanding.
    IF iv_out <= iv_in.
      RETURN.
    ENDIF.

    rv_open = iv_out - iv_in.
  ENDMETHOD.

ENDCLASS.
